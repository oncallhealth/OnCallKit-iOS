import UIKit

// MARK: - UIViewController

extension UIViewController {
    
    // MARK: Internal
    
    var topViewController: UIViewController? {
        var top = UIApplication.shared.delegate?.window??.rootViewController
        
        while true {
            if let presented = top?.presentedViewController {
                top = presented
            } else if let nav = top as? UINavigationController {
                top = nav.visibleViewController
            } else if let tab = top as? UITabBarController {
                top = tab.selectedViewController
            } else {
                break
            }
        }
        
        return top
    }
    
    func presentAlert(title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentSnackbar(_ type: Snackbar.SnackbarType = .error(message: "something_went_wrong".localized()), completion: (() -> Void)? = nil) {
        UIViewController.currentSnackbar?.dismiss()
        UIViewController.currentSnackbar = Snackbar(type: type)
        UIViewController.currentSnackbar?.present(completion: completion)
    }
    
    func presentLoadingIndicator() -> LoadingOverlayViewController {
        let viewController = LoadingOverlayViewController()
        viewController.present(on: self)
        return viewController
    }
    
    // MARK: Private
    
    static private var currentSnackbar: Snackbar? = nil
    
}
