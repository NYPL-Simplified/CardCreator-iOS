import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
  var window: UIWindow?

  func application(
    application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)
    -> Bool
  {
    self.window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
    self.window?.rootViewController = CardCreatorViewController()
    self.window?.makeKeyAndVisible()
    
    self.window?.tintAdjustmentMode = .Normal;
    
    return true
  }
}

