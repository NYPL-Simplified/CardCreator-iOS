//
//  UIViewController+Alerts.swift
//  NYPLCardCreator
//
//  Created by Ettore Pasquini on 12/1/21.
//  Copyright © 2021 NYPL Labs. All rights reserved.
//

import Foundation

extension UIViewController {
  /// - parameter title: If missing, defaults to generic error title.
  /// - parameter message: If missing, defaults to generic error message.
  func showErrorAlert(title: String? = nil, message: String? = nil) {
    let alertTitle = title ?? NSLocalizedString(
      "Error",
      comment: "The title for an error alert")

    let alertMessage = message ?? NSLocalizedString(
      "An error occurred. Please try again later.",
      comment: "An alert message explaining an error and telling the user to try again later")

    let alertController = UIAlertController(
      title: alertTitle,
      message: alertMessage,
      preferredStyle: .alert)
    alertController.addAction(UIAlertAction(
      title: NSLocalizedString("OK", comment: ""),
      style: .default,
      handler: nil))
    self.present(alertController, animated: true, completion: nil)
  }
}
