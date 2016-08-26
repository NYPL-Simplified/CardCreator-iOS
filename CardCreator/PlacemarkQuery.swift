import CoreLocation
import UIKit

class PlacemarkQuery: NSObject, CLLocationManagerDelegate {
  
  enum Result {
    case Placemark(placemark: CLPlacemark)
    case ErrorAlertController(alertController: UIAlertController)
  }
  
  var receivedRecentLocation = false
  var handler: (Result -> Void)? = nil
  let geocoder = CLGeocoder()
  let locationManager = CLLocationManager()
  
  override init() {
    super.init()
    self.locationManager.delegate = self
  }

  /// Due to limitations of CoreLocation, this must only ever be called 
  /// once per `PlacemarkQuery` instance.
  func startWithHandler(handler: Result -> Void) {
    self.handler = handler
    switch CLLocationManager.authorizationStatus() {
    case .AuthorizedAlways:
      fallthrough
    case .AuthorizedWhenInUse:
      self.locationManager.startUpdatingLocation()
    case .Denied:
      let alertController = UIAlertController(
        title: NSLocalizedString("Location Access Disabled",
          comment: "An alert title stating the user has disallowed the app to access the user's location"),
        message: NSLocalizedString(
          ("You must enable location access for this application " +
            "in order to sign up for a library card."),
          comment: "An alert message informing the user that location access is required"),
        preferredStyle: .Alert)
      alertController.addAction(UIAlertAction(
        title: NSLocalizedString("Open Settings",
          comment: "A title for a button that will open the Settings app"),
        style: .Default,
        handler: {_ in
          UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        }))
      alertController.addAction(UIAlertAction(
        title: NSLocalizedString("Cancel", comment: ""),
        style: .Cancel,
        handler: nil))
      NSOperationQueue.mainQueue().addOperationWithBlock({ 
        self.handler!(.ErrorAlertController(alertController: alertController))
      })
    case .NotDetermined:
      self.locationManager.requestWhenInUseAuthorization()
    case .Restricted:
      let alertController = UIAlertController(
        title: NSLocalizedString("Location Access Restricted",
          comment: "An alert title stating that the user needs, but cannot enable, location access"),
        message: NSLocalizedString(
          ("Location access is required to sign up for a library card, but you do not have " +
            "permission to enable location access due to parental control settings or a hardware restriction."),
          comment: "An alert message informing the user that they need, but cannnot enable, location access"),
        preferredStyle: .Alert)
      alertController.addAction(UIAlertAction(
        title: NSLocalizedString("OK", comment: ""),
        style: .Default,
        handler: nil))
      NSOperationQueue.mainQueue().addOperationWithBlock({ 
        self.handler!(.ErrorAlertController(alertController: alertController))
      })
    }
  }
  
  // MARK: CLLocationManagerDelegate
  
  func locationManager(
    manager: CLLocationManager,
    didChangeAuthorizationStatus status: CLAuthorizationStatus)
  {
    locationManager.startUpdatingLocation()
  }
  
  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if self.receivedRecentLocation {
      return
    }
    let latestLocation = locations.last!
    let fiveMinutesAgo = NSDate(timeIntervalSinceNow: -300)
    if latestLocation.timestamp == latestLocation.timestamp.laterDate(fiveMinutesAgo) {
      self.receivedRecentLocation = true
      self.locationManager.stopUpdatingLocation()
      self.geocoder.reverseGeocodeLocation(locations.last!) { (placemarks: [CLPlacemark]?, error) in
        if let placemark = placemarks?.last {
          NSOperationQueue.mainQueue().addOperationWithBlock({ 
            self.handler!(.Placemark(placemark: placemark))
          })
        } else {
          let alertController = UIAlertController(
            title: NSLocalizedString("Could Not Determine Location",
              comment: "The title for an alert when a location cannot be determined"),
            message: NSLocalizedString("Your location could not be determined at this time. Please try again later.",
              comment: "The message for an alert when a location could not be determined"),
            preferredStyle: .Alert)
          alertController.addAction(UIAlertAction(
            title: NSLocalizedString("OK", comment: ""),
            style: .Default,
            handler: nil))
          NSOperationQueue.mainQueue().addOperationWithBlock({
            self.handler!(.ErrorAlertController(alertController: alertController))
          })
        }
      }
    }
  }
}
