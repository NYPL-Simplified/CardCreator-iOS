import UIKit

/// A subclass of `UITableViewCell` that displays a section title and single line within its content view.
final class SummaryCell: UITableViewCell {
  
  let sectionLabel, cellLabel: UILabel
  
  init(section: String, cellText: String) {
    self.sectionLabel = UILabel()
    self.cellLabel = UILabel()
    
    super.init(style: .Default, reuseIdentifier: nil)
    
    self.contentView.backgroundColor = UIColor.clearColor()
    
    self.sectionLabel.text = section
    self.cellLabel.text = cellText
    
    self.sectionLabel.text  = self.sectionLabel.text?.uppercaseString
    self.sectionLabel.textColor = UIColor.darkGrayColor()
    self.sectionLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
    
    self.contentView.addSubview(self.sectionLabel)
    self.sectionLabel.autoPinEdgeToSuperviewMargin(.Left)
    self.sectionLabel.autoPinEdgeToSuperviewMargin(.Right)
    self.sectionLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 12)
    
    self.contentView.addSubview(self.cellLabel)
    self.cellLabel.autoPinEdgeToSuperviewMargin(.Left)
    self.cellLabel.autoPinEdgeToSuperviewMargin(.Right)
    self.cellLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.sectionLabel, withOffset: 2)
    self.cellLabel.autoPinEdgeToSuperviewEdge(.Bottom)
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
