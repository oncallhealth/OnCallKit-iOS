//
//  OnCallKit.swift
//  OnCallKit
//
//  Created by Domenic Bianchi on 2021-04-15.
//

import Foundation
import MobileRTC

// MARK: - OnCallKit

public struct OnCallKit {
    
    // MARK: Internal
    
    public static func initalize(
        token: String,
        baseDomain: String,
        primaryColour: BrandingColour,
        secondaryColour: BrandingColour,
        completion: @escaping (Bool) -> Void)
    {
        SessionManager.shared.initialize(
            token: token,
            baseDomain: baseDomain,
            primaryColour: primaryColour,
            secondaryColour: secondaryColour)
        { success in
            if success {
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
                
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    public static func startVideoAppointment(
        for appointmentId: Int,
        viewController: UIViewController & ZoomManagerDelegate)
    {
        guard SessionManager.shared.user != nil else {
            return
        }
            
        videoCallHelper.joinCall(for: appointmentId, callingViewController: viewController)
    }
    
    private static let videoCallHelper = VideoCallHelper()
}
