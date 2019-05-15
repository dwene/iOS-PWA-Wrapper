import UIKit
import WebKit
import os.log

class ViewController: UIViewController {
    
    // MARK: Outlets
//    @IBOutlet weak var leftButton: UIBarButtonItem!
//    @IBOutlet weak var rightButton: UIBarButtonItem!
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var offlineView: UIView!
    @IBOutlet weak var offlineIcon: UIImageView!
    @IBOutlet weak var offlineButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Globals
    var webView: WKWebView!
    var progressBar : UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = appTitle
        setupApp()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UI Actions
    // handle back press
//    @IBAction func onLeftButtonClick(_ sender: Any) {
//        if (webView.canGoBack) {
//            webView.goBack()
//            // fix a glitch, as the above seems to trigger observeValue -> WKWebView.isLoading
//            activityIndicatorView.isHidden = true
//            activityIndicator.stopAnimating()
//        } else {
//            // exit app
//            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
//        }
//    }
//    // open menu in page, or fire alternate function on large screens
//    @IBAction func onRightButtonClick(_ sender: Any) {
//        if (changeMenuButtonOnWideScreens && isWideScreen()) {
//            webView.evaluateJavaScript(alternateRightButtonJavascript, completionHandler: nil)
//        } else {
//            webView.evaluateJavaScript(menuButtonJavascript, completionHandler: nil)
//        }
//    }
//    // reload page from offline screen
//    @IBAction func onOfflineButtonClick(_ sender: Any) {
//        offlineView.isHidden = true
//        webViewContainer.isHidden = false
//        loadAppUrl()
//    }
    
    // Observers for updating UI
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == #keyPath(WKWebView.isLoading)) {
            // show activity indicator

            /*
            // this causes troubles when swiping back and forward.
            // having this disabled means that the activity view is only shown on the startup of the app.
            // ...which is fair enough.
            if (webView.isLoading) {
                activityIndicatorView.isHidden = false
                activityIndicator.startAnimating()
            }
            */
        }
        if (keyPath == #keyPath(WKWebView.estimatedProgress)) {
            progressBar.progress = Float(webView.estimatedProgress)
//            rightButton.isEnabled = (webView.estimatedProgress == 1)
        }
    }
    
    func buildContentController() -> WKUserContentController {
        let contentController = WKUserContentController()
        contentController.add(self, name: "download")
        return contentController
    }
    
    // Initialize WKWebView
    func setupWebView() {
        let webViewConfig = WKWebViewConfiguration()
        webViewConfig.userContentController = buildContentController()
        // set up webview
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: webViewContainer.frame.width, height: webViewContainer.frame.height), configuration: webViewConfig)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webViewContainer.addSubview(webView)
        
        // settings
        webView.allowsBackForwardNavigationGestures = true
        webView.configuration.preferences.javaScriptEnabled = true
        if #available(iOS 10.0, *) {
            webView.configuration.ignoresViewportScaleLimits = false
        }
        // user agent
        if #available(iOS 9.0, *) {
            if (useCustomUserAgent) {
                webView.customUserAgent = customUserAgent
            }
            if (useUserAgentPostfix) {
                if (useCustomUserAgent) {
                    webView.customUserAgent = customUserAgent + " " + userAgentPostfix
                } else {
                    webView.evaluateJavaScript("navigator.userAgent", completionHandler: { (result, error) in
                        if let resultObject = result {
                            self.webView.customUserAgent = (String(describing: resultObject) + " " + userAgentPostfix)
                        }
                    })
                }
            }
            webView.configuration.applicationNameForUserAgent = ""
        }
        
        // bounces
        webView.scrollView.bounces = enableBounceWhenScrolling

        // init observers
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.isLoading), options: NSKeyValueObservingOptions.new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    // Initialize UI elements
    // call after WebView has been initialized
    func setupUI() {
        // leftButton.isEnabled = false

        // progress bar
        progressBar = UIProgressView(frame: CGRect(x: 0, y: 0, width: webViewContainer.frame.width, height: 40))
        progressBar.autoresizingMask = [.flexibleWidth]
        progressBar.progress = 0.0
        progressBar.tintColor = progressBarColor
        webView.addSubview(progressBar)
        
        // activity indicator
        activityIndicator.color = activityIndicatorColor
        activityIndicator.startAnimating()
        
        // offline container
        offlineIcon.tintColor = offlineIconColor
        offlineButton.tintColor = buttonColor
        offlineView.isHidden = true
        
        // setup navigation bar
        if (forceLargeTitle) {
            if #available(iOS 11.0, *) {
                navigationItem.largeTitleDisplayMode = UINavigationItem.LargeTitleDisplayMode.always
            }
        }
        if (useLightStatusBarStyle) {
            self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        }
        
        // handle menu button changes
        /// set default
