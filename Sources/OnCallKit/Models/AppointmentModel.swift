import Foundation

enum AppointmentType: String, Codable {
    case video = "online"
    case inperson = "inperson"
    case phone = "phone"
    case message = "message"
    
    func displayString() -> String {
        switch self {
        case .video:
            return "video".localized()
        case .inperson:
            return "in_person".localized()
        case .phone:
            return "phone".localized()
        case .message:
            return "message".localized()
        }
    }
}

enum AppointmentStatus: String, Codable {
    case chargeFailed = "Charge failed"
    case coordinatorCancelled = "Coordinator cancelled"
    case providerCancelled = "Provider cancelled"
    case patientCancelled = "Patient cancelled"
    case staffCancelled = "Staff cancelled"
    case feeWaived = "Fee waived"
    case noShow = "No show"
    case noShowFeeCharged = "No-show fee charged"
    case complete = "Complete"
    case incomplete = "Incomplete"
    
    // MARK: Internal
    
    var isComplete: Bool {
        return self != .incomplete
    }
    
    /// Use this to check if the appointment was marked as completed but maybe charging participants failed
    var isPastAppointment: Bool {
        return isComplete || self == .chargeFailed
    }
    
    func localized() -> String {
        switch self {
        case .chargeFailed:
            return "charge_failed".localized()
        case .coordinatorCancelled:
            return "coordinator_cancelled".localized()
        case .providerCancelled:
            return "provider_cancelled".localized()
        case .patientCancelled:
            return "patient_cancelled".localized()
        case .staffCancelled:
            return "staff_cancelled".localized()
        case .feeWaived:
            return "fee_waived".localized()
        case .noShow:
            return "no_show".localized()
        case .noShowFeeCharged:
            return "no_show_fee_charged".localized()
        case .complete:
            return "complete".localized()
        case .incomplete:
            return "incomplete".localized()
        }
    }
}

struct AppointmentDivision: Codable, Equatable {
    var id: Int
    var name: String
    var paymentProcessor: String
    var videoProvider: VideoProvider?
}

enum VideoProvider: String, Codable {
    case vidyo
    case zoom
    case zoompool
    case hunter
}

struct AppointmentPageModel: Codable {
    var results: [AppointmentModel]
    var next: String?
    var count: Int
}

struct PendingAppointmentModel: OnCallAppointment, Codable {
    
    // MARK: CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case id, provider, requesters, product, date = "datetime", formAssignmentCount
    }
    
    // MARK: Lifecycle
    
    init(
        id: Int,
        provider: PendingAppointmentProviderModel,
        requesters: [PendingAppointmentRequesterModel],
        product: PendingAppointmentProductModel,
        date: Date?,
        formAssignmentCount: Int)
    {
        self.id = id
        self.provider = provider
        self.requesters = requesters
        self.product = product
        self.date = date
        self.formAssignmentCount = formAssignmentCount
        
        self.providerId = provider.id
        self.participants = []
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decodeIfPresent(String.self, forKey: .date)
        
        let finalDate: Date?
        
        if let unwrappedDateString = dateString {
            guard let date = Date(fromString: unwrappedDateString) else {
                throw DecodingError.typeMismatch(
                    Date.self,
                    DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Date string not valid"))
            }
            
            finalDate = date
        } else {
            finalDate = nil
        }
    
        
        self.init(
            id: try container.decode(Int.self, forKey: .id),
            provider: try container.decode(PendingAppointmentProviderModel.self, forKey: .provider),
            requesters: try container.decode([PendingAppointmentRequesterModel].self, forKey: .requesters),
            product: try container.decode(PendingAppointmentProductModel.self, forKey: .product),
            date: finalDate,
            formAssignmentCount: try container.decode(Int.self, forKey: .formAssignmentCount))
    }
    
    // MARK: Internal
    
    let providerId: Int
    let participants: [AppointmentParticipantModel]
    
    let id: Int
    let provider: PendingAppointmentProviderModel
    let requesters: [PendingAppointmentRequesterModel]
    let product: PendingAppointmentProductModel
    let date: Date?
    let formAssignmentCount: Int
}

struct PendingAppointmentProductModel: Codable {
    let name: String
    let appointmentType: AppointmentType
    let division: String
    let duration: Int
}

struct PendingAppointmentProviderModel: Codable {
    let id: Int
    let fullName: String
}

struct PendingAppointmentRequesterModel: Codable {
    
    // MARK: CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case id, name, email, phone, gender, dateOfBirth = "decryptedDateOfBirth"
    }
    
    // MARK: Internal
    
    let id: Int
    let name: String
    let email: String
    let phone: String?
    let gender: String?
    let dateOfBirth: String?
}

