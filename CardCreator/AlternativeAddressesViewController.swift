import UIKit

class AlternativeAddressesViewController: UITableViewController {
  private let addressStep: AddressStep
  private let alternativeAddressesAndCardTypes: [(Address, CardType)]

  private static let addressCellReuseIdentifier = "addressCellReuseIdentifier"
  
  let configuration: Configuration
  
  init(
    configuration: Configuration,
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
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
  }
  
  // MARK: UITableViewDelegate
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let (address, cardType) = self.alternativeAddressesAndCardTypes[indexPath.row]
    self.addressStep.continueFlowWithValidAddress(
      self.configuration,
      viewController: self,
      address: address,
      cardType: cardType)
  }
  
  // MARK: UITableViewDataSource
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
