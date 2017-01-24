import PureLayout
import UIKit
import CoreGraphics

/// The first step in the card registration flow.
final class IntroductionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  fileprivate let configuration: CardCreatorConfiguration
  fileprivate let descriptionLabel: UILabel
  fileprivate var ageVerified: Bool
  fileprivate var eulaVerified: Bool
  fileprivate var tableView: UITableView!

  public init(configuration: CardCreatorConfiguration) {
    self.configuration = configuration
    self.descriptionLabel = UILabel()
    self.ageVerified = false
    self.eulaVerified = false
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = NSLocalizedString("Sign Up", comment: "A title welcoming the user to library card sign up")
    self.view.backgroundColor = UIColor.white
    
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
  
  fileprivate func setupCustomViews() {
    self.descriptionLabel.textColor = UIColor.darkGray
    self.descriptionLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
    self.descriptionLabel.numberOfLines = 0
    self.descriptionLabel.text =
      NSLocalizedString(
        ("To get a digital library card from the New York Public Library, you must live, work, "
          + "or attend school in New York State. You must also be at least 13 years of age and be "
          + "physically present in New York at the time of sign-up. "
          + "\n\nYou must be at least 13 years of age.\nHow old are you?"),
        comment: "A description of what is required to get a library card")
  }
  
  // MARK: - TableView Delegate Methods
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell()

    if (indexPath.section == 0) {
      switch indexPath.row {
      case 0:
        cell.textLabel?.text = NSLocalizedString("I am under 13", comment: "Title for a user to check when they are under 13 years of age")
      default:
        cell.textLabel?.text = NSLocalizedString("I am 13 or older", comment: "Title for a user to check when they are 13 years of age or older")
      }
    } else {
      cell.textLabel?.text = NSLocalizedString("I agree to the terms of the End User License Agreement", comment: "Statement that the user will check if they agree to the terms of the agreement.")
      cell.textLabel?.numberOfLines = 2
    }
    setCheckmark(false, forCell: cell)
    cell.selectionStyle = .none
    
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 2
    } else {
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return UITableViewAutomaticDimension
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
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if section == 1 {
      let containerView = UIView()
      let button = UIButton()
      containerView.addSubview(button)
      button.setTitle(NSLocalizedString("End User License Agreement", comment: "Title of button for EULA"), for: .normal)
      button.setTitleColor(UIColor.blue, for: .normal)
      button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
      button.addTarget(self, action: #selector(eulaPressed(sender:)), for: .touchUpInside)
      button.autoAlignAxis(toSuperviewAxis: .vertical)
      button.autoPinEdge(toSuperviewEdge: .top, withInset: 8)
      button.autoPinEdges(toSuperviewMarginsExcludingEdge: .top)
      button.autoSetDimension(.height, toSize: 20, relation: .greaterThanOrEqual)
      return containerView
    } else {
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let selectedCell = tableView.cellForRow(at: indexPath)
    setCheckmark(true, forCell: selectedCell)
    
    if (indexPath.section == 0) {
      var altIndexPath: IndexPath
      if (indexPath.row == 0) {
        self.didSelectUnder13()
        altIndexPath = IndexPath(row: 1, section: 0)
        let cell = tableView.cellForRow(at: altIndexPath)
        setCheckmark(false, forCell: cell)
        self.tableView.deselectRow(at: altIndexPath, animated: true)
      } else {
        self.didSelect13OrOlder()
        altIndexPath = IndexPath(row: 0, section: 0)
        let cell = tableView.cellForRow(at: altIndexPath)
        setCheckmark(false, forCell: cell)
        self.tableView.deselectRow(at: altIndexPath, animated: true)
      }
      let altCell = tableView.cellForRow(at: altIndexPath)
    } else {
      self.eulaVerified = true
    }
  }
  
  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    if indexPath.section == 1 {
      let cell = tableView.cellForRow(at: indexPath)
      setCheckmark(false, forCell: cell)
      self.eulaVerified = false
    }
  }
  
  // MARK: -
  
  @objc fileprivate func eulaPressed(sender: Any) {
    let vc = RemoteHTMLViewController(URL: URL.init(string: "http://www.librarysimplified.org/EULA.html")!, title: "EULA", failureMessage: nil)
    self.navigationController?.pushViewController(vc, animated: true)
  }
  
  @objc fileprivate func didSelectNext() {
    if (ageVerified && eulaVerified) {
      self.navigationController?.pushViewController(
      LocationViewController(configuration: self.configuration),
      animated: true)
    } else if (!ageVerified && eulaVerified) {
      ageAlert()
    } else {
      eulaAlert()
    }
  }
  
  fileprivate func didSelect13OrOlder() {
    self.ageVerified = true
  }
  
  fileprivate func didSelectUnder13() {
    self.ageVerified = false
    ageAlert()
  }
  
  fileprivate func setCheckmark(_ state: Bool, forCell cell: UITableViewCell?) {
    if (state == true) {
      cell?.accessoryView = UIImageView(image: UIImage(named: "CheckboxOn"))
      cell?.accessibilityLabel = NSLocalizedString("Checkbox is marked", comment: "Accessible label for the current status of the item")
      cell?.accessibilityHint = NSLocalizedString("Select to remove the checkmark", comment: "Accessible label to help give context to the item")
    } else {
      cell?.accessoryView = UIImageView(image: UIImage(named: "CheckboxOff"))
      cell?.accessibilityLabel = NSLocalizedString("Checkbox is not marked", comment: "Accessible label for the current status of the item")
      cell?.accessibilityHint = NSLocalizedString("Select to add a checkmark", comment: "Accessible label to help give context to the item")
    }
  }
  
  fileprivate func ageAlert() {
    let alertController = UIAlertController(
      title: NSLocalizedString(
        "Age Restriction",
        comment: "An alert title indicating that the user has encountered an age restriction"),
      message: NSLocalizedString(
        "You must be at least 13 years old to sign up for a library card.",
        comment: "An alert message telling the user are not old enough to sign up for a library card"),
      preferredStyle: .alert)
    alertController.addAction(UIAlertAction(
      title: NSLocalizedString("OK", comment: ""),
      style: .default,
      handler: nil))
    DispatchQueue.main.async { 
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  fileprivate func eulaAlert() {
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
