import UIKit

class FormTableViewController: UITableViewController, UITextFieldDelegate {
  let cells: [UITableViewCell]
  
  init(cells: [UITableViewCell]) {
    self.cells = cells
    super.init(style: .Grouped)
    
    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: NSLocalizedString("Next", comment: "A title for a button that goes to the next screen"),
                      style: .Plain,
                      target: self,
                      action: #selector(didSelectNext))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func returnToolbar() -> UIToolbar {
    let flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    let nextBarButtonItem = UIBarButtonItem(
      title: NSLocalizedString("Return", comment: "The title of the button that goes to the next line in a form"),
      style: .Plain,
      target: self,
      action: #selector(advanceToNextTextField))
    
    let toolbar = UIToolbar()
    toolbar.setItems([flexibleSpaceBarButtonItem, nextBarButtonItem], animated: false)
    toolbar.sizeToFit()
    
    return toolbar
  }
  
  @objc private func advanceToNextTextField() {
    var firstResponser: LabelledTextViewCell? = nil
    
    for cell in self.cells {
      if let labelledTextViewCell = cell as? LabelledTextViewCell {
        // Skip fields that are not enabled, e.g. the region field when entering school
        // or work addresses.
        if firstResponser != nil && labelledTextViewCell.textField.userInteractionEnabled {
          labelledTextViewCell.textField.becomeFirstResponder()
          return
        }
        if labelledTextViewCell.textField.isFirstResponder() {
          firstResponser = labelledTextViewCell
        }
      }
    }
    
    firstResponser?.textField.resignFirstResponder()
  }
  
  // MARK: UITableViewDataSource
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.cells.count
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return self.cells[indexPath.row]
  }
  
  // MARK: UITextFieldDelegate
  
  @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
    self.advanceToNextTextField()
    return true
  }
  
  // MARK: -
  
  /// Override in subclasses.
  func didSelectNext() {
    
  }
  
  func showActivityTitleView(title: String) {
    let padding: CGFloat = 5.0
    
    let containerView = UIView()
    
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    activityIndicatorView.startAnimating()
    containerView.addSubview(activityIndicatorView)
    activityIndicatorView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Right)
    
    let titleLabel = UILabel()
    titleLabel.text = title
    titleLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    titleLabel.sizeToFit()
    containerView.addSubview(titleLabel)
    titleLabel.autoPinEdge(.Left, toEdge: .Right, ofView: activityIndicatorView, withOffset: padding)
    titleLabel.autoPinEdgeToSuperviewEdge(.Top)
    titleLabel.autoPinEdgeToSuperviewEdge(.Bottom)
    
    // This view is used to keep the title label centered as in Apple's Settings application.
    let rightPaddingView = UIView(frame:activityIndicatorView.bounds)
    containerView.addSubview(rightPaddingView)
    rightPaddingView.autoPinEdgesToSuperviewEdgesWithInsets(UIEdgeInsetsZero, excludingEdge: .Left)
    rightPaddingView.autoPinEdge(.Left, toEdge: .Right, ofView: titleLabel, withOffset: padding)
    
    containerView.frame.size = containerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    
    self.navigationItem.titleView = containerView
  }
}
