import UIKit

class LocationViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.title = NSLocalizedString(
      "Location Check",
      comment: "A title telling the user the app needs to check their location")
    
    self.view.backgroundColor = UIColor.whiteColor()
  }
}
