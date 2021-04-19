//
//  NavigationHeader.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-06-18.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - NavigationHeader

class NavigationHeader: UIView {
    
    // MARK: Lifecycle
    
    init() {
        super.init(frame: .zero)
        
        addSubview(closeButton)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(seperatorView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20).priority(.high)
            $0.trailing.equalToSuperview().offset(-18)
            titleLeadingConstraint = $0.leading.equalToSuperview().offset(18).constraint
            titleLeadingToButtonConstraint = $0.leading.equalTo(closeButton.snp.trailing).offset(18).constraint
        }
        
        titleLeadingConstraint?.deactivate()
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.trailing.equalTo(titleLabel)
        }
        
        seperatorView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(10)
            $0.height.equalTo(1)
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.width.height.equalTo(30)
        }
        
        titleLabel.font = .boldSystemFont(ofSize: 26)
        subtitleLabel.font = .systemFont(ofSize: 12)
        
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        
        subtitleLabel.numberOfLines = 0
        subtitleLabel.lineBreakMode = .byWordWrapping
        subtitleLabel.textColor = .subtitle
        
        seperatorView.backgroundColor = .border
        
        closeButton.setImage("ic-close".iconTemplate(), for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.tintColor = .primary
        
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    func configure(
        title: String,
        subtitle: String? = nil,
        hideCloseButton: Bool = false,
        hideSeperator: Bool = true)
    {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        seperatorView.isHidden = hideSeperator
        closeButton.isHidden = hideCloseButton
        
        if hideCloseButton {
            titleLeadingToButtonConstraint?.deactivate()
            titleLeadingConstraint?.activate()
        } else {
            titleLeadingConstraint?.deactivate()
            titleLeadingToButtonConstraint?.activate()
        }
    }
    
    func setInteraction(_ didTap: @escaping () -> Void) {
        self.didTap = didTap
    }
    
    // MARK: Private
    
    private let closeButton = UIButton()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let seperatorView = UIView()
    private var didTap: (() -> Void)?
    
    private var titleLeadingConstraint: Constraint?
    private var titleLeadingToButtonConstraint: Constraint?
    
    @objc private func didTapCloseButton() {
        didTap?()
    }
}
