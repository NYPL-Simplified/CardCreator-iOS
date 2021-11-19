import XCTest
@testable import NYPLCardCreator

class PasswordValidationTests: XCTestCase {
  func testPasswordCharacterCount() throws {
    XCTAssertNil(PasswordValidator.validate(password: "1234"), "Password is valid")
    XCTAssertEqual(PasswordValidator.validate(password: "123"), .invalidCount)
    
    let stringWithMaxCharacters = "abcdefghijklmnopqrstuvwxyz123456"
    XCTAssertNil(PasswordValidator.validate(password: stringWithMaxCharacters), "Password character count is valid")
    
    XCTAssertEqual(PasswordValidator.validate(password: stringWithMaxCharacters + "a"), .invalidCount)
  }
  
  func testSymbols() throws {
    let validSymbolString = #"~!?@#$%^&*()"#
    XCTAssertNil(PasswordValidator.validate(password: validSymbolString), "Password is valid")
    
    XCTAssertEqual(PasswordValidator.validate(password: "1234567<"), .invalidCharacter)
    XCTAssertEqual(PasswordValidator.validate(password: "1234567>"), .invalidCharacter)
    XCTAssertEqual(PasswordValidator.validate(password: #"1234567\"#), .invalidCharacter)
    XCTAssertEqual(PasswordValidator.validate(password: "1234567/"), .invalidCharacter)
    XCTAssertEqual(PasswordValidator.validate(password: "1234567."), .invalidCharacter)
    XCTAssertEqual(PasswordValidator.validate(password: "1234567 "), .invalidCharacter)
  }

  func testRepeatingCharacters() throws {
    XCTAssertNil(PasswordValidator.validate(password: "aabbccddeeffgg"), "Password is valid")
    
    XCTAssertEqual(PasswordValidator.validate(password: "1234444asd"), .repeatingCharacter)
    XCTAssertEqual(PasswordValidator.validate(password: "111asbciwhnk@#$"), .repeatingCharacter)
    XCTAssertEqual(PasswordValidator.validate(password: "123aaa567"), .repeatingCharacter)
    XCTAssertEqual(PasswordValidator.validate(password: "abcdefg00000000000000"), .repeatingCharacter)
    XCTAssertEqual(PasswordValidator.validate(password: "aolghe$$$$$"), .repeatingCharacter)
    XCTAssertEqual(PasswordValidator.validate(password: "123@@@mcns"), .repeatingCharacter)
  }
  
  func testRepeatingPatterns() throws {
    XCTAssertNil(PasswordValidator.validate(password: "aa4567aa"), "Password is valid")
    XCTAssertNil(PasswordValidator.validate(password: "abc12abc"), "Password is valid")
    XCTAssertNil(PasswordValidator.validate(password: "aabb234bbaa"), "Password is valid")
    XCTAssertNil(PasswordValidator.validate(password: "1234512345"), "Password is valid")
    XCTAssertNil(PasswordValidator.validate(password: "~~aa~~AA"), "Password is valid")
    XCTAssertNil(PasswordValidator.validate(password: "~~aa~~AA~~aa"), "Password is valid")
    
    XCTAssertEqual(PasswordValidator.validate(password: "ab1212ab"), .repeatingPattern)
    XCTAssertEqual(PasswordValidator.validate(password: "12124545"), .repeatingPattern)
    XCTAssertEqual(PasswordValidator.validate(password: "abcabc12"), .repeatingPattern)
    XCTAssertEqual(PasswordValidator.validate(password: "~!@~!@~!@~!@~!@"), .repeatingPattern)
    XCTAssertEqual(PasswordValidator.validate(password: "abcdabcd"), .repeatingPattern)
    XCTAssertEqual(PasswordValidator.validate(password: "~~aa~~aa"), .repeatingPattern)
    XCTAssertEqual(PasswordValidator.validate(password: "~~aa~~AA~~aa~~aa"), .repeatingPattern)
  }
}
