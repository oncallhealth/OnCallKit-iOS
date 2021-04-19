//
//  PresentationType.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-05-06.
//  Copyright © 2020 Arsham. All rights reserved.
//

import Foundation

// MARK: PresentationType

enum PresentationType: Equatable {
    case modal(fromDeeplink: Bool)
    case push
    
    // MARK: Internal
    
    static func ==(lhs: PresentationType, rhs: PresentationType) -> Bool {
        switch (lhs, rhs) {
        case (.modal, .modal), (.push, .push):
            return true
        default:
            return false
        }
    }
}
