//
//  OCJSONEncoder.swift
//  OnCall Health Staging
//
//  Created by Domenic Bianchi on 2020-08-10.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import Foundation

class OCJSONEncoder: JSONEncoder {
    
    override init() {
        super.init()
        
        keyEncodingStrategy = .convertToSnakeCase
        dateEncodingStrategy = .formatted(Date.iso8601)
    }
}

