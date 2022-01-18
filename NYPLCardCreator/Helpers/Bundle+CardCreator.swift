//
//  Bundle+CardCreator.swift
//  Created by Ettore Pasquini on 1/18/22.
//  Copyright © 2022 NYPL. All rights reserved.
//

#if !SWIFT_PACKAGE

import Foundation

private class NYPLCardCreatorDummy {}

extension Bundle {
  static var module: Bundle {
    return Bundle(for: type(of: NYPLCardCreatorDummy))
  }
}

#endif
