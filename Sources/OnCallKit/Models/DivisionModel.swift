import Foundation

struct Features: Codable {
    var enableCaseNotes: Bool
    var enableInPersonAppointments: Bool
    var enablePhoneAppointments: Bool
}

struct DivisionMembershipModel: Codable {
    var division: DivisionModel
}

struct DivisionModel: Codable {
    var name: String?
    var id: Int
    var showRoster: Bool
    var videoProvider: String
    var paymentProcessor: String
    var features: Features
    var isFreeMode: Bool
}
