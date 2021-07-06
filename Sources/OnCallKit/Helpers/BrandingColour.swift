//
//  BrandingColour.swift
//  
//
//  Created by Domenic Bianchi on 2021-07-06.
//

import Foundation

// MARK: BrandingColour

public struct BrandingColour {
    
    // MARK: Lifecycle
    
    init(light: String, dark: String) {
        self.light = light
        self.dark = dark
    }
    
    // MARK: Internal
    
    let light: String
    let dark: String
}
