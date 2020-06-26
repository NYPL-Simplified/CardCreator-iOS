import UIKit

@objcMembers public final class CardCreator: NSObject {
  public static func initialNavigationControllerWithConfiguration(
    _ configuration: CardCreatorConfiguration)
    -> UINavigationController
  {
    return UINavigationController(rootViewController: IntroductionViewController(configuration: configuration))
  }
}
