//
//  LeftRightTextRow.swift
//  OnCallHealthiOS
//
//  Created by Domenic Bianchi on 2021-03-11.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - LeftRightTextRow

class LeftRightTextRow: UIView {
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        addSubview(leftLabel)
        addSubview(rightLabel)
        
        leftLabel.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
        }
        
        rightLabel.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
        }
        
        leftLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rightLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        leftLabel.isAccessibilityElement = false
        rightLabel.isAccessibilityElement = false
        isAccessibilityElement = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    func configure(leftText: String, rightText: String, fontSize: CGFloat = 14) {
        leftLabel.text = leftText
        rightLabel.text = rightText
        
        leftLabel.font = .systemFont(ofSize: fontSize)
        rightLabel.font = .systemFont(ofSize: fontSize)
        
        accessibilityLabel = "\(leftText), \(rightText)"
    }
    
    // MARK: Private
    
    private let leftLabel = UILabel()
    private let rightLabel = UILabel()
}
