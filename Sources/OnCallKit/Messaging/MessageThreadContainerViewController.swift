//
//  MessageThreadContainerViewController.swift
//  Development Simulator
//
//  Created by Domenic Bianchi on 2020-09-03.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

//import Reachability
import SnapKit
import UIKit

// MARK: - MessageThreadContainerViewControllerDelegate

protocol MessageThreadContainerViewControllerDelegate: AnyObject {
    
    func threadUpdated(_ thread: MessagingThread)
    func didReceive403Error(handler: @escaping () -> Void)
}

// MARK: - MessageThreadContainerViewController

class MessageThreadContainerViewController: OCViewController {
    
    // MARK: Lifecycle
    
    init(threadStub: MessagingThread, presentationType: PresentationType, hideCompleteButton: Bool = false) {
        self.threadStub = threadStub
        self.presentationType = presentationType
        self.hideCompleteButton = hideCompleteButton
        
        viewAttachmentsButton.setContent(icon: "file".iconTemplate())
        editAnnouncementButton.setContent(icon: "ic-pencil-bold".iconTemplate())
        
        moreOptionsButton.setContent(icon: "ic-vertical-ellipsis".iconTemplate())
        moreOptionsButton.isHidden = true
        
        let insets = UIEdgeInsets(top: 10, left: 12.5, bottom: 10, right: 12.5)
        viewAttachmentsButton.imageEdgeInsets = insets
        moreOptionsButton.imageEdgeInsets = insets
        editAnnouncementButton.imageEdgeInsets = insets
        
        viewAttachmentsButton.tintColor = .primaryWhite
        moreOptionsButton.tintColor = .primaryWhite
        editAnnouncementButton.tintColor = .primaryWhite
        
        messagesViewController = MessageThreadViewController(threadStub: threadStub)
        
        let titleIcon: UIImage?
        
        if case .modal(let deeplink) = presentationType {
            titleIcon = deeplink ? "ic-close".icon() : nil
        } else {
            titleIcon = UIDevice.current.isIpad ? nil : "ic-arrow-left".icon()
        }
        
        super.init(
            titleIcon: titleIcon,
            titleIconColour: .primary,
            title: MessageThreadContainerViewController.getViewControllerTitle(from: threadStub),
            canTruncateTitle: false,
            titleButtons: [viewAttachmentsButton, moreOptionsButton],
            tabBarIcon: nil)
        
        if case .modal(let deeplink) = presentationType, deeplink {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(onAuthorizationFail),
                name: Notification.Name.did403,
                object: nil)
        }
        
        let divider = HairlineView()
        let announcementDivider = HairlineView()
        
        contentView.addSubview(viewAllParticipantsButton)
        contentView.addSubview(divider)
        
        leftPaddingConstraint?.update(offset: 0)
        rightPaddingConstraint?.update(offset: 0)
        
        viewAllParticipantsButton.setTitleColor(.primaryWhite, for: .normal)
        viewAllParticipantsButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        viewAllParticipantsButton.addTarget(self, action: #selector(didTapParticipantsButton), for: .touchUpInside)
        
        viewAllParticipantsButton.snp.makeConstraints {
            $0.equalTo(safeAreaEdge: .leading, of: self).offset(titleIcon == nil ? 24 : 65)
            $0.top.equalToSuperview().offset(5)
        }
        
        divider.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(viewAllParticipantsButton.snp.bottom).offset(25)
        }
        
