import Foundation

// MARK: - AppointmentParticipantCreationModel

struct AppointmentParticipantCreationModel: Codable {
    let name: String
    let email: String
    var fee: Float?
    let addToRoster: Bool
}

// MARK: - AppointmentParticipantModel

public class AppointmentParticipantModel: Codable, Equatable {
    
    // MARK: CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case id, url, chargeId, invoiceUrl, requiresPaymentInfo, name, email, fee, addToRoster
    }
    
    // MARK: Lifecycle
    
    init(
        id: Int? = nil,
        url: String? = nil,
        chargeId: Int? = nil,
        invoiceUrl: String? = nil,
        requiresPaymentInfo: Bool? = nil,
        name: String,
        email: String,
        fee: Float? = nil,
        addToRoster: Bool = false)
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
    
    required convenience public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let fee = try? container.decode(String?.self, forKey: .fee)
        
        self.init(
            id: try container.decode(Int.self, forKey: .id),
            url: try container.decode(String.self, forKey: .url),
            chargeId: try container.decode(Int?.self, forKey: .chargeId),
            invoiceUrl: try container.decodeIfPresent(String.self, forKey: .invoiceUrl),
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
    
    public static func == (lhs: AppointmentParticipantModel, rhs: AppointmentParticipantModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.url == rhs.url &&
            lhs.chargeId == rhs.chargeId &&
            lhs.invoiceUrl == rhs.invoiceUrl &&
            lhs.requiresPaymentInfo == rhs.requiresPaymentInfo &&
            lhs.name == rhs.name &&
            lhs.email == rhs.email &&
            lhs.fee == rhs.fee &&
            lhs.addToRoster == rhs.addToRoster
    }
}
