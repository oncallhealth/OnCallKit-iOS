//
//  ListErrorView.swift
//  Development Simulator
//
//  Created by Domenic Bianchi on 2020-09-28.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - ListErrorView

class ListErrorView: UIView {
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        let containerView = UIView()
        
        containerView.addSubview(imageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(actionButton)
        
        addSubview(containerView)
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.height.equalTo(100)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(25)
            $0.leading.trailing.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        actionButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(25)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(200)
            $0.centerX.equalToSuperview()
        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .lightGray
        
        actionButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    func configure(title: String, buttonText: String, iconName: String) {
        imageView.image = iconName.iconTemplate()
        titleLabel.text = title
        actionButton.configure(text: buttonText)
    }
    
    func setInteraction(didTapButton: @escaping () -> Void) {
        self.didTapButton = didTapButton
    }
    
    // MARK: Private
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let actionButton = BasicButton(style: .small)
    private var didTapButton: (() -> Void)?
    
    @objc private func didTap() {
        didTapButton?()
    }
}
