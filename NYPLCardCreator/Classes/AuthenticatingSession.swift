import UIKit

/// This class is a tiny version of `NSURLSession` that will automatically handle
/// authentication with the API endpoint using basic authentication.
class AuthenticatingSession {
  private let delegate: Delegate
  private let URLSession: NSURLSession
  
  init(configuration: CardCreatorConfiguration) {
    self.delegate = Delegate(username: configuration.endpointUsername, password: configuration.endpointPassword)
    self.URLSession = NSURLSession(
      configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
      delegate: self.delegate,
      delegateQueue: nil)
  }
  
  /// Functionally equivalent to the `NSURLSession` method with the addition of automatic
  /// authentication with the API endpoint.
  func dataTaskWithRequest(
    request: NSURLRequest,
    completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask
  {
    return self.URLSession.dataTaskWithRequest(request, completionHandler: completionHandler)
  }
  
  /// As with an `NSURLSession`, this or `finishTasksAndInvalidate` must be called else
  /// resources will not be freed.
  func invalidateAndCancel() {
    self.URLSession.invalidateAndCancel()
  }

  /// As with an `NSURLSession`, this or `invalidateAndCancel` must be called else
  /// resources will not be freed.
  func finishTasksAndInvalidate() {
    self.URLSession.finishTasksAndInvalidate()
  }
  
  private class Delegate: NSObject, NSURLSessionDelegate {
    private let username: String
    private let password: String
    
    init(username: String, password: String) {
      self.username = username
      self.password = password
    }
    
    // TODO: This needs to be declared @objc for reasons I cannot understand. This was
    // discovered only after much pain. I would like an answer.
    @objc func URLSession(
      session: NSURLSession,
      task: NSURLSessionTask,
      didReceiveChallenge challenge: NSURLAuthenticationChallenge,
                          completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential?) -> Void)
    {
      if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
        if challenge.previousFailureCount > 0 {
          completionHandler(.PerformDefaultHandling, nil)
        } else {
          completionHandler(.UseCredential, NSURLCredential(
            user: self.username,
            password: self.password,
            persistence: .ForSession))
        }
      } else {
        completionHandler(.RejectProtectionSpace, nil)
      }
    }
  }
}
