import UIKit

@objc public class CardCreator: NSObject {
  @objc public static func initialViewControllerWithConfiguration(
    configuration: CardCreatorConfiguration)
    -> UIViewController
  {
    return UINavigationController(rootViewController: IntroductionViewController(configuration: configuration))
  }
}
