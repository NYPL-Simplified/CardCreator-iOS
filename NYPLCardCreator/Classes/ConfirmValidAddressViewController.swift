import UIKit

/// This class is used to display the address listed as valid by the server
/// for the user to confirm or go back and edit.
final class ConfirmValidAddressViewController: TableViewController {
  private let addressStep: AddressStep
  private let validAddressAndCardType: (Address, CardType)
  
  private let configuration: CardCreatorConfiguration
  
  private static let addressCellReuseIdentifier = "addressCellReuseIdentifier"
  
  init(
    configuration: CardCreatorConfiguration,
    addressStep: AddressStep,
    validAddressAndCardType: (Address, CardType))
  {
    self.configuration = configuration
    self.addressStep = addressStep
    self.validAddressAndCardType = validAddressAndCardType
    
    super.init(style: .Grouped)

    self.tableView.registerClass(
      AddressCell.self,
      forCellReuseIdentifier: ConfirmValidAddressViewController.addressCellReuseIdentifier)
    
    // Estimated cell height obtained via debugging. This must be set in order for the cells
    // to be sized automatically via `UITableViewAutomaticDimension` (which is the default).
    self.tableView.estimatedRowHeight = 104
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let headerLabel = UILabel()
    headerLabel.numberOfLines = 0
    headerLabel.lineBreakMode = .ByWordWrapping
    headerLabel.textColor = UIColor.darkGrayColor()
    headerLabel.textAlignment = .Center

    switch self.addressStep {
    case .Home:
      headerLabel.text = NSLocalizedString(
        "Select your home address, or go back to make changes.",
        comment: "Description meant to inform user to review their entered information")
      self.title = NSLocalizedString(
        "Confirm",
        comment: "A title for a screen asking the user to confirm their home address")
    case .School:
      headerLabel.text = NSLocalizedString(
        "Select your school address, or go back to make changes.",
        comment: "Description meant to inform user to review their entered information")
      self.title = NSLocalizedString(
        "Confirm",
        comment: "A title for a screen asking the user to confirm their school address")
    case .Work:
      headerLabel.text = NSLocalizedString(
        "Select your work address, or go back to make changes.",
        comment: "Description meant to inform user to review their entered information")
      self.title = NSLocalizedString(
        "Confirm",
        comment: "A title for a screen asking the user to confirm their work address")
    }
    
    self.tableView.tableHeaderView = headerLabel
  }
  
  override func viewDidLayoutSubviews() {
    
    //GODO still need to look at this
    let origin_x = self.tableView.tableHeaderView!.frame.origin.x
    let origin_y = self.tableView.tableHeaderView!.frame.origin.y
    let size = self.tableView.tableHeaderView!.sizeThatFits(CGSizeMake(self.view.bounds.width, CGFloat.max))
    self.tableView.tableHeaderView?.frame = CGRectMake(origin_x, origin_y, size.width, size.height + 30.0)

  }
  
  // MARK: UITableViewDelegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let (address, cardType) = self.validAddressAndCardType
    self.addressStep.continueFlowWithValidAddress(
      self.configuration,
      viewController: self,
      address: address,
      cardType: cardType)
  }
  
  // MARK: UITableViewDataSource
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let addressCell = tableView.dequeueReusableCellWithIdentifier(
      ConfirmValidAddressViewController.addressCellReuseIdentifier,
      forIndexPath: indexPath)
      as! AddressCell
    addressCell.address = self.validAddressAndCardType.0
    return addressCell
  }
}
