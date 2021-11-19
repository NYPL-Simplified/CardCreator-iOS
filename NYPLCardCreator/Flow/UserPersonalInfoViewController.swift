import UIKit

final class UserPersonalInfoViewController: FormTableViewController {
  
  private let configuration: CardCreatorConfiguration
  private let authToken: ISSOToken
  
  private let cardType: CardType
  private let firstNameCell: LabelledTextViewCell
  private let middleInitialCell: LabelledTextViewCell
  private let lastNameCell: LabelledTextViewCell
  private let emailCell: LabelledTextViewCell
  private let birthdateCell: LabelledTextViewCell
  private let homeAddress: Address
  private let schoolOrWorkAddress: Address?
  private var birthdate: Date?
  
  private let dateFormatter: DateFormatter
  private let datePicker: UIDatePicker

  convenience init(juvenileConfiguration: CardCreatorConfiguration,
                   authToken: ISSOToken)
  {
    // providing a fake home address because it will be ignored anyway for
    // juvenile flows
    self.init(configuration: juvenileConfiguration,
              authToken: authToken,
              homeAddress: Address(street1: "", street2: "", city: "", region: "", zip: "", isResidential: false, hasBeenValidated: false),
              schoolOrWorkAddress: nil,
              cardType: .juvenile)
  }

  init(configuration: CardCreatorConfiguration,
       authToken: ISSOToken,
       homeAddress: Address,
       schoolOrWorkAddress: Address?,
       cardType: CardType) {
    self.configuration = configuration
    self.authToken = authToken

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
    
    self.birthdateCell = LabelledTextViewCell(
      title: NSLocalizedString("Birthdate", comment: "A text field title for a user's birthdate"),
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
        self.emailCell,
        self.birthdateCell
      ]
    }
    
    self.datePicker = UIDatePicker()
    datePicker.minimumDate = Calendar.current.date(from: DateComponents(year: 1900, month: 1, day: 1))
    datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -13, to: Date())
    datePicker.datePickerMode = .date
    
    if #available(iOS 13.4, *) {
      datePicker.preferredDatePickerStyle = .wheels
    }
    
    self.dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MM-dd-yyyy"
    
    super.init(cells: cells)
    
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    
    datePicker.addTarget(self, action: #selector(datePickerDidChange), for: .valueChanged)
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
    
    self.birthdateCell.textField.inputView = datePicker
    self.birthdateCell.textField.inputAccessoryView = self.returnToolbar()

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
    if let birthdate = user.birthdate {
      self.birthdateCell.textField.text = dateFormatter.string(from: birthdate)
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
      user.birthdate = self.birthdate
    }
  }
  
  @objc override func didSelectNext() {
    self.view.endEditing(false)
    
    guard let firstName = firstNameCell.textField.text,
      let lastName = lastNameCell.textField.text,
      let birthdate = birthdate else {
        return
    }
    
    guard is13OrOlder(birthdate) else {
      showErrorAlert(message: NSLocalizedString(
                      "You must be 13 years of age or older to sign up for a library card.",
                      comment: "A message to inform user about the invalid birthdate"))
      return
    }

    let middleInitial = middleInitialCell.textField.text
    let fullName = configuration.fullName(forFirstName: firstName,
                                          middleInitial: middleInitial,
                                          lastName: lastName)

    self.navigationController?.pushViewController(
      UsernameAndPasswordViewController(
        configuration: self.configuration,
        authToken: authToken,
        homeAddress: self.homeAddress,
        schoolOrWorkAddress: self.schoolOrWorkAddress,
        cardType: self.cardType,
        fullName: fullName,
        email: self.emailCell.textField.text!,
        birthdate: dateFormatter.string(from: birthdate)),
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
    // Update birthdate if user enter birthdate with physical keyboard
    birthdate = dateFormatter.date(from: self.birthdateCell.textField.text ?? "")
    
    updateNextButton()
  }
  
  @objc private func datePickerDidChange() {
    birthdate = datePicker.date
    birthdateCell.textField.text = dateFormatter.string(from: datePicker.date)
    updateNextButton()
  }
  
  private func updateNextButton() {
    if (birthdate != nil || configuration.isJuvenile) &&
        namesAreValid() &&
        (emailIsValid() || configuration.isJuvenile) {
      self.navigationItem.rightBarButtonItem?.isEnabled = true
    } else {
      self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
  }
  
  // MARK: - Helper
  
  private func is13OrOlder(_ birthdate: Date) -> Bool {
    // Add 13 year to the birthdate and use timeIntervalSinceNow to determine user's age
    guard let date = Calendar.current.date(byAdding: .year, value: 13, to: birthdate) else {
      return false
    }
    
    return date.timeIntervalSinceNow <= 0
  }
}
