import PureLayout
import UIKit

class CardCreatorViewController: UITableViewController, UITextFieldDelegate
{
  private let fullNameCell: LabelledTextViewCell
  private let emailCell: LabelledTextViewCell
  private let usernameCell: LabelledTextViewCell
  private let pinCell: LabelledTextViewCell
  private let street1Cell: LabelledTextViewCell
  private let street2Cell: LabelledTextViewCell
  private let cityCell: LabelledTextViewCell
  private let stateCell: LabelledTextViewCell
  private let zipCell: LabelledTextViewCell
  private let submitCell: UITableViewCell
  
  typealias HeaderTitle = String
  private let tableViewData: [(HeaderTitle?, [UITableViewCell])]
  private let orderedTableViewCells: [UITableViewCell]
  
  private let statePickerView = UIPickerView()
  private let statePickerViewDataSourceAndDelegate: StatePickerViewDataSourceAndDelegate
  
  init() {
    self.fullNameCell = LabelledTextViewCell(
      title: NSLocalizedString("Full Name", comment: "The full name (typically first and last) of a user"),
      placeholder: NSLocalizedString("Jane Doe", comment: "An example of a common name"))
    self.emailCell = LabelledTextViewCell(
      title: NSLocalizedString("Email", comment: "A short name for a user's email address"),
      placeholder: NSLocalizedString("jane@example.com", comment: "An example of a typical email address"))
    self.usernameCell = LabelledTextViewCell(
      title: NSLocalizedString("Username", comment: "A username used to log into a service"),
      placeholder: NSLocalizedString("janedoe123", comment: "An example of a possible username"))
    self.pinCell = LabelledTextViewCell(
      title: NSLocalizedString("PIN", comment: "An abbreviation for personal identification number"),
      placeholder: "0987")
    self.street1Cell = LabelledTextViewCell(
      title: NSLocalizedString("Street 1", comment: "The first line of a US street address"),
      placeholder: "123 Main St")
    self.street2Cell = LabelledTextViewCell(
      title: NSLocalizedString("Street 2", comment: "The second line of a US street address"),
      placeholder: "Apt 2B")
    self.cityCell = LabelledTextViewCell(
      title: NSLocalizedString("City", comment: "The city portion of a US postal address"),
      placeholder: "Springfield")
    self.stateCell = LabelledTextViewCell(
      title: NSLocalizedString("State", comment: "The name for one of the 50 states in the US"),
      placeholder: NSLocalizedString("Select a state…", comment: "An instruction to select a state with ellipsis"))
    self.zipCell = LabelledTextViewCell(
      title: NSLocalizedString("ZIP", comment: "The common name for a US ZIP code"),
      placeholder: "20540")
    self.submitCell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    
    self.tableViewData = [
      (NSLocalizedString("Name & Email", comment: "The user's name and email address"),
        [self.fullNameCell, self.emailCell]),
      (NSLocalizedString("Username & PIN", comment: "The user's username and PIN"),
        [self.usernameCell, self.pinCell]),
      (NSLocalizedString("Address", comment: "The user's full address"),
        [self.street1Cell, self.street2Cell, self.cityCell, self.stateCell, self.zipCell]),
      (nil,
        [self.submitCell])
    ]
    
    self.orderedTableViewCells = self.tableViewData.flatMap {(_, tableViewCells) in tableViewCells}
    
    self.statePickerViewDataSourceAndDelegate =
      StatePickerViewDataSourceAndDelegate(textField: self.stateCell.textField)
    
    super.init(style: UITableViewStyle.Grouped)
    
    self.statePickerView.dataSource = self.statePickerViewDataSourceAndDelegate
    self.statePickerView.delegate = self.statePickerViewDataSourceAndDelegate
    
    self.prepareTableViewCells()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func nextToolbar() -> UIToolbar {
    let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    let nextBarButtonItem = UIBarButtonItem(title: "Next",
                                            style: .Plain,
                                            target: self,
                                            action: #selector(advanceToNextTextField))
    
    let toolbar = UIToolbar()
    toolbar.setItems([flexibleSpaceBarButtonItem, nextBarButtonItem], animated: false)
    toolbar.sizeToFit()
    
    return toolbar
  }
  
  private func doneToolbar() -> UIToolbar {
    let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done,
                                            target: self,
                                            action: #selector(didSelectDone))
    
    let toolbar = UIToolbar()
    toolbar.setItems([flexibleSpaceBarButtonItem, doneBarButtonItem], animated: false)
    toolbar.sizeToFit()
    
    return toolbar
  }
  
  private func prepareTableViewCells() {
    for cell in self.orderedTableViewCells {
      if let labelledTextViewCell = cell as? LabelledTextViewCell {
        labelledTextViewCell.textField.delegate = self
        labelledTextViewCell.textField.returnKeyType = .Next
      }
    }
    
    self.fullNameCell.textField.keyboardType = .Alphabet
    self.fullNameCell.textField.autocapitalizationType = .Words
      
    self.emailCell.textField.keyboardType = .EmailAddress
    self.emailCell.textField.autocapitalizationType = .None
    self.emailCell.textField.autocorrectionType = .No
    
    self.usernameCell.textField.keyboardType = .Alphabet
    self.usernameCell.textField.autocapitalizationType = .None
    self.usernameCell.textField.autocorrectionType = .No
    
    self.pinCell.textField.keyboardType = .NumberPad
    self.pinCell.textField.inputAccessoryView = self.nextToolbar()
    
    self.street1Cell.textField.keyboardType = .Alphabet
    self.street1Cell.textField.autocapitalizationType = .Words
    
    self.street2Cell.textField.keyboardType = .Alphabet
    self.street2Cell.textField.autocapitalizationType = .Words
    
    self.cityCell.textField.keyboardType = .Alphabet
    self.cityCell.textField.autocapitalizationType = .Words
    
    self.stateCell.textField.inputView = self.statePickerView
    self.stateCell.textField.inputAccessoryView = self.nextToolbar()
    
    self.zipCell.textField.keyboardType = .NumberPad
    self.zipCell.textField.inputAccessoryView = self.doneToolbar()
    
    do {
      let button = UIButton(type: .System)
      self.submitCell.addSubview(button)
      button.setTitle("Submit", forState: .Normal)
      button.autoCenterInSuperview()
      button.addTarget(self, action: #selector(didSelectSubmit), forControlEvents: .TouchUpInside)
      button.userInteractionEnabled = false
    }
  }
  
  @objc private func advanceToNextTextField() {
    var foundFirstResponder = false
    for cell in self.orderedTableViewCells {
      if let labelledTextViewCell = cell as? LabelledTextViewCell {
        if foundFirstResponder {
          labelledTextViewCell.textField.becomeFirstResponder()
          return
        }
        if labelledTextViewCell.textField.isFirstResponder() {
          labelledTextViewCell.textField.resignFirstResponder()
          foundFirstResponder = true
        }
      }
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let (_, tableViewCells) = self.tableViewData[section]
    return tableViewCells.count
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.tableViewData.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let (_, tableViewCells) = self.tableViewData[indexPath.section]
    return tableViewCells[indexPath.row]
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let (headerTitle, _) = self.tableViewData[section]
    return headerTitle
  }
  
  // MARK: UITextFieldDelegate
  
  @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.advanceToNextTextField()
    return true
  }
  
  @objc func textField(textField: UITextField,
                       shouldChangeCharactersInRange range: NSRange,
                                                     replacementString string: String) -> Bool
  {
    return textField != self.stateCell.textField
  }
  
  // Mark: UITableViewDelegate
  
  @objc override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    let (_, tableViewCells) = self.tableViewData[indexPath.section]
    return tableViewCells[indexPath.row] == self.submitCell
  }
  
  @objc override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let (_, tableViewCells) = self.tableViewData[indexPath.section]
    if tableViewCells[indexPath.row] == self.submitCell {
      didSelectSubmit()
    }
  }
  
  // MARK: -
  
  func didSelectDone() {
    self.view.endEditing(false)
  }
  
  func didSelectSubmit() {
    
  }
  
  private class StatePickerViewDataSourceAndDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let textField: UITextField
    
    init(textField: UITextField) {
      self.textField = textField
    }
    
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
      self.textField.text = "New York"
    }
  }
}

