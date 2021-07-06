import MobileRTC

// MARK: - ZoomManagerDelegate

public protocol ZoomManagerDelegate: AnyObject {
    func callDidEnd()
}

// MARK: - ZoomManager

class ZoomManager: NSObject {
    
    // MARK: Internal
    
    func joinZoomCall(
        appointment: AppointmentModel,
        rootViewController: UIViewController & ZoomManagerDelegate) -> Bool
    {
        guard let user = SessionManager.shared.user else {
            return false
        }
        
        guard let urlString = appointment.zoomUrl,
            let url = URLComponents(string: urlString),
            let meetingNoString = url.path.split(separator: "/").last,
            let meetingNo = Int(meetingNoString) else
        {
//            Bugsnag.report(
//                title: "Zoom Error",
//                body: "Unable to join zoom appointment due to invalid url for user \(user.id)")
            
            return false
        }
        
        var params: [String: String?] = [:]
        
        if let queryItems = url.queryItems {
            for param in queryItems {
                params[param.name] = param.value
            }
        }
        
        MobileRTC.shared().getMeetingSettings()?.setAutoConnectInternetAudio(true)
        
        if let zak = params["zak"],
            let zakString = zak {
            // Provider should start the meeting
            return startMeeting(
                meetingNumber: Int(meetingNo),
                zak: zakString,
                user: user,
                appointment: appointment,
                rootViewController: rootViewController)
        } else if let passwordString = params["pwd"],
            let pwd = passwordString {
            // Patient should join the meeting
            return joinMeeting(
                meetingNumber: Int(meetingNo),
                pwd: pwd,
                user: user,
                appointment: appointment,
                rootViewController: rootViewController)
            
        } else {
//            Bugsnag.report(
//                title: "Zoom Error",
//                body: "Unable to join zoom appointment due to invalid zak or pwd for user \(user.id)")
            
            return false
        }
    }
    
    // MARK: Private
    
    private weak var delegate: ZoomManagerDelegate? = nil
    
    private func joinMeeting(
        meetingNumber: Int,
        pwd: String,
        user: UserModel,
        appointment: AppointmentModel,
        rootViewController: UIViewController & ZoomManagerDelegate) -> Bool
    {
        guard let meeting = MobileRTC.shared().getMeetingService(),
              let meetingSettings = MobileRTC.shared().getMeetingSettings() else
        {
//            Bugsnag.report(
//                title: "Zoom Error",
//                body: "Could not get zoom meeting service for \(user.id)")
            
            return false
        }
        
        let params = MobileRTCMeetingJoinParam()
        params.meetingNumber = "\(meetingNumber)"
        params.userName = appointment.getParticipantName(for: user.email) ?? ""
        params.password = pwd
        params.noAudio = false
        params.noVideo = false
        
//        if DevelopmentFlag.customZoomUi.isFlagEnabled {
//            meetingSettings.enableCustomMeeting = true
//            meeting.customizedUImeetingDelegate = self
//        } else {
//            meetingSettings.enableCustomMeeting = false
//            meeting.customizedUImeetingDelegate = nil
//            MobileRTC.shared().getMeetingService()?.delegate = self
//        }
        
        meetingSettings.enableCustomMeeting = false
        meeting.customizedUImeetingDelegate = nil
        MobileRTC.shared().getMeetingService()?.delegate = self
        
        pendingAppointment = appointment
        rootVC = rootViewController
        delegate = rootViewController
        
        let res = meeting.joinMeeting(with: params)
        
        if res == .success {
            return true
        } else {
            // There seems to be a bug in the Zoom SDK that causes the the app to join the meeting without issue but
            // also returns this error
            if res == .meetingNotStart {
                return true
            }
            
//            Bugsnag.report(
//                title: "Zoom Error",
//                body: "Could not join zoom appointment due to zoom response code being \(res) for user \(user.id)")
            
            return false
        }
    }
    
    private func startMeeting(
        meetingNumber: Int,
        zak: String,
        user: UserModel,
        appointment: AppointmentModel,
        rootViewController: UIViewController & ZoomManagerDelegate) -> Bool
    {
        guard let userId = user.zoomUserId,
            let meeting = MobileRTC.shared().getMeetingService(),
            let meetingSettings = MobileRTC.shared().getMeetingSettings() else
        {
//            Bugsnag.report(
//                title: "Zoom Error",
//                body: "Could not get zoom meeting service or zoom user id for \(user.id)")
                
            return false
        }
        
//        if DevelopmentFlag.customZoomUi.isFlagEnabled {
//            meetingSettings.enableCustomMeeting = true
//            meeting.customizedUImeetingDelegate = self
//        } else {
//            meetingSettings.enableCustomMeeting = false
//            meeting.customizedUImeetingDelegate = nil
//            MobileRTC.shared().getMeetingService()?.delegate = self
//        }
        
        meetingSettings.enableCustomMeeting = false
        meeting.customizedUImeetingDelegate = nil
        MobileRTC.shared().getMeetingService()?.delegate = self
        
        meeting.customizeMeetingTitle(appointment.title)
        
        let params = MobileRTCMeetingStartParam4WithoutLoginUser()
        params.userType = .apiUser
        params.meetingNumber = "\(meetingNumber)"
        params.userName = appointment.providerName
        params.userID = userId
        params.isAppShare = false
        params.zak = zak
        params.noVideo = false
        params.noAudio = false
        
        pendingAppointment = appointment
        rootVC = rootViewController
        delegate = rootViewController
        
        let res = meeting.startMeeting(with: params)
        
        if res == .success {
            return true
        } else {
            // There seems to be a bug in the Zoom SDK that causes the the app to join the meeting without issue but
            // also returns this error
            if res == .meetingNotStart {
                return true
            }
            
//            Bugsnag.report(
//                title: "Zoom Error",
//                body: "Could not start zoom appointment due to zoom response code being \(res.rawValue) for user \(user.id)")

            return false
        }
    }
    
    //private var zoomVc: ZoomMeetingViewController? = nil
    private var rootVC: (UIViewController & ZoomManagerDelegate)? = nil
    private var pendingAppointment: AppointmentModel? = nil
    
}

// MARK: MobileRTCMeetingServiceDelegate

extension ZoomManager: MobileRTCMeetingServiceDelegate {
    func onMeetingEndedReason(_ reason: MobileRTCMeetingEndReason) {
        delegate?.callDidEnd()
    }
}

//// MARK: MobileRTCCustomizedUIMeetingDelegate
//
//extension ZoomManager: MobileRTCCustomizedUIMeetingDelegate {
//
//    func onInitMeetingView() {
//        guard let appointment = pendingAppointment else {
//            return
//        }
//
//        let vc = ZoomMeetingViewController(appointment: appointment)
//        zoomVc = vc
//        rootVC?.present(vc, animated: true)
//    }
//
//    func onDestroyMeetingView() {
//        zoomVc?.dismiss(animated: true) {
//            self.delegate?.callDidEnd()
//        }
//    }
//}