        let isProvider = SessionManager.shared.user?.ownsAppointment(threadStub.appointment) ?? false
        let announcementLabel = NSMutableAttributedString(string: "announcement".localized() + ": ", attributes:[NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize:14)])
        
        if let announcementText = threadStub.announcementText {
            
            contentView.addSubview(announcementStackView)
            contentView.addSubview(viewAnnouncementButton)
            contentView.addSubview(announcementDivider)
            
            announcementLabel.append(NSAttributedString(string: announcementText, attributes:[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
            announcementStackView.addArrangedSubview(messagingAnnouncement)
            messagingAnnouncement.attributedText = announcementLabel
            messagingAnnouncement.numberOfLines = 2
            messagingAnnouncement.lineBreakMode = .byTruncatingTail
            
            announcementStackView.addArrangedSubview(editAnnouncementButton)
            editAnnouncementButton.setInteractions { [weak self] in
                self?.didTapViewAnnouncement()
            }
            editAnnouncementButton.isHidden = !isProvider
            editAnnouncementButton.snp.makeConstraints {
                $0.width.equalTo(44)
            }
            
            announcementStackView.axis = .horizontal
            announcementStackView.snp.makeConstraints {
                $0.equalTo(safeAreaEdge: .leading, of: self).offset(15)
                $0.equalTo(safeAreaEdge: .trailing, of: self).offset(isProvider ? 0 : -15)
                $0.top.equalTo(divider.snp.bottom).offset(10)
                $0.width.equalTo(divider.snp.width).offset(-15)
            }
            
            viewAnnouncementButton.setTitle("read_more".localized(), for: .normal)
            viewAnnouncementButton.setTitleColor(.primaryWhite, for: .normal)
            viewAnnouncementButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
            viewAnnouncementButton.addTarget(self, action: #selector(didTapViewAnnouncement), for: .touchUpInside)
            
            viewAnnouncementButton.snp.makeConstraints {
                $0.equalTo(safeAreaEdge: .leading, of: self).offset(15)
                $0.top.equalTo(announcementStackView.snp.bottom)
                $0.bottom.equalTo(announcementDivider.snp.top).offset(-5)
                viewAnnouncementButtonHeightConstraint = $0.height.equalTo(44).constraint
            }
            
            announcementDivider.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
            }
        }
        
        //contentView.addSubview(noInternetNoticeBar)
        contentView.addSubview(loadingIndicator)
        
        messagesViewController.willMove(toParent: self)
        addChild(messagesViewController)
        contentView.addSubview(messagesViewController.view)
        messagesViewController.didMove(toParent: self)
        messagesViewController.delegate = self
        
        messagesViewController.view.snp.makeConstraints {
            $0.top.equalTo(!(threadStub.announcementText?.isEmpty ?? true) ? announcementDivider.snp.bottom : divider.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
//        viewAttachmentsButton.setInteractions { [weak self] in
//            let appointment = self?.fullThread?.appointment ?? threadStub.appointment
//            let attachmentsViewController = AttachmentsTabViewController(
//                appointment: appointment,
//                presentationType: .modal,
//                canEditForms: SessionManager.shared.user?.ownsAppointment(appointment) ?? false)
//            attachmentsViewController.delegate = self
//
//            IQKeyboardManager.shared.enable = true
//            self?.present(attachmentsViewController, animated: true)
//        }
        
        if #available(iOS 14.0, *) {
            moreOptionsButton.menu = UIMenu(
                options: .displayInline,
                children: [UIAction(title: "complete".localized(), handler: { _ in self.didTapComplete() })])
            moreOptionsButton.showsMenuAsPrimaryAction = true
        } else {
            moreOptionsButton.setInteractions { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let completeAction = UIAlertAction(title: "complete".localized(), style: .default) { _ in
                    self.didTapComplete()
                }
                
                let cancelAction = UIAlertAction(title: "cancel".localized(), style: .cancel) { _ in
                    alert.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(completeAction)
                alert.addAction(cancelAction)
                
                alert.popoverPresentationController?.sourceView = self.moreOptionsButton
                alert.popoverPresentationController?.sourceRect = self.moreOptionsButton.bounds
                
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        updateThreadHeader(with: threadStub)
        
//        noInternetNoticeBar.configure(text: "no_internet_connection".localized())
//
//        noInternetNoticeBar.snp.makeConstraints {
//            $0.top.equalTo(!(threadStub.announcementText?.isEmpty ?? true) ? announcementDivider.snp.bottom : divider.snp.bottom)
//            $0.leading.trailing.equalToSuperview()
//        }
//
//        noInternetNoticeBar.alpha = 0
        
        loadingIndicator.startAnimating()
        loadingIndicator.snp.makeConstraints {
            $0.width.height.equalTo(100)
            $0.center.equalToSuperview()
        }
        
        hidesBottomBarWhenPushed = true
        
//        reachability?.whenUnreachable = { [weak self] _ in
//            self?.animateNoticeBarLayoutChanges(isHidden: false)
//            self?.messagesViewController.isSendButtonEnabled = false
//        }
//
//        reachability?.whenReachable = { [weak self] _ in
//            self?.animateNoticeBarLayoutChanges(isHidden: true)
//            self?.messagesViewController.isSendButtonEnabled = true
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var delegate: MessageThreadContainerViewControllerDelegate?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //NotificationManager.removeNotifications(for: .messageReceived(threadId: threadStub.id))
        //IQKeyboardManager.shared.enable = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateAnnouncementVisibility()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        reachability?.stopNotifier()
//    }
    
    override func didTapTitleIcon(_ sender: Any?) {
        dismissViewController()
    }
    
    // MARK: Private
    
    //private let reachability = try? Reachability()
    
    private let announcementStackView = UIStackView()
    private let threadStub: MessagingThread
    private var fullThread: MessagingThread?
    private let viewAllParticipantsButton = UIButton()
    private let viewAnnouncementButton = UIButton()
    private let presentationType: PresentationType
    private let hideCompleteButton: Bool
    private let moreOptionsButton = IconButton(size: .small)
    private let viewAttachmentsButton = IconButton(size: .small)
    private let editAnnouncementButton = IconButton(size: .small)
    //private let noInternetNoticeBar = NoticeBar()
    private let messagesViewController: MessageThreadViewController
    private let loadingIndicator = UIActivityIndicatorView(indicatorStyle: .large)
    private let messagingAnnouncement = UILabel()
    
    private var viewAnnouncementButtonHeightConstraint: Constraint?
    
//    private func animateNoticeBarLayoutChanges(isHidden: Bool) {
//        UIView.animate(withDuration: 0.5) {
//            self.noInternetNoticeBar.alpha = isHidden ? 0 : 1
//            self.view.layoutIfNeeded()
//        }
//    }
    
    private func didTapComplete() {
   
//        let indicator = presentLoadingIndicator()
//        SessionManager.shared.apiManager.getAppointment(id: self.threadStub.appointment.id){ appointment in
//            
//            indicator.dismiss {
////                guard let appointment = appointment else {
////                    self.presentSnackbar()
////                    return
////                }
//                
////                let viewController = AppointmentSummaryViewController(appointment: appointment, source: .messages)
////                viewController.delegate = self
////                IQKeyboardManager.shared.enable = true
////                self.present(viewController, animated: true)
//            }
//        }
    }
    
    private func dismissViewController() {
        //IQKeyboardManager.shared.enable = true
        switch presentationType {
        case .modal:
            dismiss(animated: true)
        case .push:
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateThreadHeader(with thread: MessagingThread) {
        moreOptionsButton.isHidden = hideCompleteButton ||
            thread.completed ||
            !(SessionManager.shared.user?.ownsAppointment(thread.appointment) ?? false)
        
        updateTitle(MessageThreadContainerViewController.getViewControllerTitle(from: thread))
        
        if thread.threadUsers.count == 0 {
            viewAllParticipantsButton.setTitle("", for: .normal)
        } else {
            viewAllParticipantsButton.setTitle(
                String(format: "view_participants".localized(), thread.threadUsers.count),
                for: .normal)
        }
    }
    
    private func updateAnnouncementVisibility() {
        viewAnnouncementButton.isHidden = !messagingAnnouncement.isTruncated
        viewAnnouncementButtonHeightConstraint?.update(offset: messagingAnnouncement.isTruncated ? 44 : 0)
    }
    
    private static func getViewControllerTitle(from thread: MessagingThread) -> String {
        guard let loggedInUser = SessionManager.shared.user else {
            return ""
        }
        
        return thread.threadUsers.filter { $0.id != loggedInUser.id }.map { $0.fullName }.joined(separator: ", ")
    }
    
    @objc private func didTapViewAnnouncement() {
//        let isProvider = SessionManager.shared.user?.ownsAppointment(threadStub.appointment) ?? false
//        let messagingThread = self.fullThread ?? threadStub
//        let announcementText = threadStub.announcementText ?? ""
//        let messageAnnouncementViewController = MessageAnnouncementViewController(
//            messagingThread: messagingThread,
//            announcementText: announcementText,
//            isEditable: isProvider)
//
//        messageAnnouncementViewController.delegate = self
//        self.present(messageAnnouncementViewController, animated: true)
    }
    
    @objc private func didTapParticipantsButton() {
        presentPanModal(
            MessageThreadParticipantsViewController(
                viewModel: MessageThreadParticipantsViewModel(threadUsers: fullThread?.threadUsers ?? threadStub.threadUsers)),
            sourceView: viewAllParticipantsButton,
            sourceRect: viewAllParticipantsButton.bounds)
    }
    
    @objc private func onAuthorizationFail() {
        //NotificationManager.createDeferedDeeplink(for: .messageReceived(threadId: threadStub.id))
    }
}

// MARK: MessageThreadViewControllerDelegate

extension MessageThreadContainerViewController: MessageThreadViewControllerDelegate {
    func threadUpdated(_ thread: MessagingThread) {
        //try? reachability?.startNotifier()
        
        loadingIndicator.stopAnimating()
        fullThread = thread
        updateThreadHeader(with: thread)
        delegate?.threadUpdated(thread)
    }
}

// MARK: TokenExpiryHandler

extension MessageThreadContainerViewController: TokenExpiryHandleable {
    func didReceive403(handler: @escaping () -> Void) {
        if let delegate = delegate {
            delegate.didReceive403Error(handler: handler)
        } else {
            handler()
        }
    }
}

// MARK: TokenExpiryHandler

//extension MessageThreadContainerViewController: AttachmentsTabViewControllerDelegate {
//    func didReceive403Error(handler: @escaping () -> Void) {
//        delegate?.didReceive403Error(handler: handler)
//    }
//}
//
//// MARK: AppointmentSummaryViewControllerDelegate
//
//extension MessageThreadContainerViewController: AppointmentSummaryViewControllerDelegate {
//    func appointmentComplete(snackbar snackbarType: SnackbarType) {
//        presentSnackbar(snackbarType)
//
//        if UIDevice.current.isIpad {
//            messagesViewController.refreshMessageThread()
//        } else {
//            dismissViewController()
//        }
//    }
//}
//
//// MARK: MessageAnnouncementViewControllerDelegate
//
//extension MessageThreadContainerViewController: MessageAnnouncementViewControllerDelegate{
//    func updateAnnouncement(announcementText: String) {
//        let announcement = NSMutableAttributedString(string: "announcement".localized() + ": ", attributes:[NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize:14)])
//        announcement.append(NSAttributedString(string: announcementText, attributes:[NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
//        messagingAnnouncement.attributedText = announcement
//        threadStub.announcementText = announcementText
//        updateAnnouncementVisibility()
//    }
//}
