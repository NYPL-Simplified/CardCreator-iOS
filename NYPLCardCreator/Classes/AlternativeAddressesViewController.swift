import UIKit

/// This class is used to display a list of addresses suggested by the server so
/// that the user can choose the correct address.
final class AlternativeAddressesViewController: TableViewController {
  private let addressStep: AddressStep
  private let alternativeAddressesAndCardTypes: [(Address, CardType)]
  
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
    
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view!.bounds.size.width, height: 80.0))
    let headerLabel = UILabel()
    headerView.addSubview(headerLabel)
    
    headerLabel.autoPinEdgeToSuperviewEdge(.Left, withInset: 22.0)
    headerLabel.autoPinEdgeToSuperviewEdge(.Right, withInset: 22.0)
    headerLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 2.0)
    headerLabel.autoPinEdgeToSuperviewEdge(.Bottom, withInset: 2.0)
    
    headerLabel.numberOfLines = 2
    headerLabel.textColor = UIColor.darkGrayColor()
    headerLabel.textAlignment = .Center
    
    self.tableView.tableHeaderView = headerView
    
    switch self.addressStep {
    case .Home:
      headerLabel.text = "Select the correct home address, or go back to make changes."
      self.title = NSLocalizedString(
        "Choose Home Address",
        comment: "A title for a screen asking the user to choose their home address from a list")
    case .School:
      headerLabel.text = "Select the correct school address, or go back to make changes."
      self.title = NSLocalizedString(
        "Choose School Address",
        comment: "A title for a screen asking the user to choose their school address from a list")
    case .Work:
      headerLabel.text = "Select the correct work address, or go back to make changes."
      self.title = NSLocalizedString(
        "Choose Work Address",
        comment: "A title for a screen asking the user to choose their work address from a list")
    }
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
