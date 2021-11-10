import Foundation

struct Address {
  let street1: String
  let street2: String?
  let city: String
  let region: String
  let zip: String
  let isResidential: Bool
  let hasBeenValidated: Bool
  
  /// Takes a JSON object of the form retured from the server (where "state" is mapped
  /// to the `region` property).
  static func addressWithJSONObject(_ object: Any) -> Address? {
    guard
      let address = object as? [String: AnyObject],
      let street1 = address["line1"] as? String,
      let city = address["city"] as? String,
      let region = address["state"] as? String,
      let zip = address["zip"] as? String
      else
    {
      return nil
    }
    
    let isResidential = address["isResidential"] as? Bool ?? false
    let hasBeenValidated = address["hasBeenValidated"] as? Bool ?? false
    
    return Address(street1: street1, street2: address["line2"] as? String, city: city, region: region, zip: zip, isResidential: isResidential, hasBeenValidated: hasBeenValidated)
  }
  
  /// Returns a JSON object of the form required by the server.
  func JSONObject() -> [String: String] {
    return [
      "line1": self.street1,
      "line2": self.street2 == nil ? "" : self.street2!,
      "city": self.city,
      "state": self.region,
      "zip": self.zip,
      "isResidential": String(self.isResidential),
      "hasBeenValidated": String(self.hasBeenValidated)
    ]
  }
}
