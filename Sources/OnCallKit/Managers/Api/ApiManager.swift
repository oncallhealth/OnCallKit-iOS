import Foundation
import Alamofire
import PromiseKit

// MARK: - ApiError

enum ApiError: Error {
    case invalidData(message: String?)
    case responseError(message: String?)
    
    // MARK: Internal
    
    var errorMessage: String {
        switch self {
        case .invalidData(let message):
            return message ?? "something_went_wrong".localized()
        case .responseError(let message):
            return message ?? "something_went_wrong".localized()
        }
    }
}

// MARK: - Network Error

enum NetworkError: Error {
    case standardError(code: Int, json: Data?)
}

// MARK: - ApiManager

typealias JSON = [String: Any]
typealias ApiResponse = (code: Int, body: Data)
typealias CancellablePromise = (promise: Promise<ApiResponse>, cancel: CancelPromiseClosure)
typealias CancelPromiseClosure = () -> Void
typealias OCResult<T> = Swift.Result<T, ApiError>

class ApiManager {
    private var basePath: String {
        return "https://\(SessionManager.shared.domain)/api"
    }
    
    private var ssoPath: String {
        return "https://\(SessionManager.shared.domain)/sso"
    }
    
    static let ssoRedirectUri = "oncallmobile://sso/login"
    static let ssoCallbackURLScheme = "oncallmobile"
    static let formRedirectUrl = "oncallmobile://forms"
}

// MARK: - User
extension ApiManager {
    func validateTwoFactorCode(_ code: String, completion: @escaping (OCResult<Void>) -> Void) {
        firstly {
            post(endpoint: "\(basePath)/second-factor/", body: ["otp": code]).promise
        }.done { _ in
            completion(.success(()))
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            completion(.failure(.responseError(message: nil)))
        }
    }
    
    func getProviders(complete: @escaping ([UserModel]?) -> Void) {
        performFetchUserRequest(params: ["clinic_providers": "true"]) { users in
            complete(users)
        }
    }
    
    func fetchCurrentUser(complete: @escaping (UserModel?) -> Void) {
        performFetchUserRequest(params: ["self": "true"]) { users in
            complete(users?.first)
        }
    }
    
