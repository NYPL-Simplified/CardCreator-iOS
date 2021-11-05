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
    self.window?.rootViewController?.view.backgroundColor = NYPLColor.primaryBackgroundColor
    self.window?.tintAdjustmentMode = .normal;
    self.window?.makeKeyAndVisible()
    
    let platformAPIInfo = NYPLPlatformAPIInfo(
      oauthTokenURL: URL(string: "https://example.com/token")!,
      clientID: "clientID",
      clientSecret: "secret",
      baseURL: URL(string: "https://example.com")!)!
    
    // This testapp does not work with the v0.3 API
    // because the clientID and clientSecret are only accessible from SimplyE,
    // and there are no test ID and secret.
    let configuration = CardCreatorConfiguration(
      endpointURL: URL(string: "https://platform.nypl.org/api/v0.3/")!,
      endpointVersion: "v1",
      endpointUsername: "test_key",
      endpointPassword: "test_secret",
      platformAPIInfo: platformAPIInfo,
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
    
    let flowCoordinator = FlowCoordinator.init(configuration: configuration)
    flowCoordinator.startRegularFlow { result in
      var viewController: UIViewController
      switch result {
      case .fail(let error):
        viewController = UIAlertController(title: "Failed to initialize Card Creation", message: error.localizedDescription, preferredStyle: .alert)
      case .success(let initialController):
        viewController = initialController
        viewController.modalPresentationStyle = .formSheet
      }
      
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)) {
        self.window?.rootViewController?.present(viewController, animated: true, completion: nil)
      }
    }
    
    return true
  }
}

