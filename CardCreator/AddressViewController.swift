import UIKit

class AddressViewController: UITableViewController, UITextFieldDelegate {
  
  enum AddressType {
    case Home
    case School
    case Work
  }
  
  private static let regions: [String] = {
    let stream = NSInputStream.init(URL: NSBundle.mainBundle().URLForResource("regions", withExtension: "json")!)!
    stream.open()
    defer {
      stream.close()
    }
    return try! NSJSONSerialization.JSONObjectWithStream(stream, options: [.AllowFragments]) as! [String]
  }()
  
  private let addressType: AddressType
  private let street1Cell: LabelledTextViewCell
  private let street2Cell: LabelledTextViewCell
  private let cityCell: LabelledTextViewCell
  private let regionCell: LabelledTextViewCell
  private let zipCell: LabelledTextViewCell
  
  let cells: [UITableViewCell]
  
  private let regionPickerView = UIPickerView()
  private let regionPickerViewDataSourceAndDelegate: RegionPickerViewDataSourceAndDelegate
  
  init(addressType: AddressType) {
    self.addressType = addressType
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
  
  override func viewDidLoad() {
    switch self.addressType {
    case .Home:
      self.title = NSLocalizedString(
        "Home Address",
        comment: "A title for a screen asking the user for their home address")
    case .School:
      self.title = NSLocalizedString(
        "School Address",
        comment: "A title for a screen asking the user for their school address")
    case .Work:
      self.title = NSLocalizedString(
        "Work Address",
        comment: "A title for a screen asking the user for their work address")
    }
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
    switch self.addressType {
    case .Home:
      break
    case .School:
      fallthrough
    case .Work:
      self.regionCell.textField.userInteractionEnabled = false
      self.regionCell.textField.text = "New York"
      self.regionCell.textField.textColor = UIColor.grayColor()
    }
    
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
        // Skip fields that are not enabled, e.g. the region field when entering school
        // or work addresses.
        if foundFirstResponder && labelledTextViewCell.textField.userInteractionEnabled {
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
    self.submit()
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
  
  private func submit() {
    self.navigationController?.view.userInteractionEnabled = false
    let originalTitle = self.title
    self.title = NSLocalizedString(
      "Validating Address…",
      comment: "A title telling the user their address is currently being validated")
    let request = NSMutableURLRequest(URL: Configuration.APIEndpoint.URLByAppendingPathComponent("validate/address"))
    let JSONObject: [String: AnyObject] = [
      "address": [
        "line_1": self.street1Cell.textField.text!,
        "line_2": self.street2Cell.textField.text == nil ? "" : self.street2Cell.textField.text!,
        "city": self.cityCell.textField.text!,
        "state": self.regionCell.textField.text!,
        "zip": self.zipCell.textField.text!
      ],
      "is_work_address": self.addressType == .School || self.addressType == .Work
    ]
    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(JSONObject, options: [.PrettyPrinted])
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 5.0
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
      NSOperationQueue.mainQueue().addOperationWithBlock {
        self.navigationController?.view.userInteractionEnabled = true
        self.title = originalTitle
        if let error = error {
          let alertController = UIAlertController(
            title: NSLocalizedString("Error", comment: "The title for an error alert"),
            message: error.localizedDescription,
            preferredStyle: .Alert)
          alertController.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .Default,
            handler: nil))
          self.presentViewController(alertController, animated: true, completion: nil)
          return
        }
        func showErrorAlert() {
          let alertController = UIAlertController(
            title: NSLocalizedString("Error", comment: "The title for an error alert"),
            message: NSLocalizedString(
              "A server error occurred during address validation. Please try again later.",
              comment: "An alert message explaining an error and telling the user to try again later"),
            preferredStyle: .Alert)
          alertController.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .Default,
            handler: nil))
          self.presentViewController(alertController, animated: true, completion: nil)
        }
        if (response as! NSHTTPURLResponse).statusCode != 200 || data == nil {
          showErrorAlert()
          return
        }
        guard let validateAddressResponse = ValidateAddressResponse.responseFromData(data!) else {
          showErrorAlert()
          return
        }
        switch validateAddressResponse {
        case let .ValidAddress(_, _, cardType):
          switch cardType {
          case .None:
            switch self.addressType {
            case .Home:
              let alertController = UIAlertController(
                title: NSLocalizedString("Out-of-State Address", comment: ""),
                message: NSLocalizedString(
                  ("Since you do not live in New York, you must work or attend school in New York to qualify for a "
                    + "library card."),
                  comment: "A message informing the user what they must assert given that they live outside NY"),
                preferredStyle: .ActionSheet)
              alertController.addAction(UIAlertAction(
                title: NSLocalizedString("I Work in New York", comment: ""),
                style: .Default,
                handler: {_ in
                  self.navigationController?.pushViewController(
                    AddressViewController(addressType: .Work),
                    animated: true)
              }))
              alertController.addAction(UIAlertAction(
                title: NSLocalizedString("I Attend School in New York", comment: ""),
                style: .Default,
                handler: {_ in
                  self.navigationController?.pushViewController(
                    AddressViewController(addressType: .School),
                    animated: true)
              }))
              alertController.addAction(UIAlertAction(
                title: NSLocalizedString("Edit Home Address", comment: ""),
                style: .Cancel,
                handler: nil))
              self.presentViewController(alertController, animated: true, completion: nil)
            case .School:
              let alertController = UIAlertController(
                title: NSLocalizedString(
                  "Card Denied",
                  comment: "An alert title telling the user they cannot receive a library card"),
                message: NSLocalizedString(
                  "You cannot receive a library card because your school address does not appear to be in New York.",
                  comment: "An alert title telling the user they cannot receive a library card"),
                preferredStyle: .Alert)
              alertController.addAction(UIAlertAction(
                title: NSLocalizedString("OK", comment: ""),
                style: .Default,
                handler: nil))
              self.presentViewController(alertController, animated: true, completion: nil)
            case .Work:
              let alertController = UIAlertController(
                title: NSLocalizedString(
                  "Card Denied",
                  comment: "An alert title telling the user they cannot receive a library card"),
                message: NSLocalizedString(
                  "You cannot receive a library card because your work address does not appear to be in New York.",
                  comment: "An alert title telling the user they cannot receive a library card"),
                preferredStyle: .Alert)
              alertController.addAction(UIAlertAction(
                title: NSLocalizedString("OK", comment: ""),
                style: .Default,
                handler: nil))
              self.presentViewController(alertController, animated: true, completion: nil)
            }
          case .Temporary:
            let alertController = UIAlertController(
              title: NSLocalizedString("Temporary Card", comment: ""),
              message: NSLocalizedString(
                ("Your address qualifies you for a temporary 30-day library card. You will need to visit your local "
                  + "NYPL branch within 30 days to receive a standard card."),
                comment: "An alert message telling the user she'll get a 30-day library card"),
              preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(
              title: NSLocalizedString("OK", comment: ""),
              style: .Default,
              handler: {_ in
                self.navigationController?.pushViewController(NameAndEmailViewController(), animated: true)
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
          case .Standard:
            let alertController = UIAlertController(
              title: NSLocalizedString("Standard Card", comment: ""),
              message: NSLocalizedString(
                "Congratulations! Your address qualifies you for a standard three-year library card.",
                comment: "An alert message telling the user she'll get a three-year library card"),
              preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(
              title: NSLocalizedString("OK", comment: ""),
              style: .Default,
              handler: {_ in
                self.navigationController?.pushViewController(NameAndEmailViewController(), animated: true)
            }))
            self.presentViewController(alertController, animated: true, completion: nil)
          }
        case .AlternateAddresses:
          // MARK: FIXME
          let alertController = UIAlertController(
            title: NSLocalizedString("FIXME: Unknown Flow", comment: ""),
            message: NSLocalizedString(
              "FIXME: The app is not sure what to do next!",
              comment: ""),
            preferredStyle: .Alert)
          alertController.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .Default,
            handler: {_ in
              self.navigationController?.pushViewController(NameAndEmailViewController(), animated: true)
          }))
          self.presentViewController(alertController, animated: true, completion: nil)
        case .UnrecognizedAddress:
          let alertController = UIAlertController(
            title: NSLocalizedString(
              "Unrecognized Address",
              comment: "An alert title telling the user their address was not recognized by the server"),
            message: NSLocalizedString(
              "Your address could not be verified. Please try another address.",
              comment: "An alert message telling the user their address was not recognized by the server"),
            preferredStyle: .Alert)
          alertController.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .Default,
            handler: nil))
          self.presentViewController(alertController, animated: true, completion: nil)
        }
      }
    }
    
    task.resume()
  }
}
