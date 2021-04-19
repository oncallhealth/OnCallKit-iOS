//
//  OnCallKit.swift
//  OnCallKit
//
//  Created by Domenic Bianchi on 2021-04-15.
//

import Foundation
import MobileRTC

public struct OnCallKit {
    
    public static func initalize() {
        let sdk = MobileRTC.shared()
        let context = MobileRTCSDKInitContext()
        context.domain = "zoom.us"
        
        #if DEBUG
        context.enableLog = true
        #endif
        
        sdk.initialize(context)
        
        let authService = sdk.getAuthService()
        if let authService = authService {
            //authService.delegate = self
            authService.clientKey = ApiKeys.zoomClientKey
            authService.clientSecret = ApiKeys.zoomClientSecret
            authService.sdkAuth()
        }
    }
}
