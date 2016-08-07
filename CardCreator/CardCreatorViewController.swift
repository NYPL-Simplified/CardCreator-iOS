import PureLayout
import UIKit

class CardCreatorViewController: UITableViewController, UITextFieldDelegate
{
  private static let regions: [String] = {
    let stream = NSInputStream.init(URL: NSBundle.mainBundle().URLForResource("regions", withExtension: "json")!)!
    stream.open()
    defer {
      stream.close()
    }
    return try! NSJSONSerialization.JSONObjectWithStream(stream, options: [.AllowFragments]) as! [String]
  }()
  
  private let fullNameCell: LabelledTextViewCell
  private let emailCell: LabelledTextViewCell
  private let usernameCell: LabelledTextViewCell
  private let pinCell: LabelledTextViewCell
  private let street1Cell: LabelledTextViewCell
  private let street2Cell: LabelledTextViewCell
  private let cityCell: LabelledTextViewCell
  private let regionCell: LabelledTextViewCell
  private let zipCell: LabelledTextViewCell
  private let submitCell: UITableViewCell
  
  private struct Section {
    let headerTitle: String?
    let cells: [UITableViewCell]
    let footerTitle: String?
  }
  
  private typealias HeaderTitle = String
  private let fullNameAndEmailSection: Section
  private let usernameAndPinSection: Section
  private let addressSection: Section
  private let submitSection: Section
  private let sections: [Section]
  private let orderedTableViewCells: [UITableViewCell]
  
  private let regionPickerView = UIPickerView()
  private let regionPickerViewDataSourceAndDelegate: RegionPickerViewDataSourceAndDelegate
  
