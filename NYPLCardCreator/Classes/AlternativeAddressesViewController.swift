import UIKit

/// This class is used to display a list of addresses suggested by the server so
/// that the user can choose the correct address.
final class AlternativeAddressesViewController: TableViewController {
  private let addressStep: AddressStep
  private let alternativeAddressesAndCardTypes: [(Address, CardType)]
  private let headerLabel: UILabel
  
  private let configuration: CardCreatorConfiguration
  
  private static let addressCellReuseIdentifier = "addressCellReuseIdentifier"
  
  init(
    configuration: CardCreatorConfiguration,
    addressStep: AddressStep,
    alternativeAddressesAndCardTypes: [(Address, CardType)])
  {
    self.configuration = configuration
    self.addressStep = addressStep
    self.alternativeAddressesAndCardTypes = alternativeAddressesAndCardTypes
    
    self.headerLabel = UILabel()
    
    super.init(style: .Grouped)
    
    self.tableView.registerClass(
      AddressCell.self,
      forCellReuseIdentifier: AlternativeAddressesViewController.addressCellReuseIdentifier)
    
    // Estimated cell height obtained via debugging. This must be set in order for the cells
    // to be sized automatically via `UITableViewAutomaticDimension` (which is the default).
    self.tableView.estimatedRowHeight = 104
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    headerLabel.numberOfLines = 0
    headerLabel.lineBreakMode = .ByWordWrapping
    headerLabel.textColor = UIColor.darkGrayColor()
    headerLabel.textAlignment = .Center
    
    switch self.addressStep {
    case .Home:
      self.title = NSLocalizedString(
        "Choose Home Address",
        comment: "A title for a screen asking the user to choose their home address from a list")
    case .School:
      self.title = NSLocalizedString(
        "Choose School Address",
        comment: "A title for a screen asking the user to choose their school address from a list")
    case .Work:
      self.title = NSLocalizedString(
        "Choose Work Address",
        comment: "A title for a screen asking the user to choose their work address from a list")
    }
    
    self.headerLabel.text = NSLocalizedString(
      ("The address you entered matches more than one location. Please choose the correct address "
        + "from the list below."),
      comment: "A message telling the user to pick the correct address")
    
    self.tableView.tableHeaderView = headerLabel
  }
  
  override func viewDidLayoutSubviews() {
    let origin_x = self.tableView.tableHeaderView!.frame.origin.x
    let origin_y = self.tableView.tableHeaderView!.frame.origin.y
    let size = self.tableView.tableHeaderView!.sizeThatFits(CGSize(width: self.view.bounds.width, height: CGFloat.max))
    
    let adjustedWidth = (size.width > CGFloat(375)) ? CGFloat(375.0) : size.width
    let padding = CGFloat(30.0)
    headerLabel.frame = CGRect(x: origin_x, y: origin_y, width: adjustedWidth, height: size.height + padding)
    
    self.tableView.tableHeaderView = self.headerLabel
  }
  
  // MARK: UITableViewDelegate
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let (address, cardType) = self.alternativeAddressesAndCardTypes[indexPath.row]
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
    return self.alternativeAddressesAndCardTypes.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let addressCell = tableView.dequeueReusableCellWithIdentifier(
      AlternativeAddressesViewController.addressCellReuseIdentifier,
      forIndexPath: indexPath)
      as! AddressCell
    addressCell.address = self.alternativeAddressesAndCardTypes[indexPath.row].0
    return addressCell
  }
}
