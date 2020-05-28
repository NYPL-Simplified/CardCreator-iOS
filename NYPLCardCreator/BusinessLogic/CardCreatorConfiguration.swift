import UIKit

/// The information regarding the 2nd version of the card creator api. This is
/// currently used only for the Juvenile cards but in the future it will be
/// used for regular patron cards too.
public final class NYPLPlatformAPIInfo: NSObject {
  let oauthTokenURL: URL
  let clientID: String
  let clientSecret: String
  let baseURL: URL

  @objc
  public init?(oauthTokenURL: URL,
               clientID: String?,
               clientSecret: String?,
               baseURL: URL) {
    guard let clientID = clientID,
      let clientSecret = clientSecret else {
        return nil
    }
    self.oauthTokenURL = oauthTokenURL
    self.clientID = clientID
    self.clientSecret = clientSecret
    self.baseURL = baseURL
    super.init()
  }
}

/// A `CardCreatorConfiguration` instance is used by applications to set
/// up a new card registration flow.
public final class CardCreatorConfiguration: NSObject {
  /// The base URL for all API requests, e.g. the base URL for
  /// "http://qa.patrons.librarysimplified.org/v1/validate/username" is
  /// "http://qa.patrons.librarysimplified.org/v1".
  public let endpointURL: URL

  /// The username to be provided via basic authentication to the API endpoint.
  public let endpointUsername: String

  /// The password to be provided via basic authentication to the API endpoint.
  public let endpointPassword: String

  /// Currently necessary only for the Juvenile flow.
  /// - Note: At some point in the future this will also include `endpointURL`,
  /// `endpointUsername`, `endpointPassword`.
  let platformAPIInfo: NYPLPlatformAPIInfo?

  /// The timeout to use for all requests to the API endpoint.
  public let requestTimeoutInterval: TimeInterval

  /// The barcode of the parent creating juvenile accounts. Unused by the
  /// regular flow.
  let juvenileParentBarcode: String

  /// The callback to use to create the child account.
  /// - Note: This is ignored by the regular flow.
  var juvenileCreationHandler: ((_: JuvenileCreationInfo, _: JuvenileCardCreationResponder?) -> Void)?

  /// This will always be called on the main thread. It will only be called in the event
  /// of a successful registration.
  @objc public var completionHandler: (_ username: String, _ PIN: String, _ userInitiated: Bool) -> Void

  /// Saves in-progress data entered by User/Patron
  var user: UserInfo

  /// Strings that differ between the regular and juvenile flows.
  let localizedStrings: FlowLocalizedStrings

  /// The minimum length of the username field.
  let usernameMinLength: Int = 5

  /// The designated initialier. This can be used for both regular and
  /// juvenile card creation.
  /// 
  /// - Parameters:
  ///   - endpointURL: The base URL for the API endpoints used by the regular
  ///   card creation flow.
  ///   - endpointVersion: Version of the API used by the regular
  ///   card creation flow.
  ///   - endpointUsername: Username for authenticating on the API used by the
  ///   regular card creation flow.
  ///   - endpointPassword: Password for authenticating on the API used by the
  ///   regular card creation flow.
  ///   - juvenileParentBarcode: Optional barcode of the parent for creating
  ///   juvenile accounts.
  ///   - juvenilePlatformAPIInfo: The platform API endpoints necessary for the
  ///   juvenile flow. For regular card creation flow, leave this nil.
  ///   - requestTimeoutInterval: Request timeouts for both flows.
  ///   - completionHandler: Completion block that will be called on the main
  ///   thread at the end of both registration flows.
  @objc public init(
    endpointURL: URL,
    endpointVersion: String,
    endpointUsername: String,
    endpointPassword: String,
    juvenileParentBarcode: String = "",
    juvenilePlatformAPIInfo: NYPLPlatformAPIInfo? = nil,
    requestTimeoutInterval: TimeInterval,
    completionHandler: @escaping (_ username: String, _ PIN: String, _ userInitiated: Bool) -> Void = { _, _, _ in })
  {
    self.endpointURL = endpointURL.appendingPathComponent(endpointVersion)
    self.endpointUsername = endpointUsername
    self.endpointPassword = endpointPassword
    self.juvenileParentBarcode = juvenileParentBarcode
    self.platformAPIInfo = juvenilePlatformAPIInfo
    self.requestTimeoutInterval = requestTimeoutInterval
    self.completionHandler = completionHandler
    let isJuvenileFlow = (juvenilePlatformAPIInfo != nil)
    self.user = UserInfo()
    if isJuvenileFlow {
      self.localizedStrings = JuvenileFlowLocalizedStrings()
    } else {
      self.localizedStrings = RegularFlowLocalizedStrings()
    }
    super.init()
  }

