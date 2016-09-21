import UIKit

/// This class is similar to `UITableViewController` except it is not broken on iOS 8 and it
/// does not implement a refresh control.
///
/// On iOS 8, `UITableViewController` has a bug where `init(style:)` will inappropriately
/// call `init(nibName:bundle:)` on `self`. This makes subclassing `UITableViewController`
/// impossible if you wish to provide a new non-zero-argument initializer that sets instance
/// variables because you *must* implement `init(nibName:bundle:)` or you'll get a crash at
/// runtime and there's no way to pass `init(nibName:bundle:)` the arguments you need.
///
/// See http://stackoverflow.com/a/30719434 for more information.
class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
  let tableView: UITableView
  
  init(style: UITableViewStyle) {
    self.tableView = UITableView(frame: CGRectZero, style: style)
    super.init(nibName: nil, bundle: nil)
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.view = self.tableView
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: UITableViewDataSource
  
  /// This should be overridden in all subclasses.
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  /// This should be overridden in all subclasses.
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    return UITableViewCell()
  }
}
