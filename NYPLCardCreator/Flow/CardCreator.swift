import UIKit

@objcMembers public final class CardCreator: NSObject {
  public static func initialNavigationController(
    configuration: CardCreatorConfiguration) -> UINavigationController
  {
    return UINavigationController(rootViewController: IntroductionViewController(configuration: configuration))
  }
}
