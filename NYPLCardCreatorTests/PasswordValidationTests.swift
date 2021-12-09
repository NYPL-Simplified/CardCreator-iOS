import XCTest
@testable import NYPLCardCreator

class PasswordValidationTests: XCTestCase {
  var config: CardCreatorConfiguration!
  var passwordValidator: PasswordValidator!

  override func setUp() {
    super.setUp()
    config = CardCreatorConfiguration(
      endpointUsername: "test",
      endpointPassword: "password",
      platformAPIInfo: NYPLPlatformAPIInfo(
        oauthTokenURL: URL(string: "https://example.com/token")!,
        clientID: "clientID",
        clientSecret: "secret",
        baseURL: URL(string: "https://example.com")!)!,
      requestTimeoutInterval: 1.0)
    passwordValidator = PasswordValidator(configuration: config)
  }

  override func tearDown() {
    config = nil
    passwordValidator = nil
    super.tearDown()
  }

  func testPasswordCharacterCount() throws {
    XCTAssertNil(passwordValidator.validate(password: "12345678"), "Password is valid")
    XCTAssertEqual(passwordValidator.validate(password: "1234"), .invalidCount)
    
    let stringWithMaxCharacters = "abcdefghijklmnopqrstuvwxyz123456"
    XCTAssertNil(passwordValidator.validate(password: stringWithMaxCharacters), "Password character count is valid")
    
    XCTAssertEqual(passwordValidator.validate(password: stringWithMaxCharacters + "a"), .invalidCount)
  }
  
  func testSymbols() throws {
    let validSymbolString = #"~!?@#$%^&*()"#
    XCTAssertNil(passwordValidator.validate(password: validSymbolString), "Password is valid")
    
    XCTAssertEqual(passwordValidator.validate(password: "1234567<"), .invalidCharacter)
    XCTAssertEqual(passwordValidator.validate(password: "1234567>"), .invalidCharacter)
    XCTAssertEqual(passwordValidator.validate(password: #"1234567\"#), .invalidCharacter)
    XCTAssertEqual(passwordValidator.validate(password: "1234567/"), .invalidCharacter)
    XCTAssertEqual(passwordValidator.validate(password: "1234567."), .invalidCharacter)
    XCTAssertEqual(passwordValidator.validate(password: "1234567 "), .invalidCharacter)
  }

  func testRepeatingCharacters() throws {
    XCTAssertNil(passwordValidator.validate(password: "aabbccddeeffgg"), "Password is valid")
    
    XCTAssertEqual(passwordValidator.validate(password: "1234444asd"), .repeatingCharacter)
    XCTAssertEqual(passwordValidator.validate(password: "111asbciwhnk@#$"), .repeatingCharacter)
    XCTAssertEqual(passwordValidator.validate(password: "123aaa567"), .repeatingCharacter)
    XCTAssertEqual(passwordValidator.validate(password: "abcdefg00000000000000"), .repeatingCharacter)
    XCTAssertEqual(passwordValidator.validate(password: "aolghe$$$$$"), .repeatingCharacter)
    XCTAssertEqual(passwordValidator.validate(password: "123@@@mcns"), .repeatingCharacter)
  }
  
  func testRepeatingPatterns() throws {
    XCTAssertNil(passwordValidator.validate(password: "aa4567aa"), "Password is valid")
    XCTAssertNil(passwordValidator.validate(password: "abc12abc"), "Password is valid")
    XCTAssertNil(passwordValidator.validate(password: "aabb234bbaa"), "Password is valid")
    XCTAssertNil(passwordValidator.validate(password: "1234512345"), "Password is valid")
    XCTAssertNil(passwordValidator.validate(password: "~~aa~~AA"), "Password is valid")
    XCTAssertNil(passwordValidator.validate(password: "~~aa~~AA~~aa"), "Password is valid")
    
    XCTAssertEqual(passwordValidator.validate(password: "ab1212ab"), .repeatingPattern)
    XCTAssertEqual(passwordValidator.validate(password: "12124545"), .repeatingPattern)
    XCTAssertEqual(passwordValidator.validate(password: "abcabc12"), .repeatingPattern)
    XCTAssertEqual(passwordValidator.validate(password: "~!@~!@~!@~!@~!@"), .repeatingPattern)
    XCTAssertEqual(passwordValidator.validate(password: "abcdabcd"), .repeatingPattern)
    XCTAssertEqual(passwordValidator.validate(password: "~~aa~~aa"), .repeatingPattern)
    XCTAssertEqual(passwordValidator.validate(password: "~~aa~~AA~~aa~~aa"), .repeatingPattern)
  }
}
