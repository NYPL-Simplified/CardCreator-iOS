import Foundation

class PasswordValidator {
  /// Below are the rules for the password
  /// 1. Password must be between 8 - 32 characters
  /// 2. Password can be a combination of numbers, uppercase / lowercase letters and the following symbols [~ ! ? @ # $ % ^ & * ( )]
  /// 3. Password cannot consecutively repeat a character 3 or more times, eg. aaa3ka2l
  /// 4. Password cannot consecutively repeat (2 or more times) a pattern of any 2, 3, or 4-character string. eg. 12341234
  static func validatePassword(_ password: String) -> Bool {
    // Rule 1
    guard password.count >= 8 && password.count <= 32 else {
      return false
    }
    
    // Rule 2
    guard password.range(of: #"[^a-zA-Z0-9~!?@#$%^&*()]"#, options: .regularExpression) == nil else {
      return false
    }
    
    // Rule 3
    guard password.range(of: #"(.)\1\1"#, options: .regularExpression) == nil else {
      return false
    }
    
    // Rule 4
    // "\w" might include underscore but we have already done character check above, so it should be safe
    guard password.range(of: #"([\w~!?@#$%^&*()]{2,4})\1+"#, options: .regularExpression) == nil else {
      return false
    }
    
    return true
  }
}
