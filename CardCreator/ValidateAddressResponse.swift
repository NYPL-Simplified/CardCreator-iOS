import Foundation

class ValidateAddressResponse {  
  enum Response {
    case ValidAddress(message: String, address: Address, cardType: CardType)
    case AlternativeAddresses(message: String, addressTuples: [(Address, CardType)])
    case UnrecognizedAddress(message: String)
  }
  
  class func responseFromData(data: NSData) -> Response? {
    guard
      let JSONObject = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject],
      let type = JSONObject["type"] as? String,
      let message = JSONObject["message"] as? String
      else { return nil }
    
    switch type {
    case "valid-address":
      var cardType = CardType.None
      if JSONObject["card_type"] as? String == "temporary" {
        cardType = .Temporary
      } else if JSONObject["card_type"] as? String == "standard" {
        cardType = .Standard
      }
      guard
        let addressObject = JSONObject["address"],
        let address = Address.addressWithJSONObject(addressObject)
        else { return nil }
      return Response.ValidAddress(message: message, address: address, cardType: cardType)
    case "alternate-addresses":
      guard let addressContainingObjects = JSONObject["addresses"] as? [AnyObject] else { return nil }
      let addressTuples = addressContainingObjects.flatMap({(object: AnyObject) -> (Address, CardType)? in
        guard
          let JSONObject = object as? [String: AnyObject],
          let addressJSON = JSONObject["address"] as? [String: AnyObject],
          let address = Address.addressWithJSONObject(addressJSON),
          let cardTypeString = JSONObject["card_type"] as? String
          else { return nil }
        var cardType = CardType.None
        if cardTypeString == "temporary" {
          cardType = .Temporary
        } else if cardTypeString == "standard" {
          cardType = .Standard
        }
        return (address, cardType)
      })
      return Response.AlternativeAddresses(message: message, addressTuples: addressTuples)
    case "unrecognized-address":
      return Response.UnrecognizedAddress(message: message)
    default:
      break
    }
    
    return nil
  }
}
