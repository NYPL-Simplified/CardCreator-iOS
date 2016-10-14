import UIKit

final class NameAndEmailViewController: FormTableViewController {
  
  private let configuration: CardCreatorConfiguration
  
  private let fullNameCell: LabelledTextViewCell
  private let emailCell: LabelledTextViewCell
  private let homeAddress: Address
  private let schoolOrWorkAddress: Address?
  
  init(configuration: CardCreatorConfiguration, homeAddress: Address, schoolOrWorkAddress: Address?) {
    self.configuration = configuration
    self.fullNameCell = LabelledTextViewCell(
      title: NSLocalizedString("Full Name", comment: "The text field title for the full name of a user"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    self.emailCell = LabelledTextViewCell(
      title: NSLocalizedString("Email", comment: "A text field title for a user's email address"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    
    self.homeAddress = homeAddress
    self.schoolOrWorkAddress = schoolOrWorkAddress
    
    super.init(
      cells: [
        self.fullNameCell,
        self.emailCell
      ])
    
    self.navigationItem.rightBarButtonItem?.enabled = false
    
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
  
  private func prepareTableViewCells() {
    for cell in self.cells {
      if let labelledTextViewCell = cell as? LabelledTextViewCell {
        labelledTextViewCell.selectionStyle = .None
        labelledTextViewCell.textField.delegate = self
        labelledTextViewCell.textField.addTarget(self,
                                                 action: #selector(textFieldDidChange),
                                                 forControlEvents: .EditingChanged)
      }
    }
    
    self.fullNameCell.textField.keyboardType = .Alphabet
    self.fullNameCell.textField.autocapitalizationType = .Words
    
    self.emailCell.textField.keyboardType = .EmailAddress
    self.emailCell.textField.autocapitalizationType = .None
    self.emailCell.textField.autocorrectionType = .No
  }
  
  // MARK: UITextFieldDelegate
  
//  @objc func textField(textField: UITextField,
//                       shouldChangeCharactersInRange range: NSRange,
//                                                     replacementString string: String) -> Bool
//  {
//    
//    if textField == self.emailCell.textField {
//      if let text = textField.text {
//        return self.isPossibleStartOfValidZIPCode(
//          (text as NSString).stringByReplacingCharactersInRange(range, withString: string))
//      } else {
//        return self.isPossibleStartOfValidZIPCode(string)
//      }
//    }
//    
//    return true
//  }
  
  // MARK: -
  
  @objc override func didSelectNext() {
    self.view.endEditing(false)
    self.navigationController?.pushViewController(
      UsernameAndPINViewController(
        configuration: self.configuration,
        homeAddress: self.homeAddress,
        schoolOrWorkAddress: self.schoolOrWorkAddress,
        fullName: self.fullNameCell.textField.text!,
        email: self.emailCell.textField.text!),
      animated: true)
  }
  
  private func emailIsValid() -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluateWithObject(self.emailCell.textField.text!)
  }
  
  
  @objc private func textFieldDidChange() {
    if (self.emailIsValid()) {
        //Color-coding email can be reintroduced if required
        //self.emailCell.textField.textColor = UIColor.greenColor()
      self.navigationItem.rightBarButtonItem?.enabled =
        self.fullNameCell.textField.text?.characters.count > 0
    } else {
      if (self.emailCell.textField.isFirstResponder()) {
        //self.emailCell.textField.textColor = UIColor.redColor()
      }
      self.navigationItem.rightBarButtonItem?.enabled = false
    }
  }
}
