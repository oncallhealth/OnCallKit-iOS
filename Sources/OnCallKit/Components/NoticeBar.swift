//
//  NoticeBar.swift
//  Development Simulator
//
//  Created by Domenic Bianchi on 2020-09-28.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - NoticeBar

class NoticeBar: UIView {
 
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        addSubview(infoLabel)
        
        infoLabel.font = .systemFont(ofSize: 12)
        infoLabel.textAlignment = .center
        
        infoLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().offset(5)
            $0.bottom.equalToSuperview().offset(-5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    func configure(text: String, textColor: UIColor = .white, backgroundColor: UIColor = .error) {
        infoLabel.text = text
        infoLabel.textColor = textColor
        self.backgroundColor = backgroundColor
    }
    
    // MARK: Private
    
    private let infoLabel = UILabel()
    
}
