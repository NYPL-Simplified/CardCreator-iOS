import UIKit

class LocationViewController: UIViewController {
  
  let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
  var observers: [NSObjectProtocol] = []
  let resultLabel = UILabel()
  var placemarkQuery: PlacemarkQuery? = nil
  var viewDidAppearPreviously: Bool = false

  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  deinit {
    for observer in self.observers {
      NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.title = NSLocalizedString(
      "Location Check",
      comment: "A title telling the user the app needs to check their location")
    
    self.view.backgroundColor = UIColor.whiteColor()
    
    self.view.addSubview(self.activityIndicatorView)
    self.activityIndicatorView.autoCenterInSuperview()
    
    self.view.addSubview(self.resultLabel)
    self.resultLabel.hidden = true
    self.resultLabel.autoPinEdgesToSuperviewMargins()
    self.resultLabel.numberOfLines = 0
    self.resultLabel.textColor = UIColor.darkGrayColor()
    self.resultLabel.textAlignment = .Center
    
    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: NSLocalizedString("Next", comment: "A title for a button that goes to the next screen"),
                      style: .Plain,
                      target: self,
                      action: #selector(didSelectNext))
    self.navigationItem.rightBarButtonItem?.enabled = false
   
    // We need to check again in case the user has gone to Settings to enable location services.
    self.observers.append(
      NSNotificationCenter.defaultCenter().addObserverForName(
        UIApplicationDidBecomeActiveNotification,
        object: nil,
        queue: NSOperationQueue.mainQueue(),
        usingBlock: { _ in
          if !(self.navigationItem.rightBarButtonItem?.enabled)! {
            self.checkLocation()
          }}))
  }
  
  override func viewDidAppear(animated: Bool) {
    if self.viewDidAppearPreviously {
      return
    }
    self.viewDidAppearPreviously = true
    self.checkLocation()
  }
  
  @objc private func didSelectNext() {
    self.navigationController?.pushViewController(AddressViewController(), animated: true)
  }
  
  private func checkLocation() {
    self.resultLabel.hidden = true
    self.activityIndicatorView.startAnimating()
    self.placemarkQuery = PlacemarkQuery()
    self.placemarkQuery!.startWithHandler { result in
      self.resultLabel.hidden = false
      self.activityIndicatorView.stopAnimating()
      switch result {
      case let .ErrorAlertController(alertController):
        self.resultLabel.text = NSLocalizedString(
          "Your location could not be determined. Please try again later.",
          comment: "A label title informing the user that their location could not be determined")
        self.presentViewController(alertController, animated: true, completion: nil)
      case let .Placemark(placemark):
        if placemark.administrativeArea == "NY" {
          self.navigationItem.rightBarButtonItem?.enabled = true
          self.resultLabel.text = NSLocalizedString(
            "We have successfully determined that you are in New York!",
            comment: "A label title informing the user that their location is acceptable")
        } else {
          self.resultLabel.text = NSLocalizedString(
            ("You must be in New York to sign up for a library card. "
              + " Please try to sign up again when you are in another location."),
            comment: "A label title informing the user that their location is not acceptable")
        }
      }
    }
  }
}
