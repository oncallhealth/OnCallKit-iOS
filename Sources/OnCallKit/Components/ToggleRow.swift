//
//  ToggleRow.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-07-08.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - ToggleRow

class ToggleRow: UITableViewCell {
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(label)
        contentView.addSubview(toggle)
        
        toggle.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
        }
        
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(18)
            $0.bottom.equalToSuperview().offset(-18)
            $0.trailing.equalTo(toggle.snp.leading).offset(-10)
        }
        
        label.font = .systemFont(ofSize: 14)
        
        toggle.onTintColor = .primary
        toggle.addTarget(self, action: #selector(didSwitch), for: .valueChanged)
    }
    
    func setInteraction(didToggle: @escaping (Bool) -> Void) {
        self.didToggle = didToggle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "ToggleRow"
    
    func configure(text: String, isOn: Bool) {
        label.text = text
        toggle.isOn = isOn
    }
    
    // MARK: Private
    
    private let label = UILabel()
    private let toggle = UISwitch()
    
    private var didToggle: ((Bool) -> Void)?
    
    @objc private func didSwitch() {
        didToggle?(toggle.isOn)
    }
}
