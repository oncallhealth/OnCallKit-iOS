//
//  ParticipantsAndTypeRow.swift
//  OnCallHealthiOS
//
//  Created by Domenic Bianchi on 2021-06-28.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import UIKit

// MARK: - ParticipantsAndTypeRowDelegate

protocol ParticipantsAndTypeRowDelegate: AnyObject {
    func didTapSeeAllParticipants(sender: UIView, _ appointment: AppointmentModel)
}

// MARK: - ParticipantsAndTypeRow

class ParticipantsAndTypeRow: UIView {
    
    init() {
        super.init(frame: .zero)
        
        addSubview(disclosureButton)
        addSubview(appointmentTypeImageView)
        addSubview(appointmentTypeLabel)
        
        disclosureButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(appointmentTypeImageView.snp.leading).offset(-5)
        }
        
        appointmentTypeImageView.snp.makeConstraints {
            $0.top.equalTo(disclosureButton)
            $0.trailing.equalTo(appointmentTypeLabel.snp.leading).offset(-5)
            $0.width.height.equalTo(16)
            $0.bottom.equalToSuperview()
        }
        
        appointmentTypeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.top.bottom.equalTo(appointmentTypeImageView)
        }
        
        appointmentTypeLabel.font = .systemFont(ofSize: 12)
        
        appointmentTypeImageView.tintColor = .subtitle
        appointmentTypeLabel.textColor = .subtitle
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    weak var delegate: ParticipantsAndTypeRowDelegate? = nil
    
    func configure(_ appointment: AppointmentModel, user: UserModel) {
        if appointment.participants.count > 1 {
            disclosureButton.configure(
                text: String(format: "number_of_participants".localized(), appointment.participants.count))
            { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.delegate?.didTapSeeAllParticipants(sender: self.disclosureButton, appointment)
            }
            
            disclosureButton.isAccessibilityElement = true
            disclosureButton.configureAccessibilityLabel(label: String(format: "number_of_participants".localized(), appointment.participants.count), hint: "Tap to view participants")
        } else if user.ownsAppointment(appointment) {
            disclosureButton.isAccessibilityElement = false
            disclosureButton.configure(text: appointment.participants.first?.name ?? "", hideChevron: true) {}
        } else {
            disclosureButton.isAccessibilityElement = false
            disclosureButton.configure(text: appointment.providerName, hideChevron: true) {}
        }
        
        switch appointment.appointmentType {
        case .inperson:
            appointmentTypeImageView.image = "appt-type-inperson".iconTemplate()
            appointmentTypeLabel.text = "in_person".localized()
        case .phone:
            appointmentTypeImageView.image = "appt-type-phone".iconTemplate()
            appointmentTypeLabel.text = "phone".localized()
        case .video:
            appointmentTypeImageView.image = "appt-type-video".iconTemplate()
            appointmentTypeLabel.text = "video".localized()
        case .message:
            appointmentTypeImageView.image = "appt-type-message".iconTemplate()
            appointmentTypeLabel.text = "message".localized()
        }
    }
    
    // MARK: Private
    
    private let disclosureButton = ChevronRow()
    private let appointmentTypeImageView = UIImageView()
    private let appointmentTypeLabel = UILabel()
    
}

// MARK: - ParticipantsAndTypeRowCell

class ParticipantsAndTypeRowCell: UITableViewCell {
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(participantsAndTypeRow)
        
        participantsAndTypeRow.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(5)
            $0.bottom.equalToSuperview().offset(-5)
        }
        
        participantsAndTypeRow.delegate = self
        
        selectionStyle = .none
        backgroundColor = .background
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Internal
    
    static let reuseIdentifier = "ParticipantsAndTypeRowCell"
    
    weak var delegate: ParticipantsAndTypeRowDelegate? = nil
    
    func configure(_ appointment: AppointmentModel, user: UserModel) {
        participantsAndTypeRow.configure(appointment, user: user)
    }
    
    // MARK: Private
    
    private let participantsAndTypeRow = ParticipantsAndTypeRow()
    
}

extension ParticipantsAndTypeRowCell: ParticipantsAndTypeRowDelegate {
    func didTapSeeAllParticipants(sender: UIView, _ appointment: AppointmentModel) {
        delegate?.didTapSeeAllParticipants(sender: sender, appointment)
    }
}