  var isJuvenile: Bool {
    platformAPIInfo != nil
  }
}

protocol FlowLocalizedStrings {
  var welcomeTitle: String {get}
  var featureRequirements: String {get}

  /// This is the copy **declining** either the age requirement for the regular
  /// flow or the legal guardianship attestation for the juvenile flow.
  var attestationDecline: String? {get}

  /// This is the copy **confirming** either the age requirement for the regular
  /// flow or the legal guardianship attestation for the juvenile flow.
  var attestationConfirm: String {get}

  var attestationRequirementTitle: String {get}
  var attestationRequirementMessage: String {get}

  var nameScreenTitle: String {get}
}

struct RegularFlowLocalizedStrings: FlowLocalizedStrings {
  let welcomeTitle = NSLocalizedString("Sign Up", comment: "A title welcoming the user to library card sign up")
  let featureRequirements = NSLocalizedString("""
      To get a digital library card from the New York Public Library, you must \
      live, work, or attend school in New York State. You must also be at least \
      13 years of age and be physically present in New York at the time of sign-up.

      You must be at least 13 years of age.
      How old are you?
      """, comment: "A description of what is required to get a library card")
  let attestationDecline: String? = NSLocalizedString("I am under 13", comment: "Title for a user to check when they are under 13 years of age")
  let attestationConfirm = NSLocalizedString("I am 13 or older", comment: "Title for a user to check when they are 13 years of age or older")
  let attestationRequirementTitle = NSLocalizedString("Age Restriction", comment: "An alert title indicating that the user has encountered an age restriction")
  let attestationRequirementMessage = NSLocalizedString(
    "You must be at least 13 years old to sign up for a library card.", comment: "An alert message telling the user are not old enough to sign up for a library card")
  let nameScreenTitle = NSLocalizedString(
    "Personal Information",
    comment: "A title for the screen asking the user for their personal information")
}

struct JuvenileFlowLocalizedStrings: FlowLocalizedStrings {
  let welcomeTitle = NSLocalizedString("Create Card for your Child", comment: "A title welcoming the user to library card sign up")
  let featureRequirements = NSLocalizedString("""
      To apply for a card for your under-13 child, you must be the \
      parent/legal guardian of the minor in question and be physically \
      present in New York State at the time of sign-up.

      Please check the box below to confirm you are the legal guardian of \
      the minor child for whom this card will be used.
      """, comment: "A description of what is required to create a juvenile library card")
  let attestationDecline: String? = nil
  let attestationConfirm = NSLocalizedString("By checking this box, I confirm that I am the parent / legal guardian of the minor for whom I am creating a library card account.", comment: "Title to indicate that the patron provides legal guardianship for their child.")
  let attestationRequirementTitle = NSLocalizedString("Legal Guardianship Restriction", comment: "An alert title indicating that the user has encountered an legal guardianship restriction")
  let attestationRequirementMessage = NSLocalizedString("You may not proceed if you are not the parent/legal guardian of the minor for whom you are applying.", comment: "A message telling the user that it is required to attest legal guardianship for the child they are creating a card for.")
  let nameScreenTitle = NSLocalizedString(
    "Create New Card",
    comment: "A title for the screen where a user can create a new card for their children")
}

final class UserInfo {
  var homeAddress: Address?
  var workAddress: Address?
  var schoolAddress: Address?
  
  var firstName: String?
  var middleName: String?
  var lastName: String?
  var email: String?
  
  var username: String?
}
