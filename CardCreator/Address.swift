import Foundation

struct Address {
  let street1: String
  let street2: String?
  let city: String
  let region: String
  let zip: String
  
  static func addressFromJSONObject(object: AnyObject) -> Address? {
    guard
      let address = object as? [String: AnyObject],
      let street1 = address["line_1"] as? String,
      let city = address["city"] as? String,
      let region = address["state"] as? String,
      let zip = address["zip"] as? String
      else
    {
      return nil
    }
    
    return Address(street1: street1, street2: address["line_2"] as? String, city: city, region: region, zip: zip)
  }
}
