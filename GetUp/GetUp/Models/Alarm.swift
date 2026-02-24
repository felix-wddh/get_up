import Foundation
import SwiftData

/// Snooze policy for alarms
enum SnoozePolicy: String, Codable, CaseIterable {
    case disabled = "disabled"
    case fiveMinutes = "5min"
    case tenMinutes = "10min"
    
    var displayName: String {
        switch self {
        case .disabled: return "Off"
        case .fiveMinutes: return "5 minutes"
        case .tenMinutes: return "10 minutes"
        }
    }
    
    var duration: TimeInterval? {
        switch self {
        case .disabled: return nil
        case .fiveMinutes: return 5 * 60
        case .tenMinutes: return 10 * 60
        }
    }
}

/// Weekday selection for repeating alarms
struct RepeatDays: Codable, Hashable {
    var sunday: Bool = false
    var monday: Bool = false
    var tuesday: Bool = false
    var wednesday: Bool = false
    var thursday: Bool = false
    var friday: Bool = false
    var saturday: Bool = false
    
    var isRepeating: Bool {
        sunday || monday || tuesday || wednesday || thursday || friday || saturday
    }
    
    var weekdays: [Int] {
        var days: [Int] = []
        if sunday { days.append(1) }
        if monday { days.append(2) }
        if tuesday { days.append(3) }
        if wednesday { days.append(4) }
        if thursday { days.append(5) }
        if friday { days.append(6) }
        if saturday { days.append(7) }
        return days
    }
    
    var displayText: String {
        if !isRepeating { return "Never" }
        
        let allWeekdays = monday && tuesday && wednesday && thursday && friday && !saturday && !sunday
        let weekend = saturday && sunday && !monday && !tuesday && !wednesday && !thursday && !friday
        let everyday = sunday && monday && tuesday && wednesday && thursday && friday && saturday
        
        if everyday { return "Every day" }
        if allWeekdays { return "Weekdays" }
        if weekend { return "Weekends" }
        
        var names: [String] = []
        if sunday { names.append("Sun") }
        if monday { names.append("Mon") }
        if tuesday { names.append("Tue") }
        if wednesday { names.append("Wed") }
        if thursday { names.append("Thu") }
        if friday { names.append("Fri") }
        if saturday { names.append("Sat") }
        return names.joined(separator: ", ")
    }
    
    static let never = RepeatDays()
    static let weekdays = RepeatDays(monday: true, tuesday: true, wednesday: true, thursday: true, friday: true)
    static let weekends = RepeatDays(sunday: true, saturday: true)
    static let everyday = RepeatDays(sunday: true, monday: true, tuesday: true, wednesday: true, thursday: true, friday: true, saturday: true)
}

/// Alarm model stored in SwiftData
@Model
final class AlarmEntity {
    /// Unique identifier
    var id: UUID
    
    /// Time components (hour and minute)
    var hour: Int
    var minute: Int
    
    /// User-provided label
    var label: String
    
    /// Whether the alarm is enabled
    var isEnabled: Bool
    
    /// Whether this alarm requires NFC to dismiss
    var requiresNFC: Bool
    
    /// Hash of the bound NFC tag (privacy-preserving)
    var tagIdentifierHash: String?
    
    /// Repeat schedule
    var repeatDaysData: Data?
    
    /// Snooze policy
    var snoozePolicyRaw: String
    
    /// Metadata
    var createdAt: Date
    var updatedAt: Date
    
    /// System alarm ID (for AlarmKit)
    var systemAlarmId: UUID?
    
    // MARK: - Computed Properties
    
    var repeatDays: RepeatDays {
        get {
            guard let data = repeatDaysData else { return .never }
            return (try? JSONDecoder().decode(RepeatDays.self, from: data)) ?? .never
        }
        set {
            repeatDaysData = try? JSONEncoder().encode(newValue)
        }
    }
    
    var snoozePolicy: SnoozePolicy {
        get {
            SnoozePolicy(rawValue: snoozePolicyRaw) ?? .disabled
        }
        set {
            snoozePolicyRaw = newValue.rawValue
        }
    }
    
    var timeString: String {
        String(format: "%d:%02d", hour, minute)
    }
    
    var time12Hour: (hour: Int, minute: Int, isPM: Bool) {
        let isPM = hour >= 12
        var displayHour = hour % 12
        if displayHour == 0 { displayHour = 12 }
        return (displayHour, minute, isPM)
    }
    
    var nextFireDate: Date? {
        let calendar = Calendar.current
        let now = Date()
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        if repeatDays.isRepeating {
            // Find the next occurrence based on repeat days
            for dayOffset in 0..<7 {
                let futureDate = calendar.date(byAdding: .day, value: dayOffset, to: now)!
                let weekday = calendar.component(.weekday, from: futureDate)
                
                if repeatDays.weekdays.contains(weekday) {
                    components.year = calendar.component(.year, from: futureDate)
                    components.month = calendar.component(.month, from: futureDate)
                    components.day = calendar.component(.day, from: futureDate)
                    
                    if let date = calendar.date(from: components), date > now {
                        return date
                    }
                }
            }
        } else {
            // One-time alarm: today or tomorrow
            components.year = calendar.component(.year, from: now)
            components.month = calendar.component(.month, from: now)
            components.day = calendar.component(.day, from: now)
            
            if let date = calendar.date(from: components) {
                if date > now {
                    return date
                } else {
                    // Tomorrow
                    return calendar.date(byAdding: .day, value: 1, to: date)
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Initialization
    
    init(
        hour: Int,
        minute: Int,
        label: String = "",
        isEnabled: Bool = true,
        requiresNFC: Bool = true,
        tagIdentifierHash: String? = nil,
        repeatDays: RepeatDays = .never,
        snoozePolicy: SnoozePolicy = .disabled
    ) {
        self.id = UUID()
        self.hour = hour
        self.minute = minute
        self.label = label
        self.isEnabled = isEnabled
        self.requiresNFC = requiresNFC
        self.tagIdentifierHash = tagIdentifierHash
        self.repeatDaysData = try? JSONEncoder().encode(repeatDays)
        self.snoozePolicyRaw = snoozePolicy.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func update() {
        updatedAt = Date()
    }
}
