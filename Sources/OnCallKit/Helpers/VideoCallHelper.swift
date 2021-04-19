//
//  VideoCallHelper.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-05-26.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import Bugsnag
import UIKit
import MobileRTC

// MARK: - VideoCallHelperDelegate

protocol VideoCallHelperDelegate: AnyObject {
    func didEncounterError(shouldRestart: Bool)
}

// MARK: - VideoCallHelper

public class VideoCallHelper: NSObject {
    
    // MARK: Internal
    
    weak var delegate: VideoCallHelperDelegate?
    var joinedAppointment: AppointmentModel?

    public func joinCall(
        for appointment: AppointmentModel,
        callingViewController viewController: UIViewController,
        delegate mobileRtcDelegate: MobileRTCMeetingServiceDelegate)
    {
        MobileRTC.shared().getMeetingService()?.delegate = mobileRtcDelegate
        if appointment.zoomUrl != nil {
            if ZoomManager.joinZoomCall(appointment: appointment) {
                SessionManager.shared.apiManager.logVideoSession(for: appointment.id)
                joinedAppointment = appointment
            } else {
                // If we could not join the zoom meeting, it might be because the division was changed from Vidyo to
                // Zoom while the current user was still logged in. Therefore, we need to fetch an updated user object
                // to get their zoom access token.
                // This is a situation that should only happen the FIRST time a division is changed from Vidyo to Zoom.
                fetchUser {
                    if ZoomManager.joinZoomCall(appointment: appointment) {
                        SessionManager.shared.apiManager.logVideoSession(for: appointment.id)
                        self.joinedAppointment = appointment
                    } else {
                        // If the refetch still didn't allow the user to join the meeting, then something else is wrong.
                        self.delegate?.didEncounterError(shouldRestart: true)
                    }
                }
            }
            
            return
        }
    }
    
    // MARK: Private
    
    private func fetchUser(complete: @escaping () -> Void) {
        SessionManager.shared.fetchCurrentUser { _ in
            DispatchQueue.main.async {
                complete()
            }
        }
    }
}
