import MobileCoreServices
import SwiftEntryKit
import UIKit

// MARK: - UIViewController

extension UIViewController {
    
    // MARK: Internal
    
    var topViewController: UIViewController {
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
        
        return top ?? UIViewController()
    }
    
    func presentAlert(title: String, body: String) {
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentSnackbar(_ type: SnackbarType = .error(message: "something_went_wrong".localized())) {
        var attributes = EKAttributes.bottomToast
        let title: String
        
        switch type {
        case .error(let message):
            attributes.entryBackground = .color(color: EKColor(.snackbarError))
            attributes.hapticFeedbackType = .error
            title = message
        case .success(let message):
            attributes.entryBackground = .color(color: EKColor(.snackbarSuccess))
            attributes.hapticFeedbackType = .success
            title = message
        }
        
        let simpleMessage = EKSimpleMessage(
            title: EKProperty.LabelContent(text: title, style: .init(font: .systemFont(ofSize: 16), color: .white)),
            description: .init(text: "", style: .init(font: .systemFont(ofSize: 1), color: .clear)))
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
//    func confirm(title: String,
//                 body: String,
//                 negativeTitle: String,
//                 negativeAction: @escaping (() -> Void),
//                 positiveTitle: String,
//                 positiveAction: @escaping (() -> Void)) {
//        
//        let confirmController = ConfirmController(title: title,
//                                                  message: body,
//                                                  negativeTitle: negativeTitle,
//                                                  negativeAction: negativeAction,
//                                                  positiveTitle: positiveTitle,
//                                                  positiveAction: positiveAction)
//        
//        self.present(confirmController.alert, animated: true, completion: nil)
//    }
    
    func presentLoadingIndicator() -> LoadingOverlayViewController {
        let viewController = LoadingOverlayViewController()
        viewController.present(on: self)
        return viewController
    }
}
