//
//  LAContextExtensions.swift
//  OnCallHealthiOS
//
//  Created by Domenic Bianchi on 2021-03-15.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import LocalAuthentication

// MARK: - LAContext

extension LAContext {
    
    // MARK: BiometricType
    
    enum BiometricType {
        case none
        case touchID
        case faceID
    }
    
    // MARK: Internal

    var biometricType: BiometricType {
        var error: NSError?

        guard canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        @unknown default:
            return .none
        }
    }
    
    func evaluatePolicy(completion: @escaping (Bool) -> Void) {
        let reason: String
        
        switch biometricType {
        case .faceID:
            reason = "sign_in_face_id".localized()
        case .touchID:
            reason = "sign_in_touch_id".localized()
        case .none:
            completion(false)
            return
        }
        
        evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
}
