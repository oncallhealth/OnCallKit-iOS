//
//  TextIconRow.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-08.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - TextIconRow

class TextIconRow: UITableViewCell {
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(label)
        contentView.addSubview(iconImageView)
        
        iconImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(20)
        }
        
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.top.equalToSuperview().offset(18)
            $0.bottom.equalToSuperview().offset(-18)
            $0.trailing.equalTo(iconImageView.snp.leading).offset(-10)
        }
        
        label.font = .systemFont(ofSize: 14)
        iconImageView.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(false, animated: animated)
        label.textColor = highlighted ? cellTintColor?.darker() : cellTintColor
        iconImageView.tintColor = highlighted ? cellTintColor?.darker() : cellTintColor
    }
    
    func configure(text: String, icon: String, tintColor: UIColor? = nil) {
        cellTintColor = tintColor
        
        label.text = text
        iconImageView.image = icon.iconTemplate()
        
        label.textColor = tintColor
        iconImageView.tintColor = tintColor
    }
    
    // MARK: Private
    
    private let label = UILabel()
    private let iconImageView = UIImageView()
    
    private var cellTintColor: UIColor?
}
