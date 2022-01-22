//
//  CLPlacemark+LocationString.swift
//  Created by Ernest Fan on 2022-01-24.
//  Copyright © 2022 NYPL. All rights reserved.
//

import Foundation
import CoreLocation

extension CLPlacemark {
  /// This method determines if the location is within NYC, NYS, US or none of the above,
  /// for patron creation purpose.
  /// - Returns: A location string, eg. nyc, nys, us or an empty string
  func getLocationString() -> String {
    guard isoCountryCode == "US" else {
      return ""
    }
    
    guard administrativeArea == "NY" else {
      return "us"
    }
    
    guard let postalCodeString = postalCode,
      let postalCodeNumber = Int(postalCodeString) else {
      return "nys"
    }

    if (10001...10499).contains(postalCodeNumber) ||
        (11001...11499).contains(postalCodeNumber) ||
        (11601...11699).contains(postalCodeNumber) {
      return "nyc"
    }
    
    return "nys"
  }
}
