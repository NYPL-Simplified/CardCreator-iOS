//
//  PlatformAPIError.swift
//  NYPLCardCreator
//
//  Created by Ettore Pasquini on 5/25/20.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

import Foundation

/// The NYPL Platform API may return error responses with information about the
/// error that occurred. This struct represents the structure of such responses.
struct PlatformAPIError: Decodable {
  /// HTTP status code
  let status: Int

  /// Error type
  let type: String?

  /// User-friendly error message
  let message: String

  static func fromData(_ data: Data) -> PlatformAPIError? {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try? decoder.decode(PlatformAPIError.self, from: data)
  }
}
