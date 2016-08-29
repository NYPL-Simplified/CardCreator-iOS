import Foundation

class ValidateAddressResponse {
  enum CardType {
    case None
    case Temporary
    case Standard
  }
  
  enum Response {
    case ValidAddress(message: String, address: Address, cardType: CardType)
    case AlternateAddresses(message: String, addresses: [Address])
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
        let address = Address.addressFromJSONObject(addressObject)
        else { return nil }
      return Response.ValidAddress(message: message, address: address, cardType: cardType)
    case "alternate-addresses":
      guard
        let addressObjects = JSONObject["addresses"] as? [AnyObject],
        let addresses = addressObjects.map(Address.addressFromJSONObject) as? [Address]
        else { return nil }
      return Response.AlternateAddresses(message: message, addresses: addresses)
    case "unrecognized-address":
      return Response.UnrecognizedAddress(message: message)
    default:
      break
    }
    
    return nil
  }
}
