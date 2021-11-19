import Foundation

enum PasswordValidationError {
  case invalidCount
  case invalidCharacter
  case repeatingCharacter
  case repeatingPattern
  
  func errorMessage() -> String {
    switch self {
    case .invalidCount:
      return NSLocalizedString("Password must be between 4 - 32 characters", comment: "The error message for the invalid password")
    case .invalidCharacter:
      return NSLocalizedString("Password can only contain letters, numbers or the following symbols ~ ! ? @ # $ % ^ & * ( ) ", comment: "The error message for the invalid password")
    case .repeatingCharacter:
      return NSLocalizedString("Password cannot consecutively repeat a character 3 or more times", comment: "The error message for the invalid password")
    case .repeatingPattern:
      return NSLocalizedString("Password cannot consecutively repeat a pattern", comment: "The error message for the invalid password")
    }
  }
}

class PasswordValidator {
  /// Below are the rules for the password
  /// 1. Password must be between 4 - 32 characters
  /// 2. Password can be a combination of numbers, uppercase / lowercase letters and the following symbols [~ ! ? @ # $ % ^ & * ( )]
  /// 3. Password cannot consecutively repeat a character 3 or more times, eg. aaa3ka2l
  /// 4. Password cannot consecutively repeat (2 or more times) a pattern of any 2, 3, or 4-character string. eg. 12341234
  static func validate(password: String?) -> PasswordValidationError? {
    // Rule 1
    guard let password = password,
          password.count >= 4 && password.count <= 32 else {
      return .invalidCount
    }
    
    // Rule 2
    guard password.range(of: #"[^a-zA-Z0-9~!?@#$%^&*()]"#, options: .regularExpression) == nil else {
      return .invalidCharacter
    }
    
    // Rule 3
    guard password.range(of: #"(.)\1\1"#, options: .regularExpression) == nil else {
      return .repeatingCharacter
    }
    
    // Rule 4
    // "\w" might include underscore but we have already done character check above, so it should be safe
    guard password.range(of: #"([\w~!?@#$%^&*()]{2,4})\1+"#, options: .regularExpression) == nil else {
      return .repeatingPattern
    }
    
    return nil
  }
}
