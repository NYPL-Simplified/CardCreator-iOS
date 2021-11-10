import Foundation

final class ValidateAddressResponse {  
  enum Response {
    case validAddress(address: Address, cardType: CardType)
    case alternativeAddresses(message: String?, addresses: [Address])
    case unrecognizedAddress(message: String)
  }
  
  class func responseWithData(_ data: Data) -> Response? {
    guard
      let JSONObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
      let type = JSONObject["type"] as? String
      else { return nil }
    switch type {
    case "valid-address":
      // The v0.3 API does not return a card type value, keeping this for future proof
      var cardType = CardType.none
      if let cardTypeString = JSONObject["cardType"] as? String,
         let newValue = CardType.init(rawValue: cardTypeString) {
        cardType = newValue
      }
      guard
        let addressObject = JSONObject["address"],
        let address = Address.addressWithJSONObject(addressObject)
        else { return nil }
      return Response.validAddress(address: address, cardType: cardType)
    case "alternate-addresses":
      guard let addressObjects = JSONObject["addresses"] as? [[String: AnyObject]] else {
        return nil
      }
      let message = JSONObject["message"] as? String
      let addresses = addressObjects.compactMap { Address.addressWithJSONObject($0) }
      return Response.alternativeAddresses(message: message, addresses: addresses)
    case "unrecognized-address":
      guard let message = JSONObject["message"] as? String else { return nil }
      return Response.unrecognizedAddress(message: message)
    default:
      break
    }
    
    return nil
  }
}
