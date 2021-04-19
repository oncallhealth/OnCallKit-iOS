import Foundation
import Bugsnag
import KeychainSwift
import Starscream
//import FirebaseMessaging

public class SessionManager {
    public static let shared = SessionManager()
    var user: UserModel?
    public let apiManager = ApiManager()
    let keychain = KeychainSwift()
    private var socket: WebSocket?
    private var socketRetryCount = 0
    
    func isLoggedIn() -> Bool {
        return user != nil && apiManager.token != nil
    }
    
    func login(username: String,
               password: String,
               complete: @escaping (Bool, String?) -> Void) {
        
        apiManager.login(username: username, password: password) { (statusCode, response) in
            if statusCode == 400 {
                
                if WhitelabelHelper.shared.country == .CA {
                    WhitelabelHelper.shared.country = .US
                    self.login(username: username, password: password, complete: complete)
                } else {
                    WhitelabelHelper.shared.country = .US
                    complete(false, "bad_user_pass".localized())
                }
            } else if let response = response,
                let token = response["token"] as? String {
                self.apiManager.token = token
                
                self.fetchCurrentUser { success in
                    if success {
                        complete(true, nil)
                        self.saveToKeychain()
                    } else {
                        complete(false, "something_went_wrong".localized())
                    }
                }
            } else {
                complete(false, "something_went_wrong".localized())
            }
        }
    }
    
    func loginUsingSso(code: String, state: String, complete: @escaping (Bool) -> Void) {
        apiManager.getTokenFromSso(code: code, state: state) {
            self.apiManager.token = $0
            self.fetchCurrentUser { success in
                if success {
                    self.saveToKeychain()
                    complete(true)
                } else {
                    complete(false)
                }
            }
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        disconnectSocket()
        
        guard let profileId = user?.profile?.id else {
            completion()
            return
        }
        
        //BiometricsTracker.updateBiometrics(state: .disabled)
            
        apiManager.updatePushNotificationToken(
            userProfileId: profileId,
            token: nil)
        { success in
            if !success {
                Bugsnag.report(
                    title: "Push Notification FCM Token Removal Error",
                    body: "Unable to remove push notification token for profile \(profileId)")
            }

            self.clearTokenFromKeychain()
            self.user = nil
            self.apiManager.logout()
            completion()
        }
    }

    public func fetchCurrentUser(complete: @escaping (Bool) -> Void) {
        apiManager.fetchCurrentUser { user in
            guard let user = user else {
                complete(false)
                return
            }
            
            self.user = user
            complete(true)
        }
    }
}


// MARK: - SESSION STORAGE
extension SessionManager {
    
    private static let keychainToken = "oncalltoken"

    func saveToKeychain() {
        guard let token = apiManager.token else {
            return
        }
        keychain.set(token, forKey: SessionManager.keychainToken)
    }
    
    func tokenInKeychain() -> Bool {
        return keychain.get(SessionManager.keychainToken) != nil
    }
    
    func clearTokenFromKeychain() {
        keychain.delete(SessionManager.keychainToken)
    }
    
    var canRestoreFromKeychain: Bool {
        return keychain.get(SessionManager.keychainToken) != nil
    }
    
    func restoreSessionFromKeychain(_ complete: @escaping (Bool) -> Void) {
        guard let token = keychain.get(SessionManager.keychainToken) else {
            complete(false)
            return
        }
        
        apiManager.token = token
        
        self.apiManager.getUser(allProviders: false, complete: { (users) in
            guard let users = users else {
                complete(false)
                return
            }
            
            guard let thisUser = users.first else {
                // TODO error report
                complete(false)
                return
            }
            
            self.user = thisUser
            complete(true)
        })
        
    }
}


// MARK: - Websockets
extension SessionManager {
    func connectSocket() {
        guard let token = apiManager.token else {
            return
        }
        
        var request = URLRequest(url: URL(string: "wss://\(WhitelabelHelper.shared.messagingDomain)/mobile/")!)
        request.timeoutInterval = 5
        request.setValue("Upgrade", forHTTPHeaderField: "Connection")
        request.setValue("websocket", forHTTPHeaderField: "Upgrade")
        request.setValue("Token \(token)", forHTTPHeaderField: "X-Authorization")
        request.setValue("14", forHTTPHeaderField: "Sec-WebSocket-Version")
        
        if let socket = socket {
            socket.connect()
        } else {
            socket = WebSocket(request: request)
            socket?.delegate = self
            socket?.connect()
        }
    }
    
    func disconnectSocket() {
        socket?.disconnect()
        socket = nil
    }
}

// MARK: - WebSocketDelegate
extension SessionManager: WebSocketDelegate {
    
    public func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected:
            socketRetryCount = 0
        case .disconnected:
            Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(retrySocketConnection), userInfo: nil, repeats: false)
        case .text(let text):
            guard let data = text.data(using: .utf8) else {
                return
            }
            
            do {
                let message = try OCJSONDecoder().decode(WebsocketMessageModel.self, from: data)
                NotificationCenter.default.post(
                    name: Notification.Name.didReceiveWebsocketMessage,
                    object: nil,
                    userInfo: ["message": message])
            } catch {
                Bugsnag.notifyError(error)
            }
        default:
            break
        }
    }
    
    @objc private func retrySocketConnection(_ sender: Any?) {
        socketRetryCount += 1
        
        if socketRetryCount < 50 {
            connectSocket()
        }
    }
}
