import Foundation

struct Address {
  let street1: String
  let street2: String?
  let city: String
  let region: String
  let zip: String
  
  static func addressFromJSONObject(object: AnyObject) -> Address? {
    guard
      let object = object as? [String: String],
      let street1 = object["line_1"],
      let city = object["city"],
      let region = object["state"],
      let zip = object["zip"]
      else
    {
      return nil
    }
    
    return Address(street1: street1, street2: object["line_2"], city: city, region: region, zip: zip)
  }
}
