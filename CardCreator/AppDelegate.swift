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
    self.window?.makeKeyAndVisible()
   
    self.window?.rootViewController?.view.backgroundColor = UIColor.whiteColor()
    self.navigationController.modalPresentationStyle = .FormSheet
    self.window?.rootViewController?.presentViewController(navigationController, animated: false, completion: nil)
    
    self.window?.tintAdjustmentMode = .Normal;
    
    return true
  }
}

