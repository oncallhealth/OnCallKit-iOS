//
//  MessageThreadRow.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-08-24.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - MessageThreadRowDelegate

protocol MessageThreadRowDelegate: AnyObject {
    func didTapSeeAllParticipants()
}

// MARK: - MessageThreadRow

class MessageThreadRow: UITableViewCell {
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(unreadIndicator)
        contentView.addSubview(namesLabel)
        contentView.addSubview(messagePreviewLabel)
        contentView.addSubview(detailsLabel)
        
        unreadIndicator.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(5)
            $0.centerY.equalTo(namesLabel)
            $0.width.height.equalTo(8)
        }
        
        namesLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalToSuperview().offset(10)
        }
        
        messagePreviewLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(namesLabel)
            $0.top.equalTo(namesLabel.snp.bottom).offset(15)
        }
        
        detailsLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(namesLabel)
            $0.top.equalTo(messagePreviewLabel.snp.bottom).offset(15)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        backgroundColor = .backgroundAlternate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "MessagingThreadTableViewCell"
    
    weak var delegate: MessageThreadRowDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        detailsLabel.configure([])
    }
    
    func configure(thread: MessagingThread, hasUnread: Bool, user: UserModel) {
        let names = thread.threadUsers.filter({$0.id != user.id}).map({ $0.fullName }).joined(separator: ", ")
        namesLabel.configure(text: names, numberOfLines: 1)
        
        var contentDescription = "\(names)."
        
        if !thread.latestMessages.isEmpty {
            let latestMessage = thread.latestMessages.sorted { $0.messageId > $1.messageId }[0]
            let lastMessageUser = thread.threadUsers.first(where: { String($0.id) == latestMessage.sender.senderId })?.fullName ?? "message".localized()
            let latestMessageText: String
            
            let formatter = DateFormatter()
            formatter.timeStyle = .none
            formatter.dateStyle = .medium
            
            let dateString = formatter.string(from: latestMessage.sentDate)
            
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            
            let timeString = formatter.string(from: latestMessage.sentDate)
            
            detailsLabel.configure([dateString, timeString])
            
            switch latestMessage.kind {
            case .text(let text):
                latestMessageText = text
                contentDescription += " The last message was sent by \(lastMessageUser) on \(dateString) at \(timeString). They said: \(latestMessageText)."
            default:
                latestMessageText = "attachment".localized()
                contentDescription += " The most recent message is an attachment sent by \(lastMessageUser) on \(dateString) at \(timeString)."
            }
            
            messagePreviewLabel.configure(text: "\(lastMessageUser): \(latestMessageText)", type: .subtitle(bolded: false))
        } else {
            messagePreviewLabel.configure(text: "no_messages".localized(), type: .subtitle(bolded: false))
            contentDescription += " \("no_messages".localized())."
        }
        
        unreadIndicator.isHidden = !hasUnread
        
        if thread.latestMessages.isEmpty {
            accessibilityLabel = contentDescription
        } else {
            accessibilityLabel = contentDescription + (hasUnread ? " This thread contains unread messages" : " All messages in this thread have been read")
        }
    }
    
    // MARK: Private
    
    private let namesLabel = TextComponent()
    private let messagePreviewLabel = TextComponent()
    private let detailsLabel = InformationRow()
    private let unreadIndicator = UnreadThreadIndicator()
    
}

// MARK: - UnreadThreadIndicator

private final class UnreadThreadIndicator: UIView {
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = true
        layer.cornerRadius = 4
        backgroundColor = .from(hexString: "#FB5300")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
