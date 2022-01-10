//
//  CardCreatorConfigurationTests.swift
//  NYPLCardCreatorTests
//
//  Created by Ettore Pasquini on 11/9/20.
//  Copyright © 2020 NYPL. All rights reserved.
//

import XCTest
@testable import NYPLCardCreator

class CardCreatorConfigurationTests: XCTestCase {
  func testJuvenileFullNameCreation() throws {
    // preconditions
    let juvenileConfig = CardCreatorConfiguration(
      endpointUsername: "test",
      endpointPassword: "password",
      platformAPIInfo: NYPLPlatformAPIInfo(
        oauthTokenURL: URL(string: "https://example.com/token")!,
        clientID: "clientID",
        clientSecret: "secret",
        baseURL: URL(string: "https://example.com")!)!,
      juvenileParentBarcode: "parent",
      requestTimeoutInterval: 1.0)
    XCTAssert(juvenileConfig.isJuvenile)

    // test
    XCTAssertEqual(juvenileConfig.fullName(forFirstName: "John",
                                           middleInitial: nil,
                                           lastName: "Smith"),
                   "John Smith")
    XCTAssertEqual(juvenileConfig.fullName(forFirstName: "John",
                                           middleInitial: "U",
                                           lastName: "Smith"),
                   "John Smith")
    XCTAssertEqual(juvenileConfig.fullName(forFirstName: "John",
                                           middleInitial: nil,
                                           lastName: ""),
                   "John")
    XCTAssertEqual(juvenileConfig.fullName(forFirstName: "John",
                                           middleInitial: "U",
                                           lastName: ""),
                   "John")
  }

  func testRegularFullNameCreation() throws {
    // preconditions
    let config = CardCreatorConfiguration(
      endpointUsername: "test",
      endpointPassword: "password",
      platformAPIInfo: NYPLPlatformAPIInfo(
        oauthTokenURL: URL(string: "https://example.com/token")!,
        clientID: "clientID",
        clientSecret: "secret",
        baseURL: URL(string: "https://example.com")!)!,
      requestTimeoutInterval: 1.0)
    XCTAssertFalse(config.isJuvenile)

    // test
    XCTAssertEqual(config.fullName(forFirstName: "John",
                                   middleInitial: nil,
                                   lastName: "Smith"),
                   "Smith, John")
    XCTAssertEqual(config.fullName(forFirstName: "John",
                                           middleInitial: "U",
                                           lastName: "Smith"),
                   "Smith, John U")
  }
}
