import Foundation


extension Date {
    static var mediumDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium

        return formatter
    }
    
    static var fullDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short

        return formatter
    }
    
    static var iso8601: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }
    
    init?(fromString: String) {
        let formatter = Date.iso8601
        
        if let date = formatter.date(from: fromString) {
            self = date
            return
        }
        
        // Might be a more precise format...
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        if let date = formatter.date(from: fromString) {
            self = date
            return
        }
        
        return nil
    }
    
    func toString() -> String {
        return Date.iso8601.string(from: self)
    }
    
    
    // Takes a Date and returns how far away it is in a localized friendly time
    // Etc "5 days" or "10 minutes"
    func timeUntil() -> String? {
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: Date(), to: self)
        guard let minute = components.minute,
            let hour = components.hour,
            let day = components.day else {
                return nil
        }
        
        if day >= 1 {
            return "calendar_days".localizedPlural(day)
        } else if hour >= 1 {
            return "calendar_hours".localizedPlural(hour)
        } else if minute >= 1 {
            return "calendar_minutes".localizedPlural(minute)
        }
        
        return nil
    }
}
