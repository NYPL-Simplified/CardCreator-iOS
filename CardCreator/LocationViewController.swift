import UIKit

class LocationViewController: UIViewController {
  
  let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
  let placemarkQuery = PlacemarkQuery()
  var viewDidAppearPreviously: Bool = false
  

  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.title = NSLocalizedString(
      "Location Check",
      comment: "A title telling the user the app needs to check their location")
    
    self.view.backgroundColor = UIColor.whiteColor()
    
    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: NSLocalizedString("Next", comment: "Go to the next screen"),
                      style: .Plain,
                      target: self,
                      action: #selector(didSelectNext))
    self.navigationItem.rightBarButtonItem?.enabled = false
  }
  
  override func viewDidAppear(animated: Bool) {
    if self.viewDidAppearPreviously {
      return
    }
    self.viewDidAppearPreviously = true
    self.placemarkQuery.startWithHandler { result in
      switch result {
      case let .ErrorAlertController(alertController):
        self.presentViewController(alertController, animated: true, completion: nil)
      case let .Placemark(placemark):
        if placemark.administrativeArea == "NY" {
          self.navigationItem.rightBarButtonItem?.enabled = true
        } else {
          
        }
      }
    }
  }
  
  func didSelectNext() {
    
  }
}
