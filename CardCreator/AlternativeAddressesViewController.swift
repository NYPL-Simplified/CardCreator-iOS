import UIKit

class AlternativeAddressesViewController: UITableViewController {
  private let addressStep: AddressStep
  private let alternativeAddressesAndCardTypes: [(Address, ValidateAddressResponse.CardType)]

  private static let addressCellReuseIdentifier = "addressCellReuseIdentifier"
  
  init(addressStep: AddressStep,
       alternativeAddressesAndCardTypes: [(Address, ValidateAddressResponse.CardType)])
  {
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
