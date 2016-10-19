import UIKit

/// A subclass of `UITableViewCell` that displays an address and section title within its content view.
final class SummaryAddressCell: UITableViewCell {
  
  let sectionLabel, street1Label, street2Label, cityLabel, regionLabel, zipLabel: UILabel
  
  private var addressValue: Address?
  var address: Address? {
    get {
      return self.addressValue
    }
    set {
      self.addressValue = newValue
      self.street1Label.text = newValue?.street1
      self.street2Label.text = newValue?.street2
      self.cityLabel.text = newValue?.city
      if let region = newValue?.region {
        self.regionLabel.text = ", \(region) "
      }
      self.zipLabel.text = newValue?.zip
    }
  }
  //GODO ready to test this
  init(section: String, style: UITableViewCellStyle, reuseIdentifier: String?) {
    self.sectionLabel = UILabel()
    self.street1Label = UILabel()
    self.street2Label = UILabel()
    self.cityLabel = UILabel()
    self.regionLabel = UILabel()
    self.zipLabel = UILabel()
    
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    self.contentView.backgroundColor = UIColor.clearColor()
    
//    let font = UIFont(name: "AvenirNext-Regular", size: 18)
    
    //GODO style labels
    self.sectionLabel.text = section
    self.sectionLabel.text  = self.sectionLabel.text?.uppercaseString
    self.sectionLabel.textColor = UIColor.darkGrayColor()
    self.sectionLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
    
//    self.street1Label.font = font
//    self.street2Label.font = font
//    self.cityLabel.font = font
//    self.regionLabel.font = font
//    self.zipLabel.font = font
    
    self.contentView.addSubview(self.sectionLabel)
    self.sectionLabel.autoPinEdgeToSuperviewMargin(.Left)
    self.sectionLabel.autoPinEdgeToSuperviewMargin(.Right)
    //GODO kluge
    if (section == "Home Address") {
    self.sectionLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 2)
    } else {
      self.sectionLabel.autoPinEdgeToSuperviewEdge(.Top, withInset: 12)
    }
    
    self.contentView.addSubview(self.street1Label)
    self.street1Label.autoPinEdgeToSuperviewMargin(.Left)
    self.street1Label.autoPinEdgeToSuperviewMargin(.Right)
    self.street1Label.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.sectionLabel, withOffset: 2)
    
    self.contentView.addSubview(self.street2Label)
    self.street2Label.autoPinEdgeToSuperviewMargin(.Left)
    self.street2Label.autoPinEdgeToSuperviewMargin(.Right)
    self.street2Label.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.street1Label)
    
    self.contentView.addSubview(self.cityLabel)
    self.contentView.addSubview(self.regionLabel)
    self.contentView.addSubview(self.zipLabel)
    
    self.cityLabel.autoPinEdgeToSuperviewMargin(.Left)
    self.cityLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.street2Label)
    self.cityLabel.autoPinEdge(.Right, toEdge: .Left, ofView: self.regionLabel)
    self.cityLabel.autoPinEdgeToSuperviewEdge(.Bottom)
    
    self.regionLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.street2Label)
    self.regionLabel.autoPinEdgeToSuperviewEdge(.Bottom)
    
    self.zipLabel.autoPinEdge(.Left, toEdge: .Right, ofView: self.regionLabel)
    self.zipLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.street2Label)
    self.zipLabel.autoPinEdgeToSuperviewEdge(.Bottom)
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
