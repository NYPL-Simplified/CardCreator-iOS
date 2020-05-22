import Foundation

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

  /// This will always be called on the main thread. It will only be called in the event
  /// of a successful registration.
  public var completionHandler: (_ username: String, _ PIN: String, _ userInitiated: Bool) -> Void

  /// Saves in-progress data entered by User/Patron
  var user: UserInfo
  
  @objc public init(
    endpointURL: URL,
    endpointVersion: String,
    endpointUsername: String,
    endpointPassword: String,
    juvenilePlatformAPIInfo: NYPLPlatformAPIInfo? = nil,
    requestTimeoutInterval: TimeInterval,
    completionHandler: @escaping (_ username: String, _ PIN: String, _ userInitiated: Bool) -> Void)
  {
    self.endpointURL = endpointURL.appendingPathComponent(endpointVersion)
    self.endpointUsername = endpointUsername
    self.endpointPassword = endpointPassword
    self.platformAPIInfo = juvenilePlatformAPIInfo
    self.requestTimeoutInterval = requestTimeoutInterval
    self.completionHandler = completionHandler
    self.user = UserInfo()
    super.init()
  }
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
