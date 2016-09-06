import UIKit

class UsernameAndPINViewController: UITableViewController, UITextFieldDelegate {
  private let usernameCell: LabelledTextViewCell
  private let pinCell: LabelledTextViewCell
  
  let cells: [UITableViewCell]
  
  init() {
    self.usernameCell = LabelledTextViewCell(
      title: NSLocalizedString("Username", comment: "A username used to log into a service"),
      placeholder: NSLocalizedString("janedoe123", comment: "An example of a possible username"))
    self.pinCell = LabelledTextViewCell(
      title: NSLocalizedString("PIN", comment: "An abbreviation for personal identification number"),
      placeholder: "0987")
    
    self.cells = [
      self.usernameCell,
      self.pinCell
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
      "Username & PIN",
      comment: "A title for a screen asking the user for the user's username and PIN")
  }
  
  private func returnToolbar() -> UIToolbar {
    let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    let nextBarButtonItem = UIBarButtonItem(
      title: NSLocalizedString("Return", comment: "The title of the button that goes to the next line in a form"),
      style: .Plain,
      target: self,
      action: #selector(advanceToNextTextField))
    
    let toolbar = UIToolbar()
    toolbar.setItems([flexibleSpaceBarButtonItem, nextBarButtonItem], animated: false)
    toolbar.sizeToFit()
    
    return toolbar
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
    
    self.usernameCell.textField.keyboardType = .Alphabet
    self.usernameCell.textField.autocapitalizationType = .None
    self.usernameCell.textField.autocorrectionType = .No
    
    self.pinCell.textField.keyboardType = .NumberPad
    self.pinCell.textField.inputAccessoryView = self.returnToolbar()
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
  
  override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return NSLocalizedString("Usernames must be 5–25 letters and numbers only. PINs must be four digits.",
                             comment: "A description of valid usernames and PINs")
}
  
  // MARK: UITextFieldDelegate
  
  @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.advanceToNextTextField()
    if(textField == self.pinCell.textField) {
      self.view.endEditing(false)
    }
    return true
  }
  
  @objc func textField(textField: UITextField,
                       shouldChangeCharactersInRange range: NSRange,
                                                     replacementString string: String) -> Bool
  {
    if textField == self.usernameCell.textField {
      if let _ = string.rangeOfCharacterFromSet(NSCharacterSet.alphanumericCharacterSet().invertedSet) {
        return false
      } else if let text = textField.text {
        return text.characters.count - range.length + string.characters.count <= 25
      } else {
        return string.characters.count <= 25
      }
    }
    
    if textField == self.pinCell.textField {
      if let _ = string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) {
        return false
      } else if let text = textField.text {
        return text.characters.count - range.length + string.characters.count <= 4
      } else {
        return string.characters.count <= 4
      }
    }
    
    fatalError()
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
      (self.usernameCell.textField.text?.characters.count >= 5
        && self.pinCell.textField.text?.characters.count == 4)
  }
}
