import UIKit

/// This class presents a `UIActivityIndicatorView` adjacent to a `UILabel`. It is meant
/// to be used as a title view when the UI is disabled due to an action in progress (as
/// demonstrated in Apple's Settings application).
class ActivityTitleView: UIView {
  
  init(title: String) {
    super.init(frame: CGRectZero)
    
    let padding: CGFloat = 5.0
    
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    activityIndicatorView.startAnimating()
    self.addSubview(activityIndicatorView)
    activityIndicatorView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Right)
    
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    titleLabel.sizeToFit()
    self.addSubview(titleLabel)
    titleLabel.autoPinEdge(.Left, toEdge: .Right, ofView: activityIndicatorView, withOffset: padding)
    titleLabel.autoPinEdgeToSuperviewEdge(.Top)
    titleLabel.autoPinEdgeToSuperviewEdge(.Bottom)
    
    // This view is used to keep the title label centered as in Apple's Settings application.
    let rightPaddingView = UIView(frame:activityIndicatorView.bounds)
    self.addSubview(rightPaddingView)
    rightPaddingView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Left)
    rightPaddingView.autoPinEdge(.Left, toEdge: .Right, ofView: titleLabel, withOffset: padding)
    
    self.frame.size = self.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
