//
//  CLPlacemarkLocationStringTests.swift
//  
//  Created by Ernest Fan on 2022-01-25.
//  Copyright © 2022 NYPL. All rights reserved.
//

import XCTest
import CoreLocation
@testable import NYPLCardCreator

class CLPlacemarkLocationStringTests: XCTestCase {

  var geoCoder: CLGeocoder!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    geoCoder = CLGeocoder()
  }
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    geoCoder = nil
  }
  
  func testPlacemarkWithinNYC() throws {
    let expectation = self.expectation(description: "retrivingLocation")
    var result: [CLPlacemark]?
    
    // Latitude and longitude of NYPL
    let location = CLLocation(latitude: 40.753, longitude: -73.982)
    self.geoCoder.reverseGeocodeLocation(location) { placemarks, error in
      if let error = error {
        XCTFail(error.localizedDescription)
      }
      result = placemarks
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    
    guard let result = result else {
      XCTFail()
      return
    }
    
    for placemark in result {
      if placemark.getLocationString() != "nyc" {
        XCTFail("Location string does not match address")
      }
    }
  }
  
  func testPlacemarkWithinNYCWithAlternateCityName() throws {
    let expectation = self.expectation(description: "retrivingLocation")
    var result: [CLPlacemark]?
    
    // Latitude and longitude of Bronx
    let location = CLLocation(latitude: 40.858, longitude: -73.885)
    self.geoCoder.reverseGeocodeLocation(location) { placemarks, error in
      if let error = error {
        XCTFail(error.localizedDescription)
      }
      result = placemarks
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    
    guard let result = result else {
      XCTFail()
      return
    }
    
    for placemark in result {
      if placemark.getLocationString() != "nyc" {
        XCTFail("Location string does not match address")
      }
    }
  }
  
  func testPlacemarkWithinNYS() throws {
    let expectation = self.expectation(description: "retrivingLocation")
    var result: [CLPlacemark]?
    
    // Latitude and longitude of Albany
    let location = CLLocation(latitude: 42.652, longitude: -73.756)
    self.geoCoder.reverseGeocodeLocation(location) { placemarks, error in
      if let error = error {
        XCTFail(error.localizedDescription)
      }
      result = placemarks
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    
    guard let result = result else {
      XCTFail()
      return
    }
    
    for placemark in result {
      if placemark.getLocationString() != "nys" {
        XCTFail("Location string does not match address")
      }
    }
  }
  
  func testPlacemarkWithinUS() throws {
    let expectation = self.expectation(description: "retrivingLocation")
    var result: [CLPlacemark]?
    
    // Latitude and longitude of Seattle
    let location = CLLocation(latitude: 47.620, longitude: -122.349)
    self.geoCoder.reverseGeocodeLocation(location) { placemarks, error in
      if let error = error {
        XCTFail(error.localizedDescription)
      }
      result = placemarks
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    
    guard let result = result else {
      XCTFail()
      return
    }
    
    for placemark in result {
      if placemark.getLocationString() != "us" {
        XCTFail("Location string does not match address")
      }
    }
  }
  
  func testPlacemarkOutsideUS() throws {
    let expectation = self.expectation(description: "retrivingLocation")
    var result: [CLPlacemark]?
    
    // Latitude and longitude of Vancouver
    let location = CLLocation(latitude: 49.288, longitude: -123.116)
    self.geoCoder.reverseGeocodeLocation(location) { placemarks, error in
      if let error = error {
        XCTFail(error.localizedDescription)
      }
      result = placemarks
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 3, handler: nil)
    
    guard let result = result else {
      XCTFail()
      return
    }
    
    for placemark in result {
      if placemark.getLocationString() != "" {
        XCTFail("Location string does not match address")
      }
    }
  }
}