//        rightButton.title = menuButtonTitle
        /// update if necessary
//        updateRightButtonTitle(invert: false)
//        /// create callback for device rotation
//        let deviceRotationCallback : (Notification) -> Void = { _ in
//            // this fires BEFORE the UI is updated, so we check for the opposite orientation,
//            // if it's not the initial setup
//            self.updateRightButtonTitle(invert: true)
//        }
//        /// listen for device rotation
//        NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: .main, using: deviceRotationCallback)

        /*
        // @DEBUG: test offline view
        offlineView.isHidden = false
        webViewContainer.isHidden = true
        */
    }

    // load startpage
    func loadAppUrl() {
        let urlRequest = URLRequest(url: webAppUrl!)
        webView.load(urlRequest)
    }
    
    // Initialize App and start loading
    func setupApp() {
        setupWebView()
        setupUI()
        loadAppUrl()
    }
    
    // Cleanup
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.isLoading))
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    // Helper method to determine wide screen width
    func isWideScreen() -> Bool {
        // this considers device orientation too.
        if (UIScreen.main.bounds.width >= wideScreenMinWidth) {
            return true
        } else {
            return false
        }
    }
    
    func downloadFile(dict: NSDictionary) {
        let urlString = dict["url"] as? String ?? ""
        let jwt = dict["jwt"] as? String ?? ""
        let fileName = dict["fileName"] as? String ?? ""
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue(jwt, forHTTPHeaderField: "Authorization")
        URLSession.shared.downloadTask(with: request) { (urlOrNil, responseOrNil, error) in
            if let response = responseOrNil as? HTTPURLResponse {
                if(response.statusCode > 299 || response.statusCode < 200) {
                    DispatchQueue.main.async {
                        os_log("Download failed with status code %{public}@", response.statusCode)
                        self.showToast(message: "Download Failed")
                    }
                    return;
                }
            }
            guard let fileURL = urlOrNil else { return }
            do {
                let documentsURL = try
                    FileManager.default.url(for: .downloadsDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: nil,
                                            create: true)
                let savedURL = documentsURL.appendingPathComponent(fileName)
                try FileManager.default.moveItem(at: fileURL, to: savedURL)
                os_log("Download successful")
                DispatchQueue.main.async {
                   self.openDocument(url: savedURL)
                }
            } catch {
                os_log("Download failed with error: %{public}@", error.localizedDescription)
                DispatchQueue.main.async {
                    self.showToast(message: "Download Failed")
                }
            }
        }.resume()
    }
    
    func openDocument(url: URL) {
        UINavigationBar.appearance().barTintColor = .green
        let documentController = UIDocumentInteractionController.init(url: url)
        documentController.delegate = self
        documentController.presentPreview(animated: true)
    }
    
    func showToast(message : String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 200, height: 50))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

// WebView Event Listeners
extension ViewController: WKNavigationDelegate {
    // didFinish
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // set title
        if (changeAppTitleToPageTitle) {
            navigationItem.title = webView.title
        }
        // hide progress bar after initial load
        progressBar.isHidden = true
        // hide activity indicator
        activityIndicatorView.isHidden = true
        activityIndicator.stopAnimating()
    }
    // didFailProvisionalNavigation
    // == we are offline / page not available
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // show offline screen
        offlineView.isHidden = false
        webViewContainer.isHidden = true
    }
}

extension ViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

// WebView additional handlers
extension ViewController: WKUIDelegate {
    // handle links opening in new tabs
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if (navigationAction.targetFrame == nil) {
            webView.load(navigationAction.request)
        }
        return nil
    }
    // restrict navigation to target host, open external links in 3rd party apps
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let requestUrl = navigationAction.request.url {
            if let requestHost = requestUrl.host {
                decisionHandler(.allow)
//                if (requestHost.range(of: allowedOrigin) != nil ) {
//
//                } else {
//                    decisionHandler(.cancel)
//                    if (UIApplication.shared.canOpenURL(requestUrl)) {
//                        if #available(iOS 10.0, *) {
//                            UIApplication.shared.open(requestUrl)
//                        } else {
//                            // Fallback on earlier versions
//                            UIApplication.shared.openURL(requestUrl)
//                        }
//                    }
//                }
            } else {
                decisionHandler(.cancel)
            }
        }
    }
}


extension ViewController:WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "download", let dict = message.body as? NSDictionary {
            os_log("attempting to download")
            downloadFile(dict: dict)
        }
    }
}
