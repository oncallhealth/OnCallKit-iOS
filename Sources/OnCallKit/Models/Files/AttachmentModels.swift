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
    let createdAt: Date?
    let fileExtension: String
    let isHidden: Bool
    let isEditable: Bool
    let accessibleTo: [Int]
    let appointment: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, displayName, createdAt, fileExtension, isHidden, isEditable, accessibleTo, appointment
    }
    
    init(
        id: Int,
        displayName: String,
        createdAt: Date?,
        fileExtension: String,
        isHidden: Bool?,
        isEditable: Bool,
        accessibleTo: [Int]?,
        appointment: String?)
    {
        self.id = id
        self.displayName = displayName
        self.createdAt = createdAt
        self.fileExtension = fileExtension
        self.isHidden = isHidden ?? false
        self.isEditable = isEditable
        self.accessibleTo = accessibleTo ?? []
        self.appointment = appointment
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decode(String.self, forKey: .createdAt)
        
        guard let date = Date(fromString: dateString) else {
            throw DecodingError.typeMismatch(Date.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Date string not valid"))
        }
        
        // Depending on the API endpoint called, sometimes the `appointment` field can be Int or a String. Therfore,
        // lets always store the value as a String just to keep things a little bit more consistent
        
        let appointmentString = try? container.decodeIfPresent(String.self, forKey: .appointment)
        let appointmentInt: String?
        
        if let appointment = try? container.decodeIfPresent(Int.self, forKey: .appointment) {
            appointmentInt = String(appointment)
        } else {
            appointmentInt = nil
        }

        self.init(
            id: try container.decode(Int.self, forKey: .id),
            displayName: try container.decode(String.self, forKey: .displayName),
            createdAt: date,
            fileExtension: try container.decode(String.self, forKey: .fileExtension),
            isHidden: try container.decodeIfPresent(Bool.self, forKey: .isHidden),
            isEditable: try container.decode(Bool.self, forKey: .isEditable),
            accessibleTo: try container.decodeIfPresent([Int].self, forKey: .accessibleTo),
            appointment: appointmentString ?? appointmentInt)
    }
}
