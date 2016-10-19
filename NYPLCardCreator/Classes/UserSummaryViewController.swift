import UIKit

/// This class is used for summarizing the user's details before
/// submitting the request to create a library card.
final class UserSummaryViewController: TableViewController {
  private var cells: [UITableViewCell]
//  private var sectionHeaderTitles: [String]
  private let headerLabel: UILabel
  
  private let configuration: CardCreatorConfiguration
  private let session: AuthenticatingSession
  
  private let homeAddressCell: SummaryAddressCell
  private let altAddressCell: SummaryAddressCell
  private let cardType: CardType
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
    cardType: CardType,
    fullName: String,
    email: String,
    username: String,
    pin: String)
  {
    self.configuration = configuration
    self.session = AuthenticatingSession(configuration: configuration)

    self.homeAddress = homeAddress
    self.schoolOrWorkAddress = schoolOrWorkAddress
    self.cardType = cardType
    self.fullName = fullName
    self.email = email
    self.username = username
    self.pin = pin
    
    self.headerLabel = UILabel()
    
    self.homeAddressCell = SummaryAddressCell(section: NSLocalizedString(
      "Home Address",
      comment: "Title of the section for the user's home address"),
                                              style: .Default, reuseIdentifier: nil)
    self.altAddressCell = SummaryAddressCell(section: NSLocalizedString(
      "School or Work Address",
      comment: "Title of the section for the user's possible work or school address"),
                                             style: .Default, reuseIdentifier: nil)
  
    self.homeAddressCell.address = self.homeAddress
    if let address = self.schoolOrWorkAddress {
      self.altAddressCell.address = address
    }
    
    self.fullNameCell = SummaryCell(section: "Full Name", cellText: self.fullName)
    self.emailCell = SummaryCell(section: "Email", cellText: self.email)
    self.usernameCell = SummaryCell(section: "Username", cellText: self.username)
    self.pinCell = SummaryCell(section: "Pin", cellText: self.pin)

    self.cells = [
      self.homeAddressCell,
      self.fullNameCell,
      self.emailCell,
      self.usernameCell,
      self.pinCell
    ]

    if (self.schoolOrWorkAddress != nil) {
      self.cells.insert(self.altAddressCell, atIndex: 1)
    }
    
    super.init(style: .Plain)
    
    self.tableView.separatorStyle = .None
    
    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: NSLocalizedString(
        "Create Card",
        comment: "A title for a button that submits the user's information to create a library card"),
                      style: .Plain,
                      target: self,
                      action: #selector(createPatron))

    self.prepareTableViewCells()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
    
    self.title = NSLocalizedString(
      "Review",
      comment: "A title for a screen letting the user know they can review the information they have entered")
    
    headerLabel.numberOfLines = 0
    headerLabel.lineBreakMode = .ByWordWrapping
    headerLabel.textColor = UIColor.darkGrayColor()
    headerLabel.textAlignment = .Center
    
    switch self.cardType {
    case .Temporary:
      headerLabel.text = NSLocalizedString(
        "We were not able to verify your address, so we have issued you a temporary card. Please visit your local " +
        "NYPL branch within 30 days to receive a standard card.",
        comment: "A message telling the user she'll get a 30-day library card")
    case .Standard:
      headerLabel.text = NSLocalizedString(
        "Your address will result in a standard\n three-year ebook-only library card.",
        comment: "A message telling the user she'll get a 3-year library card")
    default:
      headerLabel.text = NSLocalizedString(
        "Review your information before creating your library card.",
        comment: "Description to tell a user to either review and confirm, or go back and make changes to their information.")
    }

    self.tableView.estimatedRowHeight = 120
    self.tableView.allowsSelection = false
    self.tableView.tableHeaderView = headerLabel
  }
  
  override func viewDidLayoutSubviews() {
    let origin_x = self.tableView.tableHeaderView!.frame.origin.x
    let origin_y = self.tableView.tableHeaderView!.frame.origin.y
    let size = self.tableView.tableHeaderView!.sizeThatFits(CGSizeMake(self.view.bounds.width, CGFloat.max))
    
    let adjustedWidth = (size.width > CGFloat(375)) ? CGFloat(375.0) : size.width
    let padding = CGFloat(30.0)
    self.headerLabel.frame = CGRectMake(origin_x, origin_y, adjustedWidth, size.height + padding)
    
    self.tableView.tableHeaderView = self.headerLabel
  }
  
  private func prepareTableViewCells() {
    for cell in self.cells {
      cell.backgroundColor = UIColor.clearColor()
      self.tableView.separatorStyle = .None
      
      if let labelledTextViewCell = cell as? LabelledTextViewCell {
        labelledTextViewCell.selectionStyle = .None
        labelledTextViewCell.textField.allowsEditingTextAttributes = false
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
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 0
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0
  }
  
  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//    if self.cells[indexPath.section] is SummaryAddressCell {
//      return UITableViewAutomaticDimension
//    } else {
//      return 20
//    }
    
    return UITableViewAutomaticDimension

  }
  
//  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//    return self.sectionHeaderTitles[section]
//  }
  
  // MARK: -
  
  @objc private func createPatron() {
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
