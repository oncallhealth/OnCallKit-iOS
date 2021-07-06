import Foundation
import Starscream

// MARK: - SessionManager

class SessionManager {
    
    // MARK: Internal
    
    static let shared = SessionManager()
    let apiManager = ApiManager()
    
    private(set) var domain: String = ""
    private(set) var primaryColor: BrandingColour!
    private(set) var secondaryColor: BrandingColour!
    
    func isLoggedIn() -> Bool {
        return user != nil && token != nil
    }

    func fetchCurrentUser(complete: @escaping (Bool) -> Void) {
        apiManager.fetchCurrentUser { user in
            guard let user = user else {
                complete(false)
                return
            }
            
            self.apiManager.getProviders { (providers) in
                guard let providers = providers else {
                    complete(false)
                    return
                }
                
                self.user = user
                self.providers = providers
                connectSocket()
                complete(true)
            }
        }
    }
    
    func initialize(
        token: String,
        baseDomain: String,
        primaryColour: BrandingColour,
        secondaryColour: BrandingColour,
        completion: @escaping (Bool) -> Void)
    {
        self.token = token
        self.domain = baseDomain
        self.primaryColor = primaryColour
        self.secondaryColor = secondaryColour
        
        fetchCurrentUser(complete: completion)
    }
    
    // MARK: Private
    
    private(set) var user: UserModel?
    private(set) var providers: [UserModel] = []
    private var socket: WebSocket?
    private var socketRetryCount = 0
    
    private(set) var token: String? = nil
    
}


// MARK: - Websockets
extension SessionManager {
    func connectSocket() {
        guard let token = token else {
            return
        }
        
        var request = URLRequest(url: URL(string: "wss://\(SessionManager.shared.domain)/mobile/")!)
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
    
    func didReceive(event: WebSocketEvent, client: WebSocket) {
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
                //Bugsnag.notifyError(error)
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
