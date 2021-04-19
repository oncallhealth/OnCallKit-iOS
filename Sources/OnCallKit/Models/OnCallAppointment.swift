//
//  OnCallAppointment.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-08-25.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import Foundation

// MARK: - OnCallAppointment

protocol OnCallAppointment {
    
    // MARK: Internal
    
    var id: Int { get }
    var providerId: Int { get }
    var participants: [AppointmentParticipantModel] { get }
    
}
