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
    self.window?.rootViewController = UIViewController()
    self.window?.rootViewController?.view.backgroundColor = UIColor.whiteColor()
    self.window?.tintAdjustmentMode = .Normal;
    self.window?.makeKeyAndVisible()
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
      self.navigationController.modalPresentationStyle = .FormSheet
      self.window?.rootViewController?.presentViewController(self.navigationController, animated: true, completion: nil)
    }
    
    return true
  }
}

