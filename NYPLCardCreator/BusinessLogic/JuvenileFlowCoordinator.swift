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
  /// - the Error will be in the `CardCreatorDomain` domain;
  /// - it will have one of the `ErrorCode` error codes;
  /// - it will contain a user-friendly error message in the NSError's
  /// `localizedDescription`.
  /// 
  /// - Parameters:
  ///   - parentBarcode: The barcode of the parent to use to create dependent cards.
  ///   - completion: Always called at the end of the calls mentioned above on
  ///   the main queue.
  public func startJuvenileFlow(parentBarcode: String,
                                completion: @escaping (Result<UINavigationController>) -> Void) {
    guard let platformAPI = configuration.platformAPIInfo else {
      let err = NSError(domain: CardCreatorDomain,
                        code: ErrorCode.missingConfiguration.rawValue)
      OperationQueue.main.addOperation {
        completion(.fail(JuvenileFlowCoordinator.errorWithUserFriendlyMessage(amending: err)))
      }
      return
    }

    let config = configuration

    authenticate(using: platformAPI) { [weak self] result in
      guard let self = self else {
        return
      }

      switch result {
      case .success(let issoToken):
        self.fetchJuvenileElegibility(using: platformAPI, authToken: issoToken, parentBarcode: parentBarcode) { error in

          OperationQueue.main.addOperation {
            if let error = error {
              completion(.fail(JuvenileFlowCoordinator.errorWithUserFriendlyMessage(amending: error)))
              return
            }

            completion(.success(UINavigationController(rootViewController: IntroductionViewController(configuration: config))))
          }
        }
      case .fail(let error):
        OperationQueue.main.addOperation {
          completion(.fail(JuvenileFlowCoordinator.errorWithUserFriendlyMessage(amending: error)))
        }
      }
    }
  }

  // MARK: - Private API calls

  private func authenticate(using platformEndpoints: NYPLPlatformAPIInfo,
                            completion: @escaping (Result<ISSOToken>) -> Void) {
    guard let req = ISSORequest(using: platformEndpoints) else {
      let err = NSError(domain: CardCreatorDomain,
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
        let err = NSError(domain: CardCreatorDomain,
                          code: ErrorCode.noData.rawValue,
                          userInfo: ["requestURL": urlStrLog])
        completion(.fail(err))
        return
      }

      guard let response = response as? HTTPURLResponse else {
        let err = NSError(domain: CardCreatorDomain,
                          code: ErrorCode.noHTTPResponse.rawValue,
                          userInfo: ["requestURL": urlStrLog])
        completion(.fail(err))
        return
      }

      guard (200...299).contains(response.statusCode) else {
        let err = NSError(domain: CardCreatorDomain,
                          code: ErrorCode.unsuccessfulHTTPStatusCode.rawValue,
                          userInfo: ["requestURL": urlStrLog, "response": response])
        completion(.fail(err))
        return
      }

      guard let token = ISSOToken.fromData(data) else {
        let err = NSError(domain: CardCreatorDomain,
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
      completion(JuvenileFlowCoordinator.errorWithUserFriendlyMessage(amending: err))
    case .success(let req):
      execute(req, completion: completion)
    }
  }

  private func execute(_ req: URLRequest,
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
        let err = NSError(domain: CardCreatorDomain,
                          code: ErrorCode.noData.rawValue,
                          userInfo: ["requestURL": urlStr])
        completion(err)
        return
      }

      guard let response = response as? HTTPURLResponse else {
        let err = NSError(domain: CardCreatorDomain,
                          code: ErrorCode.noHTTPResponse.rawValue,
                          userInfo: ["requestURL": urlStr])
        completion(err)
        return
      }

      guard (200...299).contains(response.statusCode) else {
        let msg = NSLocalizedString("An error occurred while processing your request.", comment: "A generic error message regarding a low-level error")
        let recoveryMsg = NSLocalizedString("Try signing out and back in and try again.", comment: "A error recovery suggestion")
        let err = NSError(domain: CardCreatorDomain,
                          code: ErrorCode.unsuccessfulHTTPStatusCode.rawValue,
                          userInfo: [
                            NSLocalizedDescriptionKey: msg,
                            NSLocalizedRecoverySuggestionErrorKey: recoveryMsg,
                            "requestURL": urlStr,
                            "response": response])
        completion(err)
        return
      }

      guard let eligibility = JuvenileCardCreationEligibility.fromData(data) else {
        let err = NSError(domain: CardCreatorDomain,
                          code: ErrorCode.jsonDecodingFail.rawValue,
                          userInfo: ["requestURL": urlStr, "data": data])
        completion(err)
        return
      }

      if eligibility.eligible == false {
        let err = NSError(domain: CardCreatorDomain,
                          code: ErrorCode.ineligibleForJuvenileCardCreation.rawValue,
                          userInfo: [
                            NSLocalizedDescriptionKey: eligibility.userFriendlyMessage])
        completion(err)
        return
      }

      completion(nil)
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
      let err = NSError(domain: CardCreatorDomain,
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
