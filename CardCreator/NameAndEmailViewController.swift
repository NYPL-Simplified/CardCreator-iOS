import UIKit

class NameAndEmailViewController: UITableViewController, UITextFieldDelegate {
  private let fullNameCell: LabelledTextViewCell
  private let emailCell: LabelledTextViewCell
  
  let cells: [UITableViewCell]
  
  init() {
    self.fullNameCell = LabelledTextViewCell(
      title: NSLocalizedString("Full Name", comment: "The text field title for the full name of a user"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    self.emailCell = LabelledTextViewCell(
      title: NSLocalizedString("Email", comment: "A text field title for a user's email address"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    
    self.cells = [
      self.fullNameCell,
      self.emailCell
    ]
    
    super.init(style: UITableViewStyle.Grouped)
    
    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: NSLocalizedString("Next", comment: "A title for a button that goes to the next screen"),
                      style: .Plain,
                      target: self,
                      action: #selector(didSelectNext))
    self.navigationItem.rightBarButtonItem?.enabled = false
    
    self.prepareTableViewCells()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
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
    self.emailCell.textField.returnKeyType = .Done
  }
  
  @objc private func advanceToNextTextField() {
    var foundFirstResponder = false
    for cell in self.cells {
      if let labelledTextViewCell = cell as? LabelledTextViewCell {
        if foundFirstResponder {
          labelledTextViewCell.textField.becomeFirstResponder()
          return
        }
        if labelledTextViewCell.textField.isFirstResponder() {
          foundFirstResponder = true
        }
      }
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.cells.count
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return self.cells[indexPath.row]
  }
  
  // MARK: UITextFieldDelegate
  
  @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.advanceToNextTextField()
    if(textField == self.emailCell.textField) {
      self.view.endEditing(false)
    }
    return true
  }
  
  // MARK: -
  
  @objc private func didSelectDone() {
    self.view.endEditing(false)
  }
  
  @objc private func didSelectNext() {
    self.view.endEditing(false)
    self.navigationController?.pushViewController(UsernameAndPINViewController(), animated: true)
  }
  
  @objc private func textFieldDidChange() {
    self.navigationItem.rightBarButtonItem?.enabled =
      (self.fullNameCell.textField.text?.characters.count > 0
        && self.emailCell.textField.text?.characters.count > 0
        && self.emailCell.textField.text!.rangeOfString("@") != nil)
  }
}
