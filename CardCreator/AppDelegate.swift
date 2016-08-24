import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
  var placemarkQuery: PlacemarkQuery!
  var window: UIWindow?

  override init() {
    super.init()
    let placemarkQuery = PlacemarkQuery(handler: { result in
      switch result {
      case let .ErrorAlertController(alertController):
        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
      case let .Placemark(placemark):
        break
      }
    })
    self.placemarkQuery = placemarkQuery
  }
  
  func application(
    application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)
    -> Bool
  {
    self.window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
    self.window?.rootViewController = IntroductionViewController()
    self.window?.makeKeyAndVisible()
    
    self.window?.tintAdjustmentMode = .Normal;
    
    self.placemarkQuery.start()
    
    return true
  }
}

