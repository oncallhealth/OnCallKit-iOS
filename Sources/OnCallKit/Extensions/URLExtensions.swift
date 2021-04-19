//
//  URLExtensions.swift
//  Development Simulator
//
//  Created by Domenic Bianchi on 2020-09-11.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import Foundation

extension URL {
    
    func getQueryStringParameter(_ parameter: String) -> String? {
        return URLComponents(string: absoluteString)?.queryItems?.first { $0.name == parameter }?.value
    }
}
