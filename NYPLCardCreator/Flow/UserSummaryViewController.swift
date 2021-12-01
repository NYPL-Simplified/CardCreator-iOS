import UIKit

protocol JuvenileCardCreationResponder {
  /// The callback to handle the result of the api response for creating a
  /// juvenile account. In case of error, the error must include a
  /// user-friendly error message.
  func handleJuvenilePatronResponse(_: Result<String>)
}

/// This class is used for summarizing the user's details before
/// submitting the request to create a library card.
final class UserSummaryViewController: TableViewController, JuvenileCardCreationResponder {
  private var cells: [UITableViewCell]
  private let headerLabel: UILabel
  
  private let configuration: CardCreatorConfiguration
  private let authToken: ISSOToken
  private let session: AuthenticatingSession
  
  private let homeAddressCell: SummaryAddressCell
  private let altAddressCell: SummaryAddressCell
  private let cardType: CardType
  private let fullNameCell: SummaryCell
  private let emailCell: SummaryCell
  private let birthdateCell: SummaryCell
  private let usernameCell: SummaryCell
  private let passwordCell: SummaryCell
  
  private let patronInfo: PatronCreationInfo

  init(
    configuration: CardCreatorConfiguration,
    authToken: ISSOToken,
    patronInfo: PatronCreationInfo,
    cardType: CardType)
  {
    self.configuration = configuration
    self.authToken = authToken
    self.session = AuthenticatingSession(configuration: configuration)

    self.patronInfo = patronInfo
    self.cardType = cardType
    
    self.headerLabel = UILabel()
    
    self.homeAddressCell = SummaryAddressCell(section: NSLocalizedString(
      "Home Address",
      comment: "Title of the section for the user's home address"),
                                              style: .default, reuseIdentifier: nil)
    self.altAddressCell = SummaryAddressCell(section: NSLocalizedString(
      "School or Work Address",
      comment: "Title of the section for the user's possible work or school address"),
                                             style: .default, reuseIdentifier: nil)
  
    self.homeAddressCell.address = self.patronInfo.homeAddress
    if let address = self.patronInfo.workAddress {
      self.altAddressCell.address = address
    }
    
    self.fullNameCell = SummaryCell(section: NSLocalizedString("Full Name", comment: "Title of the section for the user's full name"),
                                    cellText: self.patronInfo.name)
    self.emailCell = SummaryCell(section: NSLocalizedString("Email", comment: "Title of the section for the user's email"),
                                 cellText: self.patronInfo.email)
    self.birthdateCell = SummaryCell(section: NSLocalizedString("Birthdate", comment: "Title of the section for the user's birthdate"),
                                     cellText: self.patronInfo.birthdate)
    self.usernameCell = SummaryCell(section: NSLocalizedString("Username", comment: "Title of the section for the user's chosen username"),
                                    cellText: self.patronInfo.username)
    self.passwordCell = SummaryCell(section: NSLocalizedString("Password", comment: "Title of the section for the user's chosen password"),
                                    cellText: self.patronInfo.password)

    if configuration.isJuvenile {
      self.cells = [
        self.fullNameCell,
        self.usernameCell,
        self.passwordCell
      ]
    } else {
      self.cells = [
        self.homeAddressCell,
        self.fullNameCell,
        self.emailCell,
        self.birthdateCell,
        self.usernameCell,
        self.passwordCell
      ]
    }

    if (self.patronInfo.workAddress != nil) {
      self.cells.insert(self.altAddressCell, at: 1)
    }
    
    super.init(style: .plain)
    
    self.tableView.separatorStyle = .none

    let actionCallback: Selector
    if configuration.isJuvenile {
      actionCallback = #selector(createJuvenilePatron)
    } else {
      actionCallback = #selector(createRegularPatron)
    }
    self.navigationItem.rightBarButtonItem =
      UIBarButtonItem(title: NSLocalizedString(
        "Create Card",
        comment: "A title for a button that submits the user's information to create a library card"),
                      style: .plain,
                      target: self,
                      action: actionCallback)

    self.prepareTableViewCells()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tableView.backgroundColor = NYPLColor.primaryBackgroundColor
    
    self.title = NSLocalizedString(
      "Review",
      comment: "A title for a screen letting the user know they can review the information they have entered")
    
    headerLabel.numberOfLines = 0
    headerLabel.lineBreakMode = .byWordWrapping
    headerLabel.textColor = NYPLColor.disabledFieldTextColor
    headerLabel.textAlignment = .center
    
    headerLabel.text = NSLocalizedString(
      "Before creating your card, please review and go back to make changes if necessary.",
      comment: "Description to inform a user to review their information, and press the back button to make changes if they are needed.")

    self.tableView.estimatedRowHeight = 120
    self.tableView.allowsSelection = false
  }
  
