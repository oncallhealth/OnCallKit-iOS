//
//  TokenExpiryHandelable.swift
//  OnCallKit
//
//  Created by Domenic Bianchi on 2021-01-21.
//  Copyright © 2021 OnCall Health. All rights reserved.
//

import Foundation

// MARK: TokenExpiryHandleable

protocol TokenExpiryHandleable {
    func didReceive403(handler: @escaping () -> Void)
}
