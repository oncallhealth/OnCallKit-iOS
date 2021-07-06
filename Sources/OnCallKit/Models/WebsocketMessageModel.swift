import Foundation

// MARK: - WebsocketMessageModel

struct WebsocketMessageModel: Decodable {
    
    // MARK: MessageType
    
    enum MessageType: String, Decodable {
        case messagePosted = "MESSAGE_POSTED"
        case attachmentAdded = "ATTACHMENT_ADDED"
    }
    
    // MARK: Internal
    
    let type: MessageType?
    let threadId: Int?
    let appointmentId: Int
    let userId: Int
    
}
