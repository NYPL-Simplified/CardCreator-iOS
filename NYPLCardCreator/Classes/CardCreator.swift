import UIKit

@objc public final class CardCreator: NSObject {
  @objc public static func initialNavigationControllerWithConfiguration(
    configuration: CardCreatorConfiguration)
    -> UINavigationController
  {
    return UINavigationController(rootViewController: IntroductionViewController(configuration: configuration))
  }
}
