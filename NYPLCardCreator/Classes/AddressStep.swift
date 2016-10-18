import UIKit

/// This represents the user's progress in the registration flow.
enum AddressStep {
  /// The user is currently entering their home address.
  case Home
  /// The user is currently entering their school address (and has previously entered
  /// the given home address).
  case School(homeAddress: Address)
  /// The user is currently entering their work address (and has previously entered
  /// the given home address).
  case Work(homeAddress: Address)
  
  /// Returns the previously entered home address (if any).
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
  
  /// Given a `Configuration`, the current `UIViewController`, an `Address` that has just
  /// been validated, and the `CardType` implied by the validated address, continue with the
  /// registration flow as appropriate.
  func continueFlowWithValidAddress(
    configuration: CardCreatorConfiguration,
    viewController: UIViewController,
    address: Address,
    cardType: CardType)
  {
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
          preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(
          title: NSLocalizedString("I Work in New York", comment: ""),
          style: .Default,
          handler: {_ in
            viewController.navigationController?.pushViewController(
              AddressViewController(configuration: configuration, addressStep: .Work(homeAddress: address)),
              animated: true)
        }))
        alertController.addAction(UIAlertAction(
          title: NSLocalizedString("I Attend School in New York", comment: ""),
          style: .Default,
          handler: {_ in
            viewController.navigationController?.pushViewController(
              AddressViewController(configuration: configuration, addressStep: .School(homeAddress: address)),
              animated: true)
        }))
        alertController.addAction(UIAlertAction(
          title: NSLocalizedString("Edit Home Address", comment: ""),
          style: .Cancel,
          handler: {_ in
          viewController.navigationController?.popViewControllerAnimated(true)
        }))
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
      let (homeAddress, schoolOrWorkAddress) = self.pairWithAppendedAddress(address)
      let nameAndEmailViewController = NameAndEmailViewController(
        configuration: configuration,
        homeAddress: homeAddress,
        schoolOrWorkAddress: schoolOrWorkAddress)
      viewController.navigationController?.pushViewController(nameAndEmailViewController, animated: true)
//GODO may need to come back and use the copy at the end summary screen
//      let alertController = UIAlertController(
//        title: NSLocalizedString(
//          "30-Day Card",
//          comment: "An alert title telling the user they've received a temporary card"),
//        message: NSLocalizedString(
//          ("We were not able to verify your address, so we have issued you a temporary card. Please visit your local "
//            + "NYPL branch within 30 days to receive a standard card."),
//          comment: "An alert message telling the user she'll get a 30-day library card"),
//        preferredStyle: .Alert)
//      alertController.addAction(UIAlertAction(
//        title: NSLocalizedString("OK", comment: ""),
//        style: .Default,
//        handler: {_ in
//          let (homeAddress, schoolOrWorkAddress) = self.pairWithAppendedAddress(address)
//          let nameAndEmailViewController = NameAndEmailViewController(
//            configuration: configuration,
//            homeAddress: homeAddress,
//            schoolOrWorkAddress: schoolOrWorkAddress)
//          viewController.navigationController?.pushViewController(nameAndEmailViewController, animated: true)
//      }))
//      viewController.presentViewController(alertController, animated: true, completion: nil)
    case .Standard:
      let (homeAddress, schoolOrWorkAddress) = self.pairWithAppendedAddress(address)
      let nameAndEmailViewController = NameAndEmailViewController(
        configuration: configuration,
        homeAddress: homeAddress,
        schoolOrWorkAddress: schoolOrWorkAddress)
      viewController.navigationController?.pushViewController(nameAndEmailViewController, animated: true)
//      let alertController = UIAlertController(
//        title: NSLocalizedString(
//          "Standard Card",
//          comment: "An alert title telling the user they've received a standard card"),
//        message: NSLocalizedString(
//          "Your address qualifies you for a standard three-year ebook-only library card.",
//          comment: "An alert message telling the user she'll get a three-year library card"),
//        preferredStyle: .Alert)
//      alertController.addAction(UIAlertAction(
//        title: NSLocalizedString("OK", comment: ""),
//        style: .Default,
//        handler: {_ in
//          let (homeAddress, schoolOrWorkAddress) = self.pairWithAppendedAddress(address)
//          let nameAndEmailViewController = NameAndEmailViewController(
//            configuration: configuration,
//            homeAddress: homeAddress,
//            schoolOrWorkAddress: schoolOrWorkAddress)
//          viewController.navigationController?.pushViewController(nameAndEmailViewController, animated: true)
//      }))
//      viewController.presentViewController(alertController, animated: true, completion: nil)
    }
  }
}