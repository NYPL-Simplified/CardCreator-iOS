import UIKit

enum AddressStep {
  case Home
  case School(homeAddress: Address)
  case Work(homeAddress: Address)
  
  var homeAddress: Address? {
    get {
      switch self {
      case .Home:
        return nil
      case let .School(homeAddress):
        return homeAddress
      case let .Work(homeAddress):
        return homeAddress
      }
    }
  }
  
  private func pairWithAppendedAddress(address: Address) -> (Address, Address?) {
    if let homeAddress = self.homeAddress {
      return (homeAddress, address)
    } else {
      return (address, nil)
    }
  }
  
  func continueFlowWithValidAddress(viewController: UIViewController, address: Address, cardType: CardType) {
    switch cardType {
    case .None:
      switch self {
      case .Home:
        let alertController = UIAlertController(
          title: NSLocalizedString("Out-of-State Address", comment: ""),
          message: NSLocalizedString(
            ("Since you do not live in New York, you must work or attend school in New York to qualify for a "
              + "library card."),
            comment: "A message informing the user what they must assert given that they live outside NY"),
          preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(
          title: NSLocalizedString("I Work in New York", comment: ""),
          style: .Default,
          handler: {_ in
            viewController.navigationController?.pushViewController(
              AddressViewController(addressStep: .Work(homeAddress: address)),
              animated: true)
        }))
        alertController.addAction(UIAlertAction(
          title: NSLocalizedString("I Attend School in New York", comment: ""),
          style: .Default,
          handler: {_ in
            viewController.navigationController?.pushViewController(
              AddressViewController(addressStep: .School(homeAddress: address)),
              animated: true)
        }))
        alertController.addAction(UIAlertAction(
          title: NSLocalizedString("Edit Home Address", comment: ""),
          style: .Cancel,
          handler: nil))
        viewController.presentViewController(alertController, animated: true, completion: nil)
      case .School:
        let alertController = UIAlertController(
          title: NSLocalizedString(
            "Card Denied",
            comment: "An alert title telling the user they cannot receive a library card"),
          message: NSLocalizedString(
            "You cannot receive a library card because your school address does not appear to be in New York.",
            comment: "An alert title telling the user they cannot receive a library card"),
          preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(
          title: NSLocalizedString("OK", comment: ""),
          style: .Default,
          handler: nil))
        viewController.presentViewController(alertController, animated: true, completion: nil)
      case .Work:
        let alertController = UIAlertController(
          title: NSLocalizedString(
            "Card Denied",
            comment: "An alert title telling the user they cannot receive a library card"),
          message: NSLocalizedString(
            "You cannot receive a library card because your work address does not appear to be in New York.",
            comment: "An alert title telling the user they cannot receive a library card"),
          preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(
          title: NSLocalizedString("OK", comment: ""),
          style: .Default,
          handler: nil))
        viewController.presentViewController(alertController, animated: true, completion: nil)
      }
    case .Temporary:
      let alertController = UIAlertController(
        title: NSLocalizedString("Temporary Card", comment: ""),
        message: NSLocalizedString(
          ("Your address qualifies you for a temporary 30-day library card. You will need to visit your local "
            + "NYPL branch within 30 days to receive a standard card."),
          comment: "An alert message telling the user she'll get a 30-day library card"),
        preferredStyle: .Alert)
      alertController.addAction(UIAlertAction(
        title: NSLocalizedString("OK", comment: ""),
        style: .Default,
        handler: {_ in
          let (homeAddress, schoolOrWorkAddress) = self.pairWithAppendedAddress(address)
          let nameAndEmailViewController = NameAndEmailViewController(
            homeAddress: homeAddress,
            schoolOrWorkAddress: schoolOrWorkAddress)
          viewController.navigationController?.pushViewController(nameAndEmailViewController, animated: true)
      }))
      viewController.presentViewController(alertController, animated: true, completion: nil)
    case .Standard:
      let alertController = UIAlertController(
        title: NSLocalizedString("Standard Card", comment: ""),
        message: NSLocalizedString(
          "Congratulations! Your address qualifies you for a standard three-year library card.",
          comment: "An alert message telling the user she'll get a three-year library card"),
        preferredStyle: .Alert)
      alertController.addAction(UIAlertAction(
        title: NSLocalizedString("OK", comment: ""),
        style: .Default,
        handler: {_ in
          let (homeAddress, schoolOrWorkAddress) = self.pairWithAppendedAddress(address)
          let nameAndEmailViewController = NameAndEmailViewController(
            homeAddress: homeAddress,
            schoolOrWorkAddress: schoolOrWorkAddress)
          viewController.navigationController?.pushViewController(nameAndEmailViewController, animated: true)
      }))
      viewController.presentViewController(alertController, animated: true, completion: nil)
    }
  }
}