import UIKit

/// This class is used for summarizing the user's details before
/// submitting the request to create a library card
//GODO think of better name for class
final class UserSummaryViewController: TableViewController {
  private var cells: [UITableViewCell]
  private var sectionHeaderTitles: [String]
  
  private let configuration: CardCreatorConfiguration
  private let session: AuthenticatingSession
  
  private let homeAddressCell: AddressCell
  private let altAddressCell: AddressCell
  private let fullNameCell: UITableViewCell
  private let emailCell: UITableViewCell
  private let usernameCell: UITableViewCell
  private let pinCell: UITableViewCell
  
  private let homeAddress: Address
  private let schoolOrWorkAddress: Address?
  private let fullName: String
  private let email: String
  private let username: String
  private let pin: String
  
  init(
    configuration: CardCreatorConfiguration,
    homeAddress: Address,
    schoolOrWorkAddress: Address?,
    fullName: String,
    email: String,
    username: String,
    pin: String)
  {
    self.configuration = configuration
    self.session = AuthenticatingSession(configuration: configuration)
    
    //GODO check on this
    self.homeAddressCell = AddressCell()
    self.altAddressCell = AddressCell()
    self.fullNameCell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    self.emailCell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    self.usernameCell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    self.pinCell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    
    //do I really need the properties in addition to the cells?
    self.homeAddress = homeAddress
    self.schoolOrWorkAddress = schoolOrWorkAddress
    self.fullName = fullName
    self.email = email
    self.username = username
    self.pin = pin
    
    self.homeAddressCell.address = self.homeAddress
    if let address = self.schoolOrWorkAddress {
      self.altAddressCell.address = address
    }
    self.fullNameCell.textLabel?.text = self.fullName
    self.emailCell.textLabel?.text = self.email
    self.usernameCell.textLabel?.text = self.username
    self.pinCell.textLabel?.text = self.pin

    //GODO here this code diverts from other classes,
    //combines both alternative addresses and formtableview
    self.cells = [
      self.homeAddressCell,
      self.fullNameCell,
      self.emailCell,
      self.usernameCell,
      self.pinCell
    ]
    self.sectionHeaderTitles = [
      "Home Address",
      "Full Name",
      "Email",
      "Username",
      "Pin"
    ]
    if (self.schoolOrWorkAddress != nil) {
      self.cells.insert(self.altAddressCell, atIndex: 1)
      self.sectionHeaderTitles.insert("School or Work Address", atIndex: 1)
    }
    
    super.init(style: .Grouped)
    self.tableView.estimatedRowHeight = 104
    
    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: NSLocalizedString("Submit", comment: "A title for a button that submits the user's information to create a library card"),
                      style: .Plain,
                      target: self,
                      action: #selector(createPatron))

    self.prepareTableViewCells()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //GODO need to update localized strings
    self.title = NSLocalizedString(
      "Review",
      comment: "A title for a screen letting the user know they can review the information they have entered")
  }
  
  private func prepareTableViewCells() {
    
    //GODO so far this is not really being used at all to style
    for cell in self.cells {
      
      //GODO make sure these are caught
      if let addressViewCell = cell as? AddressCell {
        //style as an address cell
      }
      
      if let labelledTextViewCell = cell as? LabelledTextViewCell {
        labelledTextViewCell.selectionStyle = .None
        //GODO I know this is klunky
//        labelledTextViewCell.textField.alpha = 0
        labelledTextViewCell.textField.allowsEditingTextAttributes = false
        //GODO need to make cells without background and borders
      }

    }
  }
  
  
  // MARK: UITableViewDataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return self.cells.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return self.cells[indexPath.section]
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 1.0
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //GODO need to create localized strings for this
    //CHANGE! should change to use property of the cell to name the section
    return self.sectionHeaderTitles[section]
  }
  
  // MARK: -
  
  //GODO submit patron info to server
  
  @objc private func createPatron() {
    self.view.endEditing(false)
    self.navigationController?.view.userInteractionEnabled = false
    self.navigationItem.titleView =
      ActivityTitleView(title:
        NSLocalizedString(
          "Creating Card",
          comment: "A title telling the user their card is currently being created"))
    let request = NSMutableURLRequest(URL: self.configuration.endpointURL.URLByAppendingPathComponent("create_patron"))
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
      "username": self.username,
      "pin": self.pin,
      "work_or_school_address": schoolOrWorkAddressOrNull
    ]
    request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(JSONObject, options: [.PrettyPrinted])
    request.HTTPMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = self.configuration.requestTimeoutInterval
    let task = self.session.dataTaskWithRequest(request) { (data, response, error) in
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
            self.configuration.completionHandler(
              username: self.username,
              PIN: self.pin)
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
      }
    }
    
    task.resume()
  }

  
}
