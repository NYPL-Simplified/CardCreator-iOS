import UIKit

class AlternativeAddressesViewController: UITableViewController {
  private let addressType: AddressViewController.AddressType
  private let alternativeAddressesAndCardTypes: [(Address, ValidateAddressResponse.CardType)]

  private static let addressCellReuseIdentifier = "addressCellReuseIdentifier"
  
  init(addressType: AddressViewController.AddressType,
       alternativeAddressesAndCardTypes: [(Address, ValidateAddressResponse.CardType)])
  {
    self.addressType = addressType
    self.alternativeAddressesAndCardTypes = alternativeAddressesAndCardTypes
    
    super.init(style: .Grouped)
    
    self.tableView.registerClass(
      AddressCell.self,
      forCellReuseIdentifier: AlternativeAddressesViewController.addressCellReuseIdentifier)
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // MARK: - Table view data source
  
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
