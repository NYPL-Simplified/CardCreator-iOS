import Foundation

final class Configuration {
  static let APIEndpoint = NSURL(string: "http://qa.patrons.librarysimplified.org/v1")!
  static let requestTimeoutInterval = 10.0
}
