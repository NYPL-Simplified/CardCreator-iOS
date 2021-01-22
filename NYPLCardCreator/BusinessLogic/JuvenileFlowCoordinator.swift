//
//  JuvenileFlowCoordinator.swift
//  NYPLCardCreator
//
//  Created by Ettore Pasquini on 5/13/20.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

import UIKit

public class JuvenileFlowCoordinator {

  private let urlSession: URLSession
  public let configuration: CardCreatorConfiguration
  private var authToken: ISSOToken?

  public init(configuration: CardCreatorConfiguration) {
    self.configuration = configuration
    self.urlSession = URLSession(configuration: .ephemeral)
  }

  /// The starting point of the juvenile card creation flow.
  /// This performs a first call to isso.nypl.org to obtain a OAuth token, and
  /// then uses that to reach an endpoint on platform.nypl.org to determine
  /// the patron's eligibility status for creating dependent cards.
  ///
  /// If any of the calls fails, an error is returned in the completion handler.
  /// This error could be an application error or a system error (such as
  /// lack of connectivity). If it is an application error:
  /// - the Error will be in the `ErrorDomain` domain;
  /// - it will have one of the `ErrorCode` error codes;
  /// - it will contain a user-friendly error message in the NSError's
  /// `localizedDescription`.
  ///
  /// - Parameters:
  ///   - completion: Always called at the end of the calls mentioned above on
  ///   the main queue.
  public func startJuvenileFlow(completion: @escaping (Result<UINavigationController>) -> Void) {
    guard let platformAPI = configuration.platformAPIInfo else {
      let err = NSError(domain: ErrorDomain,
                        code: ErrorCode.missingConfiguration.rawValue)
      OperationQueue.main.addOperation {
        completion(.fail(JuvenileFlowCoordinator.errorWithUserFriendlyMessage(amending: err)))
      }
      return
    }

    let config = configuration
    let parentBarcode = configuration.juvenileParentBarcode

    configuration.juvenileCreationHandler = { [weak self] juvenileInfo, responder in
      self?.createPatron(using: platformAPI, parameters: juvenileInfo) { result in
        if case .fail(let err) = result {
          responder?.handleJuvenilePatronResponse(.fail(
            JuvenileFlowCoordinator.errorWithUserFriendlyMessage(amending: err)))
          return
        }

        responder?.handleJuvenilePatronResponse(result)
      }
    }

    checkJuvenileCreationEligibility(parentBarcode: parentBarcode) { (error) in
      if let error = error {
        completion(.fail(error))
        return
      }
      completion(.success(UINavigationController(rootViewController: IntroductionViewController(configuration: config))))
    }
  }
  
  /// This is part of the Juvenile Flow being refactored into a separated function.
  /// This allows the client application to authenticate and check Juvenile eligibility without Juvenile creation.
  ///
  /// If any of the calls fails, an error is returned in the completion handler.
  /// This error could be an application error or a system error (such as
  /// lack of connectivity). If it is an application error:
  /// - the Error will be in the `ErrorDomain` domain;
  /// - it will have one of the `ErrorCode` error codes;
  /// - it will contain a user-friendly error message in the NSError's
  /// `localizedDescription`.
  ///
  /// - Parameters:
  ///   - parentBarcode: The barcode of user's account
  ///   - completion: Always called at the end of the calls mentioned above on
  ///   the main queue.
  public func checkJuvenileCreationEligibility(parentBarcode: String,
                                               completion: @escaping (_ error: Error?) -> Void) {
    guard let platformAPI = configuration.platformAPIInfo else {
      let err = NSError(domain: ErrorDomain,
                        code: ErrorCode.missingConfiguration.rawValue)
      OperationQueue.main.addOperation {
        completion(JuvenileFlowCoordinator.errorWithUserFriendlyMessage(amending: err))
      }
      return
    }
    
    authenticate(using: platformAPI) { [weak self] result in
      guard let self = self else {
        return
      }

      switch result {
      case .success(let authToken):
        self.authToken = authToken
        self.fetchJuvenileElegibility(using: platformAPI, authToken: authToken, parentBarcode: parentBarcode) { error in
          OperationQueue.main.addOperation {
            if let error = error {
              completion(JuvenileFlowCoordinator.errorWithUserFriendlyMessage(amending: error))
              return
            }
            completion(nil)
          }
        }
      case .fail(let error):
        OperationQueue.main.addOperation {
          completion(JuvenileFlowCoordinator.errorWithUserFriendlyMessage(amending: error))
        }
      }
    }
  }

