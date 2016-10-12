import UIKit

/// This class is used for summarizing the user's details before
/// submitting the request to create a patron
//GODO think of better name for class
final class PatronInfoViewController: TableViewController {
  let cells: [UITableViewCell]
  
  private let configuration: CardCreatorConfiguration
  
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
  
  //GODO right now I'm sort of straddling two different way of getting the info into the tableview
  private static let addressCellReuseIdentifier = "addressCellReuseIdentifier"
//  private static let infoCellReuseIdentifier = "infoCellReuseIdentifier"

  //GODO don't think i need this
  //but eventually the 'add patron' stuff will be moved from the pin/username vc to this one
//  private let session: AuthenticatingSession
  
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
    
    //GODO check on this
    self.homeAddressCell = AddressCell()
    self.altAddressCell = AddressCell()
    
    self.fullNameCell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    self.emailCell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    self.usernameCell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    self.pinCell = UITableViewCell(style: .Default, reuseIdentifier: nil)
    
//    self.fullNameCell = LabelledTextViewCell(
//      title: NSLocalizedString("Full Name", comment: "The text field title for the full name of a user"),
//      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
//    self.emailCell = LabelledTextViewCell(
//      title: NSLocalizedString("Email", comment: "A text field title for a user's email address"),
//      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
//    self.usernameCell = LabelledTextViewCell(
//      title: NSLocalizedString("Username", comment: "A username used to log into a service"),
//      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
//    self.pinCell = LabelledTextViewCell(
//      title: NSLocalizedString("PIN", comment: "An abbreviation for personal identification number"),
//      placeholder: NSLocalizedString("Optional", comment: "A placeholder for an optional text field"))
    
    //do I really need the properties in addition to the cells?
    self.homeAddress = homeAddress
    self.schoolOrWorkAddress = schoolOrWorkAddress
    self.fullName = fullName
    self.email = email
    self.username = username
    self.pin = pin
    
    self.homeAddressCell.address = self.homeAddress
    self.altAddressCell.address = self.schoolOrWorkAddress
    self.fullNameCell.textLabel?.text = self.fullName
    self.emailCell.textLabel?.text = self.email
    self.usernameCell.textLabel?.text = self.username
    self.pinCell.textLabel?.text = self.pin

    
//    self.session = AuthenticatingSession(configuration: configuration)
    
    //GODO here this code diverts from other classes, combines both alternative addresses and formtableview
    self.cells = [
    self.homeAddressCell,
    self.altAddressCell,
    self.fullNameCell,
    self.emailCell,
    self.usernameCell,
    self.pinCell
    ]
    
    super.init(style: .Grouped)
    
//    self.tableView.registerClass(
//      AddressCell.self,
//      forCellReuseIdentifier: PatronInfoViewController.addressCellReuseIdentifier)
    
    self.tableView.estimatedRowHeight = 104

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
        
//        labelledTextViewCell.textField.delegate = self
//        labelledTextViewCell.textField.addTarget(self,
//                                                 action: #selector(textFieldDidChange),
//                                                 forControlEvents: .EditingChanged)
      }

    }
    
//    self.usernameCell.textField.keyboardType = .Alphabet
//    self.usernameCell.textField.autocapitalizationType = .None
//    self.usernameCell.textField.autocorrectionType = .No
//    
//    self.pinCell.textField.keyboardType = .NumberPad
//    self.pinCell.textField.inputAccessoryView = self.returnToolbar()
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
    return 0
  }
  
  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //GODO need to create localized strings for this
    //CHANGE! should change to use property of the cell to name the section
    switch section {
    case 0:
      return "Home Address"
    case 1:
      return "School or Work Address"
    case 2:
      return "Full Name"
    case 3:
      return "Email"
    case 4:
      return "Username"
    case 5:
      return "PIN"
    default:
      return nil
    }
  }
  
  // MARK: -
  
  
  
}
