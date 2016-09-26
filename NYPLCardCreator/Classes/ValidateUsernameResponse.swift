import Foundation

final class ValidateUsernameResponse {
  enum Response {
    case InvalidUsername
    case UnavailableUsername
    case AvailableUsername
  }
  
  class func responseWithData(data: NSData) -> Response? {
    guard
      let JSONObject = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject],
      let type = JSONObject["type"] as? String
      else { return nil }
    
    switch type {
    case "invalid-username":
      return .InvalidUsername
    case "unavailable-username":
      return .UnavailableUsername
    case "available-username":
      return .AvailableUsername
    default:
      break
    }
    
    return nil
  }
}
