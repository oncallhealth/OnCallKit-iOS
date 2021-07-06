//
//  AttachmentRow.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-07-14.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - AttachmentRow

class AttachmentRow: UITableViewCell {
    
    // MARK: Position
    
    enum Position {
        case top(onlyCell: Bool)
        case middle
        case bottom
    }
    
    // MARK: Style
    
    enum Style {
        case form(isComplete: Bool?)
        case file(type: FileType)
    }
    
    // MARK: FileType
    
    enum FileType: String {
        case pdf
        case doc
        case docx
        case xlsx
        case xls
        case jpeg
        case jpg
        case png
        case mp4
        case m4a
        case mp3
        case gif
        case other
        
        // MARK: Fileprivate
        
        fileprivate var icon: UIImage? {
            switch self {
            case .pdf:
                return "ic-file-pdf".icon()
            case .doc, .docx:
                return "ic-file-word".icon()
            case .xls, .xlsx:
                return "ic-file-excel".icon()
            case .jpeg, .jpg, .png:
                return "ic-file-image".icon()
            case .mp4, .gif:
                return "ic-file-video".icon()
            case .mp3, .m4a:
                return "ic-file-audio".icon()
            default:
                return "ic-file".icon()
            }
        }
    }
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        let containerView = UIView()
        contentView.addSubview(containerView)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(iconImageView)
        containerView.addSubview(menuImageView)
        containerView.addSubview(topBorder)
        containerView.addSubview(bottomBorder)
        containerView.addSubview(leftBorder)
        containerView.addSubview(rightBorder)
        
        containerView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
        
        menuImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(24)
            $0.centerY.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(24)
            $0.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalTo(iconImageView.snp.trailing).offset(20)
            $0.trailing.equalTo(menuImageView.snp.leading).offset(-10)
            nameCenterYConstraint = $0.centerY.equalToSuperview().constraint
        }
        
        nameCenterYConstraint?.deactivate()
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom)
            $0.leading.trailing.equalTo(nameLabel)
            $0.bottom.equalToSuperview().offset(-15)
        }
        
        leftBorder.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.top.bottom.leading.equalToSuperview()
        }
        
        rightBorder.snp.makeConstraints {
            $0.width.equalTo(1)
            $0.top.bottom.trailing.equalToSuperview()
        }
        
        topBorder.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.leading.trailing.equalToSuperview()
        }
        
        bottomBorder.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.bottom.leading.trailing.equalToSuperview()
        }
        
        leftBorder.backgroundColor = .border
        rightBorder.backgroundColor = .border
        topBorder.backgroundColor = .border
        bottomBorder.backgroundColor = .border
        
        nameLabel.font = .boldSystemFont(ofSize: 14)
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .subtitle
        
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.numberOfLines = 0
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .lightGray
        
        menuImageView.contentMode = .scaleAspectFit
        menuImageView.tintColor = .lightGray
        menuImageView.image = "ic-vertical-ellipsis".iconTemplate()
        
        menuImageView.isUserInteractionEnabled = true
        
        menuImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapMenuButton)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "AttachmentRow"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameCenterYConstraint?.deactivate()
        bottomBorder.isHidden = false
        subtitleLabel.text = nil
    }
    
    func configure(
        id: Int,
        name: String,
        subtitle: String?,
        position: Position,
        style: Style,
        isEditable: Bool) {
        self.style = style
        self.id = id
        
        nameLabel.text = name
        subtitleLabel.text = subtitle
        
        menuImageView.isHidden = !isEditable
        menuImageView.isAccessibilityElement = true
        menuImageView.accessibilityTraits = .button
        menuImageView.configureAccessibilityLabel(label: "Manage attachment \(name)")
        
        
        switch style {
        case let .form(isComplete):
            if let isComplete = isComplete {
                subtitleLabel.text = (subtitle ?? "") + " - " + (isComplete ? "complete".localized() : "incomplete".localized())
                iconImageView.image = (isComplete ? "ic-solid-check" : "ic-error").iconTemplate()
                iconImageView.tintColor = (isComplete ? .success : .gray)
                
                accessibilityHint = "Double tap to open form"
            } else {
                iconImageView.image = FileType.other.icon?.template()
            }
        case let .file(type):
            iconImageView.image = type.icon?.template()
            accessibilityHint = "Double tap to open file"
        }
        
        if subtitleLabel.text == nil {
            nameCenterYConstraint?.activate()
        }
        
        switch position {
        case .top(let onlyCell):
            if !onlyCell {
                bottomBorder.isHidden = true
            }
        case .middle:
            bottomBorder.isHidden = true
        case .bottom:
            break
        }
    }
    
    func setInteraction(didTapMenu: @escaping (_ id: Int?, _ sender: UIView) -> Void) {
        self.didTapMenu = didTapMenu
    }
    
    // MARK: Private
    
    private var style: Style?
    private var id: Int?
    
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let iconImageView = UIImageView()
    private let menuImageView = UIImageView()
    
    private let leftBorder = UIView()
    private let rightBorder = UIView()
    private let topBorder = UIView()
    private let bottomBorder = UIView()
    
    private var nameCenterYConstraint: Constraint?
    
    private var didTapMenu: ((_ id: Int?, _ sender: UIView) -> Void)?
    
    @objc private func didTapMenuButton() {
        didTapMenu?(id, menuImageView)
    }
}

// MARK: - NoFileAttachmentsTableViewCell

class NoFileAttachmentsTableViewCell: UITableViewCell {
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textComponent)
        textComponent.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "NoFileAttachmentsTableViewCell"
    
    func configure(text: String) {
        textComponent.configure(text: text, alignment: .center, type: .subtitle(bolded: false))
    }
    
    // MARK: Private
    
    private let textComponent = TextComponent()
    
}
