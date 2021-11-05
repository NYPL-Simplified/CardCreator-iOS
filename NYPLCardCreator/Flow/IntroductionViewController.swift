import PureLayout
import UIKit
import CoreGraphics

/// The first step in the card registration flow.
final class IntroductionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  private let configuration: CardCreatorConfiguration
  private let descriptionLabel: UILabel
  private var attestationVerified: Bool
  private var eulaVerified: Bool
  private var tableView: UITableView!
  private let authToken: ISSOToken

  public init(configuration: CardCreatorConfiguration,
              authToken: ISSOToken)
  {
    self.configuration = configuration
    self.descriptionLabel = UILabel()
    self.attestationVerified = false
    self.eulaVerified = false
    self.authToken = authToken
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = configuration.localizedStrings.welcomeTitle
    self.view.backgroundColor = NYPLColor.primaryBackgroundColor
    
    self.tableView = UITableView.init(frame: view.frame, style: .grouped)
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.tableView.allowsMultipleSelection = true
    self.view.addSubview(self.tableView)
    self.tableView.autoPinEdgesToSuperviewEdges()
    
    self.setupCustomViews()
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: NSLocalizedString("Next", comment: "A title for a button that goes to the next screen"),
      style: .plain,
      target: self,
      action: #selector(didSelectNext))
  }
  
  private func setupCustomViews() {
    self.descriptionLabel.textColor = NYPLColor.primaryTextColor
    self.descriptionLabel.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
    self.descriptionLabel.numberOfLines = 0
    self.descriptionLabel.text = configuration.localizedStrings.featureRequirements
  }
  
  // MARK: - TableView Delegate Methods
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()

    if (indexPath.section == 0) {
      if indexPath.row == 0 && !configuration.isJuvenile {
        cell.textLabel?.text = configuration.localizedStrings.attestationDecline
      } else {
        cell.textLabel?.text = configuration.localizedStrings.attestationConfirm
      }
    } else {
      let eula = NSLocalizedString("I have read and agree to the End User License Agreement", comment: "Statement that the user will check if they agree to the terms of the agreement.")
      var disclaimer = ""
      if configuration.isJuvenile {
        disclaimer = NSLocalizedString("and the Legal Disclaimer", comment: "addendum to EULA text to mention the legal disclaimer for juvenile card creation")
      }
      cell.textLabel?.text = "\(eula) \(disclaimer)"
    }
    cell.textLabel?.numberOfLines = 0
    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .callout)
    setCheckmark(false, forCell: cell)
    cell.selectionStyle = .none
    
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 && !configuration.isJuvenile {
      return 2
    } else {
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return 80
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
    return 80
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      let containerView = UIView()
      containerView.addSubview(self.descriptionLabel)
      self.descriptionLabel.autoPinEdges(toSuperviewMarginsExcludingEdge: .bottom)
      self.descriptionLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 8)
      return containerView
    } else {
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView,
                 viewForFooterInSection section: Int) -> UIView? {

    guard section == 1 else {
      return nil
    }

    let linkColor = NYPLColor.actionColor
    let eulaButton = UIButton()
    eulaButton.setTitle(NSLocalizedString("End User License Agreement", comment: "Title of button for EULA"), for: .normal)
    eulaButton.setTitleColor(linkColor, for: .normal)
    eulaButton.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
    eulaButton.addTarget(self,
                         action: #selector(eulaPressed(_:)),
                         for: .touchUpInside)

    let arrangedViews: [UIView]
    if configuration.isJuvenile {
      let disclaimerButton = UIButton()
      disclaimerButton.setTitle(NSLocalizedString("Legal Disclaimer", comment: "Title of legal disclaimer action for juvenile card creation"), for: .normal)
      disclaimerButton.setTitleColor(linkColor, for: .normal)
      disclaimerButton.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
      disclaimerButton.addTarget(self,
                                 action: #selector(disclaimerPressed),
                                 for: .touchUpInside)
      arrangedViews = [eulaButton, disclaimerButton]
    } else {
      arrangedViews = [eulaButton]
    }

    let containerView = UIStackView(arrangedSubviews: arrangedViews)
    containerView.axis = .vertical
    containerView.alignment = .center
    containerView.spacing = 5
    containerView.isLayoutMarginsRelativeArrangement = true
    containerView.layoutMargins = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)

    return containerView
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let selectedCell = tableView.cellForRow(at: indexPath)
    setCheckmark(true, forCell: selectedCell)

    if indexPath.section == 0 {
      if configuration.isJuvenile {
        didConfirmAttestation()
      } else {
        var altIndexPath: IndexPath
        if (indexPath.row == 0) {
          self.didDenyAttestation()
          altIndexPath = IndexPath(row: 1, section: 0)
          let cell = tableView.cellForRow(at: altIndexPath)
          setCheckmark(false, forCell: cell)
          self.tableView.deselectRow(at: altIndexPath, animated: true)
        } else {
          self.didConfirmAttestation()
          altIndexPath = IndexPath(row: 0, section: 0)
          let cell = tableView.cellForRow(at: altIndexPath)
          setCheckmark(false, forCell: cell)
          self.tableView.deselectRow(at: altIndexPath, animated: true)
        }
        _ = tableView.cellForRow(at: altIndexPath)
      }
    } else {
      self.eulaVerified = true
    }
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      if configuration.isJuvenile {
        let cell = tableView.cellForRow(at: indexPath)
        setCheckmark(false, forCell: cell)
        didDenyAttestation()
      }
    } else {
      let cell = tableView.cellForRow(at: indexPath)
      setCheckmark(false, forCell: cell)
      self.eulaVerified = false
    }
  }
  
  // MARK: -
  
  @objc private func eulaPressed(_ sender: Any) {
    let vc = RemoteHTMLViewController(URL: URL.init(string: "https://www.librarysimplified.org/EULA")!, title: "EULA", failureMessage: nil)
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  @objc private func disclaimerPressed(_ sender: Any) {
    let msg = NSLocalizedString("""
    I understand that the ecard will be valid for 3 years. After that time, \
    I am required to renew the ecard. I understand that if the Library \
    determines I am not the parent / legal guardian of the minor(s) I created \
    a library ecard account for, the Library will deactivate the ecard account.

    For more information, please see:
    www.nypl.org/help/library-card/terms-conditions.
    """, comment: "Body of the legal disclaimer for juvenile card creation")
    let alert = UIAlertController(title: NSLocalizedString("Legal Disclaimer", comment: "Title of legal disclaimer action for juvenile card creation"),
                                  message: msg,
                                  preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    alert.view.isUserInteractionEnabled = true
    present(alert, animated: true, completion: nil)
  }

  @objc private func didSelectNext() {
    if (attestationVerified && eulaVerified) {
      self.navigationController?.pushViewController(
      LocationViewController(configuration: self.configuration, authToken: authToken),
      animated: true)
    } else if (!attestationVerified && eulaVerified) {
      attestationAlert()
    } else {
      eulaAlert()
    }
  }
  
  private func didConfirmAttestation() {
    self.attestationVerified = true
  }
  
  private func didDenyAttestation() {
    self.attestationVerified = false
    attestationAlert()
  }
  
  private func setCheckmark(_ state: Bool, forCell cell: UITableViewCell?) {
    let bundle = Bundle(for: type(of: self))
    if (state == true) {
      let image = UIImage(named: "CheckboxOn", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
      let imageView = UIImageView(image: image)
      imageView.tintColor = NYPLColor.primaryTextColor
      cell?.accessoryView = imageView
      cell?.accessibilityLabel = NSLocalizedString("Checkbox is marked", comment: "Accessible label for the current status of the item")
      cell?.accessibilityHint = NSLocalizedString("Select to remove the checkmark", comment: "Accessible label to help give context to the item")
    } else {
      let image = UIImage(named: "CheckboxOff", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
      let imageView = UIImageView(image: image)
      imageView.tintColor = NYPLColor.primaryTextColor
      cell?.accessoryView = imageView
      cell?.accessibilityLabel = NSLocalizedString("Checkbox is not marked", comment: "Accessible label for the current status of the item")
      cell?.accessibilityHint = NSLocalizedString("Select to add a checkmark", comment: "Accessible label to help give context to the item")
    }
  }
  
  private func attestationAlert() {
    let alertController = UIAlertController(
      title: configuration.localizedStrings.attestationRequirementTitle,
      message: configuration.localizedStrings.attestationRequirementMessage,
      preferredStyle: .alert)
    alertController.addAction(UIAlertAction(
      title: NSLocalizedString("OK", comment: ""),
      style: .default,
      handler: nil))
    DispatchQueue.main.async { 
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  private func eulaAlert() {
    let alertController = UIAlertController(
      title: NSLocalizedString(
        "EULA Requirement",
        comment: "An alert title indicating that the user has encountered a requirement not met"),
      message: NSLocalizedString(
        "You must agree to the EULA in order to create an account.",
        comment: "An alert message telling the user they must accept the EULA in order to sign up for a library card"),
      preferredStyle: .alert)
    alertController.addAction(UIAlertAction(
      title: NSLocalizedString("OK", comment: ""),
      style: .default,
      handler: nil))
    self.present(alertController, animated: true, completion: nil)
  }
}
