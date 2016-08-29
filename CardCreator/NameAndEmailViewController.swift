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
    self.navigationController?.view.userInteractionEnabled = false
    let originalTitle = self.title
    self.title = NSLocalizedString(
      "Validating Name…",
      comment: "A title telling the user their full name is currently being validated")
    let request = NSMutableURLRequest(URL: NSURL(string: "https://patrons.librarysimplified.org/validate/address")!)
    let JSONObject: [String: String] = ["name": self.fullNameCell.textField.text!]
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
      
      // FIXME: Continue
    }
    
    task.resume()
  }
  
  @objc private func textFieldDidChange() {
    self.navigationItem.rightBarButtonItem?.enabled =
      (self.fullNameCell.textField.text?.characters.count > 0
        && self.emailCell.textField.text?.characters.count > 0
        && self.emailCell.textField.text!.rangeOfString("@") != nil)
  }
}
