import Foundation

struct AttachmentUploadData: Codable {
    var policy: String
    var keyPrefix: String
    var signature: String
    var bucket: String
}

struct AttachmentPage: Codable {
    var count: Int
    var next: String?
    var results: [Attachment]
}

struct Attachment: Codable {
    let id: Int
    let displayName: String
    let createdAt: Date
    let fileExtension: String
    let isHidden: Bool
    let isEditable: Bool
    let accessibleTo: [Int]
    let appointmentTitle: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, displayName, createdAt, fileExtension, isHidden, isEditable, accessibleTo, appointmentTitle
    }
    
    init(
        id: Int,
        displayName: String,
        createdAt: Date,
        fileExtension: String,
        isHidden: Bool?,
        isEditable: Bool,
        accessibleTo: [Int]?,
        appointmentTitle: String?)
    {
        self.id = id
        self.displayName = displayName
        self.createdAt = createdAt
        self.fileExtension = fileExtension
        self.isHidden = isHidden ?? false
        self.isEditable = isEditable
        self.accessibleTo = accessibleTo ?? []
        self.appointmentTitle = appointmentTitle
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decode(String.self, forKey: .createdAt)
        
        guard let date = Date(fromString: dateString) else {
            throw DecodingError.typeMismatch(Date.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Date string not valid"))
        }

        self.init(
            id: try container.decode(Int.self, forKey: .id),
            displayName: try container.decode(String.self, forKey: .displayName),
            createdAt: date,
            fileExtension: try container.decode(String.self, forKey: .fileExtension),
            isHidden: try container.decodeIfPresent(Bool.self, forKey: .isHidden),
            isEditable: try container.decode(Bool.self, forKey: .isEditable),
            accessibleTo: try container.decodeIfPresent([Int].self, forKey: .accessibleTo),
            appointmentTitle: try container.decodeIfPresent(String.self, forKey: .appointmentTitle))
    }
}
