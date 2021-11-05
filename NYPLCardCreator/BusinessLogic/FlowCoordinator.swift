//
//  FlowCoordinator.swift
//  NYPLCardCreator
//
//  Created by Ernest Fan on 2021-11-04.
//  Copyright © 2021 NYPL Labs. All rights reserved.
//

import UIKit

public class FlowCoordinator {
  internal let urlSession: URLSession
  public let configuration: CardCreatorConfiguration
  internal var authToken: ISSOToken?
  
  public init(configuration: CardCreatorConfiguration) {
    self.configuration = configuration
    self.urlSession = URLSession(configuration: .ephemeral)
  }
  
  public func startRegularFlow(completion: @escaping (Result<UINavigationController>) -> Void) {    
    authenticate(using: configuration.platformAPIInfo) { [weak self] result in
      guard let self = self else {
        return
      }

      switch result {
      case .success(let authToken):
        self.authToken = authToken
        let introVC = IntroductionViewController(configuration: self.configuration, authToken: authToken)
        completion(.success(UINavigationController(rootViewController: introVC)))
      case .fail(let error):
        OperationQueue.main.addOperation {
          completion(.fail(FlowCoordinator.errorWithUserFriendlyMessage(amending: error)))
        }
      }
    }
  }
  
  // MARK: - Fetch ISSOToken
  
  func authenticate(using platformEndpoints: NYPLPlatformAPIInfo,
                    completion: @escaping (Result<ISSOToken>) -> Void) {
    guard let req = ISSORequest(using: platformEndpoints,
                                timeoutInterval: configuration.requestTimeoutInterval) else {
      let err = NSError(domain: ErrorDomain,
                        code: ErrorCode.jsonEncodingFail.rawValue)
      completion(.fail(err))
      return
    }

    let task = urlSession.dataTask(with: req) { data, response, error in
      if let error = error {
        completion(.fail(error))
        return
      }

      // note: the request built by ISSORequest(using...) will always contain
      // a valid url. This nil-coalescing check is just for future-proofing.
      let urlStrLog = req.url?.absoluteString ?? "missing URL from ISSO auth request"

      guard let data = data else {
        let err = NSError(domain: ErrorDomain,
                          code: ErrorCode.noData.rawValue,
                          userInfo: ["requestURL": urlStrLog])
        completion(.fail(err))
        return
      }

      guard let response = response as? HTTPURLResponse else {
        let err = NSError(domain: ErrorDomain,
                          code: ErrorCode.noHTTPResponse.rawValue,
                          userInfo: ["requestURL": urlStrLog])
        completion(.fail(err))
        return
      }

      guard (200...299).contains(response.statusCode) else {
        let err = NSError(domain: ErrorDomain,
                          code: ErrorCode.unsuccessfulHTTPStatusCode.rawValue,
                          userInfo: ["requestURL": urlStrLog, "response": response])
        completion(.fail(err))
        return
      }

      guard let token = ISSOToken.fromData(data) else {
        let err = NSError(domain: ErrorDomain,
                          code: ErrorCode.jsonDecodingFail.rawValue,
                          userInfo: ["requestURL": urlStrLog, "data": data])
        completion(.fail(err))
        return
      }
      
      completion(.success(token))
    }
    task.resume()
  }
  
  private func ISSORequest(using platformAPI: NYPLPlatformAPIInfo,
                           timeoutInterval: TimeInterval) -> URLRequest? {
    let parameters: [String: String] = [
      "client_id": platformAPI.clientID,
      "client_secret": platformAPI.clientSecret,
      "grant_type": "client_credentials"
    ]

    let boundary = "Boundary-\(UUID().uuidString)"
    var body = ""
    parameters.forEach { (key: String, value: String) in
      body += "--\(boundary)\r\n"
      body += "Content-Disposition:form-data; name=\"\(key)\"\r\n"
      body += "\r\n\(value)\r\n"
    }
    body += "--\(boundary)--\r\n";
    guard let bodyData = body.data(using: .utf8) else {
      return nil
    }

    var req = URLRequest(url: platformAPI.oauthTokenURL,
                         timeoutInterval: timeoutInterval)
    req.setValue("application/json", forHTTPHeaderField: "Accept")
    req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    req.httpMethod = "POST"
    req.httpBody = bodyData
    return req
  }
  
  // MARK: - Helper
  
  internal static func errorWithUserFriendlyMessage(amending error: Error) -> NSError {
    let nsError = error as NSError
    if !nsError.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      // if we already have a localized description, we're going to trust that
      return nsError
    }

    let errorMsg = NSLocalizedString("An error occurred while processing your request.\n\nError Code: \(nsError.code)", comment: "A generic error message for low-level errors")
    var userInfo = nsError.userInfo
    userInfo[NSLocalizedDescriptionKey] = errorMsg
    return NSError(domain: nsError.domain, code: nsError.code, userInfo: userInfo)
  }
}
