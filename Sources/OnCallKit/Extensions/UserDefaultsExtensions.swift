//
//  UserDefaultsExtensions.swift
//  OnCallHealthiOS
//
//  Created by Domenic Bianchi on 2021-03-02.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import Foundation

// MARK: - UserDefaults

extension UserDefaults {
    
    // MARK: Keys
    
    struct Keys {
        
        // MARK: Internal
        
        static var lastReadMessages: String {
            return "last_read_messages_" + String(SessionManager.shared.user?.id ?? 0)
        }
        
        static var seenLearningCards: String {
            return "seen_learning_cards" + String(SessionManager.shared.user?.id ?? 0)
        }
        
        static var confirmedPendingAppointment: String {
            return "confimed_pending_appointment" + String(SessionManager.shared.user?.id ?? 0)
        }
        
        static var declinedPendingAppointment: String {
            return "declined_pending_appointment" + String(SessionManager.shared.user?.id ?? 0)
        }
        
        static var biometricsState = "biometricsState"
    }
}
