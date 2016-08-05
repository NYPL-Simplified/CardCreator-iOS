import UIKit

class StatePickerViewDataSourceAndDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
  
  static let sharedInstance = StatePickerViewDataSourceAndDelegate()
  
  @objc func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  @objc func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return 50
  }
  
  @objc func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return "New York"
  }
}