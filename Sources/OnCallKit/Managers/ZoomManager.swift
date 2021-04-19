import Bugsnag
import MobileRTC

class ZoomManager {
    static func joinZoomCall(appointment: AppointmentModel) -> Bool {
        guard let user = SessionManager.shared.user else {
            return false
        }
        
        guard let urlString = appointment.zoomUrl,
            let url = URLComponents(string: urlString),
            let meetingNoString = url.path.split(separator: "/").last,
            let meetingNo = Int(meetingNoString) else
        {
            Bugsnag.report(
                title: "Zoom Error",
                body: "Unable to join zoom appointment due to invalid url for user \(user.id)")
            
            return false
        }
        
        var params: [String: String?] = [:]
        
        if let queryItems = url.queryItems {
            for param in queryItems {
                params[param.name] = param.value
            }
        }
        
        if let zak = params["zak"],
            let zakString = zak {
            // Provider should start the meeting
            return ZoomManager.startMeeting(
                meetingNumber: Int(meetingNo),
                zak: zakString,
                user: user,
                appointment: appointment)
        } else if let passwordString = params["pwd"],
            let pwd = passwordString {
            // Patient should join the meeting
            return ZoomManager.joinMeeting(meetingNumber: Int(meetingNo), pwd: pwd, user: user, appointment: appointment)
            
        } else {
            Bugsnag.report(
                title: "Zoom Error",
                body: "Unable to join zoom appointment due to invalid zak or pwd for user \(user.id)")
            
            return false
        }
    }
    
    static func joinMeeting(meetingNumber: Int, pwd: String, user: UserModel, appointment: AppointmentModel) -> Bool {
        guard let meeting = MobileRTC.shared().getMeetingService() else {
            Bugsnag.report(
                title: "Zoom Error",
                body: "Could not get zoom meeting service for \(user.id)")
            
            return false
        }
        
        let params = MobileRTCMeetingJoinParam()
        params.meetingNumber = "\(meetingNumber)"
        params.userName = appointment.getParticipantName(for: user.email) ?? ""
        params.password = pwd

        meeting.joinMeeting(with: params)
        
        let res = meeting.joinMeeting(with: params)
        
        if res == .success {
            return true
        } else {
            // There seems to be a bug in the Zoom SDK that causes the the app to join the meeting without issue but
            // also returns this error
            if res == .meetingNotStart {
                return true
            }
            
            Bugsnag.report(
                title: "Zoom Error",
                body: "Could not join zoom appointment due to zoom response code being \(res) for user \(user.id)")
            
            return false
        }
    }
    
    static func startMeeting(meetingNumber: Int, zak: String, user: UserModel, appointment: AppointmentModel) -> Bool {
        guard let userId = user.zoomUserId,
            let meeting = MobileRTC.shared().getMeetingService() else
        {
            Bugsnag.report(
                title: "Zoom Error",
                body: "Could not get zoom meeting service or zoom user id for \(user.id)")
                
            return false
        }
        
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
        
        let res = meeting.startMeeting(with: params)
        
        if res == .success {
            return true
        } else {
            // There seems to be a bug in the Zoom SDK that causes the the app to join the meeting without issue but
            // also returns this error
            if res == .meetingNotStart {
                return true
            }
            
            Bugsnag.report(
                title: "Zoom Error",
                body: "Could not start zoom appointment due to zoom response code being \(res) for user \(user.id)")
            
            return false
        }
    }
}
