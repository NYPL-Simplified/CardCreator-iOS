import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
  let navigationController = UINavigationController(rootViewController: IntroductionViewController())
  var window: UIWindow?
  
  func application(
    application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)
    -> Bool
  {
    self.window = UIWindow.init(frame: UIScreen.mainScreen().bounds)
    self.window?.rootViewController = self.navigationController
    self.window?.makeKeyAndVisible()
    
    self.window?.tintAdjustmentMode = .Normal;
    
    return true
  }
}

