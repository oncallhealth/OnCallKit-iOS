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
    
    static var iso8601ExcludingSeconds: DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:00Z"
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
    
    func toString(excludingSeconds: Bool = false) -> String {
        return excludingSeconds ? Date.iso8601ExcludingSeconds.string(from: self) : Date.iso8601.string(from: self)
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
    
    // https://stackoverflow.com/a/31973686
    static func numberOfWeekdaysInMonth(weekday: Int, month: Int, year: Int) -> Int? {
        var calendar = Calendar.current
        calendar.firstWeekday = weekday

        var components = DateComponents(
            year: year,
            month: month,
            weekday: calendar.firstWeekday,
            weekdayOrdinal: 1)
        
        guard let first = calendar.date(from: components) else {
            return nil
        }

        components.weekdayOrdinal = -1
        
        guard let last = calendar.date(from: components) else {
            return nil
        }

        let weeks = calendar.dateComponents([.weekOfMonth], from: first, to: last)
        
        guard let weekOfMonth = weeks.weekOfMonth else {
            return nil
        }
        
        return weekOfMonth + 1
    }
    
    var weekdayOrdinal: Int? {
        return Calendar.current.dateComponents([.weekdayOrdinal], from: self).weekdayOrdinal
    }
    
    var weekdayNumber: Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    var weekday: String? {
        guard let index = weekdayNumber else {
            return nil
        }
        
        return Calendar.current.weekdaySymbols[index - 1]
    }
    
    var dayNumber: Int? {
        return Calendar.current.dateComponents([.day], from: self).day
    }
    
    var day: String? {
        guard let day = dayNumber else {
            return nil
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        
        return formatter.string(from: NSNumber(integerLiteral: day))
    }
    
    var weekOfMonth: Int? {
        return Calendar.current.dateComponents([.weekOfMonth], from: self).weekOfMonth
    }
    
    var hour: Int? {
        return Calendar.current.dateComponents([.hour], from: self).hour
    }
    
    var minute: Int? {
        return Calendar.current.dateComponents([.minute], from: self).minute
    }
    
    var second: Int? {
        return Calendar.current.dateComponents([.second], from: self).second
    }
    
    var month: Int? {
        return Calendar.current.dateComponents([.month], from: self).month
    }
}
