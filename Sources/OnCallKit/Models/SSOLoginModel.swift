//
//  SSOLoginModel.swift
//  Development
//
//  Created by Domenic Bianchi on 2020-09-01.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import Foundation

// MARK: - SSOLoginModel

struct SSOLoginModel: Decodable {
    
    // MARK: Internal
    
    let url: String
    let parameters: SSOLoginParameters
}

// MARK: - SSOLoginParameters

struct SSOLoginParameters: Decodable {
    
    // MARK: Internal
    
    let identityProvider: String
    let clientId: String
    let responseType: String
    let state: String
}

// MARK: - SSOLoginTokenModel

struct SSOLoginTokenModel: Decodable {
    
    // MARK: Internal
    
    let token: String
}
