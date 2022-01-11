//
//  PlatformAPIError.swift
//  NYPLCardCreator
//
//  Created by Ettore Pasquini on 5/25/20.
//  Copyright © 2020 NYPL. All rights reserved.
//

import Foundation

/// The NYPL Platform API may return error responses with information about the
/// error that occurred. This struct represents the structure of such responses.
struct PlatformAPIError: Decodable {
  /// HTTP status code
  let status: Int

  /// Error type
  let type: String?

  /// A subject for what went wrong.
  let title: String?

  /// User-friendly error message, usually a succint summary.
  let detail: String?

  /// Legacy user-friendly error message
  let message: String?

  /// This contains more specific and informative error causes.
  let error: [String: String]?

  /// Collates `detail` and `error` values into one string, after sorting the
  /// `error` key-value pairs by key.
  var fullErrorDetails: String {
    let errorHash = error ?? [:]

    let sortedHash = errorHash.sorted { kvPair1, kvPair2 in
      kvPair1.key.lowercased() < kvPair2.key.lowercased()
    }

    let msg = sortedHash.reduce(detail ?? message ?? "") { partialResult, val in
      partialResult + "\n" + val.value
    }

    if msg.isEmpty {
      return NSLocalizedString("An error occurred. Please try again later.",
                               comment: "A fallback error message")
    }

    return msg
  }

  static func fromData(_ data: Data) -> PlatformAPIError? {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try? decoder.decode(PlatformAPIError.self, from: data)
  }
}
