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
    self.continueButton.setTitle(
      NSLocalizedString(
        "Continue",
        comment: "A button that lets the user go to the next section or screen"),
      forState: .Normal)
  }
}
