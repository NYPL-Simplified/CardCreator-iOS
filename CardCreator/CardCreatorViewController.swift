import PureLayout
import UIKit

class CardCreatorViewController: UITableViewController, UITextFieldDelegate
{
  private enum Section {
    case NameAndEmail
    case UsernameAndPIN
    case Address
  }
  
  private let labelledTextViewCellReuseIdentifier = "LabelledTextViewCell"
  private let labelledStatePickerCellReuseIdentifier = "LabelledStatePickerCell"
  
  init() {
    super.init(style: UITableViewStyle.Grouped)
    
    self.tableView.registerClass(LabelledTextViewCell.self,
                                 forCellReuseIdentifier: labelledTextViewCellReuseIdentifier)
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    self.tableView.allowsSelection = false
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 2
    case 1:
      return 2
    case 2:
      return 5
    case 3:
      return 1
    default:
      fatalError()
    }
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 4
  }
  
  private func dequeueLabelledTextViewCell(title: String, _ placeholder: String?) -> LabelledTextViewCell {
    let cell = self.tableView.dequeueReusableCellWithIdentifier(labelledTextViewCellReuseIdentifier)
      as! LabelledTextViewCell
    cell.textField.delegate = self
    cell.label.text = title
    cell.textField.placeholder = placeholder
    return cell
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    switch (indexPath.section, indexPath.row) {
    case (0, 0):
      let cell = dequeueLabelledTextViewCell("Full Name", "Jane Doe")
      cell.textField.tag = 0
      cell.textField.keyboardType = .Alphabet
      cell.textField.autocapitalizationType = .Words
      cell.textField.returnKeyType = .Next
      return cell
    case (0, 1):
      let cell = dequeueLabelledTextViewCell("Email", "jane@example.com")
      cell.textField.tag = 1
      cell.textField.keyboardType = .EmailAddress
      cell.textField.autocapitalizationType = .None
      cell.textField.autocorrectionType = .No
      cell.textField.returnKeyType = .Next
      return cell
    case (1, 0):
      let cell = dequeueLabelledTextViewCell("Username", "janedoe123")
      cell.textField.tag = 2
      cell.textField.keyboardType = .Alphabet
      cell.textField.autocapitalizationType = .None
      cell.textField.autocorrectionType = .No
      cell.textField.returnKeyType = .Next
      return cell
    case (1, 1):
      let cell = dequeueLabelledTextViewCell("PIN", "Required (e.g. 0987)")
      cell.textField.tag = 3
      cell.textField.keyboardType = .NumberPad
      return cell
    case (2, 0):
      let cell = dequeueLabelledTextViewCell("Street 1", "123 Main St")
      cell.textField.tag = 4
      cell.textField.keyboardType = .Alphabet
      cell.textField.autocapitalizationType = .Words
      cell.textField.returnKeyType = .Next
      return cell
    case (2, 1):
      let cell = dequeueLabelledTextViewCell("Street 2", "Apt 2B")
      cell.textField.tag = 5
      cell.textField.keyboardType = .Alphabet
      cell.textField.autocapitalizationType = .Words
      cell.textField.returnKeyType = .Next
      return cell
    case (2, 2):
      let cell = dequeueLabelledTextViewCell("City", "Springfield")
      cell.textField.tag = 6
      cell.textField.keyboardType = .Alphabet
      cell.textField.autocapitalizationType = .Words
      cell.textField.returnKeyType = .Next
      return cell
    case (2, 3):
      let cell = dequeueLabelledTextViewCell("State", "FIXME")
      cell.textField.tag = 7
      return cell
    case (2, 4):
      let cell = dequeueLabelledTextViewCell("ZIP", "20540")
      cell.textField.tag = 8
      cell.textField.keyboardType = .NumberPad
      return cell
    case (3, 0):
      let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
      let button = UIButton(type: .System)
      cell.addSubview(button)
      button.setTitle("Submit", forState: .Normal)
      button.autoCenterInSuperview()
      return cell
    default:
      fatalError()
    }
  }
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Name & Email"
    case 1:
      return "Username & PIN"
    case 2:
      return "Address"
    case 3:
      return nil
    default:
      fatalError()
    }
  }
  
  
  // MARK: UITextFieldDelegate
  
  @objc func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField.tag < 8 {
      self.tableView.viewWithTag(textField.tag + 1)?.becomeFirstResponder()
    }
    
    return true
  }
}

