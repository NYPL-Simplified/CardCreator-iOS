import PureLayout
import UIKit

class StatePickerView: UIPickerView {
  
  let pickerViewDataSourceAndDelegate = PickerViewDataSourceAndDelegate()
  
  init() {
    self.pickerView = UIPickerView()
    
    super.init(frame: CGRectZero, inputViewStyle: .Default)
    
    self.addSubview(self.pickerView)
    self.pickerView.autoPinEdgesToSuperviewEdges()
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  class PickerViewDataSourceAndDelegate: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
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
}