  enum Validity {
    case Valid
    case Invalid
  }
  
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
      title: NSLocalizedString("Street 2", comment: "The second line of a US street address (optional)"),
      placeholder: "Apt 2B (Optional)")
    self.cityCell = LabelledTextViewCell(
      title: NSLocalizedString("City", comment: "The city portion of a US postal address"),
      placeholder: "Springfield")
    self.regionCell = LabelledTextViewCell(
      title: NSLocalizedString("Region", comment: "The name for one of the 50+ states and regions in the US"),
      placeholder: NSLocalizedString("Select a region…", comment: "An instruction to select a region with ellipsis"))
    self.zipCell = LabelledTextViewCell(
      title: NSLocalizedString("ZIP", comment: "The common name for a US ZIP code"),
      placeholder: "20540")
    self.submitCell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    
    self.fullNameAndEmailSection = Section(
      headerTitle: NSLocalizedString("Name & Email", comment: "The user's name and email address"),
      cells: [self.fullNameCell, self.emailCell],
      footerTitle: nil)
    self.usernameAndPinSection = Section(
      headerTitle: NSLocalizedString("Username & PIN", comment: "The user's username and PIN"),
      cells: [self.usernameCell, self.pinCell],
      footerTitle: "Usernames must be 5–25 alphanumeric characters. PINs must be four digits.")
    self.addressSection = Section(
      headerTitle: NSLocalizedString("Address", comment: "The user's full address"),
      cells: [self.street1Cell, self.street2Cell, self.cityCell, self.regionCell, self.zipCell],
      footerTitle: nil)
    self.submitSection = Section(
      headerTitle: nil,
      cells: [self.submitCell],
      footerTitle: nil)
    
    self.sections = [
      self.fullNameAndEmailSection,
      self.usernameAndPinSection,
      self.addressSection,
      self.submitSection
    ]
    
    self.orderedTableViewCells = self.sections.flatMap {section in section.cells}
    
    self.regionPickerViewDataSourceAndDelegate =
      RegionPickerViewDataSourceAndDelegate(textField: self.regionCell.textField)
    
    super.init(style: UITableViewStyle.Grouped)
    
    self.regionPickerView.dataSource = self.regionPickerViewDataSourceAndDelegate
    self.regionPickerView.delegate = self.regionPickerViewDataSourceAndDelegate
    
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
    
    self.regionCell.textField.inputView = self.regionPickerView
    self.regionCell.textField.inputAccessoryView = self.nextToolbar()
    
    self.zipCell.textField.keyboardType = .NumberPad
    self.zipCell.textField.inputAccessoryView = self.doneToolbar()
    self.zipCell.textField.addTarget(self,
                                     action: #selector(zipTextFieldDidChange),
                                     forControlEvents: .AllEditingEvents)
    
    do {
      let button = UIButton(type: .System)
      self.submitCell.addSubview(button)
      button.setTitle("Submit", forState: .Normal)
      button.autoCenterInSuperview()
      button.addTarget(self, action: #selector(didSelectSubmit), forControlEvents: .TouchUpInside)
      // button.userInteractionEnabled = false
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
          foundFirstResponder = true
        }
      }
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.sections[section].cells.count
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.sections.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return self.sections[indexPath.section].cells[indexPath.row]
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return self.sections[section].headerTitle
  }
  
  override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return self.sections[section].footerTitle
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
    if textField == self.pinCell.textField {
      if let _ = string.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) {
        return false
      } else if let text = textField.text {
        return text.characters.count - range.length + string.characters.count <= 4
      } else {
        return string.characters.count <= 4
      }
    }
    
    if textField == self.usernameCell.textField {
      if let _ = string.rangeOfCharacterFromSet(NSCharacterSet.alphanumericCharacterSet().invertedSet) {
        return false
      } else if let text = textField.text {
        return text.characters.count - range.length + string.characters.count <= 25
      } else {
        return string.characters.count <= 25
      }
    }
    
    if textField == self.regionCell.textField {
      return false
    }
    
    if textField == self.zipCell.textField {
      if let text = textField.text {
        return self.isPossibleStartOfValidZIPCode(
          (text as NSString).stringByReplacingCharactersInRange(range, withString: string))
      } else {
        return self.isPossibleStartOfValidZIPCode(string)
      }
    }
    
    return true
  }
  
  // Mark: UITableViewDelegate
  
  @objc override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return self.sections[indexPath.section].cells[indexPath.row] == self.submitCell
  }
  
  @objc override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    if self.sections[indexPath.section].cells[indexPath.row] == self.submitCell {
      didSelectSubmit()
    }
  }
  
  // MARK: -
  
  @objc private func didSelectDone() {
    self.view.endEditing(false)
  }
  
  @objc private func didSelectSubmit() {
    if self.validateFields() == .Valid {
      self.view.endEditing(false)
    }
  }
  
  private func validateFields() -> Validity {
    func validateLabelledTextViewCellNotEmpty(cell: LabelledTextViewCell) -> Validity {
      if cell.textField.text == nil || cell.textField.text! == "" {
        let mustNotBeEmpty = NSLocalizedString("The field %@ must not be left blank.",
                                               comment: "A specific field that must not be empty")
        let alertController = UIAlertController(
          title: NSLocalizedString("Required Field", comment: "A field that cannot be empty"),
          message: String(format: mustNotBeEmpty, cell.label.text!),
          preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(
          title: NSLocalizedString("OK", comment: ""),
          style: .Default,
          handler: nil))
        self.presentViewController(alertController,
                                   animated: true,
                                   completion: {
                                    self.tableView.scrollRectToVisible(cell.frame, animated: true)
                                    cell.textField.becomeFirstResponder()})
        return .Invalid
      } else {
        return .Valid
      }
    }
    
    func validateLabelledTextViewCell(cell: LabelledTextViewCell, minimumCharacters: Int) -> Validity {
      if cell.textField.text == nil || cell.textField.text!.characters.count < minimumCharacters {
        let mustContainMoreCharacters = NSLocalizedString("The field %@ must contain at least %d characters.",
                                                          comment: "A specific field that must contain N characters")
        let alertController = UIAlertController(
          title: NSLocalizedString(
            "Not Enough Characters",
            comment: "The quality of a field not having enough characters entered into it"),
          message: String(format: mustContainMoreCharacters, cell.label.text!, minimumCharacters),
          preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(
          title: NSLocalizedString("OK", comment: ""),
          style: .Default,
          handler: {_ in self.tableView.scrollRectToVisible(cell.frame, animated: true)}))
        self.presentViewController(alertController,
                                   animated: true,
                                   completion: nil)
        return .Invalid
      } else {
        return .Valid
      }
    }
    
    let requiredCells = [self.fullNameCell,
                         self.emailCell,
                         self.usernameCell,
                         self.pinCell,
                         self.street1Cell,
                         self.cityCell,
                         self.regionCell,
                         self.zipCell]
    
    for cell in requiredCells {
      if validateLabelledTextViewCellNotEmpty(cell) == .Invalid {
        return .Invalid
      }
    }
    
    if validateLabelledTextViewCell(self.usernameCell, minimumCharacters: 5) == .Invalid {
      return .Invalid
    }
    
    if validateLabelledTextViewCell(self.pinCell, minimumCharacters: 4) == .Invalid {
      return .Invalid
    }
    
    if !self.isValidZIPCode(self.zipCell.textField.text!) {
      let alertController = UIAlertController(
        title: NSLocalizedString(
          "Invalid ZIP Code",
          comment: "The quality of a ZIP code not being valid"),
        message: NSLocalizedString(
          "The ZIP code you entered is not valid.",
          comment: "A message to the user explaining that their zip code is not valid"),
        preferredStyle: .Alert)
      alertController.addAction(UIAlertAction(
        title: NSLocalizedString("OK", comment: ""),
        style: .Default,
        handler: {_ in self.tableView.scrollRectToVisible(self.zipCell.frame, animated: true)}))
      self.presentViewController(alertController,
                                 animated: true,
                                 completion: nil)
      return .Invalid
    }
    
    return .Valid
  }
  
  private func isPossibleStartOfValidZIPCode(string: String) -> Bool {
    if string.containsString("-") {
      if string.characters.count > 10 {
        return false
      }
    } else {
      if string.characters.count > 9 {
        return false
      }
    }
    
    for (i, c) in zip(0..<10, string.characters) {
      if !(c >= "0" && c <= "9") {
        if i == 5 {
          if c != "-" {
            return false
          }
        } else {
          return false
        }
      }
    }
    
    return true
  }
  
  private func isValidZIPCode(string: String) -> Bool {
    return isPossibleStartOfValidZIPCode(string) && (string.characters.count == 5 || string.characters.count == 10)
  }
  
  @objc private func zipTextFieldDidChange() {
    if let text = self.zipCell.textField.text {
      if text.characters.count > 5 && !text.containsString("-") {
        let index = text.startIndex.advancedBy(5)
        self.zipCell.textField.text = text.substringToIndex(index) + "-" + text.substringFromIndex(index)
      } else if text.characters.count == 6 && text.containsString("-") {
        self.zipCell.textField.text = text.stringByReplacingOccurrencesOfString("-", withString: "")
      }
    }
  }
  
  private class RegionPickerViewDataSourceAndDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let textField: UITextField
    
    init(textField: UITextField) {
      self.textField = textField
    }
    
    @objc func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
      return 1
    }
    
    @objc func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return CardCreatorViewController.regions.count
    }
    
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return CardCreatorViewController.regions[row]
    }
    
    @objc func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      self.textField.text = CardCreatorViewController.regions[row]
    }
  }
}