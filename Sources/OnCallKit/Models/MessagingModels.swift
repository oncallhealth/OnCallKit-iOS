import Foundation
import MessageKit

struct MessagingResultPage: Codable {
    var count: Int
    var results: [MessagingThread]
}

struct MessagingAppointment: OnCallAppointment, Codable {
    
    // MARK: CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case id
        case date = "datetime"
        case hasEditPermission
        case url
        case participantIds
        case providerId
        case appointmentType
    }
    
    // MARK: Lifecycle
    
    init(
        id: Int,
        date: Date?,
        hasEditPermission: Bool,
        url: String,
        participantIds: [Int],
        providerId: Int,
        appointmentType: AppointmentType)
    {
        self.id = id
        self.date = date
        self.hasEditPermission = hasEditPermission
        self.url = url
        self.participantIds = participantIds
        self.providerId = providerId
        self.appointmentType = appointmentType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decode(String?.self, forKey: .date)
        
        var date: Date? = nil
        
        if let dateString = dateString {
            date = Date(fromString: dateString)
        }
        
        self.init(
            id: try container.decode(Int.self, forKey: .id),
            date: date,
            hasEditPermission: try container.decode(Bool.self, forKey: .hasEditPermission),
            url: try container.decode(String.self, forKey: .url),
            participantIds: try container.decode([Int].self, forKey: .participantIds),
            providerId: try container.decode(Int.self, forKey: .providerId),
            appointmentType: try container.decode(AppointmentType.self, forKey: .appointmentType))
    }
    
    // MARK: Internal
    
    static func createStub() -> MessagingAppointment {
        return MessagingAppointment(id: 0, date: nil, hasEditPermission: false, url: "", participantIds: [], providerId: 0, appointmentType: .message)
    }
    
    // If you need the actual appointment call the getAppointment API using the following ID
    let id: Int
    let date: Date?
    let hasEditPermission: Bool
    let url: String
    let participantIds: [Int]
    var participants: [AppointmentParticipantModel] = []
    let providerId: Int
    let appointmentType: AppointmentType
}

struct MessagingUser: Codable {
    var id: Int
    var fullName: String
    var email: String?
}

struct MessagingAttachment: Codable {
    var id: Int
    var displayName: String
}

struct MessageSender: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

class MessagingMessage: Codable, MessageType {
    private(set) var sender: SenderType
    let messageId: String
    let sentDate: Date
    let kind: MessageKind
    
    private let text: String? = nil
    private let attachment: MessagingAttachment? = nil
    private let userId: String? = nil
    
    private enum CodingKeys: String, CodingKey {
        case messageId = "id"
        case sentDate = "createdAt"
        case text
        case attachment
        case userId
    }
    
    fileprivate func updateSender(_ sender: MessagingUser) {
        self.sender = MessageSender(senderId: String(sender.id), displayName: sender.fullName)
    }
    
    init(
        id: Int,
        createdAt: Date,
        userId: Int,
        text: String,
        attachment: MessagingAttachment?)
    {
        self.messageId = String(id)
        self.sentDate = createdAt
        self.sender = MessageSender(senderId: String(userId), displayName: "")
        
        if let unwrappedAttachment = attachment {
            self.kind = .custom(unwrappedAttachment)
        } else {
            self.kind = .text(text)
        }
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decode(String.self, forKey: .sentDate)
        
        guard let date = Date(fromString: dateString) else {
            throw DecodingError.typeMismatch(
                Date.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Date string not valid"))
        }
        
        self.init(
            id: try container.decode(Int.self, forKey: .messageId),
            createdAt: date,
            userId: try container.decode(Int.self, forKey: .userId),
            text: try container.decode(String.self, forKey: .text),
            attachment: try container.decodeIfPresent(MessagingAttachment.self, forKey: .attachment))
    }
}

class MessagingThread: Codable {
    let id: Int
    let completed: Bool
    let appointment: MessagingAppointment
    let threadUsers: [MessagingUser]
    let createdAt: Date
    var announcementText: String?
    var latestMessages: [MessagingMessage] {
        didSet {
            groupMessages()
        }
    }
    
    private(set) var groupedMessages: [[MessagingMessage]]
    
    private enum CodingKeys: String, CodingKey {
        case id, completed, appointment, threadUsers, latestMessages, createdAt, announcementText
    }
    
    init(
        id: Int,
        completed: Bool,
        appointment: MessagingAppointment,
        threadUsers: [MessagingUser],
        createdAt: Date,
        latestMessages: [MessagingMessage],
        announcementText: String?)
    {
        self.id = id
        self.completed = completed
        self.appointment = appointment
        self.threadUsers = threadUsers
        self.createdAt = createdAt
        self.latestMessages = latestMessages
        self.announcementText = announcementText
        
        groupedMessages = [[]]
        groupMessages()
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let announcementText = try container.decode(String?.self, forKey: .announcementText)
        
        guard let date = Date(fromString: dateString) else {
            throw DecodingError.typeMismatch(
                Date.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Date string not valid"))
        }
        
        self.init(
            id: try container.decode(Int.self, forKey: .id),
            completed: try container.decode(Bool.self, forKey: .completed),
            appointment: try container.decode(MessagingAppointment.self, forKey: .appointment),
            threadUsers: try container.decode([MessagingUser].self, forKey: .threadUsers),
            createdAt: date,
            latestMessages: try container.decode([MessagingMessage].self, forKey: .latestMessages),
            announcementText: announcementText)
    }
    
    static func createStub(for threadId: Int) -> MessagingThread {
        MessagingThread(id: threadId, completed: false, appointment: MessagingAppointment.createStub(), threadUsers: [], createdAt: Date(), latestMessages: [], announcementText: nil)
    }
    
    func getLatestMessage() -> MessagingMessage? {
        guard latestMessages.count > 0 else {
            return nil
        }
        
        let latest = latestMessages.sorted(by: { (left, right) -> Bool in
            return left.messageId > right.messageId
        })
        
        return latest[0]
    }
    
    func userForMessage(_ message: MessagingMessage) -> MessagingUser? {
        return threadUsers.first { String($0.id) == message.sender.senderId }
    }
    
    private func groupMessages() {
        var finalGroup: [[MessagingMessage]] = []
        var currentGroup: [MessagingMessage] = []
        var currentId = "-1"
        var currentDate = Date()
        
        for message in latestMessages {
            if let user = userForMessage(message) {
                message.updateSender(user)
            }
            
            if Calendar.current.isDate(message.sentDate, inSameDayAs: currentDate) {
                if message.sender.senderId == currentId {
                    currentGroup.append(message)
                } else {
                    if !currentGroup.isEmpty {
                        finalGroup.append(currentGroup)
                        currentGroup.removeAll()
                    }
    
                    currentGroup.append(message)
                    currentId = message.sender.senderId
                }
            } else {
                if !currentGroup.isEmpty {
                    finalGroup.append(currentGroup)
                    currentGroup.removeAll()
                }
                
                currentGroup.append(message)
                currentId = message.sender.senderId
                currentDate = message.sentDate
            }
        }

        finalGroup.append(currentGroup)
        groupedMessages = finalGroup
    }
}