    func pushStripeToken(user: UserModel, token: String, complete: @escaping ((Bool) -> Void)) {
        firstly {
            patch(endpoint: "\(basePath)/oncallusers/\(user.id)", body: ["stripe_creditcard_token": token]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
    
    func getSessionFromToken(complete: @escaping (([HTTPCookie]?) -> Void)) {
        guard let token = SessionManager.shared.token, let loginEndpoint = URL(string: "\(basePath)/login") else {
            complete(nil)
            return
        }
        
        // There appears to be a situation where if you open a form, then force quit the app (without closing the webview),
        // the cookies will persist even though there are only supposed to be persist within the WKWebView instance.
        // I suspect there might be more scenarios where cookies aren't actually cleared so to be on the safe side, lets
        // make sure the cookies are deleted before AND after making the login request.
        deleteCookies(for: loginEndpoint)
        
        firstly {
            post(endpoint: loginEndpoint.absoluteString, body: ["token": token]).promise
        }.done { _ in
            complete(self.deleteCookies(for: loginEndpoint))
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            self.deleteCookies(for: loginEndpoint)
            complete(nil)
        }
    }
    
    @discardableResult
    private func deleteCookies(for endpoint: URL) -> [HTTPCookie]? {
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: endpoint)
        
        // Alamofire automatically saves the cookies and attaches them to all future API requests. If we call either
        // login endpoint again, the cookies will cause a 403; therefore, we need to delete the cookies from the
        // system.
        cookies?.forEach {
            cookieStorage.deleteCookie($0)
        }
        
        return cookies
    }
    
    private func performFetchUserRequest(params: JSON, complete: @escaping ([UserModel]?) -> Void) {
        firstly {
            get(endpoint: "\(basePath)/oncallusers/", parameters: params).promise
        }.map {
            try OCJSONDecoder().decode(UserModelResults.self, from: $0.body)
        }.done {
            complete($0.results)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
}

// MARK: - Appointments
extension ApiManager {
    
    func getAppointments(
        user: UserModel,
        upcoming: Bool,
        search: String?,
        page: Int,
        complete: @escaping (AppointmentPageModel?) -> Void) -> CancelPromiseClosure
    {
        var params: JSON = [
            "page": page,
            "page_size": 15,
            "completed": upcoming ? "False" : "True",
            "ordering": upcoming ? "datetime" : "-datetime"
        ]
        
        if let search = search {
            let query = search.trimmingCharacters(in: .whitespaces)
            if query.count > 0 {
                params["query"] = query
            }
        }
        
        let request = get(endpoint: "\(basePath)/v1/appointments/", parameters: params)
        
        firstly {
            request.promise
        }.map {
            try OCJSONDecoder().decode(AppointmentPageModel.self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
        
        return request.cancel
    }
    
    func getAppointment(id: Int, complete: @escaping (AppointmentModel?) -> Void) {
        firstly {
            get(endpoint: "\(basePath)/v1/appointments/\(id)/").promise
        }.map {
            try OCJSONDecoder().decode(AppointmentModel.self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
    
    func acceptPendingAppointment(appointment: PendingAppointmentModel, divisionId: Int, complete: @escaping (Bool) -> Void){
        
        let body: JSON = [
            "division_id": divisionId,
            "provider_id": appointment.provider.id,
            "status": "accepted"
        ]
        
        firstly {
            patch(endpoint: "\(basePath)/appointmentrequest/\(appointment.id)", body: body).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
    
    func declinePendingAppointment(appointment: PendingAppointmentModel, complete: @escaping (Bool) -> Void){
        
        firstly {
            patch(endpoint: "\(basePath)/appointmentrequest/\(appointment.id)", body: ["status": "denied"]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
    
    func getPendingAppointments(complete: @escaping ([PendingAppointmentModel]?) -> Void) -> CancelPromiseClosure {
        
        let request = get(endpoint: "\(basePath)/appointmentrequest/?status=pending")
        
        firstly {
            request.promise
        }.map {
            try OCJSONDecoder().decode([PendingAppointmentModel].self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError(error)
            complete(nil)
        }
        
        return request.cancel
    }
    
    func cancelParticipant(_ participant: AppointmentParticipantModel, complete: @escaping (Bool) -> Void) {
        guard let participantId = participant.id else {
            complete(false)
            return
        }
        
        firstly {
            patch(endpoint: "\(basePath)/appointmentparticipants/\(participantId)/", body: ["cancelled": "true"]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
    
    func cancelAppointment(_ appointment: AppointmentModel, complete: @escaping (Bool) -> Void) {
        guard let url = appointment.url else {
            complete(false)
            return
        }
        
        firstly {
            post(endpoint: "\(basePath)/appointment_cancellations/", body: ["appointment": url]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
    
    func createAppointment(_ appointment: AppointmentCreationModel, completion: @escaping (OCResult<Void>) -> Void) {
        let data: Data
        let json: JSON?
        
        do {
            data = try OCJSONEncoder().encode(appointment)
            json = try JSONSerialization.jsonObject(with: data, options: []) as? JSON
        } catch {
            //Bugsnag.notifyError(error)
            completion(.failure(.invalidData(message: nil)))
            return
        }
        
        guard let unwrappedJson = json else {
            completion(.failure(.invalidData(message: nil)))
            return
        }
        
        firstly {
            post(endpoint: "\(basePath)/appointments/", body: unwrappedJson).promise
        }.done { _ in
            completion(.success(()))
        }.catch { error in
            //Bugsnag.reportApiError(error)
            
            if let error = error as? NetworkError,
               case let .standardError(_, jsonData) = error,
               let unwrappedJsonData = jsonData,
               let jsonError = try? OCJSONDecoder().decode(JSONError.self, from: unwrappedJsonData),
               let message = jsonError.error
            {
                completion(.failure(.responseError(message: message)))
            } else {
                completion(.failure(.responseError(message: nil)))
            }
        }
    }
    
    func updateAppointment(appointment: AppointmentModel, completion: @escaping (OCResult<Void>) -> Void) {
        do {
            let appointmentData = try OCJSONEncoder().encode(appointment)
            let appointmentJSON = try JSONSerialization.jsonObject(with: appointmentData, options: []) as? JSON
            
            firstly {
                put(endpoint: "\(basePath)/appointments/\(appointment.id)/", body: appointmentJSON).promise
            }.done { _ in
                completion(.success(()))
            }.catch {
                //Bugsnag.reportApiError($0)
                
                if let error = $0 as? NetworkError,
                   case let .standardError(_, jsonData) = error,
                   let unwrappedJsonData = jsonData,
                   let jsonError = try? OCJSONDecoder().decode([String].self, from: unwrappedJsonData),
                   let message = jsonError.first
                {
                    completion(.failure(.responseError(message: message)))
                } else {
                    completion(.failure(.responseError(message: nil)))
                }
            }
        } catch {
            //Bugsnag.notifyError(error)
            completion(.failure(.invalidData(message: nil)))
        }
    }
    
    func completeMessagingAppointment(appointment: MessagingAppointment, complete: @escaping (() -> Void)) {
        firstly {
            post(
                endpoint: "\(basePath)/appointmentprovidersummarys/",
                body: [
                    "appointment_id": appointment.id,
                    "notes": ""
                ]).promise
        }.done { _ in
            complete()
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete()
        }
    }
    
    func completeAppointment(
        appointmentId: Int,
        patientNotes: String,
        completion: @escaping (OCResult<Void>) -> Void)
    {
        firstly {
            post(
                endpoint: "\(basePath)/appointmentprovidersummarys/",
                body: [
                    "appointment_id": appointmentId,
                    "notes": patientNotes
                ]).promise
        }.done { _ in
            completion(.success(()))
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            completion(.failure(.responseError(message: nil)))
        }
    }
    
    func chargeAppointment(appointmentCharge: AppointmentCharge, completion: @escaping (OCResult<Bool>) -> Void) {
        do {
            let appointmentChargeData = try OCJSONEncoder().encode(appointmentCharge)
            let appointmentChargeJSON = try JSONSerialization.jsonObject(with: appointmentChargeData, options: []) as? JSON
            
            firstly {
                post(endpoint: "\(basePath)/appointmentcharges/", body: appointmentChargeJSON).promise
            }.map {
                try OCJSONDecoder().decode(AppointmentChargeResult.self, from: $0.body)
            }.done {
                completion(.success($0.amountFailed == 0))
            }.catch { _ in
                //Bugsnag.reportApiError($0)
                completion(.failure(.responseError(message: nil)))
            }
        } catch {
            //Bugsnag.notifyError(error)
            completion(.failure(.invalidData(message: nil)))
        }
    }
    
    func chargeParticipantAppointment(
        appointmentCharge: ParticipantAppointmentCharge,
        chargeId: Int,
        complete: @escaping ((Bool) -> Void))
    {
        do {
            let appointmentChargeData = try OCJSONEncoder().encode(appointmentCharge)
            let appointmentChargeJSON = try JSONSerialization.jsonObject(with: appointmentChargeData, options: []) as? JSON
            
            firstly {
                patch(endpoint: "\(basePath)/appointmentparticipantcharges/\(chargeId)/", body: appointmentChargeJSON).promise
            }.map {
                try OCJSONDecoder().decode(AppointmentChargeStatusModel.self, from: $0.body)
            }.done {
                complete($0.status == .charged)
            }.catch { _ in
                //Bugsnag.reportApiError($0)
                complete(false)
            }
        } catch {
            //Bugsnag.notifyError(error)
            complete(false)
        }
    }
    
    func downloadInvoice(url: URL, completion: @escaping (URL?) -> Void) {
        guard let token = SessionManager.shared.token else {
            completion(nil)
            return
        }
        
        var headers = HTTPHeaders()
        headers.add(HTTPHeader(name: "Authorization", value: "Token \(token)"))
        headers.add(HTTPHeader(name: "X-Authorization", value: "Token \(token)"))
        
        AF.download(
            url,
            method: .get,
            headers: headers,
            to: { _, _ -> (destinationURL: URL, options: DownloadRequest.Options) in
                let fileName: String
                
                if let displayName = Bundle.main.displayName {
                    fileName = displayName + " \("invoice".localized()).pdf"
                } else {
                    fileName = "\("invoice".localized()).pdf"
                }
                
                return (
                    FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName),
                    [.removePreviousFile, .createIntermediateDirectories])
            }).response { downloadResponse in
                completion(downloadResponse.fileURL)
            }
    }
    
    func joinVideoAppointment(_ id: Int, complete: @escaping (AppointmentModel?) -> Void) {
        firstly {
            get(endpoint: "\(basePath)/appointments/\(id)/join").promise
        }.map {
            try OCJSONDecoder().decode(AppointmentModel.self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
}


// MARK: - Messaging
extension ApiManager {
    func fetchThreads(
        completed: Bool,
        page: Int,
        complete: @escaping ((Bool, MessagingResultPage?) -> Void)) -> CancelPromiseClosure
    {
        let request = get(
            endpoint: "https://\(SessionManager.shared.domain)/messaging/api/v1/threads/",
            parameters: [
                "page": page,
                "appointment_type": "message",
                "completed": completed ? "True" : "False"
            ])
        
        firstly {
            request.promise
        }.map {
            try OCJSONDecoder().decode(MessagingResultPage.self, from: $0.body)
        }.done {
            complete(true, $0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false, nil)
        }
        
        return request.cancel
    }
    
    func fetchThread(threadId: Int, complete: @escaping ((MessagingThread?) -> Void)) {
        firstly {
            get(endpoint: "https://\(SessionManager.shared.domain)/messaging/api/v2/threads/\(threadId)", parameters: [:]).promise
        }.map {
            try OCJSONDecoder().decode(MessagingThread.self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
    
    func fetchMessagesInThread(threadId: Int, page: Int?, complete: @escaping ((MessagingMessageResultPage?) -> Void)) {
        var params: JSON = [:]

        if let page = page {
            params["page"] = page
        }

        firstly {
            get(endpoint: "https://\(SessionManager.shared.domain)/messaging/api/v2/threads/\(threadId)/messages", parameters: params).promise
        }.map {
            try OCJSONDecoder().decode(MessagingMessageResultPage.self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
    
    func updateThreadAnnouncement(threadId: Int, announcementText: String, complete: @escaping ((Bool, String?) -> Void)) {
        firstly {
            patch(endpoint: "https://\(SessionManager.shared.domain)/messaging/api/threads/\(threadId)", body: ["announcement": announcementText]).promise
        }.done { _ in
            complete(true, nil)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false, "something_went_wrong".localized())
        }
    }
    
    func sendMessage(thread: MessagingThread, message: String, complete: @escaping ((MessagingMessage?) -> Void)) {
        firstly {
            post(
                endpoint: "https://\(SessionManager.shared.domain)/messaging/api/threads/\(thread.id)/messages/",
                body: ["text": message]).promise
        }.map {
            try OCJSONDecoder().decode(MessagingMessage.self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
}

// MARK: - Attachment
extension ApiManager {
    func getDownloadAttachmentLink(attachmentId: Int, complete: @escaping ((OCResult<URL>) -> Void)) {
        firstly {
            get(endpoint: "https://\(SessionManager.shared.domain)/download_appointment_attachment/\(attachmentId)/").promise
        }.map {
            try OCJSONDecoder().decode(DownloadableAttachmentModel.self, from: $0.body)
        }.done {
            complete(.success($0.url))
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(.failure(.responseError(message: nil)))
        }
    }
    
    func getDownloadContactAttachmentLink(attachmentId: Int, complete: @escaping ((OCResult<URL>) -> Void)) {
        firstly {
            get(endpoint: "https://\(SessionManager.shared.domain)/download_contact_attachment/\(attachmentId)/").promise
        }.map {
            try OCJSONDecoder().decode(DownloadableAttachmentModel.self, from: $0.body)
        }.done {
            complete(.success($0.url))
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(.failure(.responseError(message: nil)))
        }
    }
    
    func getAttachmentDetails(forAppointment: Bool, _ complete: @escaping ((AttachmentUploadData?) -> Void)) {
        var params: JSON = [:]
        
        if !forAppointment {
            params["attachment_type"] = "attachment"
        }
        
        firstly {
            get(endpoint: "https://\(SessionManager.shared.domain)/get_attachment_upload_data/", parameters: params).promise
        }.map {
            try OCJSONDecoder().decode(AttachmentUploadData.self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
    
    func uploadFileS3(filename: String, data: AttachmentUploadData, file: Data, complete: @escaping (Bool) -> Void) {
        AF.upload(
            multipartFormData: { formdata in
                formdata.append(filename.data(using: .utf8)!, withName: "key")
                formdata.append(ApiKeys.s3.data(using: .utf8)!, withName: "AWSAccessKeyId")
                formdata.append("private".data(using: .utf8)!, withName: "acl")
                formdata.append("/".data(using: .utf8)!, withName: "success_action_redirect")
                formdata.append(data.policy.data(using: .utf8)!, withName: "policy")
                formdata.append(data.signature.data(using: .utf8)!, withName: "signature")
                formdata.append(file, withName: "file")
            },
            to: data.bucket).response { response in
                if let error = response.error {
                    //Bugsnag.notifyError(error)
                    complete(false)
                } else {
                    complete(true)
                }
            }
    }
    
    func attachToAppointment(
        appointmentUrl: String,
        filename: String,
        displayname: String,
        participants: [Int],
        complete: @escaping ((Bool) -> Void))
    {
        firstly {
            post(endpoint: "\(basePath)/appointmentattachments/",
                 body: [
                    "appointment": appointmentUrl,
                    "display_name": displayname,
                    "file_key": filename,
                    "participants": participants
                 ]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
    
    func attachToContact(
        contactUrl: String,
        filename: String,
        displayName: String,
        complete: @escaping ((Bool) -> Void))
    {
        firstly {
            post(endpoint: "\(basePath)/contactattachments/",
                 body: [
                    "contact": contactUrl,
                    "display_name": displayName,
                    "file_key": filename
                 ]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
    
    func getPatientAttachments(page: Int, complete: @escaping ((AttachmentPage?) -> Void)) {
        firstly {
            get(endpoint: "\(basePath)/readonlyuseruploadedfiles/", parameters: ["ordering": "-created_at", "page": page]).promise
        }.map {
            try OCJSONDecoder().decode(AttachmentPage.self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
    
    func getAttachments(for appointmentId: Int, complete: @escaping ((AttachmentPage?) -> Void)) {
        firstly {
            get(endpoint: "\(basePath)/appointmentattachments/", parameters: ["appointment_id": appointmentId]).promise
        }.map {
            try OCJSONDecoder().decode(AttachmentPage.self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
    
    func deleteAttachment(id: Int, complete: @escaping (Bool) -> Void) {
        firstly {
            delete(endpoint: "\(basePath)/appointmentattachments/\(id)/", body: nil).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
    
    func deleteContactAttachment(id: Int, complete: @escaping (Bool) -> Void) {
        firstly {
            patch(endpoint: "\(basePath)/contactattachments/\(id)/", body: ["is_deleted": true]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
    
    func updateAttachmentVisibility(id: Int, visible: [Int], hidden: [Int], complete: @escaping (Bool) -> Void) {
        firstly {
            patch(
                endpoint: "\(basePath)/appointmentattachments/\(id)/",
                body: ["participants": visible]).promise
        }.then { _ in
            self.patch(
                endpoint: "\(self.basePath)/appointmentattachments/\(id)/",
                body: ["hidden_to_participants": hidden]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
}

// MARK: - Forms

extension ApiManager {
    
    func getAllForms(complete: @escaping ((FormPage?) -> Void)) {
        firstly {
            get(endpoint: "\(basePath)/patientforms/").promise
        }.map {
            try OCJSONDecoder().decode(FormPage.self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
    
    func getAssignedForms(for appointmentId: Int? = nil, completion: @escaping ((FormPage?) -> Void)) {
        var parameters: JSON?
        
        if let appointmentId = appointmentId {
            parameters = ["appointment": appointmentId]
        }
        
        firstly {
            get(endpoint: "\(basePath)/patientformassignments/", parameters: parameters).promise
        }.map {
            try OCJSONDecoder().decode(FormPage.self, from: $0.body)
        }.done {
            completion($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            completion(nil)
        }
    }
    
    func getPatientAssignedForms(page: Int, completion: @escaping ((FormPage?) -> Void)) {
        firstly {
            get(endpoint: "\(basePath)/readonlypatientformassignments/", parameters: ["ordering": "is_completed", "page": page]).promise
        }.map {
            try OCJSONDecoder().decode(FormPage.self, from: $0.body)
        }.done {
            completion($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            completion(nil)
        }
    }
    
    func getIntakeForms(for requestId: Int? = nil, completion: @escaping ((FormPage?) -> Void)) {
        var parameters: JSON?
        
        if let requestId = requestId {
            parameters = ["request": requestId]
        }
        
        firstly {
            get(endpoint: "\(basePath)/patientformassignments/", parameters: parameters).promise
        }.map {
            try OCJSONDecoder().decode(FormPage.self, from: $0.body)
        }.done {
            completion($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            completion(nil)
        }
    }
    
    func assignForm(to participant: AssignFormToParticipantsViewModel.User, formUrl: String, complete: @escaping (Bool) -> Void) {
        firstly {
            post(
                endpoint: "\(basePath)/patientformassignments/",
                body: [
                    "participant": participant.url,
                    "form": formUrl
                ]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }

    func assignForm(to rosterContact: RosterContactModel, formUrl: String, complete: @escaping (Bool) -> Void) {
        firstly {
            post(
                endpoint: "\(basePath)/patientformassignments/",
                body: [
                    "contact": rosterContact.url,
                    "form": formUrl
                ]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
    
    func unassignForm(id: Int, complete: @escaping (Bool) -> Void) {
        firstly {
            patch(
                endpoint: "\(basePath)/patientformassignments/\(id)/",
                body: ["is_deleted": true]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
    
    func deleteForm(id: Int, complete: @escaping (Bool) -> Void) {
        firstly {
            delete(endpoint: "\(basePath)/patientforms/\(id)/", body: nil).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
}

// MARK: - Notifications

extension ApiManager {
    /// To remove the token associated with a proflle ID, pass `nil` as `token`.
    func updatePushNotificationToken(userProfileId: Int, token: String?, complete: @escaping (Bool) -> Void) {
        firstly {
            patch(
                endpoint: "\(basePath)/userprofile/\(userProfileId)",
                body: [
                    "notification_token": token as Any,
                    "notification_token_platform": "ios"
                ]).promise
        }.done { _ in
            complete(true)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(false)
        }
    }
}

// MARK: - SSO

extension ApiManager {
    func getSsoLoginUrl(complete: @escaping (SSOLoginModel?) -> Void) {
        firstly {
            get(endpoint: "\(ssoPath)/login-info").promise
        }.map {
            try OCJSONDecoder().decode(SSOLoginModel.self, from: $0.body)
        }.done {
            complete($0)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
    
    func getTokenFromSso(code: String, state: String, complete: @escaping (String?) -> Void) {
        var headers = HTTPHeaders()
        headers.add(HTTPHeader(name: "X-OIDC-State", value: state))
        
        firstly {
            get(
                endpoint: "\(ssoPath)/api-login",
                parameters: [
                    "code": code,
                    "state": state,
                    "redirect_uri": ApiManager.ssoRedirectUri
                ],
                headers: headers).promise
        }.map {
            try OCJSONDecoder().decode(SSOLoginTokenModel.self, from: $0.body)
        }.done {
            complete($0.token)
        }.catch { _ in
            //Bugsnag.reportApiError($0)
            complete(nil)
        }
    }
}

// MARK: Analytics

extension ApiManager {
    
    func logVideoSession(for appointmentId: Int) {
        firstly {
            post(endpoint: "\(basePath)/appointmentusersessions/", body: ["appointment_id": appointmentId]).promise
        }.done { _ in }.catch { _ in }
    }
}

// MARK: - Helpers

extension ApiManager {
    
    private func request(endpoint: String, method: HTTPMethod, body: JSON?) -> CancellablePromise {
        return request(endpoint: endpoint, method: method, body: body,headers: nil)
    }
    
    private func request(
        endpoint: String,
        method: HTTPMethod,
        body: JSON?,
        headers inputheaders: HTTPHeaders?) -> CancellablePromise
    {
        var headers = inputheaders ?? [:]
        
        if inputheaders == nil {
            headers = [:]
            if let token = SessionManager.shared.token {
                headers["Authorization"] = "Token \(token)"
                headers["X-Authorization"] = "Token \(token)"
            }
        }
        
        let request = ApiRequest()
        request.createRequest(endpoint: endpoint, method: method, body: body, headers: headers)
        
        let cancel = {
            request.cancel()
        }
        
        let promise = Promise<ApiResponse> { seal in
            request.completion = { status in
                switch status {
                case .success(let response):
                    seal.fulfill(response)
                case .error(let code, let json):
                    seal.reject(NetworkError.standardError(code: code, json: json))
                case .cancelled:
                    seal.reject(PMKError.cancelled)
                }
            }
        }
        
        return (promise, cancel)
    }
    
    private func post(endpoint: String, body: JSON?, headers: HTTPHeaders?) -> CancellablePromise {
        return self.request(
            endpoint: endpoint,
            method: .post,
            body: body,
            headers: headers)
    }
    
    private func post(endpoint: String, body: JSON?) -> CancellablePromise {
        return self.request(
            endpoint: endpoint,
            method: .post,
            body: body,
            headers: nil)
    }
    
    private func patch(endpoint: String, body: JSON?) -> CancellablePromise {
        return self.request(
            endpoint: endpoint,
            method: .patch,
            body: body,
            headers: nil)
    }
    
    private func put(endpoint: String, body: JSON?) -> CancellablePromise {
        return self.request(
            endpoint: endpoint,
            method: .put,
            body: body,
            headers: nil)
    }
    
    private func delete(endpoint: String, body: JSON?) -> CancellablePromise {
        return self.request(
            endpoint: endpoint,
            method: .delete,
            body: body,
            headers: nil)
    }
    
    private func get(endpoint: String) -> CancellablePromise {
        return get(endpoint: endpoint, parameters: nil, headers: nil)
    }
    
    private func get(endpoint: String, parameters: JSON?, headers: HTTPHeaders? = nil) -> CancellablePromise {
        return self.request(endpoint: endpoint, method: .get, body: parameters, headers: headers)
    }
    
    private func sortByDescendingDate(firstDate: Date?, secondDate: Date?) -> Bool {
        // https://stackoverflow.com/a/44144424
        return (firstDate ?? .distantPast) > (secondDate ?? .distantPast)
    }
}
