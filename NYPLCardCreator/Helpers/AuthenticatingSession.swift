import UIKit

/// This class is a tiny version of `NSURLSession` that will automatically handle
/// authentication with the API endpoint using basic authentication.
final class AuthenticatingSession {
  private let delegate: Delegate
  private let urlSession: Foundation.URLSession
  
  init(configuration: CardCreatorConfiguration) {
    self.delegate = Delegate(username: configuration.endpointUsername, password: configuration.endpointPassword)
    self.urlSession = Foundation.URLSession(
      configuration: URLSessionConfiguration.ephemeral,
      delegate: self.delegate,
      delegateQueue: nil)
  }
  
  /// Functionally equivalent to the `NSURLSession` method with the addition of automatic
  /// authentication with the API endpoint.
  func dataTaskWithRequest(
    _ request: URLRequest,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
  {
    return urlSession.dataTask(with: request, completionHandler: completionHandler)
  }
  
  /// As with an `NSURLSession`, this or `finishTasksAndInvalidate` must be called else
  /// resources will not be freed.
  func invalidateAndCancel() {
    urlSession.invalidateAndCancel()
  }

  /// As with an `NSURLSession`, this or `invalidateAndCancel` must be called else
  /// resources will not be freed.
  func finishTasksAndInvalidate() {
    urlSession.finishTasksAndInvalidate()
  }

  // MARK:-
  
  private class Delegate: NSObject, URLSessionDelegate {
    private let username: String
    private let password: String
    
    init(username: String, password: String) {
      self.username = username
      self.password = password
    }
    
    // TODO: This needs to be declared @objc for reasons I cannot understand. This was
    // discovered only after much pain. I would like an answer.
    @objc func URLSession(
      _ session: Foundation.URLSession,
      task: URLSessionTask,
      didReceiveChallenge challenge: URLAuthenticationChallenge,
                          completionHandler: (Foundation.URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
      if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
        if challenge.previousFailureCount > 0 {
          completionHandler(.performDefaultHandling, nil)
        } else {
          completionHandler(.useCredential, URLCredential(
            user: self.username,
            password: self.password,
            persistence: .forSession))
        }
      } else {
        completionHandler(.rejectProtectionSpace, nil)
      }
    }
  }
}
