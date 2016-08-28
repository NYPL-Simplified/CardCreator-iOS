import UIKit

class AddressViewController: UITableViewController, UITextFieldDelegate {
  private static let regions: [String] = {
    let stream = NSInputStream.init(URL: NSBundle.mainBundle().URLForResource("regions", withExtension: "json")!)!
    stream.open()
    defer {
      stream.close()
    }
    return try! NSJSONSerialization.JSONObjectWithStream(stream, options: [.AllowFragments]) as! [String]
  }()
  
  private let street1Cell: LabelledTextViewCell
  private let street2Cell: LabelledTextViewCell
  private let cityCell: LabelledTextViewCell
  private let regionCell: LabelledTextViewCell
  private let zipCell: LabelledTextViewCell
  
  let cells: [UITableViewCell]
  
  private let regionPickerView = UIPickerView()
  private let regionPickerViewDataSourceAndDelegate: RegionPickerViewDataSourceAndDelegate
  
  init() {
    self.street1Cell = LabelledTextViewCell(
      title: NSLocalizedString("Street 1", comment: "The first line of a US street address"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    self.street2Cell = LabelledTextViewCell(
      title: NSLocalizedString("Street 2", comment: "The second line of a US street address (optional)"),
      placeholder: NSLocalizedString("Optional", comment: "A placeholder for an optional text field"))
    self.cityCell = LabelledTextViewCell(
      title: NSLocalizedString("City", comment: "The city portion of a US postal address"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    self.regionCell = LabelledTextViewCell(
      title: NSLocalizedString("Region", comment: "The name for one of the 50+ states and regions in the US"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    self.zipCell = LabelledTextViewCell(
      title: NSLocalizedString("ZIP", comment: "The common name for a US ZIP code"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))

    self.cells = [
      self.street1Cell,
      self.street2Cell,
      self.cityCell,
      self.regionCell,
      self.zipCell
    ]
    
    self.regionPickerViewDataSourceAndDelegate =
      RegionPickerViewDataSourceAndDelegate(textField: self.regionCell.textField)
    
    super.init(style: UITableViewStyle.Grouped)
    
    self.regionPickerView.dataSource = self.regionPickerViewDataSourceAndDelegate
    self.regionPickerView.delegate = self.regionPickerViewDataSourceAndDelegate
    
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
    for cell in self.cells {
      if let labelledTextViewCell = cell as? LabelledTextViewCell {
        labelledTextViewCell.selectionStyle = .None
        labelledTextViewCell.textField.delegate = self
        labelledTextViewCell.textField.addTarget(self,
                                                 action: #selector(textFieldDidChange),
                                                 forControlEvents: .EditingChanged)
      }
    }

    self.street1Cell.textField.keyboardType = .Alphabet
    self.street1Cell.textField.autocapitalizationType = .Words
    
    self.street2Cell.textField.keyboardType = .Alphabet
    self.street2Cell.textField.autocapitalizationType = .Words
    
    self.cityCell.textField.keyboardType = .Alphabet
    self.cityCell.textField.autocapitalizationType = .Words
    
    self.regionCell.textField.inputView = self.regionPickerView
    self.regionCell.textField.inputAccessoryView = self.returnToolbar()
    
    self.zipCell.textField.keyboardType = .NumberPad
    self.zipCell.textField.inputAccessoryView = self.doneToolbar()
    self.zipCell.textField.addTarget(self,
                                     action: #selector(zipTextFieldDidChange),
                                     forControlEvents: .AllEditingEvents)
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
    return true
  }
  
  @objc func textField(textField: UITextField,
                       shouldChangeCharactersInRange range: NSRange,
                                                     replacementString string: String) -> Bool
  {
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
  
  // MARK: -
  
  @objc private func didSelectDone() {
    self.view.endEditing(false)
  }
  
  @objc private func didSelectNext() {
    self.view.endEditing(false)
    // FIXME: Do stuff!
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
      self.textFieldDidChange()
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
      return AddressViewController.regions.count
    }
    
    @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return AddressViewController.regions[row]
    }
    
    @objc func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      self.textField.text = AddressViewController.regions[row]
    }
  }
  
  @objc private func textFieldDidChange() {
    self.navigationItem.rightBarButtonItem?.enabled =
      (self.street1Cell.textField.text?.characters.count > 0
        && self.cityCell.textField.text?.characters.count > 0
        && self.regionCell.textField.text?.characters.count > 0
        && self.zipCell.textField.text?.characters.count > 0
        && self.isValidZIPCode(self.zipCell.textField.text!))
  }
}
