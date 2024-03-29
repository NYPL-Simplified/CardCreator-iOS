import UIKit

/// This class is used to display the address listed as valid by the server
/// for the user to confirm or go back and edit.
final class ConfirmValidAddressViewController: TableViewController {
  fileprivate let addressStep: AddressStep
  fileprivate let validAddressAndCardType: (Address, CardType)
  
  fileprivate let configuration: CardCreatorConfiguration
  fileprivate let authToken: ISSOToken
  
  fileprivate let headerLabel: UILabel
  
  fileprivate static let addressCellReuseIdentifier = "addressCellReuseIdentifier"
  
  init(
    configuration: CardCreatorConfiguration,
    authToken: ISSOToken,
    addressStep: AddressStep,
    validAddressAndCardType: (Address, CardType))
  {
    self.configuration = configuration
    self.authToken = authToken
    self.addressStep = addressStep
    self.validAddressAndCardType = validAddressAndCardType
    
    self.headerLabel = UILabel()

    super.init(style: .grouped)

    self.tableView.register(
      AddressCell.self,
      forCellReuseIdentifier: ConfirmValidAddressViewController.addressCellReuseIdentifier)
    
    // Estimated cell height obtained via debugging. This must be set in order for the cells
    // to be sized automatically via `UITableViewAutomaticDimension` (which is the default).
    self.tableView.estimatedRowHeight = 64
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    headerLabel.numberOfLines = 0
    headerLabel.lineBreakMode = .byWordWrapping
    headerLabel.textColor = NYPLColor.disabledFieldTextColor
    headerLabel.textAlignment = .center

    switch self.addressStep {
    case .home:
      headerLabel.text = NSLocalizedString(
        "Confirm your home address, or go back to make changes.",
        comment: "Description meant to inform user to review their entered information")
    case .school:
      headerLabel.text = NSLocalizedString(
        "Confirm your school address, or go back to make changes.",
        comment: "Description meant to inform user to review their entered information")
    case .work:
      headerLabel.text = NSLocalizedString(
        "Confirm your work address, or go back to make changes.",
        comment: "Description meant to inform user to review their entered information")
    }
    
    self.tableView.allowsSelection = false
    
    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: NSLocalizedString(
        "Confirm",
        comment: "A title for a button that confirms the address after the user has reviewed it"),
                      style: .plain,
                      target: self,
                      action: #selector(addressConfirmed))
  }
  
  // MARK: UITableViewDataSource
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return 44
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let containerView = UIView()
    containerView.addSubview(self.headerLabel)
    self.headerLabel.autoPinEdge(toSuperviewMargin: .left)
    self.headerLabel.autoPinEdge(toSuperviewMargin: .right)
    self.headerLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
    self.headerLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
    return containerView
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let addressCell = tableView.dequeueReusableCell(
      withIdentifier: ConfirmValidAddressViewController.addressCellReuseIdentifier,
      for: indexPath)
      as! AddressCell
    addressCell.address = self.validAddressAndCardType.0
    return addressCell
  }
  
  // MARK: -

  @objc func addressConfirmed() {
    let (address, cardType) = self.validAddressAndCardType
    self.addressStep.continueFlowWithValidAddress(
      self.configuration,
      authToken: authToken,
      viewController: self,
      address: address,
      cardType: cardType)
  }
}
