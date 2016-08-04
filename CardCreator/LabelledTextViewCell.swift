import PureLayout
import UIKit

final class LabelledTextViewCell: UITableViewCell
{
  let label: UILabel
  let textField: UITextField
  
  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    self.label = UILabel()
    self.textField = UITextField()
    
    super.init(style: .Default, reuseIdentifier: reuseIdentifier)
    
    self.label.autoSetDimension(.Width, toSize: 100)
    
    self.textField.leftView = label
    self.textField.leftViewMode = .Always
    self.addSubview(self.textField)
    self.textField.autoPinEdgeToSuperviewEdge(.Left, withInset: 15)
    self.textField.autoPinEdgeToSuperviewEdge(.Right, withInset: 15)
    self.textField.autoCenterInSuperview()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
