import UIKit

/// This class is used for summarizing the user's registered credentials
/// after successfully creating a library card.
final class UserCredentialsViewController: TableViewController {
  private var cells: [UITableViewCell]
  private let headerLabel: UILabel
  private let cardType: CardType
  
  private let configuration: CardCreatorConfiguration
  private let session: AuthenticatingSession
  
  private let usernameCell: UITableViewCell
  private let barcodeCell: UITableViewCell
  private let pinCell: UITableViewCell
  
  private let username: String
  private let barcode: String?
  private let pin: String
  
  init(
    configuration: CardCreatorConfiguration,
    username: String,
    barcode: String?,
    pin: String,
    cardType: CardType)
  {
    self.configuration = configuration
    self.session = AuthenticatingSession(configuration: configuration)
    
    self.username = username
    self.barcode = barcode
    self.pin = pin
    self.cardType = cardType
    
    self.headerLabel = UILabel()
    
    self.usernameCell = SummaryCell(section: NSLocalizedString("Username", comment: "Title of the section for the user's chosen username"),
                                    cellText: self.username)
    self.barcodeCell = SummaryCell(section: NSLocalizedString("Barcode", comment: "Title of the section for the user's assigned barcode after they register"),
                                    cellText: self.barcode)
    self.pinCell = SummaryCell(section: NSLocalizedString("Pin", comment: "Title of the section for the user's PIN number"),
                               cellText: self.pin)
    
    self.cells = [
      self.usernameCell,
      self.barcodeCell,
      self.pinCell
    ]
    
    super.init(style: .Plain)
    
    self.tableView.separatorStyle = .None
    
    self.navigationItem.hidesBackButton = true
    
    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: NSLocalizedString(
        "Done",
        comment: "A title for a button that sends the user back to wherever the card creator was started from"),
                      style: .Plain,
                      target: self,
                      action: #selector(openCatalog))
    
    self.prepareTableViewCells()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()

    self.title = NSLocalizedString(
      "Your Card Information",
      comment: "A title for a screen informing the user of their library card's information")
    
    switch self.cardType {
    case .Temporary:
      headerLabel.text = NSLocalizedString(
        "We were not able to verify your residential address, so we have issued you a temporary card. Please visit your local " +
        "NYPL branch within 30 days to receive a standard card.",
        comment: "A message telling the user she'll get a 30-day library card")
    case .Standard:
      headerLabel.text = NSLocalizedString(
        "Your address will result in a standard three-year ebook-only library card." +
        " Be sure to keep your username and PIN in a safe location.",
        comment: "A message telling the user she'll get a 3-year library card")
    default:
      headerLabel.text = NSLocalizedString(
        "Your digital library card has been created. Be sure to keep your username and PIN in a safe location.",
        comment: "Title describing to the user that they have successfully created a card and can save their information for their records.")
    }
    
    headerLabel.numberOfLines = 0
    headerLabel.lineBreakMode = .ByWordWrapping
    headerLabel.textColor = UIColor.darkGrayColor()
    headerLabel.textAlignment = .Center
    
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
  
  override func viewDidAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.configuration.completionHandler(username: self.username, PIN: self.pin, userInitiated: false)
  }
  
  private func prepareTableViewCells() {
    for cell in self.cells {
      cell.backgroundColor = UIColor.clearColor()
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
    return UITableViewAutomaticDimension
  }
  
  // MARK: -
  
  @objc private func openCatalog() {
    self.configuration.completionHandler(username: self.username, PIN: self.pin, userInitiated: true)
  }
}
