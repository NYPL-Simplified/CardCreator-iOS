//
//  PlatformAPIErrorTests.swift
//  NYPLCardCreatorTests
//
//  Created by Ettore Pasquini on 12/9/21.
//  Copyright © 2021 NYPL. All rights reserved.
//

import XCTest
@testable import NYPLCardCreator

class PlatformAPIErrorTests: XCTestCase {

  override func setUpWithError() throws {
  }

  override func tearDownWithError() throws {
  }

  func testParseFullyQualifiedError() throws {
    let jsonString = """
    {
      "status": 400,
      "type": "invalid-request",
      "title": "Invalid Request",
      "detail": "Here is the detail.",
      "message": "Here is the message.",
      "name": "The name",
      "error": {
        "email": "Email is wrong.",
        "password": "Password is messed up.",
        "birthdate": "Bday ain't right."
      }
    }
    """
    let jsonData = jsonString.data(using: .utf8)

    // test
    let error = PlatformAPIError.fromData(jsonData!)

    // verify
    guard let error = error else {
      XCTFail("couldn't parse error")
      return
    }
    XCTAssertEqual(error.status, 400)
    XCTAssertEqual(error.type, "invalid-request")
    XCTAssertEqual(error.title, "Invalid Request")
    XCTAssertEqual(error.detail, "Here is the detail.")
    XCTAssertEqual(error.message, "Here is the message.")
    XCTAssertEqual(error.fullErrorDetails, """
      Here is the detail.
      Bday ain't right.
      Email is wrong.
      Password is messed up.
      """)
  }

  func testParseMinimalError() throws {
    let jsonString = """
    {
      "status": 502,
      "type": "ils-integration-error",
      "message": "The ILS messed up.",
    }
    """
    let jsonData = jsonString.data(using: .utf8)

    // test
    let error = PlatformAPIError.fromData(jsonData!)

    // verify
    guard let error = error else {
      XCTFail("couldn't parse error")
      return
    }
    XCTAssertEqual(error.status, 502)
    XCTAssertEqual(error.type, "ils-integration-error")
    XCTAssertNil(error.detail)
    XCTAssertEqual(error.message, "The ILS messed up.")
    XCTAssertEqual(error.fullErrorDetails, """
      The ILS messed up.
      """)
  }

  func testParseEmptyErrorHash() throws {
    let jsonString = """
    {
      "status": 500,
      "error": {}
    }
    """
    let jsonData = jsonString.data(using: .utf8)

    // test
    let error = PlatformAPIError.fromData(jsonData!)

    // verify
    guard let error = error else {
      XCTFail("couldn't parse error")
      return
    }
    XCTAssertEqual(error.status, 500)
    XCTAssertEqual(error.fullErrorDetails, """
      An error occurred. Please try again later.
      """)
  }

  func testParseBareMinimalError() throws {
    let jsonString = """
    {
      "status": 401,
    }
    """
    let jsonData = jsonString.data(using: .utf8)

    // test
    let error = PlatformAPIError.fromData(jsonData!)

    // verify
    guard let error = error else {
      XCTFail("couldn't parse error")
      return
    }
    XCTAssertEqual(error.status, 401)
    XCTAssertEqual(error.fullErrorDetails, """
      An error occurred. Please try again later.
      """)
  }
}
