//
//  MessageThreadViewController.swift
//  Development Simulator
//
//  Created by Domenic Bianchi on 2020-09-02.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import InputBarAccessoryView
import MessageKit
import SafariServices
import UIKit

// MARK: - MessageThreadViewControllerDelegate

protocol MessageThreadViewControllerDelegate: AnyObject {
    
    func threadUpdated(_ thread: MessagingThread)
}

// MARK: - MessageThreadViewController

class MessageThreadViewController: MessagesViewController, MessagesLayoutDelegate, UINavigationControllerDelegate {
    
    // MARK: Lifecycle
    
    init(threadStub: MessagingThread) {
        self.threadStub = threadStub
        
        super.init(nibName: nil, bundle: nil)
        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(didReceiveMessage(_:)),
//            name: Notification.Name.didReceiveWebsocketMessage,
//            object: nil)
        
        inputBar.sendButton.configure {
            configureAttachmentButton($0)
        }
        
        configureAppointmentNotice(for: threadStub)
        
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: MyCustomMessagesFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var delegate: MessageThreadViewControllerDelegate?
    
    var isSendButtonEnabled: Bool = false {
        didSet {
            inputBar.sendButton.isEnabled = isSendButtonEnabled
        }
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        parent?.view.addSubview(inputBar)
        keyboardManager.bind(inputAccessoryView: inputBar) { [weak self] in
            return UIDevice.current.isIpad ? -(self?.topViewController.tabBarController?.tabBar.frame.height ?? 0) : 0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        additionalBottomInset = inputBar.calculateIntrinsicContentSize().height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.register(MessagingThreadAttachmentCell.self)
        
        inputBar.delegate = self
        inputBar.inputTextView.placeholder = "enter_message".localized()

        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            let outgoingAlignment = LabelAlignment(
                textAlignment: .right,
                textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
            let incomingAlignment = LabelAlignment(
                textAlignment: .left,
                textInsets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))

            
            layout.setMessageOutgoingAvatarSize(.zero)
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingMessageTopLabelAlignment(outgoingAlignment)
            layout.setMessageOutgoingMessageBottomLabelAlignment(outgoingAlignment)
            layout.setMessageIncomingMessageTopLabelAlignment(incomingAlignment)
            layout.setMessageIncomingMessageBottomLabelAlignment(incomingAlignment)
            layout.minimumLineSpacing = 2
        }
        
        isSendButtonEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isBeingShown = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isBeingShown = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !loadedOnce {
            loadedOnce = true
            loadMessages(firstLoad: true)
        }
    }
    
    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            return UICollectionViewCell()
        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(MessagingThreadAttachmentCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    func refreshMessageThread() {
        loadMessages()
    }
    
    // MARK: Private
    
    private var threadStub: MessagingThread
    private var thread: MessagingThread?
    private var appointment: AppointmentModel?
    private var loadedOnce = false
    private var isBeingShown = false
    
    private let keyboardManager = KeyboardManager()
    private let inputBar = InputBarAccessoryView()
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private func configureAppointmentNotice(for thread: MessagingThread) {
        if let appointmentDate = thread.appointment.date,
           Date() < appointmentDate,
           thread.appointment.appointmentType == .message
        {
            setAppointmentNotice(
                String(
                    format: "future_message".localized(),
                    Date.fullDate.string(from: thread.appointment.date ?? Date())
                )
            )
        } else if thread.completed {
            setAppointmentNotice("message_thread_closed".localized())
        }
    }
    
    private func loadMessages(firstLoad: Bool = false) {
        SessionManager.shared.apiManager.fetchThreadMessages(threadId: threadStub.id) {
            guard let thread = $0 else {
                return
            }
            
            self.thread = thread
            
            if firstLoad {
                SessionManager.shared.apiManager.getAppointment(id: thread.appointment.id) {
                    self.appointment = $0
                }
            }
            
            DispatchQueue.main.async {
                //MessageThreadTracker.markThreadAsRead(thread)
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
                self.configureAppointmentNotice(for: thread)
                self.delegate?.threadUpdated(thread)
            }
        }
    }
    
    private func send(_ text: String, inputBar: InputBarAccessoryView) {
        let message = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let thread = self.thread, message.count > 0 else {
            return
        }
        
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.text = nil
        inputBar.inputTextView.placeholder = "sending".localized()
        inputBar.inputTextView.isEditable = false
        
        SessionManager.shared.apiManager.sendMessage(thread: thread, message: message) { message in
            DispatchQueue.main.async {
                inputBar.sendButton.stopAnimating()
            }
            
            inputBar.inputTextView.placeholder = "enter_message".localized()
            inputBar.inputTextView.isEditable = true
            
            guard let message = message else {
                self.presentAlert(title: "basic_error_title".localized(), body: "something_went_wrong".localized())
                return
            }
            
            thread.latestMessages.append(message)
            
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    private func setAppointmentNotice(_ text: String) {
        inputBar.inputTextView.textAlignment = .center
        inputBar.inputTextView.isEditable = false
        inputBar.inputTextView.text = text
        inputBar.setStackViewItems([], forStack: .right, animated: false)
        inputBar.setRightStackViewWidthConstant(to: 0, animated: false)
    }
    
    @objc private func didReceiveMessage(_ notification: Notification) {
        guard isBeingShown,
              let message = notification.userInfo?["message"] as? WebsocketMessageModel,
              let thread = self.thread,
              message.threadId == thread.id else
        {
            return
        }
        
        loadMessages()
    }
    
    private func clickedAttach() {
        let allowFormAttachments: Bool
        
        if let appointment = thread?.appointment {
            allowFormAttachments = SessionManager.shared.user?.ownsAppointment(appointment) ?? false
        } else {
            allowFormAttachments = false
        }
        
        AttachmentOptionSelectorHelper.present(
            on: self,
            sender: inputBar.sendButton,
            allowFormAttachments: appointment != nil && allowFormAttachments,
            imageAction:
            {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.allowsEditing = false
                picker.mediaTypes = AttachmentOptionSelectorHelper.supportedMediaTypes
                picker.sourceType = .photoLibrary
                
                self.present(picker, animated: true, completion: nil)
        }, documentAction: {
            let picker = UIDocumentPickerViewController(
                documentTypes: AttachmentOptionSelectorHelper.supportedDocumentTypes,
                in: .import)
            
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }, formsAction: {
//            guard let appointment = self.appointment else {
//                return
//            }
            
//            let viewController = AssignFormWrapperViewController(
//                viewModel: AssignFormViewModel(
//                    state: .appointment(participants: appointment.participants)), source: .messages)
//            self.present(viewController, animated: true)
        })
    }
    
    private func upload(
        document data: Data,
        pathExtension: String,
        originalFileName: String,
        completion: @escaping (Bool) -> Void)
    {
//        guard let thread = thread else {
//            completion(false)
//            return
//        }
        
//        let uploadHelper = AttachmentUploadHelper()
//        uploadHelper.promptForAttachmentName(viewController: self, name: originalFileName) { name in
//            self.inputBar.sendButton.startAnimating()
//            uploadHelper.upload(
//                mode: .appointment(url: thread.appointment.url, participantIds: thread.appointment.participantIds),
//                document: data,
//                displayName: name,
//                pathExtension: pathExtension,
//                source: .messages)
//            { _ in
//                self.inputBar.sendButton.stopAnimating()
//            }
//        }
    }
    
    private func configureAttachmentButton(_ item: InputBarButtonItem) {
        item.setSize(CGSize(width: 25, height: 25), animated: false)
        item.image = "ic-paperclip".iconTemplate()
        item.imageView?.tintColor = .iconTintColor
        item.isEnabled = isSendButtonEnabled
    }
    
    private func configureSendButton(_ item: InputBarButtonItem) {
        item.setSize(CGSize(width: 52, height: 36), animated: false)
        item.title = "send".localized()
        item.image = nil
        item.isEnabled = isSendButtonEnabled
    }
    
    private func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard let thread = thread, indexPath.row - 1 >= 0 else {
            return false
            
        }
        
        return thread.groupedMessages[indexPath.section][indexPath.row].sender.senderId == thread.groupedMessages[indexPath.section][indexPath.row - 1].sender.senderId
    }
    
    private func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard let thread = thread, indexPath.row + 1 < thread.groupedMessages[indexPath.section].count else {
            return false
        }
        
        return thread.groupedMessages[indexPath.section][indexPath.row].sender.senderId == thread.groupedMessages[indexPath.section][indexPath.row + 1].sender.senderId
    }
    
    private func isNextGroupDifferentDate(at indexPath: IndexPath, message: MessageType) -> Bool {
        guard let thread = thread,
            indexPath.section - 1 > 0,
            let lastMessage = thread.groupedMessages[indexPath.section - 1].last else
        {
            return indexPath.section == 0
        }
        
        return !Calendar.current.isDate(lastMessage.sentDate, inSameDayAs: message.sentDate)
    }
}

// MARK: MessagesDataSource

extension MessageThreadViewController: MessagesDataSource {
    
    func currentSender() -> SenderType {
        guard let user = SessionManager.shared.user else {
            return MessageSender(senderId: "", displayName: "")
        }
        
        return MessageSender(senderId: String(user.id), displayName: user.fullName)
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return thread?.groupedMessages.count ?? 0
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return thread?.groupedMessages[section].count ?? 0
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return thread!.groupedMessages[indexPath.section][indexPath.row]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.row == 0 && isNextGroupDifferentDate(at: indexPath, message: message) {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                    NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.row == 0 {
            return NSAttributedString(
                string: message.sender.displayName,
                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if thread?.groupedMessages[indexPath.section].count == indexPath.row + 1 {
            let dateString = formatter.string(from: message.sentDate)
            return NSAttributedString(
                string: dateString,
                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        }
        
        return nil
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.row == 0 && isNextGroupDifferentDate(at: indexPath, message: message) ? 18 : 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return indexPath.row == 0 ? 20 : 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return thread?.groupedMessages[indexPath.section].count == indexPath.row + 1 ? 16 : 0
    }
}

// MARK: MessagesDisplayDelegate

extension MessageThreadViewController: MessagesDisplayDelegate {
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .custom { [weak self] in
            let mask = CAShapeLayer()
            mask.path = UIBezierPath(
                roundedRect: $0.bounds,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: 16, height: 16)).cgPath
            $0.layer.mask = mask
            
            if self?.isFromCurrentSender(message: message) == true {
                $0.backgroundColor = .messageColor
            }
        }
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .labelText
    }
}

// MARK: InputBarAccessoryViewDelegate

extension MessageThreadViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
//        if let attachmentCell = cell as? MessagingThreadAttachmentCell {
//            let indicator = presentLoadingIndicator()
//            SessionManager.shared.apiManager.getDownloadAttachmentLink(
//                attachmentId: attachmentCell.attachmentId)
//            { url in
//                indicator.dismiss {
//                    guard let url = url else { return }
//
//                    if (url.pathExtension.lowercased() == "pdf") {
//                        self.present(UINavigationController(
//                                    rootViewController: PDFViewController(
//                                        url: url,
//                                        title: "file".localized(),
//                                        savedMessage: "file_saved".localized(),
//                                        sentMessage: "file_sent".localized())),
//                                animated: true)
//                    } else {
//                        self.present(SFSafariViewController(url: url), animated: true)
//                    }
//                }
//            }
//        }
    }
}

// MARK: InputBarAccessoryViewDelegate

extension MessageThreadViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if text.isEmpty {
            clickedAttach()
        } else {
            send(text, inputBar: inputBar)
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text.isEmpty {
            configureAttachmentButton(inputBar.sendButton)
        } else {
            configureSendButton(inputBar.sendButton)
        }
    }
}

// MARK: - UIDocumentPickerDelegate

extension MessageThreadViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true)
        
        guard let url = urls.first else {
            return
        }

        let data: Data?
        let pathExtension: String
        
        if let image = UIImage(contentsOfFile: url.path) {
            data = image.compress()
            pathExtension = "jpg"
        } else {
            data = try? Data(contentsOf: url)
            pathExtension = url.pathExtension
        }
        
        guard let unwrappedData = data else {
            return
        }
        
        upload(
            document: unwrappedData,
            pathExtension: pathExtension,
            originalFileName: url.lastPathComponent)
        { success in
            if success {
                self.loadMessages()
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension MessageThreadViewController: UIImagePickerControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage, let data = image.compress() else {
            return
        }
        
        let originalFileName = (info[.imageURL] as? URL)?.lastPathComponent ?? ""
        
        upload(
            document: data,
            pathExtension: "jpg",
            originalFileName: originalFileName)
        { success in
            if success {
                self.loadMessages()
            }
        }
    }
}
