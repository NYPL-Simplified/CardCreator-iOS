//
//  ResultErrors.swift
//  NYPLCardCreator
//
//  Created by Ettore Pasquini on 5/14/20.
//  Copyright © 2020 NYPL. All rights reserved.
//

import Foundation

public enum Result<T> {
  case success(T)
  case fail(Error)
}

public let ErrorDomain = "org.nypl.cardcreator"

/// Error codes related to Card Creator functionality.
public enum ErrorCode: Int {
  case ignore = 0

  // business logic errors
  case ineligibleForJuvenileCardCreation = 100
  case wrongPtype = 101
  case reachedMaxJuvenileCards = 102
  case missingAuthentication = 103
  case createJuvenileAccountFail = 104

  // MARK:- Low-level error codes

  // low-level errors: misc
  case missingConfiguration = 200
  case jsonEncodingFail = 201
  case unableToCreateURL = 202

  // low-level errors: networking
  case noData = 300
  case noHTTPResponse = 301
  case unsuccessfulHTTPStatusCode = 302
  case jsonDecodingFail = 303

  func isLowLevelError() -> Bool {
    return rawValue >= 200
  }
}
