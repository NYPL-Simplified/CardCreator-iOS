//
//  JuvenileCreationResponseBody.swift
//  NYPLCardCreator
//
//  Created by Ettore Pasquini on 5/26/20.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

import Foundation

/// The struct used to decode a successful response of
/// `POST /patrons/dependents` api.
struct JuvenileCreationResponseBody: Decodable {
  // - note: The body of the response contains other pieces of information
  // which are not relevant to us, hence we skip parsing them altogether.
  struct Body: Decodable {
    struct Dependent: Decodable {
      /// The barcode of the newly created juvenile account.
      let barcode: String
    }

    let dependent: Dependent
  }

  private let data: Body

  var barcode: String {
    return data.dependent.barcode
  }

  static func fromData(_ data: Data) -> JuvenileCreationResponseBody? {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try? decoder.decode(JuvenileCreationResponseBody.self, from: data)
  }
}
