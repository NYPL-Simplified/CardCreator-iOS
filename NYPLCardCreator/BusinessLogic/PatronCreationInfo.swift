import Foundation

// This class looks similar to UserInfo but
// this is designed to store info ready to be send to server,
// while UserInfo is designed to store info entered by user.
struct PatronCreationInfo {
  var name: String
  var email: String
  var username: String
  var password: String
  var homeAddress: Address
  var workAddress: Address?
  var birthdate: String?
  
  init(name: String,
       email: String,
       birthdate: String?,
       username: String,
       password: String,
       homeAddress: Address,
       workAddress: Address?)
  {
    self.name = name
    self.email = email
    self.birthdate = birthdate
    self.username = username
    self.password = password
    self.homeAddress = homeAddress
    self.workAddress = workAddress
  }
  
  func JSONObject() -> [String: AnyObject] {
    let workAddressOrNull: AnyObject = {
      if let workAddress = self.workAddress {
        return workAddress.JSONObject() as AnyObject
      } else {
        return NSNull()
      }
    }()
    
    return [
      "name": self.name as AnyObject,
      "email": self.email as AnyObject,
      "username": self.username as AnyObject,
      "pin": self.password as AnyObject,
      "address": self.homeAddress.JSONObject() as AnyObject,
      "workAddress": workAddressOrNull,
      "usernameHasBeenValidated": true as AnyObject,
      "policyType": "simplye" as AnyObject,
      "ageGate": true as AnyObject,
      "acceptTerms": true as AnyObject,
      "birthdate": self.birthdate as AnyObject
    ]
  }
}
