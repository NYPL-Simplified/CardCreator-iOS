import Foundation

@objc public class Configuration: NSObject {
  public var endpointURL: NSURL = NSURL(string: "http://qa.patrons.librarysimplified.org/v1")!
  public var requestTimeoutInterval: NSTimeInterval = 10.0
  public var completionHandler: (barcode: String, PIN: String) -> Void = {_ in}
}
