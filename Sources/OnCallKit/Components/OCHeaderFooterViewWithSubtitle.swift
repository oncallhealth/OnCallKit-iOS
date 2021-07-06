//
//  OCHeaderFooterViewWithSubtitle.swift
//  OnCallHealthiOS
//
//  Created by Domenic Bianchi on 2021-06-25.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - OCHeaderFooterViewWithSubtitle

class OCHeaderFooterViewWithSubtitle: UITableViewHeaderFooterView {
    
    // MARK: Lifecycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.bottom.equalToSuperview().offset(-4)
        }
    
        tintColor = .background
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "OCHeaderFooterViewWithSubtitle"
    
    func configure(title: String, subtitle: String, type: TextComponent.TextType = .normal(bolded: true)) {
        titleLabel.configure(text: title, type: type)
        subtitleLabel.configure(text: subtitle, type: .subtitle(bolded: false), fontSize: 12)
    }
    
    // MARK: Private
    
    private let titleLabel = TextComponent()
    private let subtitleLabel = TextComponent()
    
}
