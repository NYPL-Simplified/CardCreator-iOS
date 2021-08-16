import NYPLCardCreator
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
  var window: UIWindow?
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool
  {
    self.window = UIWindow.init(frame: UIScreen.main.bounds)
    self.window?.rootViewController = UIViewController()
    self.window?.rootViewController?.view.backgroundColor = UIColor.white
    self.window?.tintAdjustmentMode = .normal;
    self.window?.makeKeyAndVisible()
    
    let configuration = CardCreatorConfiguration(
      endpointURL: URL(string: "http://qa.patrons.librarysimplified.org/")!,
      endpointVersion: "v1",
      endpointUsername: "test_key",
      endpointPassword: "test_secret",
      requestTimeoutInterval: 20.0)
    { (username, PIN, initiated) in
        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
        let alertController = UIAlertController(
          title: "Sign-Up Successful",
          message: "Username: \(username)\nPIN: \(PIN)\nThe app would now log the user in automatically.",
          preferredStyle: .alert)
        alertController.addAction(UIAlertAction(
          title: "OK",
          style: .default,
          handler: nil))
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    let initialViewController = CardCreator.initialNavigationController(configuration: configuration)
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
      initialViewController.modalPresentationStyle = .formSheet
      self.window?.rootViewController?.present(initialViewController, animated: true, completion: nil)
    }
    
    return true
  }
}

