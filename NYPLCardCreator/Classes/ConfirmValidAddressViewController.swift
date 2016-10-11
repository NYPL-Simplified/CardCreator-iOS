import UIKit

/// This class is used to display the address listed as valid by the server
/// for the user to confirm.
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
        switch self.addressStep {
            //GODO could potentially change localized string to "confirm ____ address"
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