  // MARK: - Private API calls

  private func authenticate(using platformEndpoints: NYPLPlatformAPIInfo,
                            completion: @escaping (Result<ISSOToken>) -> Void) {
    guard let req = ISSORequest(using: platformEndpoints) else {
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

  private func fetchJuvenileElegibility(using platformEndpoints: NYPLPlatformAPIInfo,
                                        authToken: ISSOToken,
                                        parentBarcode: String,
                                        completion: @escaping (_ error: Error?) -> Void) {

    let result = eligibilityRequest(using: platformEndpoints,
                                    authToken: authToken,
                                    parentBarcode: parentBarcode)

    switch result {
    case .fail(let err):
      completion(err)
    case .success(let req):
      executeEligibility(req, completion: completion)
    }
  }

  private func executeEligibility(_ req: URLRequest,
                                  completion: @escaping (_ error: Error?) -> Void) {

    // note: the request built by eligibilityRequest(using...) will always
    // contain a valid url. This nil-coalescing check is just for future-proofing.
    let urlStr = req.url?.absoluteString ?? "missing URL from eligibility request"

    let task = urlSession.dataTask(with: req) { data, response, error in
      if let error = error {
        completion(error)
        return
      }

      guard let data = data else {
        let err = NSError(domain: ErrorDomain,
                          code: ErrorCode.noData.rawValue,
                          userInfo: ["requestURL": urlStr])
        completion(err)
        return
      }

      guard let response = response as? HTTPURLResponse else {
        let err = NSError(domain: ErrorDomain,
                          code: ErrorCode.noHTTPResponse.rawValue,
                          userInfo: ["requestURL": urlStr])
        completion(err)
        return
      }

      guard (200...299).contains(response.statusCode) else {
        var userInfo: [String: Any] = ["requestURL": urlStr, "response": response]
        if response.statusCode == 401 || response.statusCode == 403 {
          userInfo[NSLocalizedRecoverySuggestionErrorKey] = NSLocalizedString("Please log out and try your card information again.", comment: "A error recovery suggestion related to missing login info")
        }

        guard let responseError = PlatformAPIError.fromData(data) else {
          completion(NSError(domain: ErrorDomain,
                             code: ErrorCode.jsonDecodingFail.rawValue,
                             userInfo: userInfo))
          return
        }

        // NB: the server will return product-approved yet non-localized
        // messages, but because of time constraints we are not going to
        // localize those
        userInfo[NSLocalizedDescriptionKey] = responseError.message
        completion(NSError(domain: ErrorDomain,
                           code: ErrorCode.ineligibleForJuvenileCardCreation.rawValue,
                           userInfo: userInfo))
        return
      }

      completion(nil)
    }
    task.resume()
  }

  private func createPatron(using platformAPI: NYPLPlatformAPIInfo,
                            parameters: JuvenileCreationInfo,
                            completion: @escaping (_ result: Result<String>) -> Void) {

    let result = juvenileCreateRequest(using: platformAPI,
                                       parameters: parameters)
    switch result {
    case .fail(let err):
      completion(.fail(err))
    case .success(let req):
      executeCreatePatron(req, completion: completion)
    }
  }

  private func executeCreatePatron(_ req: URLRequest,
                                   completion: @escaping (_ result: Result<String>) -> Void) {

    // note: the request built by juvenileCreateRequest(using...) will always
    // contain a valid url. This nil-coalescing check is just for future-proofing.
    let urlStr = req.url?.absoluteString ?? "missing URL from /patrons/dependents request"

    let task = urlSession.dataTask(with: req) { data, response, error in
      if let error = error {
        completion(.fail(error))
        return
      }

      guard let data = data else {
        let err = NSError(domain: ErrorDomain,
                          code: ErrorCode.noData.rawValue,
                          userInfo: ["requestURL": urlStr])
        completion(.fail(err))
        return
      }

      guard let response = response as? HTTPURLResponse else {
        let err = NSError(domain: ErrorDomain,
                          code: ErrorCode.noHTTPResponse.rawValue,
                          userInfo: ["requestURL": urlStr])
        completion(.fail(err))
        return
      }

      guard (200...299).contains(response.statusCode) else {
        guard let error = PlatformAPIError.fromData(data) else {
          let err = NSError(domain: ErrorDomain,
                            code: ErrorCode.jsonDecodingFail.rawValue,
                            userInfo: [
                              "requestURL": urlStr,
                              "response": response])
          completion(.fail(err))
          return
        }

        completion(.fail(NSError(domain: ErrorDomain,
                                 code: ErrorCode.createJuvenileAccountFail.rawValue,
                                 userInfo: [
                                  NSLocalizedDescriptionKey: error.message,
                                  "requestURL": urlStr,
                                  "response": response])))
        return
      }

      guard let juvBarcode = JuvenileCreationResponseBody.fromData(data) else {
        let err = NSError(domain: ErrorDomain,
                          code: ErrorCode.jsonDecodingFail.rawValue,
                          userInfo: ["requestURL": urlStr, "data": data])
        completion(.fail(err))
        return
      }

      completion(.success(juvBarcode.barcode))
    }
    task.resume()
  }

  // MARK: - Private Helpers

  private func ISSORequest(using platformAPI: NYPLPlatformAPIInfo) -> URLRequest? {
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
                         timeoutInterval: configuration.requestTimeoutInterval)
    req.setValue("application/json", forHTTPHeaderField: "Accept")
    req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    req.httpMethod = "POST"
    req.httpBody = bodyData
    return req
  }

  private func eligibilityRequest(using platformEndpoints: NYPLPlatformAPIInfo,
                                  authToken: ISSOToken,
                                  parentBarcode: String) -> Result<URLRequest> {
    let url = platformEndpoints.baseURL
      .appendingPathComponent("patrons/dependent-eligibility")
    var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
    comps?.queryItems = [URLQueryItem(name: "barcode", value: parentBarcode)]
    guard let finalURL = comps?.url else {
      let err = NSError(domain: ErrorDomain,
                        code: ErrorCode.unableToCreateURL.rawValue,
                        userInfo: [
                          "urlString": comps?.debugDescription ?? url.debugDescription])
      return .fail(err)
    }

    var req = URLRequest(url: finalURL)
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.setValue("application/json", forHTTPHeaderField: "Accept")
    req.setValue("\(authToken.tokenType) \(authToken.accessToken)", forHTTPHeaderField: "Authorization")
    req.timeoutInterval = configuration.requestTimeoutInterval
    return .success(req)
  }

  private func juvenileCreateRequest(using platformAPI: NYPLPlatformAPIInfo,
                                     parameters: JuvenileCreationInfo) -> Result<URLRequest> {
    let url = platformAPI.baseURL
      .appendingPathComponent("patrons/dependents")

    guard let authToken = self.authToken else {
      let err = NSError(domain: ErrorDomain,
                        code: ErrorCode.missingAuthentication.rawValue,
                        userInfo: ["requestURL": url])
      return .fail(err)
    }

    var req = URLRequest(url: url)
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.setValue("application/json", forHTTPHeaderField: "Accept")
    req.setValue("\(authToken.tokenType) \(authToken.accessToken)", forHTTPHeaderField: "Authorization")
    req.timeoutInterval = configuration.requestTimeoutInterval
    req.httpMethod = "POST"
    req.httpBody = parameters.encode()
    return .success(req)
  }

  private static func errorWithUserFriendlyMessage(amending error: Error) -> NSError {
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
