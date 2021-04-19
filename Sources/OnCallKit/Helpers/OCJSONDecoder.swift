//
//  OCJSONDecoder.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-08-24.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import Foundation

// MARK: - OCJSONDecoder

class OCJSONDecoder: JSONDecoder {
    
    // MARK: Lifecycle
    
    override init() {
        super.init()
        
        keyDecodingStrategy = .convertFromSnakeCase
    }
}
