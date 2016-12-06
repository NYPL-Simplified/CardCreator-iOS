import UIKit

final class NameAndEmailViewController: FormTableViewController {
  
  fileprivate let configuration: CardCreatorConfiguration
  
  fileprivate let cardType: CardType
  fileprivate let firstNameCell: LabelledTextViewCell
  fileprivate let middleInitialCell: LabelledTextViewCell
  fileprivate let lastNameCell: LabelledTextViewCell
  fileprivate let emailCell: LabelledTextViewCell
  fileprivate let homeAddress: Address
  fileprivate let schoolOrWorkAddress: Address?
  
  init(configuration: CardCreatorConfiguration,
       homeAddress: Address,
       schoolOrWorkAddress: Address?,
       cardType: CardType) {
    self.configuration = configuration
    self.firstNameCell = LabelledTextViewCell(
      title: NSLocalizedString("First Name", comment: "The text field title for the first name of a user"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    self.middleInitialCell = LabelledTextViewCell(
      title: NSLocalizedString("Middle Initial", comment: "The text field title for the middle initial of a user"),
      placeholder: NSLocalizedString("Optional", comment: "A placeholder for a required text field"))
    self.lastNameCell = LabelledTextViewCell(
      title: NSLocalizedString("Last Name", comment: "The text field title for the last name of a user"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    self.emailCell = LabelledTextViewCell(
      title: NSLocalizedString("Email", comment: "A text field title for a user's email address"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    
    self.homeAddress = homeAddress
    self.schoolOrWorkAddress = schoolOrWorkAddress
    self.cardType = cardType
    
    super.init(
      cells: [
        self.firstNameCell,
        self.middleInitialCell,
        self.lastNameCell,
        self.emailCell
      ])
    
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    
    self.prepareTableViewCells()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = NSLocalizedString(
      "Personal Information",
      comment: "A title for a screen asking the user for their personal information")
  }
  
  fileprivate func prepareTableViewCells() {
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
  }
  
  // MARK: -
  
  @objc override func didSelectNext() {
    self.view.endEditing(false)
    
    var fullName: String
    if self.middleInitialCell.textField.text!.isEmpty {
      fullName = self.firstNameCell.textField.text! + " " + self.lastNameCell.textField.text!
    } else {
      fullName = self.firstNameCell.textField.text! + " " + "\(self.middleInitialCell.textField.text!) " +
        self.lastNameCell.textField.text!
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
  
  fileprivate func emailIsValid() -> Bool {
    let emailRegEx = ".+@.+\\..+"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: self.emailCell.textField.text!)
  }
  
  fileprivate func namesAreValid() -> Bool {
    return !self.firstNameCell.textField.text!.isEmpty && !self.lastNameCell.textField.text!.isEmpty
  }
  
  @objc fileprivate func textFieldDidChange() {
    if (self.emailIsValid()) {
      if namesAreValid() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
      } else {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
      }
    } else {
      self.navigationItem.rightBarButtonItem?.isEnabled = false
    }
  }
}
