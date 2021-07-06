//
//  VideoCallHelper.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-05-26.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import MobileRTC

// MARK: - VideoCallHelperDelegate

protocol VideoCallHelperDelegate: AnyObject {
    func didEncounterError(errorMessage: String)
}

// MARK: - VideoCallHelper

class VideoCallHelper: NSObject {
    
    // MARK: Internal
    
    weak var delegate: VideoCallHelperDelegate?
    var joinedAppointment: AppointmentModel?

    func joinCall(
        for appointmentId: Int,
        callingViewController viewController: UIViewController & ZoomManagerDelegate)
    {
        let loadingIndicator = viewController.presentLoadingIndicator()
        
        SessionManager.shared.apiManager.joinVideoAppointment(appointmentId) { updatedAppointment in
            SessionManager.shared.fetchCurrentUser { _ in
                loadingIndicator.dismiss {
                    guard let updatedAppointment = updatedAppointment else {
                        self.delegate?.didEncounterError(errorMessage: "Unable to create room for appointment: \(appointmentId)")
                        return
                    }
                    
                    guard let user = SessionManager.shared.user else {
                        return
                    }
                    
                    switch updatedAppointment.division.videoProvider {
                    case .zoom, .zoompool:
                        if updatedAppointment.zoomUrl == nil {
                            self.delegate?.didEncounterError(errorMessage: "Appointment \(updatedAppointment.id) has its division set to either zoom or zoom pool but does not have a zoom url.")
                        } else if !user.ownsAppointment(updatedAppointment) || (user.ownsAppointment(updatedAppointment) == true && user.zoomUserId != nil) {
                            if self.zoomManager.joinZoomCall(
                                appointment: updatedAppointment,
                                rootViewController: viewController)
                            {
                                SessionManager.shared.apiManager.logVideoSession(for: updatedAppointment.id)
                                self.joinedAppointment = updatedAppointment
                            } else {
                                // No need to report anything to bugsnag here since the zoom manager will report to
                                // bugsnag for us.
                                self.delegate?.didEncounterError(errorMessage: "something_went_wrong".localized())
                            }
                        } else {
                            self.delegate?.didEncounterError(errorMessage: "Appointment \(updatedAppointment.id) failed pre-condition checks. It is possible that the provider does not have a zoomUserId attached to their user object.")
                        }
                    case .vidyo, .hunter:
                        self.delegate?.didEncounterError(errorMessage: "Division \(updatedAppointment.divisionId) is using vidyo or hunter which the SDK does not support")
                    default:
                        self.delegate?.didEncounterError(errorMessage: "Division \(updatedAppointment.divisionId) has an unrecognizable video provider.")
                    }
                }
            }
        }
    }
    
    // MARK: Private
    
    private let zoomManager = ZoomManager()
    
    private func connectedName(for user: UserModel, in appointment: AppointmentModel) -> String {
        if user.ownsAppointment(appointment) {
            return appointment.providerName
        } else {
            return appointment.getParticipantName(for: user.email) ?? ""
        }
    }
}
