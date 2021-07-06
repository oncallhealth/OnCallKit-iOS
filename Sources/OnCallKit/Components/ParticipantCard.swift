//
//  ParticipantCard.swift
//  OnCallHealthiOS
//
//  Created by Domenic Bianchi on 2021-06-08.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import SnapKit
import UIKit

// MARK: - ParticipantCard

class ParticipantCard: UITableViewCell {
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(iconsStackView)
        
        containerView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(5)
            $0.trailing.bottom.equalToSuperview().offset(-5)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalTo(iconsStackView.snp.leading).offset(-5)
        }
        
        iconsStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.height.equalTo(25)
            $0.centerY.equalToSuperview()
        }
        
        iconsStackView.spacing = 15
        
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.border.cgColor
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "ParticipantCard"
    static let reuseIdentifierForProvider = "ParticipantCardProvider"
    
    func configure(participant: AppointmentParticipantModel, isProvider: Bool = false, buttonTitles: [String] = []) {
        nameLabel.configure(
            text: participant.name + (isProvider ? " (\("provider".localized()))" : ""),
            textColor: isProvider ? .darkGray : nil,
            type: .normal(bolded: true))
        
        if isProvider {
            subtitleLabel.isHidden = true
            iconsStackView.isHidden = true
            
            subtitleLabel.snp.remakeConstraints {
                $0.leading.trailing.equalTo(nameLabel)
                $0.bottom.equalToSuperview()
                $0.top.equalTo(nameLabel.snp.bottom).offset(15)
            }
        } else {
            var infoArray = [participant.email]
            
            if let fee = participant.fee, fee > 0 {
                infoArray.append(String(format: "$%.02f", fee))
            }
            
            subtitleLabel.configure(infoArray)
            subtitleLabel.isHidden = false

            subtitleLabel.snp.remakeConstraints {
                $0.leading.trailing.equalTo(nameLabel)
                $0.bottom.equalToSuperview().offset(-15)
                $0.top.equalTo(nameLabel.snp.bottom)
            }
        }
        
        iconsStackView.removeSubviews()
        
        buttonTitles.forEach {
            let iconButton = UIButton()
            
            iconButton.imageView?.contentMode = .scaleAspectFit
            iconButton.tintColor = .primaryWhite
            iconButton.setImage($0.iconTemplate(), for: .normal)
            iconButton.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right:4)
            
            iconButton.snp.makeConstraints {
                $0.height.width.equalTo(25)
            }
            
            iconsStackView.addArrangedSubview(iconButton)
            iconButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        }
        
        containerView.backgroundColor = isProvider ? .clear : .secondaryBackground
    }
    
    func setInteraction(didTapButtonAction: @escaping (Int) -> Void) {
        self.didTapButtonAction = didTapButtonAction
    }
    
    // MARK: Private
    
    private let containerView = UIView()
    private let nameLabel = TextComponent()
    private let subtitleLabel = InformationRow()
    private let iconsStackView = UIStackView()
    
    private var didTapButtonAction: ((Int) -> Void)? = nil
    
    @objc func didTapButton(_ sender: UIButton) {
        guard let index = iconsStackView.subviews.firstIndex(of: sender) else {
            return
        }
        
        didTapButtonAction?(index)
    }
}