// MARK: - AppointmentModel

public struct AppointmentModel: OnCallAppointment, Codable, Equatable {
    
    // MARK: JoinableState
    
    enum JoinableState: Encodable, Equatable {
        
        // MARK: Lifecycle
        
        init(from decoder: Decoder) throws {
            throw DecodingError.typeMismatch(
                JoinableState.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Decoding not supported"))
        }
        
        func encode(to encoder: Encoder) throws {
            throw EncodingError.invalidValue(
                JoinableState.self,
                EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Encoding not supported"))
        }
        
        // MARK: Internal
        
        case complete
        case joinNow
        case joinIn(timeUntil: String?)
    }
    
    // MARK: CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case id
        case appointmentType
        case completed
        case attachmentCount
        case formAssignmentCount
        case division
        case date = "datetime"
        case divisionId
        case duration
        case participants
        case allParticipants
        case title
        case vidyoResourceId
        case vidyoSessionToken
        case zoomUrl
        case providerName
        case provider
        case cancellation
        case cancellationFee
        case cancellationHourThreshold
        case enablePatientCancellation
        case url
        case messageThreadId
        case fee
        case status
        case hunterRoom
        case recurrenceId
    }
    
    // MARK: Lifecycle
    
    init(
        id: Int,
        appointmentType: AppointmentType,
        completed: Bool,
        attachmentCount: Int,
        formAssignmentCount: Int,
        division: AppointmentDivision,
        date: Date?,
        divisionId: Int,
        duration: Int,
        participants: [AppointmentParticipantModel],
        allParticipants: [AppointmentParticipantModel],
        title: String,
        vidyoResourceId: String?,
        vidyoSessionToken: String?,
        zoomUrl: String?,
        providerName: String,
        provider: String,
        cancellation: String?,
        cancellationFee: Float?,
        cancellationHourThreshold: Int?,
        enablePatientCancellation: Bool?,
        url: String?,
        messageThreadId: Int?,
        fee: Float,
        status: AppointmentStatus,
        hunterRoom: HunterRoom?,
        recurrenceId: Int?)
    {
        self.id = id
        self.appointmentType = appointmentType
        self.completed = completed
        self.attachmentCount = attachmentCount
        self.formAssignmentCount = formAssignmentCount
        self.division = division
        self.date = date
        self.divisionId = divisionId
        self.duration = duration
        self.participants = participants
        self.allParticipants = allParticipants
        self.title = title
        self.vidyoResourceId = vidyoResourceId
        self.vidyoSessionToken = vidyoSessionToken
        self.zoomUrl = zoomUrl
        self.providerName = providerName
        self.provider = provider
        self.providerId = Int(String(provider.split(separator: "/").last ?? "0")) ?? 0
        self.cancellation = cancellation
        self.cancellationFee = cancellationFee
        self.cancellationHourThreshold = cancellationHourThreshold
        self.enablePatientCancellation = enablePatientCancellation
        self.url = url
        self.messageThreadId = messageThreadId
        self.fee = fee
        self.status = status
        self.hunterRoom = hunterRoom
        self.recurrenceId = recurrenceId
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decodeIfPresent(String.self, forKey: .date)
        
        var date: Date? = nil
        
        if let dateString = dateString {
            date = Date(fromString: dateString)
        }
        
        self.init(
            id: try container.decode(Int.self, forKey: .id),
            appointmentType: try container.decode(AppointmentType.self, forKey: .appointmentType),
            completed: try container.decode(Bool.self, forKey: .completed),
            attachmentCount: try container.decode(Int.self, forKey: .attachmentCount),
            formAssignmentCount: try container.decode(Int.self, forKey: .formAssignmentCount),
            division: try container.decode(AppointmentDivision.self, forKey: .division),
            date: date,
            divisionId: try container.decode(Int.self, forKey: .divisionId),
            duration: try container.decode(Int.self, forKey: .duration),
            participants: try container.decode([AppointmentParticipantModel].self, forKey: .participants),
            allParticipants: try container.decode([AppointmentParticipantModel].self, forKey: .allParticipants),
            title: try container.decode(String.self, forKey: .title),
            vidyoResourceId: try container.decodeIfPresent(String.self, forKey: .vidyoResourceId),
            vidyoSessionToken: try container.decodeIfPresent(String.self, forKey: .vidyoSessionToken),
            zoomUrl: try container.decodeIfPresent(String.self, forKey: .zoomUrl),
            providerName: try container.decode(String.self, forKey: .providerName),
            provider: try container.decode(String.self, forKey: .provider),
            cancellation: try container.decodeIfPresent(String.self, forKey: .cancellation),
            cancellationFee: try container.decodeIfPresent(Float.self, forKey: .cancellationFee),
            cancellationHourThreshold: try container.decodeIfPresent(Int.self, forKey: .cancellationHourThreshold),
            enablePatientCancellation: try container.decodeIfPresent(Bool.self, forKey: .enablePatientCancellation),
            url: try container.decodeIfPresent(String.self, forKey: .url),
            messageThreadId: try container.decodeIfPresent(Int.self, forKey: .messageThreadId),
            fee: try container.decode(Float.self, forKey: .fee),
            status: try container.decode(AppointmentStatus.self, forKey: .status),
            hunterRoom: try container.decodeIfPresent(HunterRoom.self, forKey: .hunterRoom),
            recurrenceId: try container.decodeIfPresent(Int.self, forKey: .recurrenceId))
    }
    
