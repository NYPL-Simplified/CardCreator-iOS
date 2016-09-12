import UIKit

class UsernameAndPINViewController: FormTableViewController {
  private let usernameCell: LabelledTextViewCell
  private let pinCell: LabelledTextViewCell
  private let homeAddress: Address
  private let schoolOrWorkAddress: Address?
  private let fullName: String
  private let email: String
  
  init(homeAddress: Address, schoolOrWorkAddress: Address?, fullName: String, email: String) {
    self.usernameCell = LabelledTextViewCell(
      title: NSLocalizedString("Username", comment: "A username used to log into a service"),
      placeholder: NSLocalizedString("janedoe123", comment: "An example of a possible username"))
    self.pinCell = LabelledTextViewCell(
      title: NSLocalizedString("PIN", comment: "An abbreviation for personal identification number"),
      placeholder: "0987")
    
    self.homeAddress = homeAddress
    self.schoolOrWorkAddress = schoolOrWorkAddress
    self.fullName = fullName
    self.email = email
    
    super.init(cells: [
      self.usernameCell,
      self.pinCell
      ])
    
    self.navigationItem.rightBarButtonItem?.enabled = false
    
    self.prepareTableViewCells()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    self.title = NSLocalizedString(
      "Username & PIN",
      comment: "A title for a screen asking the user for the user's username and PIN")
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
  
  // MARK: UITableViewDataSource
  
  override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return NSLocalizedString("Usernames must be 5–25 letters and numbers only. PINs must be four digits.",
                             comment: "A description of valid usernames and PINs")
  }
  
  // MARK: UITextFieldDelegate
  
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
  
  @objc override func didSelectNext() {
    self.view.endEditing(false)
    self.navigationController?.view.userInteractionEnabled = false
    self.navigationItem.titleView =
      ActivityTitleView(title:
        NSLocalizedString(
          "Validating Name",
          comment: "A title telling the user their full name is currently being validated"))
    let request = NSMutableURLRequest(URL: Configuration.APIEndpoint.URLByAppendingPathComponent("validate/username"))
    let JSONObject: [String: String] = ["username": self.usernameCell.textField.text!]
    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(JSONObject, options: [.PrettyPrinted])
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = Configuration.requestTimeoutInterval
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
      NSOperationQueue.mainQueue().addOperationWithBlock {
        self.navigationController?.view.userInteractionEnabled = true
        self.navigationItem.titleView = nil
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
              "A server error occurred during username validation. Please try again later.",
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
        guard let validateUsernameResponse = ValidateUsernameResponse.responseWithData(data!) else {
          showErrorAlert()
          return
        }
        switch validateUsernameResponse {
        case .UnavailableUsername:
          let alertController = UIAlertController(
            title: NSLocalizedString("Username Unavailable", comment: "The title for an error alert"),
            message: NSLocalizedString(
              "Your chosen username is already in use. Please choose another and try again.",
              comment: "An alert message explaining an error and telling the user to try again"),
            preferredStyle: .Alert)
          alertController.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .Default,
            handler: nil))
          self.presentViewController(alertController, animated: true, completion: nil)
        case .InvalidUsername:
          // We should never be here due to client-side validation, but we'll report it anyway.
          let alertController = UIAlertController(
            title: NSLocalizedString("Username Invalid", comment: "The title for an error alert"),
            message: NSLocalizedString(
              "Usernames must be 5–25 letters and numbers only. Please correct your username and try again.",
              comment: "An alert message explaining an error and telling the user to try again"),
            preferredStyle: .Alert)
          alertController.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .Default,
            handler: nil))
          self.presentViewController(alertController, animated: true, completion: nil)
        case .AvailableUsername:
          self.createPatron()
        }
      }
    }
    
    task.resume()
  }
  
  @objc private func textFieldDidChange() {
    self.navigationItem.rightBarButtonItem?.enabled =
      (self.usernameCell.textField.text?.characters.count >= 5
        && self.pinCell.textField.text?.characters.count == 4)
  }
  
  private func createPatron() {
    self.view.endEditing(false)
    self.navigationController?.view.userInteractionEnabled = false
    self.navigationItem.titleView =
      ActivityTitleView(title:
        NSLocalizedString(
          "Creating Card",
          comment: "A title telling the user their card is currently being created"))
    let request = NSMutableURLRequest(URL: Configuration.APIEndpoint.URLByAppendingPathComponent("create_patron"))
    let schoolOrWorkAddressOrNull: AnyObject = {
      if let schoolOrWorkAddress = self.schoolOrWorkAddress {
        return schoolOrWorkAddress.JSONObject()
      } else {
        return NSNull()
      }
    }()
    let JSONObject: [String: AnyObject] = [
      "name": self.fullName,
      "email": self.email,
      "address": self.homeAddress.JSONObject(),
      "username": self.usernameCell.textField.text!,
      "pin": self.pinCell.textField.text!,
      "work_or_school_address": schoolOrWorkAddressOrNull
    ]
    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(JSONObject, options: [.PrettyPrinted])
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = Configuration.requestTimeoutInterval
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
      NSOperationQueue.mainQueue().addOperationWithBlock {
        self.navigationController?.view.userInteractionEnabled = true
        self.navigationItem.titleView = nil
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
              "A server error occurred during card creation. Please try again later.",
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
        let alertController = UIAlertController(
          title: NSLocalizedString(
            "Card Created Successfully",
            comment: "An alert title telling the user their card has been created"),
          message: NSLocalizedString(
            "You have been issued a digital library card! Be sure to keep your username and PIN in a safe location.",
            comment: "An alert message telling the user they received a library card"),
          preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(
          title: NSLocalizedString(
            "Sign In",
            comment: "An alert action the user may select to sign in with their new library card"),
          style: .Default,
          handler: { _ in
            // FIXME
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
      }
    }
    
    task.resume()
  }
}
