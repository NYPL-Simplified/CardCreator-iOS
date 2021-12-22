// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "NYPLCardCreator",
  platforms: [.iOS(.v10), .macOS(.v10_12)],
  products: [
    .library(name: "NYPLCardCreator",
             targets: ["NYPLCardCreator"]),
  ],
  dependencies: [
    .package(name: "NYPLUtilities",
             url: "https://github.com/NYPL-Simplified/iOS-Utilities.git",
             branch: "main"),
    .package(url: "https://github.com/PureLayout/PureLayout.git", from: "3.1.9"),
  ],
  targets: [
    .target(
      name: "NYPLCardCreator",
      dependencies: ["NYPLUtilities", "PureLayout"],
      path: "NYPLCardCreator",
      exclude: [
        "Info.plist", "NYPLCardCreator.h"
      ],
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "NYPLCardCreatorTests",
      dependencies: ["NYPLCardCreator"],
      path: "NYPLCardCreatorTests",
      exclude: [
        "Info.plist"
      ]
    ),
  ]
)
