import PureLayout
import UIKit

class CardCreatorViewController: UITableViewController, UITextFieldDelegate
{
  private enum Section {
    case NameAndEmail
    case UsernameAndPIN
    case Address
  }
  
  private let labelledTextViewCellReuseIdentifier = "LabelledTextViewCell"
  private let labelledStatePickerCellReuseIdentifier = "LabelledStatePickerCell"
  
  private let statePickerView = UIPickerView()
  private let statePickerViewDataSourceAndDelegate = StatePickerViewDataSourceAndDelegate()
  private let toolbarStateTextFieldInputAccessoryView = UIToolbar()
  private let zipTextFieldInputAccessoryView = UIToolbar()
  
  init() {
    super.init(style: UITableViewStyle.Grouped)
    
    self.tableView.registerClass(LabelledTextViewCell.self,
                                 forCellReuseIdentifier: labelledTextViewCellReuseIdentifier)
    
    self.statePickerView.dataSource = self.statePickerViewDataSourceAndDelegate
    self.statePickerView.delegate = self.statePickerViewDataSourceAndDelegate
    
    do {
      let nextBarButtonItem = UIBarButtonItem(title: "Next",
        style: .Plain,
        target: self,
        action: #selector(didSelectNextAfterState))
      let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
      let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done,
        target: self,
        action: #selector(didSelectDone))
      self.toolbarStateTextFieldInputAccessoryView.setItems(
        [nextBarButtonItem, flexibleSpaceBarButtonItem, doneBarButtonItem],
        animated: false)
      self.toolbarStateTextFieldInputAccessoryView.sizeToFit()
    }
    
    do {
      let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done,
                                               target: self,
                                               action: #selector(didSelectDone))
      let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
      self.zipTextFieldInputAccessoryView.setItems([flexibleSpaceBarButtonItem, doneBarButtonItem], animated: false)
      self.zipTextFieldInputAccessoryView.sizeToFit()
    }
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 2
    case 1:
      return 2
    case 2:
      return 5
    case 3:
      return 1
    default:
      fatalError()
    }
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 4
  }
  
  private func dequeueLabelledTextViewCell(title: String, _ placeholder: String?) -> LabelledTextViewCell {
    let cell = self.tableView.dequeueReusableCellWithIdentifier(labelledTextViewCellReuseIdentifier)
      as! LabelledTextViewCell
    cell.label.text = title
    cell.textField.delegate = self
    cell.textField.placeholder = placeholder
    cell.textField.inputView = nil
    cell.textField.inputAccessoryView = nil
    return cell
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch (indexPath.section, indexPath.row) {
    case (0, 0):
      let cell = dequeueLabelledTextViewCell("Full Name", "Jane Doe")
      cell.textField.tag = 0
      cell.textField.keyboardType = .Alphabet
      cell.textField.autocapitalizationType = .Words
      cell.textField.returnKeyType = .Next
      return cell
    case (0, 1):
      let cell = dequeueLabelledTextViewCell("Email", "jane@example.com")
      cell.textField.tag = 1
      cell.textField.keyboardType = .EmailAddress
      cell.textField.autocapitalizationType = .None
      cell.textField.autocorrectionType = .No
      cell.textField.returnKeyType = .Next
      return cell
    case (1, 0):
      let cell = dequeueLabelledTextViewCell("Username", "janedoe123")
      cell.textField.tag = 2
      cell.textField.keyboardType = .Alphabet
      cell.textField.autocapitalizationType = .None
      cell.textField.autocorrectionType = .No
      cell.textField.returnKeyType = .Next
      return cell
    case (1, 1):
      let cell = dequeueLabelledTextViewCell("PIN", "Required (e.g. 0987)")
      cell.textField.tag = 3
      cell.textField.keyboardType = .NumberPad
      return cell
    case (2, 0):
      let cell = dequeueLabelledTextViewCell("Street 1", "123 Main St")
      cell.textField.tag = 4
      cell.textField.keyboardType = .Alphabet
      cell.textField.autocapitalizationType = .Words
      cell.textField.returnKeyType = .Next
      return cell
    case (2, 1):
      let cell = dequeueLabelledTextViewCell("Street 2", "Apt 2B")
      cell.textField.tag = 5
      cell.textField.keyboardType = .Alphabet
      cell.textField.autocapitalizationType = .Words
      cell.textField.returnKeyType = .Next
      return cell
    case (2, 2):
      let cell = dequeueLabelledTextViewCell("City", "Springfield")
      cell.textField.tag = 6
      cell.textField.keyboardType = .Alphabet
      cell.textField.autocapitalizationType = .Words
      cell.textField.returnKeyType = .Next
      return cell
    case (2, 3):
      let cell = dequeueLabelledTextViewCell("State", "Select a state…")
      cell.textField.tag = 7
      cell.textField.inputView = self.statePickerView
      cell.textField.inputAccessoryView = self.toolbarStateTextFieldInputAccessoryView
      self.statePickerViewDataSourceAndDelegate.textField = cell.textField
      return cell
    case (2, 4):
      let cell = dequeueLabelledTextViewCell("ZIP", "20540")
      cell.textField.tag = 8
      cell.textField.keyboardType = .NumberPad
      cell.textField.inputAccessoryView = zipTextFieldInputAccessoryView
      return cell
    case (3, 0):
      let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
      let button = UIButton(type: .System)
      cell.addSubview(button)
      button.setTitle("Submit", forState: .Normal)
      button.autoCenterInSuperview()
      button.addTarget(self, action: #selector(didSelectSubmit), forControlEvents: .TouchUpInside)
      button.userInteractionEnabled = false
      return cell
    default:
      fatalError()
    }
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Name & Email"
    case 1:
      return "Username & PIN"
    case 2:
      return "Address"
    case 3:
      return nil
    default:
      fatalError()
    }
  }
  
  
  // MARK: UITextFieldDelegate
  
  @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField.tag < 8 {
      self.tableView.viewWithTag(textField.tag + 1)?.becomeFirstResponder()
    }
    
    return true
  }
  
  @objc func textField(textField: UITextField,
                       shouldChangeCharactersInRange range: NSRange,
                                                     replacementString string: String) -> Bool
  {
    return textField.tag != 7
  }
  
  // Mark: UITableViewDelegate
  
  @objc override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return indexPath == NSIndexPath(forRow: 0, inSection: 3)
  }
  
  @objc override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if indexPath == NSIndexPath(forRow: 0, inSection: 3) {
      didSelectSubmit()
    }
  }
  
  // MARK: -
  
  func didSelectNextAfterState() {
    self.tableView.viewWithTag(8)?.becomeFirstResponder()
  }
  
  func didSelectDone() {
    self.view.endEditing(false)
  }
  
  func didSelectSubmit() {
    
  }
  
  private class StatePickerViewDataSourceAndDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    weak var textField: UITextField?
    
    @objc func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
      return 1
    }
    
    @objc func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return 50
    }
    
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return "New York"
    }
    
    @objc func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      self.textField?.text = "New York"
    }
  }
}

