//
//  BundleExtensions.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-05-28.
//  Copyright © 2020 Arsham. All rights reserved.
//

import Foundation

extension Bundle {
    var displayName: String? {
        return infoDictionary?["CFBundleDisplayName"] as? String
    }
    
    var version: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
