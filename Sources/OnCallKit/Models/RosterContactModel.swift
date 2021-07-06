import Foundation

struct RosterContactPage: Codable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [RosterContactModel]
}

struct RosterContactModel: Codable {
    var divisionId: Int
    var id: Int
    var isDeleted: Bool
    var email: String
    var name: String
    var phone: String?
    var provider: Int
    var url: String
    var notes: String?
}

struct RosterContactDetailsAttachment: Codable {
    var contactAppointments: [AppointmentModel]
    var contactAppointmentAttachments: [Attachment]
    var contactAppointmentForms: [Form]
}

// MARK: - RosterContactAttachment

private struct RosterContactAttachment: Codable {
    
    // MARK: Internal
    
    let id: Int
    let displayName: String
    let isHidden: Bool
}

// MARK: - RosterContactDetails

struct RosterContactDetails: Codable {
    
    // MARK: - CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case id, divisionId, isDeleted, phone, appointmentsFormsAttachments, formAssignments, attachments
    }
    
    // MARK: Lifecycle
    
    private init(
        id: Int,
        divisionId: Int,
        isDeleted: Bool,
        phone: String?,
        appointmentsFormsAttachments: RosterContactDetailsAttachment,
        formAssignments: [Form],
        attachments: [Attachment])
    {
        self.id = id
        self.divisionId = divisionId
        self.isDeleted = isDeleted
        self.phone = phone
        self.appointmentsFormsAttachments = appointmentsFormsAttachments
        self.formAssignments = formAssignments
        self.attachments = attachments
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let attachments = try container.decode([RosterContactAttachment].self, forKey: .attachments)
        
        self.init(
            id: try container.decode(Int.self, forKey: .id),
            divisionId: try container.decode(Int.self, forKey: .divisionId),
            isDeleted: try container.decode(Bool.self, forKey: .isDeleted),
            phone: try container.decodeIfPresent(String.self, forKey: .phone),
            appointmentsFormsAttachments: try container.decode(RosterContactDetailsAttachment.self, forKey: .appointmentsFormsAttachments),
            formAssignments: try container.decode([Form].self, forKey: .formAssignments),
            attachments: attachments.map { Attachment(
                id: $0.id,
                displayName: $0.displayName,
                createdAt: nil,
                fileExtension: "",
                isHidden: $0.isHidden,
                isEditable: true,
                accessibleTo: [],
                appointment: nil) })
    }
    
    // MARK: Internal
    
    let divisionId: Int
    let id: Int
    let isDeleted: Bool
    let phone: String?
    var appointmentsFormsAttachments: RosterContactDetailsAttachment
    let formAssignments: [Form]
    let attachments: [Attachment]
}
