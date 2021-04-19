import Foundation

struct WebsocketMessageModel: Codable {
    var threadId: Int?
    var appointmentId: Int
    var type: String
    var userId: Int
}
