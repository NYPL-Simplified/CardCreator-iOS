import UIKit

/// This class is used to allow the user to enter their desired username and PIN.
final class UsernameAndPINViewController: FormTableViewController {
  
  private let configuration: CardCreatorConfiguration
  
  private let usernameCell: LabelledTextViewCell
  private let pinCell: LabelledTextViewCell
  private let homeAddress: Address
  private let schoolOrWorkAddress: Address?
  private let cardType: CardType
  private let fullName: String
  private let email: String
  
  private let session: AuthenticatingSession
  
  init(
    configuration: CardCreatorConfiguration,
    homeAddress: Address,
    schoolOrWorkAddress: Address?,
    cardType: CardType,
    fullName: String,
    email: String)
  {
    self.configuration = configuration
    self.usernameCell = LabelledTextViewCell(
      title: NSLocalizedString("Username", comment: "A username used to log into a service"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    self.pinCell = LabelledTextViewCell(
      title: NSLocalizedString("PIN", comment: "An abbreviation for personal identification number"),
      placeholder: NSLocalizedString("Required", comment: "A placeholder for a required text field"))
    
    self.homeAddress = homeAddress
    self.schoolOrWorkAddress = schoolOrWorkAddress
    self.cardType = cardType
    self.fullName = fullName
    self.email = email
    
    self.session = AuthenticatingSession(configuration: configuration)
    
    super.init(
      cells: [
        self.usernameCell,
        self.pinCell
      ])
    
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    
    self.prepareTableViewCells()
    self.checkToPrefillForm()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = NSLocalizedString(
      "User Details",
      comment: "A title for a screen asking the user for the user's username and PIN")
  }
  
  private func prepareTableViewCells() {
    for cell in self.cells {
      if let labelledTextViewCell = cell as? LabelledTextViewCell {
        labelledTextViewCell.selectionStyle = .none
        labelledTextViewCell.textField.delegate = self
        labelledTextViewCell.textField.addTarget(self,
                                                 action: #selector(textFieldDidChange),
                                                 for: .editingChanged)
      }
    }
    
    self.usernameCell.textField.keyboardType = .alphabet
    self.usernameCell.textField.autocapitalizationType = .none
    self.usernameCell.textField.autocorrectionType = .no
    
    self.pinCell.textField.keyboardType = .numberPad
    self.pinCell.textField.inputAccessoryView = self.returnToolbar()
  }
  
  func checkToPrefillForm() {
    let user = self.configuration.user
    if let username = user.username {
      self.usernameCell.textField.text = username
      textFieldDidChange()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if isMovingFromParent {
      self.configuration.user.username = self.usernameCell.textField.text
    }
  }
  
  // MARK: UITableViewDataSource
  
  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return NSLocalizedString(
      "Username should be 5–25 letters and numbers only.\nPIN should be 4 numeric characters only.",
      comment: "A description of valid usernames and PINs")
  }
  
  // MARK: UITextFieldDelegate
  
  @objc func textField(_ textField: UITextField,
                       shouldChangeCharactersInRange range: NSRange,
                                                     replacementString string: String) -> Bool
  {
    guard string.canBeConverted(to: String.Encoding.ascii) else {
      return false
    }
    
    if textField == self.usernameCell.textField {
      if let _ = string.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) {
        return false
      } else if let text = textField.text {
        return text.count - range.length + string.count <= 25
      } else {
        return string.count <= 25
      }
    }
    
    if textField == self.pinCell.textField {
      if let _ = string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) {
        return false
      } else if let text = textField.text {
        return text.count - range.length + string.count <= 4
      } else {
        return string.count <= 4
      }
    }

    assert(false)
    return false
  }
  
  // MARK: -
  
  @objc override func didSelectNext() {
    if configuration.isJuvenile {
      moveToFinalReview()
      return
    }

    self.view.endEditing(false)
    self.navigationController?.view.isUserInteractionEnabled = false
    self.navigationItem.titleView =
      ActivityTitleView(title:
        NSLocalizedString(
          "Validating Name",
          comment: "A title telling the user their full name is currently being validated"))
    var request = URLRequest.init(url: self.configuration.endpointURL.appendingPathComponent("validate/username"))
    let JSONObject: [String: String] = ["username": self.usernameCell.textField.text!]
    request.httpBody = try! JSONSerialization.data(withJSONObject: JSONObject, options: [.prettyPrinted])
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = self.configuration.requestTimeoutInterval
    let task = self.session.dataTaskWithRequest(request) { [weak self] data, response, error in
      OperationQueue.main.addOperation {
        guard let self = self else {
          return
        }
        self.navigationController?.view.isUserInteractionEnabled = true
        self.navigationItem.titleView = nil

        if let error = error {
          self.showErrorAlert(message: error.localizedDescription)
          return
        }

        guard let response = response as? HTTPURLResponse,
          response.statusCode == 200,
          let data = data,
          let decodedData = ValidateUsernameResponse.responseWithData(data) else {
            self.showErrorAlert()
            return
        }

        switch decodedData {
        case .unavailableUsername:
          self.showErrorAlert(
            title: NSLocalizedString("Username Unavailable", comment: "The title for an error alert"),
            message: NSLocalizedString(
              "Your chosen username is already in use. Please choose another and try again.",
              comment: "An alert message explaining an error and telling the user to try again"))
        case .invalidUsername:
          // We should never be here due to client-side validation, but we'll report it anyway.
          self.showErrorAlert(
            title: NSLocalizedString("Username Invalid", comment: "The title for an error alert"),
            message: NSLocalizedString(
              "Usernames must be 5–25 letters and numbers only. Please revise your username.",
              comment: "An alert message explaining an error and telling the user to try again"))
        case .availableUsername:
          self.moveToFinalReview()
        }
      }
    }
    
    task.resume()
  }

  @objc private func textFieldDidChange() {
    guard let usernameTextCount = self.usernameCell.textField.text?.count,
          let pinCellTextCount = self.pinCell.textField.text?.count else {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        return
    }
    self.navigationItem.rightBarButtonItem?.isEnabled = (usernameTextCount >= configuration.usernameMinLength && pinCellTextCount == 4)
  }
  
  private func moveToFinalReview() {
    self.view.endEditing(false)
    self.navigationController?.pushViewController(
      UserSummaryViewController(
        configuration: self.configuration,
        homeAddress: self.homeAddress,
        schoolOrWorkAddress: self.schoolOrWorkAddress,
        cardType: self.cardType,
        fullName: self.fullName,
        email: self.email,
        username: self.usernameCell.textField.text!,
        pin: self.pinCell.textField.text!),
      animated: true)
  }

  /// - parameter title: If missing, defaults to generic error title.
  /// - parameter message: If missing, defaults to server error message.
  private func showErrorAlert(title: String? = nil, message: String? = nil) {
    let alertTitle = title ?? NSLocalizedString(
      "Error",
      comment: "The title for an error alert")

    let alertMessage = message ?? NSLocalizedString(
      "A server error occurred during username validation. Please try again later.",
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
