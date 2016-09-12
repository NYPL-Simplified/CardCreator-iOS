import PureLayout
import UIKit

final class IntroductionViewController: UIViewController {
  
  let descriptionLabel: UILabel

  init() {
    descriptionLabel = UILabel()
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.title = NSLocalizedString("Sign Up", comment: "A title welcoming the user to library card sign up")
    
    self.view.backgroundColor = UIColor.whiteColor()
    
    self.view.addSubview(self.descriptionLabel)
    self.descriptionLabel.autoPinEdgesToSuperviewMargins()
    self.descriptionLabel.textColor = UIColor.darkGrayColor()
    self.descriptionLabel.textAlignment = .Center
    self.descriptionLabel.numberOfLines = 0
    self.descriptionLabel.text =
      NSLocalizedString(
        ("To obtain a digital library card from the New York Public Library, you must live, work, "
          + "or attend school in New York State. You must also be at least 13 years of age and be "
          + "physically present in New York at the time of sign-up."),
        comment: "A description of what is required to get a library card")
    
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: NSLocalizedString("Next", comment: "A title for a button that goes to the next screen"),
      style: .Plain,
      target: self,
      action: #selector(didSelectNext))
  }
  
  @objc private func didSelectNext() {
    let alertController = UIAlertController(
      title: NSLocalizedString(
        "Age Verification",
        comment: "An alert title indicating the user needs to verify their age"),
      message: NSLocalizedString(
        "You must be 13 years of age or older to sign up for a library card. How old are you?",
        comment: "An alert message telling the user they must be at least 13 years old and asking how old they are"),
      preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(
      title: NSLocalizedString("13 or Older", comment: "A button title indicating an age range"),
      style: .Default,
      handler: { _ in self.didSelect13OrOlder()}))
    alertController.addAction(UIAlertAction(
      title: NSLocalizedString("Under 13", comment: "A button title indicating an age range"),
      style: .Cancel,
      handler: { _ in self.didSelectUnder13()}))
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  
  private func didSelect13OrOlder() {
    self.navigationController?.pushViewController(LocationViewController(), animated: true)
  }
  
  private func didSelectUnder13() {
    let alertController = UIAlertController(
      title: NSLocalizedString(
        "Age Restriction",
        comment: "An alert title indicating that the user has encountered an age restriction"),
      message: NSLocalizedString(
        "You are not old enough to sign up for a library card.",
        comment: "An alert message telling the user are not old enough to sign up for a library card"),
      preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(
      title: NSLocalizedString("OK", comment: ""),
      style: .Default,
      handler: nil))
    self.presentViewController(alertController, animated: true, completion: nil)
  }
}
