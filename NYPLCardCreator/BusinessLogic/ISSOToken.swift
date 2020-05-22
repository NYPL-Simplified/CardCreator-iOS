//
//  ISSOToken.swift
//  NYPLCardCreator
//
//  Created by Ettore Pasquini on 5/19/20.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

import Foundation

struct ISSOToken: Decodable {
  let accessToken: String
  let expiresIn: TimeInterval? // Optional because non-essential

  private let tokenTypeInternal: String?

  /// Defaults to `Bearer` type in case an actual token type is missing.
  var tokenType: String {
    return tokenTypeInternal ?? "Bearer"
  }

  enum CodingKeys: String, CodingKey {
    case accessToken, expiresIn
    case tokenTypeInternal = "tokenType"
  }

  static func fromData(_ data: Data) -> ISSOToken? {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    return try? jsonDecoder.decode(ISSOToken.self, from: data)
  }
}
