import UIKit

/// This class is used for summarizing the user's registered credentials
/// after successfully creating a library card.
final class UserCredentialsViewController: TableViewController {
  fileprivate var cells: [UITableViewCell]
  fileprivate let headerLabel: UILabel
  fileprivate let cardType: CardType
  
  fileprivate let configuration: CardCreatorConfiguration
  fileprivate let session: AuthenticatingSession
  
  fileprivate let usernameCell: UITableViewCell
  fileprivate let barcodeCell: UITableViewCell
  fileprivate let pinCell: UITableViewCell
  
  fileprivate let username: String
  fileprivate let barcode: String?
  fileprivate let pin: String
  
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
    
    super.init(style: .plain)
    
    self.tableView.separatorStyle = .none
    
    self.navigationItem.hidesBackButton = true
    
    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: NSLocalizedString(
        "Done",
        comment: "A title for a button that sends the user back to wherever the card creator was started from"),
                      style: .plain,
                      target: self,
                      action: #selector(openCatalog))
    
    self.prepareTableViewCells()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.backgroundColor = UIColor.groupTableViewBackground

    self.title = NSLocalizedString(
      "Your Card Information",
      comment: "A title for a screen informing the user of their library card's information")
    
    switch self.cardType {
    case .temporary:
      headerLabel.text = NSLocalizedString(
        "We were not able to verify your residential address, so we have issued you a temporary card. Please visit your local " +
        "NYPL branch within 30 days to receive a standard card.",
        comment: "A message telling the user she'll get a 30-day library card")
    case .standard:
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
    headerLabel.lineBreakMode = .byWordWrapping
    headerLabel.textColor = UIColor.darkGray
    headerLabel.textAlignment = .center
    
    self.tableView.estimatedRowHeight = 120
    self.tableView.allowsSelection = false
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.configuration.completionHandler(self.username, self.pin, false)
  }
  
  fileprivate func prepareTableViewCells() {
    for cell in self.cells {
      cell.backgroundColor = UIColor.clear
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
    return self.cells.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return self.cells[indexPath.section]
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 44
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return UITableView.automaticDimension
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let containerView = UIView()
    containerView.addSubview(self.headerLabel)
    self.headerLabel.autoPinEdge(toSuperviewMargin: .left)
    self.headerLabel.autoPinEdge(toSuperviewMargin: .right)
    self.headerLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
    self.headerLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
    return containerView
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0
  }
  
  func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  // MARK: -
  
  @objc fileprivate func openCatalog() {
    self.configuration.completionHandler(self.username, self.pin, true)
  }
}
