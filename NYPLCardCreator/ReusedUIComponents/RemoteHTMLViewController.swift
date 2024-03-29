import PureLayout
import UIKit
import WebKit

/// Similar functionality to BundledHTMLViewController, except for loading remote HTTP URL's where
/// it does not make sense in certain contexts to have bundled resources loaded.
final class RemoteHTMLViewController: UIViewController, WKNavigationDelegate {
  let fileURL: URL
  let failureMessage: String
  var webView: WKWebView
  var activityView: UIActivityIndicatorView!
  
  required init(URL: Foundation.URL, title: String, failureMessage: String?) {
    self.webView = WKWebView()
    self.fileURL = URL
    if let message = failureMessage {
      self.failureMessage = message
    } else {
      self.failureMessage = "Could not load page. Please try again later"
    }
    
    super.init(nibName: nil, bundle: nil)
    
    self.title = title
  }
  
  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    webView.frame = self.view.frame
    webView.navigationDelegate = self
    webView.backgroundColor = NYPLColor.primaryBackgroundColor
    webView.allowsBackForwardNavigationGestures = true

    view.addSubview(self.webView)
    webView.autoPinEdgesToSuperviewEdges()

    let request = URLRequest.init(url: fileURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
    webView.load(request)
    
    activityView(true)
  }
  
  func activityView(_ animated: Bool) -> Void {
    if animated == true {
      activityView = UIActivityIndicatorView.init()
      activityView.color = NYPLColor.disabledFieldTextColor
      activityView.center = self.view.center
      view.addSubview(activityView)
      activityView.startAnimating()
    } else {
      activityView?.stopAnimating()
      activityView?.removeFromSuperview()
    }
  }

  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    activityView(false)
    let alert = UIAlertController.init(title: NSLocalizedString(
      "Connection Failed",
      comment: "Title for alert that explains that the page could not download the information"),
                                       message: error.localizedDescription,
                                       preferredStyle: .alert)
    let action1 = UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "Button that says to cancel and go back to the last screen."), style: .destructive) { (cancelAction) in
      _ = self.navigationController?.popViewController(animated: true)
    }
    let action2 = UIAlertAction.init(title: NSLocalizedString("Reload", comment: "Button that says to try again"), style: .destructive) { (reloadAction) in
      let urlRequest = URLRequest(url: self.fileURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
      webView.load(urlRequest)
    }
    
    alert.addAction(action1)
    alert.addAction(action2)
    self.present(alert, animated: true, completion: nil)
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    activityView(false)
  }
}
