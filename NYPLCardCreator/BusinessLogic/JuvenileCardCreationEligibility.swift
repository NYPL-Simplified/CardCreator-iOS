//
//  JuvenileCardCreationEligibility.swift
//  NYPLCardCreator
//
//  Created by Ettore Pasquini on 5/20/20.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

import Foundation

/// The object returned by a successful call to the api that determines the
/// logged-in patron's eligibility to create juvenile library cards.
struct JuvenileCardCreationEligibility: Decodable {
  let eligible: Bool

  /// A user-friendly description of the patron's eligibility status. This
  /// is not localized. It's optional because non-essential to the business
  /// logic.
  let description: String?

  /// Same as `description` except that it provides a default eligibility
  /// error message in case `description` is missing.
  var userFriendlyMessage: String {
    return description ?? NSLocalizedString("This card type is not eligible to create dependent cards.", comment: "A generic message for lacking eligibility for juvenile card creation")
  }

  static func fromData(_ data: Data) -> JuvenileCardCreationEligibility? {
    let decoder = JSONDecoder()
    return try? decoder.decode(JuvenileCardCreationEligibility.self, from: data)
  }
}
