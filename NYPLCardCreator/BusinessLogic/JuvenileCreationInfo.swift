//
//  JuvenileCreationInfo.swift
//  NYPLCardCreator
//
//  Created by Ettore Pasquini on 5/25/20.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

import Foundation

/// An encodable struct that contains the information necessary to create a
/// juvenile account.
struct JuvenileCreationInfo: Encodable {
  /// The barcode of the parent creating the juvenile account.
  let parentBarcode: String

  // The juvenile's full name.
  let name: String

  // The juvenile's username.
  let username: String

  // The juvenile's pin.
  let pin: String

  enum CodingKeys: String, CodingKey {
    case parentBarcode = "barcode"
    case name, username, pin
  }

  func encode() -> Data? {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let data = try? encoder.encode(self)
    return data
  }
}
