import UIKit

class AddressViewController: FormTableViewController {
  
  private static let regions: [String] = {
    let stream = NSInputStream.init(URL: NSBundle.mainBundle().URLForResource("regions", withExtension: "json")!)!
    stream.open()
    defer {
      stream.close()
    }
    return try! NSJSONSerialization.JSONObjectWithStream(stream, options: [.AllowFragments]) as! [String]
  }()
  
  private let addressStep: AddressStep
  private let street1Cell: LabelledTextViewCell
  private let street2Cell: LabelledTextViewCell
  private let cityCell: LabelledTextViewCell
  private let regionCell: LabelledTextViewCell
  private let zipCell: LabelledTextViewCell
  
  private let regionPickerView = UIPickerView()
  private let regionPickerViewDataSourceAndDelegate: RegionPickerViewDataSourceAndDelegate
  
  init(addressStep: AddressStep) {
    self.addressStep = addressStep
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
    
    self.regionPickerViewDataSourceAndDelegate =
      RegionPickerViewDataSourceAndDelegate(textField: self.regionCell.textField)
    
    super.init(cells: [
      self.street1Cell,
      self.street2Cell,
      self.cityCell,
      self.regionCell,
      self.zipCell
      ])
    
    self.regionPickerView.dataSource = self.regionPickerViewDataSourceAndDelegate
    self.regionPickerView.delegate = self.regionPickerViewDataSourceAndDelegate
    
    self.navigationItem.rightBarButtonItem?.enabled = false
    
    self.prepareTableViewCells()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    switch self.addressStep {
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
    switch self.addressStep {
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
    self.zipCell.textField.inputAccessoryView = self.returnToolbar()
    self.zipCell.textField.addTarget(self,
                                     action: #selector(zipTextFieldDidChange),
                                     forControlEvents: .AllEditingEvents)
  }

  // MARK: UITextFieldDelegate
  
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
  
  @objc override func didSelectNext() {
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
  
  private func currentAddress() -> Address? {
    guard let
      street1 = self.street1Cell.textField.text,
      city = self.cityCell.textField.text,
      region = self.regionCell.textField.text,
      zip = self.zipCell.textField.text
      else
    {
      return nil
    }
    
    return Address(street1: street1, street2: self.street2Cell.textField.text, city: city, region: region, zip: zip)
  }
  
  private func submit() {
    self.navigationController?.view.userInteractionEnabled = false
    let originalTitle = self.title
    self.title = NSLocalizedString(
      "Validating Address…",
      comment: "A title telling the user their address is currently being validated")
    let request = NSMutableURLRequest(URL: Configuration.APIEndpoint.URLByAppendingPathComponent("validate/address"))
    let isSchoolOrWorkAddress: Bool = {
      switch self.addressStep {
      case .Home:
        return false
      case .School:
        return true
      case .Work:
        return true
      }
    }()
    let JSONObject: [String: AnyObject] = [
      "address": self.currentAddress()!.JSONObject(),
      "is_work_or_school_address": isSchoolOrWorkAddress
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
        guard let validateAddressResponse = ValidateAddressResponse.responseWithData(data!) else {
          showErrorAlert()
          return
        }
        switch validateAddressResponse {
        case let .ValidAddress(_, address, cardType):
          self.addressStep.continueFlowWithValidAddress(self, address: address, cardType: cardType)
        case let .AlternativeAddresses(_, addressTuples):
          let alertViewController = UIAlertController(
            title: NSLocalizedString(
              "Multiple Matching Addresses",
              comment: "An alert title telling the user we've found multiple matching addresses"),
            message: NSLocalizedString(
              ("The address you entered matches more than one location. Please choose the correct address "
                + "from the list of addresses on the following screen."),
              comment: "An alert message telling the user to pick the correct address"),
            preferredStyle: .Alert)
          alertViewController.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .Default,
            handler: { _ in
              let viewController = AlternativeAddressesViewController(
                addressStep: self.addressStep,
                alternativeAddressesAndCardTypes: addressTuples)
              self.navigationController?.pushViewController(viewController, animated: true)
          }))
          self.presentViewController(alertViewController, animated: true, completion: nil)
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
