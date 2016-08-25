import PureLayout
import UIKit

final class IntroductionViewController: UIViewController {
  
  let containerView: UIView
  let continueButton: UIButton
  let descriptionLabel: UILabel

  init() {
    containerView = UIView()
    continueButton = UIButton(type: .System)
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
    
    self.view.addSubview(self.containerView)
    
    self.containerView.autoAlignAxisToSuperviewAxis(.Horizontal)
    self.containerView.autoPinEdgeToSuperviewMargin(.Left)
    self.containerView.autoPinEdgeToSuperviewMargin(.Right)
    self.containerView.addSubview(self.descriptionLabel)
    self.containerView.addSubview(self.continueButton)
    
    self.descriptionLabel.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Bottom)
    self.descriptionLabel.textColor = UIColor.darkGrayColor()
    self.descriptionLabel.textAlignment = .Center
    self.descriptionLabel.numberOfLines = 0
    self.descriptionLabel.text =
      NSLocalizedString(
        ("In order to obtain a library card, you must dolor sit amet, consectetur adipiscing elit. "
          + "Phasellus sagittis augue sed nisl tincidunt pulvinar vitae eget nulla. Suspendisse ante "
          + "purus, semper a tortor et, semper ornare augue."),
        comment: "A description of what is required to get a library card")
    
    self.continueButton.autoAlignAxisToSuperviewAxis(.Vertical)
    self.continueButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.descriptionLabel, withOffset: 8)
    self.continueButton.autoPinEdgeToSuperviewEdge(.Bottom)
    self.continueButton.addTarget(self, action: #selector(didSelectContinue), forControlEvents: .PrimaryActionTriggered)
    self.continueButton.setTitle(
      NSLocalizedString(
        "Continue",
        comment: "A button that lets the user go to the next section or screen"),
      forState: .Normal)
  }
  
  @objc private func didSelectContinue() {
    let alertController = UIAlertController(
      title: NSLocalizedString(
        "Age Verification",
        comment: "An alert title indicating the user needs to verify their age"),
      message: NSLocalizedString(
        "You must be 13 years of age or older to sign up for a library card. How old are you?",
        comment: "An alert message telling the user they must be at least 13 years old and asking how old they are"),
      preferredStyle: .Alert)
    alertController.addAction(UIAlertAction(
      title: "13 or Older",
      style: .Default,
      handler: { _ in self.didSelect13OrOlder()}))
    alertController.addAction(UIAlertAction(
      title: "Under 13",
      style: .Cancel,
      handler: { _ in self.didSelectUnder13()}))
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  
  private func didSelect13OrOlder() {
    self.navigationController?.pushViewController(LocationViewController(), animated: true)
  }
  
  private func didSelectUnder13() {
    
  }
}
