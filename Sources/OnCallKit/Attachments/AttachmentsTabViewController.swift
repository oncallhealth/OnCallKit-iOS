import SafariServices
import UIKit

// MARK: - AttachmentsTabViewControllerDelegate

protocol AttachmentsTabViewControllerDelegate: AnyObject {
    func didReceive403Error(handler: @escaping () -> Void)
    func didUpdateAttachments()
}

extension AttachmentsTabViewControllerDelegate {
    func didReceive403Error(handler: @escaping () -> Void) {
        //Override me
    }
    
    func didUpdateAttachments() {
        //Override me
    }

}


class AttachmentsTabViewController: OCViewController {
    
    // MARK: PresentationType
    
    enum PresentationType {
        case modal
        case none
    }
    
    // MARK: PresentingSheet
    
    enum PresentingSheet {
        case fileVisibility
        case formAssignment
    }
    
    // MARK: Lifecycle
    
    init(
        appointment: OnCallAppointment? = nil,
        presentationType: PresentationType = .none,
        canEditForms: Bool = false)
    {
        self.appointment = appointment
        self.pageViewController = AttachmentsPageViewController(
            appointment: appointment,
            canEditAttachments: canEditForms)
        
        super.init(
            titleIcon: presentationType == .modal ? "ic-close".icon() : nil,
            titleIconColour: .primary,
            title: "attachments".localized(),
            titleButtons: nil,
            tabBarIcon: "ic-file-solid".icon())
        
        contentView.addSubview(headerBar)
        contentView.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        headerBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalTo(pageViewController.view.snp.top).offset(-10)
        }
        
        pageViewController.view.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        headerBar.configure(options: buttonNames)
        headerBar.setInteraction { [weak self] index in
            guard let `self` = self else {
                return
            }
            
            self.headerBar.setSelected(index: index)
            self.pageViewController.setVisibleViewController(index: index)
        }
        
        pageViewController.attachmentsPageDelegate = self
        
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var delegate: AttachmentsTabViewControllerDelegate?
    
    override func didTapTitleIcon(_ sender: Any?) {
        dismiss(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if attachmentsUpdated {
            delegate?.didUpdateAttachments()
        }
    }
    
    // MARK: Private
    
    private let pageViewController: AttachmentsPageViewController
    
    private let appointment: OnCallAppointment?
    private let headerBar = MaterialTabBar()
    private let buttonNames = ["forms".localized(), "files".localized()]
    
    private var presentingSheet: PresentingSheet? = nil
    private var attachmentsUpdated = false

}

// MARK: AttachmentsPageViewControllerDelegate

extension AttachmentsTabViewController: AttachmentsPageViewControllerDelegate {
    func didChangeViewController(to index: Int) {
        headerBar.setSelected(index: index)
    }
    
    func openForm(id: Int) {
        let loadingIndicator = presentLoadingIndicator()
        SessionManager.shared.apiManager.getSessionFromToken { cookies in
            loadingIndicator.dismiss {
                guard let cookies = cookies,
                      let url = URL(string: "https://\(SessionManager.shared.domain)/forms/mobile/\(id)?redirect=\(ApiManager.formRedirectUrl)") else
                {
                    self.presentSnackbar()
                    return
                }
                
                let webViewController = WebViewViewController()
                webViewController.navigationActionCallback = { [weak self] action, decisionHandler in
                    if action.navigationType == .other,
                       let redirectUrl = action.request.url,
                       let scheme = redirectUrl.scheme,
                       let host = redirectUrl.host
                    {
                        if scheme + "://" + host == ApiManager.formRedirectUrl {
                            decisionHandler(.cancel)
                            
                            switch redirectUrl.getQueryStringParameter("status") {
                            case ResponseStatus.success.rawValue:
                                self?.pageViewController.refreshFormViewController(removeOldForms: true)
                                self?.presentSnackbar(.success(message: "form_submitted".localized()))
                            case ResponseStatus.notFound.rawValue:
                                self?.presentSnackbar(.error(message: "form_not_found".localized()))
                            default:
                                self?.presentSnackbar(.error(message: "form_not_submitted".localized()))
                            }
                            
                            return
                        }
                    }
                    
                    decisionHandler(.allow)
                }
                
                webViewController.load(url: url, withCookies: cookies)
                
                self.present(webViewController, animated: true)
            }
        }
    }
    
    func openFile(url: URL) {
        if url.pathExtension.lowercased() == "pdf" {
            present(UINavigationController(
                        rootViewController: PDFViewController(
                            url: url,
                            title: "file".localized(),
                            savedMessage: "file_saved".localized(),
                            sentMessage: "file_sent".localized())),
                    animated: true)
        } else {
            present(SFSafariViewController(url: url), animated: true)
        }
    }
    
    func presentFileMenu(for attachment: Attachment, sender: UIView) {
        var canEditVisibility = false
        
        if let appointment = appointment {
            canEditVisibility = SessionManager.shared.user?.ownsAppointment(appointment) ?? false
        }
        
        let viewController = FileVisibilityViewController(
            viewModel: FileVisibilityViewModel(
                attachment: attachment,
                allUsers: appointment?.participants.compactMap {
                    guard let id = $0.id else {
                        return nil
                    }
                    
                    return FileVisibilityViewModel.User(id: id, name: $0.name)
                } ?? [],
                canEditVisibility: canEditVisibility))
        
        viewController.delegate = self
        presentingSheet = .fileVisibility
        presentPanModal(viewController, sourceView: sender, sourceRect: sender.bounds)
    }
    
    func presentFormMenu(for form: Form, sender: UIView) {
        let viewController = UnassignFormViewController(viewModel: UnassignFormViewModel(form: form))
        
        viewController.delegate = self
        presentingSheet = .formAssignment
        presentPanModal(viewController, sourceView: sender, sourceRect: sender.bounds)
    }
}

// MARK: SheetViewControllerDelegate

extension AttachmentsTabViewController: SheetViewControllerDelegate {
    func actionFailed(message: String?) {
        if let message = message {
            presentAlert(title: "basic_error_title".localized(), body: message)
        }
    }
    
    func actionComplete(message: String?) {
        if let message = message {
            presentSnackbar(.success(message: message))
        }
        
        if presentingSheet == .fileVisibility {
            pageViewController.refreshFileViewController(removeOldForms: true)
        } else if presentingSheet == .formAssignment {
            pageViewController.refreshFormViewController(removeOldForms: true)
        }
        attachmentsUpdated = true
    }
}

// MARK: TokenExpiryHandler

extension AttachmentsTabViewController: TokenExpiryHandleable {
    func didReceive403(handler: @escaping () -> Void) {
        if let delegate = delegate {
            delegate.didReceive403Error(handler: handler)
        } else {
            handler()
        }
    }
}
