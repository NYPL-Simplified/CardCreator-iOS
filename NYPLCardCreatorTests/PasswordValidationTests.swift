import XCTest
@testable import NYPLCardCreator

class PasswordValidationTests: XCTestCase {
  func testPasswordCharacterCount() throws {
    XCTAssertFalse(PasswordValidator.validatePassword("1234567"))
    
    XCTAssertTrue(PasswordValidator.validatePassword("12345678"))
    
    let stringWithMaxCharacters = "abcdefghijklmnopqrstuvwxyz123456"
    XCTAssertTrue(PasswordValidator.validatePassword(stringWithMaxCharacters))
    
    XCTAssertFalse(PasswordValidator.validatePassword(stringWithMaxCharacters + "a"))
  }
  
  func testSymbols() throws {
    let validSymbolString = #"~!?@#$%^&*()"#
    XCTAssertTrue(PasswordValidator.validatePassword(validSymbolString))
    
    XCTAssertFalse(PasswordValidator.validatePassword("asdfg_<"))
    XCTAssertFalse(PasswordValidator.validatePassword("asdfg_>"))
    XCTAssertFalse(PasswordValidator.validatePassword(#"asdfg_\"#))
    XCTAssertFalse(PasswordValidator.validatePassword("asdfg_/"))
    XCTAssertFalse(PasswordValidator.validatePassword("asdfg_."))
    XCTAssertFalse(PasswordValidator.validatePassword("asdfg_ "))
  }

  func testRepeatingCharacters() throws {
    XCTAssertTrue(PasswordValidator.validatePassword("aabbccddeeffgg"))
    
    XCTAssertFalse(PasswordValidator.validatePassword("1234444asd"))
    XCTAssertFalse(PasswordValidator.validatePassword("111asbciwhnk@#$"))
    XCTAssertFalse(PasswordValidator.validatePassword("123aaa567"))
    XCTAssertFalse(PasswordValidator.validatePassword("abcdefg00000000000000"))
    XCTAssertFalse(PasswordValidator.validatePassword("aolghe$$$$$"))
    XCTAssertFalse(PasswordValidator.validatePassword("123@@@mcns"))
  }
  
  func testRepeatingPatterns() throws {
    XCTAssertTrue(PasswordValidator.validatePassword("aa4567aa"))
    XCTAssertTrue(PasswordValidator.validatePassword("abc12abc"))
    XCTAssertTrue(PasswordValidator.validatePassword("aabb234bbaa"))
    XCTAssertTrue(PasswordValidator.validatePassword("1234512345"))
    XCTAssertTrue(PasswordValidator.validatePassword("~~aa~~AA"))
    XCTAssertTrue(PasswordValidator.validatePassword("~~aa~~AA~~aa"))
    
    XCTAssertFalse(PasswordValidator.validatePassword("ab1212ab"))
    XCTAssertFalse(PasswordValidator.validatePassword("12124545"))
    XCTAssertFalse(PasswordValidator.validatePassword("abcabc12"))
    XCTAssertFalse(PasswordValidator.validatePassword("~!@~!@~!@~!@~!@"))
    XCTAssertFalse(PasswordValidator.validatePassword("abcdabcd"))
    XCTAssertFalse(PasswordValidator.validatePassword("~~aa~~aa"))
    XCTAssertFalse(PasswordValidator.validatePassword("~~aa~~AA~~aa~~aa"))
  }
}
