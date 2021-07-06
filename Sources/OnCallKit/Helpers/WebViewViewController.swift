import UIKit
import WebKit

// MARK: - WebViewViewController

protocol WebViewDelegate: AnyObject {
    func didTapDismiss()
}

class WebViewViewController: UIViewController {
    
    // MARK: Lifecycle
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        exitButton.configure(text: "close".localized())
        exitButton.setInteraction { [weak self] in
            self?.dismiss(animated: true)
            self?.delegate?.didTapDismiss()
        }
        
        view.addSubview(exitButton)
        exitButton.snp.makeConstraints { (make) in
            make.leading.equalTo(view).offset(20)
            make.equalTo(safeAreaEdge: .top, of: self)
            make.height.equalTo(35)
        }
        
        view.backgroundColor = .white
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    /// If you want to dismiss the webview after a redirect, DO NOT dismiss the view controller through this completion block; you will end up creating a retain cycle.
    /// Instead, use `WKNavigationActionPolicy.cancel` when calling the second parameter in this completion block.
    var navigationActionCallback: ((WKNavigationAction, (WKNavigationActionPolicy) -> Void) -> Void)? = nil
    weak var delegate: WebViewDelegate?
    
    func load(url: URL, withCookies cookies: [HTTPCookie]? = nil) {
        let dispatchGroup = DispatchGroup()
        
        cookies?.forEach {
            dispatchGroup.enter()
            dataStore.httpCookieStore.setCookie($0) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.configureWebview()
            self.load(urlRequest: URLRequest(url: url))
        }
    }
    
    private func load(urlRequest: URLRequest) {
        loadingOverlay = presentLoadingIndicator()
        var updatedRequest = urlRequest
        updatedRequest.setValue(Bundle.main.preferredLocalization, forHTTPHeaderField: "Accept-Language")
        webview?.load(updatedRequest)
    }
    
    private func configureWebview() {
        configuration.websiteDataStore = dataStore
        
        if let webview = webview {
            webview.removeFromSuperview()
        }
        
        webview = WKWebView(frame: .zero, configuration: configuration)
        webview?.navigationDelegate = self
        
        guard let webview = webview else {
            return
        }
        
        view.addSubview(webview)
        webview.snp.makeConstraints {
            $0.top.equalTo(exitButton.snp.bottom).offset(10)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: Private
    
    private var webview: WKWebView?
    private let configuration = WKWebViewConfiguration()
    private let dataStore = WKWebsiteDataStore.nonPersistent()
    private var loadingOverlay: LoadingOverlayViewController?
    private let exitButton = BasicButton(style: .small)
    
    var reloaded = false
    
}

// MARK: WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        navigationActionCallback?(navigationAction) { response in
            if response == .cancel {
                dismiss(animated: true)
            }
            
            decisionHandler(response)
        } ?? decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        webView.evaluateJavaScript("window.locale = 'fr'") { success, error  in
//            print(success)
//            if !self.reloaded {
//                self.reloaded = true
//                //webView.reload()
//            }
//        }
        
        loadingOverlay?.dismiss()
    }
}
