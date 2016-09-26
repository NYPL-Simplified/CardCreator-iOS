import PureLayout
import UIKit

/// A subclass of `UITableViewCell` with a label on the left side and a text field
/// on the right. Metrics are identical to those often used by Apple.
final class LabelledTextViewCell: UITableViewCell
{
  let label: UILabel
  let textField: UITextField
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    self.label = UILabel()
    self.textField = UITextField()
    
    super.init(style: .Default, reuseIdentifier: reuseIdentifier)
    
    if NSProcessInfo().isOperatingSystemAtLeastVersion(
      NSOperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0))
    {
      self.label.autoSetDimension(.Width, toSize: 100)
    } else {
      // The above method does not work correctly on iOS 8 so we do this instead.
      self.label.text = "Temporary"
      let labelSize = self.label.sizeThatFits(CGSizeMake(100, CGFloat.max))
      self.label.frame = CGRectMake(0, 0, labelSize.width, labelSize.height)
      self.label.text = nil
    }
    
    self.textField.leftView = label
    self.textField.leftViewMode = .Always
    self.addSubview(self.textField)
    self.textField.autoPinEdgeToSuperviewEdge(.Left, withInset: 15)
    self.textField.autoPinEdgeToSuperviewEdge(.Right, withInset: 15)
    self.textField.autoCenterInSuperview()
  }
  
  convenience init(title: String?, placeholder: String?) {
    self.init(style: .Default, reuseIdentifier: nil)
    self.label.text = title
    self.textField.placeholder = placeholder
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
