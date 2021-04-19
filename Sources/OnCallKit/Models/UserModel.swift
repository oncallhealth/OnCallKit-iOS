import Foundation

enum UserType: String, Codable {
    case provider
    case patient
}

struct UserRequiresPayment: Codable {
    var divisionName: String?
    var providerName: String?
    var isSubscription: Bool
}

struct UserPermissions: Codable {
    var useCaseNotes: Bool
    var useInPersonAppointments: Bool
    var usePhoneAppointments: Bool
    var requiresPaymentInfo: UserRequiresPayment?
}

struct UserProfile: Codable {
    var id: Int
    var isCoordinator: Bool
    var userType: UserType
}

public struct UserModel: Codable {
    var id: Int
    var email: String
    var fullName: String
    var url: String
    var profile: UserProfile?
    var permissions: UserPermissions?
    var memberships: [DivisionMembershipModel]
    var zoomUserId: String?
    let hunterProfile: HunterProfile?
    
    func hasRoster() -> Bool {
        for membership in memberships {
            if membership.division.showRoster {
                return true
            }
        }
        
        return false
    }
    
    func ownsAppointment(_ appointment: OnCallAppointment) -> Bool {
        return appointment.providerId == id
    }
    
    func allowedToJoinAppointment(_ appointment: AppointmentModel) -> Bool {
        return ownsAppointment(appointment) || appointment.participants.contains { $0.email == email }
    }
}

struct UserModelResults: Codable {
    var results: [UserModel]
}

struct HunterProfile: Codable {
    let username: String
    let password: String
}