  private func prepareTableViewCells() {
    for cell in self.cells {
      cell.backgroundColor = UIColor.clear
      self.tableView.separatorStyle = .none
    }
  }
  
  // MARK: UITableViewDataSource
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return self.cells.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return self.cells[indexPath.section]
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }

  // MARK: Headers and footers
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return UITableView.automaticDimension
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return 40
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      let containerView = UIView()
      containerView.addSubview(self.headerLabel)
      self.headerLabel.autoPinEdge(toSuperviewMargin: .left)
      self.headerLabel.autoPinEdge(toSuperviewMargin: .right)
      self.headerLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
      self.headerLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 20)
      return containerView
    } else {
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 0
  }
  
  // MARK: - Juvenile Patron Flow

  @objc private func createJuvenilePatron() {
    let info = JuvenileCreationInfo(parentBarcode: configuration.juvenileParentBarcode,
                                    name: patronInfo.name,
                                    username: patronInfo.username,
                                    pin: patronInfo.password)
    configuration.juvenileCreationHandler?(info, self)
  }

  func handleJuvenilePatronResponse(_ result: Result<String>) {
    OperationQueue.main.addOperation { [weak self] in
      guard let self = self else {
        return
      }
      
      self.navigationController?.view.isUserInteractionEnabled = true
      self.navigationItem.titleView = nil
      
      switch result {
      case .success(let juvenileBarcode):
        self.navigationController?.pushViewController(
          UserCredentialsViewController(configuration: self.configuration,
                                        username: self.patronInfo.username,
                                        barcode: juvenileBarcode,
                                        pin: self.patronInfo.password,
                                        cardType: self.cardType),
          animated: true)
      case .fail(let error):
        self.showErrorAlertEnablingNavigation(message: error.localizedDescription)
      }
    }
  }

  // MARK: - Regular Patron Flow

  @objc private func createRegularPatron() {
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    self.navigationController?.view.isUserInteractionEnabled = false
    self.navigationItem.titleView =
      ActivityTitleView(title:
        NSLocalizedString(
          "Creating Card",
          comment: "A title telling the user their card is currently being created"))
    var request = URLRequest.init(url: self.configuration.platformAPIInfo.baseURL.appendingPathComponent("patrons"))

    request.httpBody = try! JSONSerialization.data(withJSONObject: patronInfo.JSONObject(), options: [.prettyPrinted])
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue("\(authToken.tokenType) \(authToken.accessToken)", forHTTPHeaderField: "Authorization")
    request.timeoutInterval = self.configuration.requestTimeoutInterval
    let task = session.dataTaskWithRequest(request) { [weak self] data, response, error in
      OperationQueue.main.addOperation {
        self?.handleRegularPatronResponse(response, data: data, error: error)
      }
    }
    
    task.resume()
  }

  private func handleRegularPatronResponse(_ response: URLResponse?,
                                           data: Data?,
                                           error: Error?) {
    self.navigationController?.view.isUserInteractionEnabled = true
    self.navigationItem.titleView = nil

    // if we don't have an HTTP response nor usable data, display error message
    guard
      let httpResponse = response as? HTTPURLResponse,
      httpResponse.statusCode == 200 || httpResponse.statusCode == 400,
      let data = data,
      let JSONObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
    else {
      showErrorAlertEnablingNavigation(message: error?.localizedDescription)
      return
    }
    
    // Responses with status 400 contain informative error messages from API:
    // https://github.com/NYPL/dgx-patron-creator-service/wiki/API-V0.3#error-responses-2
    if httpResponse.statusCode == 400 {
      let msg = JSONObject["detail"] as? String ?? error?.localizedDescription
      showErrorAlertEnablingNavigation(title: JSONObject["title"] as? String,
                                       message: msg)
      return
    }

    // if we have any other error, display it
    if let error = error {
      showErrorAlertEnablingNavigation(message: error.localizedDescription)
      return
    }

    guard httpResponse.statusCode == 200 else {
      showErrorAlertEnablingNavigation()
      return
    }

    let barcode = JSONObject["barcode"] as? String

    self.navigationController?.pushViewController(
      UserCredentialsViewController(configuration: self.configuration,
                                    username: self.patronInfo.username,
                                    barcode: barcode,
                                    pin: self.patronInfo.password,
                                    cardType: self.cardType),
      animated: true)
  }

  // MARK: - Private helpers

  private func showErrorAlertEnablingNavigation(title: String? = nil,
                                                message: String? = nil) {
    self.showErrorAlert(title: title, message: message)
    self.navigationItem.rightBarButtonItem?.isEnabled = true
  }
}
