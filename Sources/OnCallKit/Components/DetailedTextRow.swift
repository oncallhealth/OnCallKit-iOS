//
//  DetailedTextRow.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-08-26.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - DetailedTextRow

class DetailedTextRow: UITableViewCell {
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        iconButton.imageView?.contentMode = .scaleAspectFit
        iconButton.tintColor = .primaryWhite
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(iconButton)
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-5)
            $0.trailing.equalTo(iconButton.snp.leading).offset(-10)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        iconButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(20)
        }
        
        iconButton.addTarget(self, action: #selector(didTapIcon), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "DetailedTextRow"
    
    func configure(title: String, subtitle: String, icon: String? = nil) {
        titleLabel.configure(text: title)
        subtitleLabel.configure(text: subtitle, type: .subtitle(bolded: false))
        
        if let image = icon?.iconTemplate() {
            iconButton.setImage(image, for: .normal)
            iconButton.isEnabled = true
        } else {
            iconButton.isEnabled = false
        }
    }
    
    func setInteraction(_ didTap: @escaping () -> Void) {
        self.didTap = didTap
    }
    
    // MARK: Private
    
    private let titleLabel = TextComponent()
    private let subtitleLabel = TextComponent()
    private let iconButton = UIButton()
    
    private var didTap: (() -> Void)?
    
    @objc private func didTapIcon() {
        didTap?()
    }
}
