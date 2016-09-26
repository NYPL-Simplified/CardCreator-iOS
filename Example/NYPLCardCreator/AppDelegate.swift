import NYPLCardCreator
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
    self.window?.rootViewController = UIViewController()
    self.window?.rootViewController?.view.backgroundColor = UIColor.whiteColor()
    self.window?.tintAdjustmentMode = .Normal;
    self.window?.makeKeyAndVisible()
    
    let configuration = CardCreatorConfiguration(
      endpointURL: NSURL(string: "http://qa.patrons.librarysimplified.org/v1")!,
      endpointUsername: "test_key",
      endpointPassword: "test_secret",
      requestTimeoutInterval: 20.0)
    { (username, PIN) in
        self.window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
        let alertController = UIAlertController(
          title: "Sign-Up Successful",
          message: "Username: \(username)\nPIN: \(PIN)\nThe app would now log the user in automatically.",
          preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(
          title: "OK",
          style: .Default,
          handler: nil))
        self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    let initialViewController = CardCreator.initialViewControllerWithConfiguration(configuration)
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
      initialViewController.modalPresentationStyle = .FormSheet
      self.window?.rootViewController?.presentViewController(initialViewController, animated: true, completion: nil)
    }
    
    return true
  }
}

