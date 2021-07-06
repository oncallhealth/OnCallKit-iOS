//
//  TextIconView.swift
//  OnCallHealthiOS
//
//  Created by Domenic Bianchi on 2021-06-08.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - TextIconView

class TextIconView: UIView {
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
    
        addSubview(label)
        addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(20)
        }
        
        label.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(18)
            $0.trailing.equalToSuperview().offset(-18)
            $0.top.equalToSuperview().offset(5)
            $0.bottom.equalToSuperview().offset(-5)
        }
        
        label.font = .systemFont(ofSize: 14)
        iconImageView.contentMode = .scaleAspectFit
        
        label.textColor = .darkGray
        iconImageView.tintColor = .darkGray
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    func configure(text: String, icon: String) {
        label.text = text
        iconImageView.image = icon.iconTemplate()
    }
    
    // MARK: Private
    
    private let label = UILabel()
    private let iconImageView = UIImageView()

}
