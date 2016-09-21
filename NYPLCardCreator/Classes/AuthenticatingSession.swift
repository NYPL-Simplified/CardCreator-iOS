import UIKit

class AuthenticatingSession {
   private let delegate: Delegate
  private let URLSession: NSURLSession
  
  init(endpointUsername: String, endpointPassword: String) {
    self.delegate = Delegate(username: endpointUsername, password: endpointPassword)
    self.URLSession = NSURLSession(
      configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration(),
      delegate: self.delegate,
      delegateQueue: nil)
  }
  
  func dataTaskWithRequest(
    request: NSURLRequest,
    completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask
  {
    return self.URLSession.dataTaskWithRequest(request, completionHandler: completionHandler)
  }
  
  func invalidateAndCancel() {
    self.URLSession.invalidateAndCancel()
  }
  
  func finishTasksAndInvalidate() {
    self.URLSession.finishTasksAndInvalidate()
  }
  
  private class Delegate: NSObject, NSURLSessionDelegate {
    let username: String
    let password: String
    
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
