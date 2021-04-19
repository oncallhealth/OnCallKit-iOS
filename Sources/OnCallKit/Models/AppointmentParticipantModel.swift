import Foundation

// MARK: - AppointmentParticipantCreationModel

struct AppointmentParticipantCreationModel: Codable {
    let name: String
    let email: String
    var fee: Float?
    let addToRoster: Bool
}

// MARK: - AppointmentParticipantModel

class AppointmentParticipantModel: Codable {
    
    // MARK: CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case id, url, chargeId, invoiceUrl, requiresPaymentInfo, name, email, fee, addToRoster
    }
    
    // MARK: Lifecycle
    
    init(id: Int? = nil, name: String, email: String, fee: Float, addToRoster: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.fee = fee
        self.addToRoster = addToRoster
    }
    
    private init(
        id: Int?,
        url: String,
        chargeId: Int?,
        invoiceUrl: String?,
        requiresPaymentInfo: Bool?,
        name: String,
        email: String,
        fee: Float?,
        addToRoster: Bool)
    {
        self.id = id
        self.url = url
        self.chargeId = chargeId
        self.invoiceUrl = invoiceUrl
        self.requiresPaymentInfo = requiresPaymentInfo
        self.name = name
        self.email = email
        self.fee = fee
        self.addToRoster = addToRoster
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fee = try? container.decode(String?.self, forKey: .fee)
        
        self.init(
            id: try container.decode(Int.self, forKey: .id),
            url: try container.decode(String.self, forKey: .url),
            chargeId: try container.decode(Int?.self, forKey: .chargeId),
            invoiceUrl: try container.decode(String?.self, forKey: .invoiceUrl),
            requiresPaymentInfo: try? container.decode(Bool?.self, forKey: .requiresPaymentInfo),
            name: try container.decode(String.self, forKey: .name),
            email: try container.decode(String.self, forKey: .email),
            fee: Float(fee ?? "") ?? nil,
            addToRoster: try (container.decodeIfPresent(Bool.self, forKey: .addToRoster) ?? false))
    }
    
    // MARK: Internal
    
    var id: Int?
    var url: String?
    var chargeId: Int?
    var invoiceUrl: String?
    var requiresPaymentInfo: Bool?
    var name: String
    var email: String
    var fee: Float?
    var addToRoster: Bool

}
