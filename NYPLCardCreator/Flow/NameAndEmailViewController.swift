import UIKit

final class NameAndEmailViewController: FormTableViewController {
  
  private let configuration: CardCreatorConfiguration
  
  private let cardType: CardType
  private let firstNameCell: LabelledTextViewCell
  private let middleInitialCell: LabelledTextViewCell
  private let lastNameCell: LabelledTextViewCell
  private let emailCell: LabelledTextViewCell
  private let homeAddress: Address
  private let schoolOrWorkAddress: Address?

  convenience init(juvenileConfiguration: CardCreatorConfiguration) {
    // providing a fake home address because it will be ignored anyway for
    // juvenile flows
    self.init(configuration: juvenileConfiguration,
              homeAddress: Address(street1: "", street2: "", city: "", region: "", zip: ""),
              schoolOrWorkAddress: nil,
              cardType: .juvenile)
  }

  init(configuration: CardCreatorConfiguration,
       homeAddress: Address,
       schoolOrWorkAddress: Address?,
       cardType: CardType) {
    self.configuration = configuration

    let requiredPlaceholder = NSLocalizedString("Required", comment: "A placeholder for a required text field")
    let optionalPlaceholder = NSLocalizedString("Optional", comment: "A placeholder for a required text field")

    self.firstNameCell = LabelledTextViewCell(
      title: NSLocalizedString("First Name", comment: "The text field title for the first name of a user"),
      placeholder: requiredPlaceholder)

    self.middleInitialCell = LabelledTextViewCell(
      title: NSLocalizedString("Middle", comment: "The text field title for the middle name of a user"),
      placeholder: optionalPlaceholder)

    self.lastNameCell = LabelledTextViewCell(
      title: NSLocalizedString("Last Name", comment: "The text field title for the last name of a user"),
      placeholder: (configuration.isJuvenile ? optionalPlaceholder : requiredPlaceholder))

    self.emailCell = LabelledTextViewCell(
      title: NSLocalizedString("Email", comment: "A text field title for a user's email address"),
      placeholder: requiredPlaceholder)
    
    self.homeAddress = homeAddress
    self.schoolOrWorkAddress = schoolOrWorkAddress
    self.cardType = cardType

    let cells: [LabelledTextViewCell]
    if configuration.isJuvenile {
      cells = [
        self.firstNameCell,
        self.lastNameCell,
      ]
    } else {
      cells = [
        self.firstNameCell,
        self.middleInitialCell,
        self.lastNameCell,
        self.emailCell
      ]
    }
    super.init(cells: cells)
    
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    
    self.prepareTableViewCells()
    self.checkToPrefillForm()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = configuration.localizedStrings.nameScreenTitle
  }
  
  private func prepareTableViewCells() {
    for cell in self.cells {
      if let labelledTextViewCell = cell as? LabelledTextViewCell {
        labelledTextViewCell.selectionStyle = .none
        labelledTextViewCell.textField.delegate = self
        labelledTextViewCell.textField.addTarget(self,
                                                 action: #selector(textFieldDidChange),
                                                 for: .editingChanged)
      }
    }
    
    self.firstNameCell.textField.keyboardType = .alphabet
    self.firstNameCell.textField.autocapitalizationType = .words
    self.middleInitialCell.textField.keyboardType = .alphabet
    self.middleInitialCell.textField.autocapitalizationType = .words
    self.lastNameCell.textField.keyboardType = .alphabet
    self.lastNameCell.textField.autocapitalizationType = .words
    
    self.emailCell.textField.keyboardType = .emailAddress
    self.emailCell.textField.autocapitalizationType = .none
    self.emailCell.textField.autocorrectionType = .no

    if #available(iOS 10.0, *) {
      self.firstNameCell.textField.textContentType     = .givenName
      self.middleInitialCell.textField.textContentType = .middleName
      self.lastNameCell.textField.textContentType      = .familyName
      self.emailCell.textField.textContentType         = .emailAddress
    }
  }
  
  func checkToPrefillForm() {
    let user = self.configuration.user
    if let firstName = user.firstName {
      self.firstNameCell.textField.text = firstName
      self.middleInitialCell.textField.text = user.middleName
      self.lastNameCell.textField.text = user.lastName
      self.emailCell.textField.text = user.email
      textFieldDidChange()
    }
  }
  
  // MARK: -
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if isMovingFromParent {
      let user = self.configuration.user
      user.firstName = self.firstNameCell.textField.text
      user.middleName = self.middleInitialCell.textField.text
      user.lastName = self.lastNameCell.textField.text
      user.email = self.emailCell.textField.text
    }
  }
  
  @objc override func didSelectNext() {
    self.view.endEditing(false)

    guard let firstName = firstNameCell.textField.text,
      let middleInitial = middleInitialCell.textField.text,
      let lastName = lastNameCell.textField.text else {
        return
    }

    var fullName: String
    if configuration.isJuvenile && lastName.isEmpty {
      fullName = firstName
    } else if middleInitial.isEmpty {
      fullName = lastName + ", " + firstName
    } else {
      fullName = lastName + ", " + firstName + " " + middleInitial
    }
    
    self.navigationController?.pushViewController(
      UsernameAndPINViewController(
        configuration: self.configuration,
        homeAddress: self.homeAddress,
        schoolOrWorkAddress: self.schoolOrWorkAddress,
        cardType: self.cardType,
        fullName: fullName,
        email: self.emailCell.textField.text!),
      animated: true)
  }
  
  private func emailIsValid() -> Bool {
    let emailRegEx = ".+@.+\\..+"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: self.emailCell.textField.text!)
  }
  
  private func namesAreValid() -> Bool {
    if configuration.isJuvenile {
      return !self.firstNameCell.textField.text!.isEmpty
    } else {
      return !self.firstNameCell.textField.text!.isEmpty && !self.lastNameCell.textField.text!.isEmpty
    }
  }
  
  @objc private func textFieldDidChange() {
    if namesAreValid() && (emailIsValid() || configuration.isJuvenile) {
      self.navigationItem.rightBarButtonItem?.isEnabled = true
    } else {
      self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
  }
}
