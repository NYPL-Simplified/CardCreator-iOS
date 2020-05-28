//
//  NYPLCardCreatorTests.swift
//  NYPLCardCreatorTests
//
//  Created by Ettore Pasquini on 5/27/20.
//  Copyright © 2020 NYPL Labs. All rights reserved.
//

import XCTest
@testable import NYPLCardCreator

class JuvenileCreationResponseBodyTests: XCTestCase {
  let successfulResponse = """
  {
    "status": 200,
    "data": {
      "dependent": {
        "id": 666,
        "username": "ciccio",
        "name": "first name, last name",
        "barcode": "2380000121666",
        "pin": "1234",
        "link": "https://nypl-sierra-test.nypl.org/iii/sierra-api/v6/patrons/666"
      },
      "parent": {
        "updated": true
      }
    }
  }
  """

  func testDecode() throws {
    guard let jsonData = successfulResponse.data(using: .utf8) else {
      XCTFail("unable to encode JSON test response to Data")
      return
    }
    let decoded = JuvenileCreationResponseBody.fromData(jsonData)
    XCTAssertNotNil(decoded)
    XCTAssertEqual(decoded?.barcode, "2380000121666")
  }
}
