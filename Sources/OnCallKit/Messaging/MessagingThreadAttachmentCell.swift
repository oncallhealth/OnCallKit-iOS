//
//  MessagingThreadAttachmentCell.swift
//  Development
//
//  Created by Domenic Bianchi on 2020-09-03.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import MessageKit
import SnapKit
import UIKit

// MARK: - MessagingThreadAttachmentCell

class MessagingThreadAttachmentCell: MessageContentCell {
    
    // MARK: Internal
    
    private(set) var attachmentId: Int = 0
    
    override func setupSubviews() {
        super.setupSubviews()
        
        attachmentView.layer.cornerRadius = 16
        
        fileTypeIcon.contentMode = .scaleAspectFit
        
        fileNameLabel.font = .systemFont(ofSize: 12)
        fileTypeLabel.font = .systemFont(ofSize: 12)
        
        attachmentView.addSubview(fileTypeIcon)
        attachmentView.addSubview(fileNameLabel)
        messageContainerView.addSubview(attachmentView)
        messageContainerView.addSubview(fileTypeLabel)
        
        attachmentView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview().offset(-5)
            $0.height.equalTo(32)
        }
        
        fileTypeIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(15)
            $0.bottom.equalToSuperview().offset(-5)
            $0.width.height.equalTo(15)
        }
        
        fileNameLabel.snp.makeConstraints {
            $0.leading.equalTo(fileTypeIcon.snp.trailing).offset(5)
            $0.top.bottom.equalTo(fileTypeIcon)
            $0.trailing.equalToSuperview().offset(-3)
        }
        
        fileTypeLabel.snp.makeConstraints {
            $0.leading.equalTo(attachmentView).offset(5)
            $0.top.equalTo(attachmentView.snp.bottom).offset(5)
            $0.bottom.trailing.equalToSuperview().offset(-5)
        }
    }
    
    override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        if case let .custom(attachment) = message.kind, let unwrappedAttachment = attachment as? MessagingAttachment {
            attachmentId = unwrappedAttachment.id
            
            fileNameLabel.text = unwrappedAttachment.displayName
            
            let fileExtension = URL(fileURLWithPath: unwrappedAttachment.displayName).pathExtension
            fileTypeIcon.image = icon(for: fileExtension)
            fileTypeLabel.text = fileExtension.isEmpty ? "file".localized() : fileExtension.uppercased()
        }
        
        // This is a hack but there really isn't any better way.
        // If the background colour is `messageColor`, the message was sent by the logged in user
        if messageContainerView.backgroundColor == UIColor.messageColor {
            fileNameLabel.textColor = .white
            fileTypeLabel.textColor = .white
            fileTypeIcon.tintColor = .white
        } else {
            fileNameLabel.textColor = .labelText
            fileTypeLabel.textColor = .labelText
            fileTypeIcon.tintColor = .labelText
        }
        
        attachmentView.backgroundColor = messageContainerView.backgroundColor?.darker()
    }
    
    // MARK: Private
    
    private let attachmentView =  UIView()
    private let fileTypeIcon = UIImageView()
    private let fileNameLabel = UILabel()
    private let fileTypeLabel = UILabel()
    
    private func icon(for fileExtension: String) -> UIImage? {
        switch fileExtension {
        case "pdf":
            return "ic-file-pdf".iconTemplate()
        case "doc", "docx":
            return "ic-file-word".iconTemplate()
        case "xls", "xlsx":
            return "ic-file-excel".iconTemplate()
        case "jpeg", "jpg", "png":
            return "ic-file-image".iconTemplate()
        case "mp4", "gif":
            return "ic-file-video".iconTemplate()
        case "mp3", "m4a":
            return "ic-file-audio".iconTemplate()
        default:
            return "ic-file".iconTemplate()
        }
    }
}

class CustomMessageSizeCalculator: MessageSizeCalculator {
    public override init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        outgoingAvatarSize = .zero
        incomingAvatarSize = .zero
        
        let outgoingAlignment = LabelAlignment(
            textAlignment: .right,
            textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))
        let incomingAlignment = LabelAlignment(
            textAlignment: .left,
            textInsets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        
        outgoingMessageTopLabelAlignment = outgoingAlignment
        outgoingMessageBottomLabelAlignment = outgoingAlignment
        incomingMessageTopLabelAlignment = incomingAlignment
        incomingMessageBottomLabelAlignment = incomingAlignment

        self.layout = layout
    }

    override func messageContainerSize(for message: MessageType) -> CGSize {
        return CGSize(width: 250, height: 65)
    }
}

class MyCustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    lazy var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)
    
    override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath);
    }
}
