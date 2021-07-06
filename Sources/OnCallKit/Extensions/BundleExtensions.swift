//
//  BundleExtensions.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-05-28.
//  Copyright © 2020 Arsham. All rights reserved.
//

import Foundation

// MARK: - Bundle

extension Bundle {
    
    // MARK: Internal
    
    var displayName: String? {
        return infoDictionary?["CFBundleDisplayName"] as? String
    }
    
    var version: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var preferredLocalization: String? {
        return Bundle.main.preferredLocalizations.first
    }
    
    var bundleId: String? {
        return infoDictionary?["CFBundleIdentifier"] as? String
    }
}