    // MARK: Internal
    
    var appointmentType: AppointmentType
    var completed: Bool
    var attachmentCount: Int
    var formAssignmentCount: Int
    var division: AppointmentDivision
    var date: Date?
    var divisionId: Int
    var duration: Int
    var id: Int
    var participants: [AppointmentParticipantModel]
    var allParticipants: [AppointmentParticipantModel]
    var title: String
    var vidyoResourceId: String?
    var vidyoSessionToken: String?
    var zoomUrl: String?
    var providerName: String
    var provider: String
    let providerId: Int
    var cancellation: String?
    var cancellationFee: Float?
    var cancellationHourThreshold: Int?
    var enablePatientCancellation: Bool?
    var url: String?
    var messageThreadId: Int?
    var fee: Float
    var status: AppointmentStatus
    let hunterRoom: HunterRoom?
    let recurrenceId: Int?
    
    var joinableState: JoinableState? {
        let joinInterval: TimeInterval = 10 * 60 // 10 minutes
        let startTime = date ?? Date()
        let endTime = startTime.addingTimeInterval(TimeInterval(duration * 60))
        let joinTime = startTime.addingTimeInterval(-joinInterval)
        let isUpcoming = completed == false && cancellation == nil
        
        // If session can now be joined
        if Date() >= joinTime {
            if endTime < Date() {
                return .complete
            } else if appointmentType == .video {
                return .joinNow
            } else {
                return .complete
            }
        } else {
            // Join time is in the future
            if isUpcoming && appointmentType == .video {
                return .joinIn(timeUntil: joinTime.timeUntil())
            }
        }
        
        return nil
    }
    
    func getParticipantName(for email: String) -> String? {
        return allParticipants.first { $0.email == email }?.name
    }
}

struct AppointmentCreationModel: Codable {
    let appointmentType: String
    let datetime: String?
    let divisionId: Int
    let division: Int
    let duration: Int
    let title: String
    let participants: [AppointmentParticipantCreationModel]
    let provider: String
}

// MARK: - AppointmentReccurrenceCreationModel

struct AppointmentReccurrenceCreationModel: Codable {
    
    // MARK: CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case appointment
        case dateTimeList = "datetime_list"
    }
    
    // MARK: Internal
    
    let appointment: AppointmentCreationModel
    let dateTimeList: [String]
    
}

// MARK: - AppointmentRecurrencesModel

struct AppointmentRecurrencesModel: Codable {
    
    // MARK: Internal
    
    let id: Int
    let appointments: [AppointmentModel]
    
}

// MARK: - AppointmentRecurrenceCancellationModel

struct AppointmentRecurrenceCancellationModel: Encodable {
    
    // MARK: Operation
    
    enum Operation: String, Encodable {
        case all = "ALL"
        case following = "FOLLOWING"
    }
    
    // MARK: Internal
    
    let recurrenceId: Int
    let operation: Operation
    let contextAppointmentId: Int?

}

enum AppointmentChargeType: String, Codable {
    case complete = "Completion"
    case noshow = "CancellationFee"
    case nocharge = "Waived"
}

enum AppointmentChargeStatus: String, Decodable {
    case charged
    case failed
    case pending
}

struct AppointmentChargeStatusModel: Decodable {
    let status: AppointmentChargeStatus
}

struct AppointmentChargeResult: Decodable {
    let amountFailed: Double
}

struct AppointmentCharge: Codable {
    let appointment: String
    let chargeType: String
}

struct ParticipantAppointmentCharge: Codable {
    let appointmentId: Int
    let chargeType: AppointmentChargeType
    let participant: String
}

struct HunterRoom: Codable, Equatable {
    let pin: String
    let key: String
}
