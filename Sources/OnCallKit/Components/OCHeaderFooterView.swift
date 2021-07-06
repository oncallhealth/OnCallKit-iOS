//
//  OCHeaderFooterView.swift
//  OnCallHealthiOS
//
//  Created by Domenic Bianchi on 2021-06-25.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - OCHeaderFooterView

class OCHeaderFooterView: UITableViewHeaderFooterView {
    
    // MARK: Lifecycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
        
        label.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.bottom.equalToSuperview().offset(-4)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
    
        tintColor = .background
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "OCHeaderFooterView"
    
    func configure(text: String, type: TextComponent.TextType = .normal(bolded: true), fontSize: CGFloat = 14) {
        label.configure(text: text, type: type, fontSize: fontSize)
    }
    
    // MARK: Private
    
    private let label = TextComponent()
    
}
