import Foundation
import AlarmKit
import ActivityKit
import AppIntents

// MARK: - Alarm Metadata

/// Custom metadata for GetUp alarms
struct GetUpAlarmMetadata: AlarmMetadata {
    var alarmEntityId: String  // Link back to SwiftData entity
    var label: String
    var requiresNFC: Bool
    var tagHash: String?
    
    init(alarmEntityId: String, label: String = "GetUp Alarm", requiresNFC: Bool = true, tagHash: String? = nil) {
        self.alarmEntityId = alarmEntityId
        self.label = label
        self.requiresNFC = requiresNFC
        self.tagHash = tagHash
    }
}

// MARK: - Alarm Service

/// Service for managing alarms via AlarmKit (iOS 26)
@MainActor
final class AlarmService: ObservableObject {
    static let shared = AlarmService()
    
    @Published var authorizationState: AlarmManager.AuthorizationState = .notDetermined
    @Published var scheduledCount: Int = 0
    
    private let manager = AlarmManager.shared
    
    private init() {
        // Sync authorization state
        authorizationState = manager.authorizationState
        
        Task {
            await refreshCount()
        }
    }
    
    // MARK: - Authorization
    
    /// Request AlarmKit authorization
    func requestAuthorization() async throws -> AlarmManager.AuthorizationState {
        let state = try await manager.requestAuthorization()
        authorizationState = state
        return state
    }
    
    /// Check current authorization
    func checkAuthorization() {
        authorizationState = manager.authorizationState
    }
    
    // MARK: - Schedule Alarm
    
    /// Schedule a system alarm for an AlarmEntity
    func scheduleAlarm(for entity: AlarmEntity) async throws -> UUID {
        let alarmId = UUID()
        
        // Calculate time for the alarm
        let time = AlarmKit.Alarm.Schedule.Relative.Time(
            hour: entity.hour,
            minute: entity.minute
        )
        
        // Build recurrence from repeat days
        let recurrence: AlarmKit.Alarm.Schedule.Relative.Recurrence
        if entity.repeatDays.isRepeating {
            let weekdays = entity.repeatDays.weekdays.compactMap { dayNumber -> Locale.Weekday? in
                switch dayNumber {
                case 1: return .sunday
                case 2: return .monday
                case 3: return .tuesday
                case 4: return .wednesday
                case 5: return .thursday
                case 6: return .friday
                case 7: return .saturday
                default: return nil
                }
            }
            recurrence = .weekly(weekdays)
        } else {
            recurrence = .never
        }
        
        // Create schedule
        let schedule = AlarmKit.Alarm.Schedule.relative(.init(time: time, repeats: recurrence))
        
        // Create presentation
        let alertTitle = entity.label.isEmpty ? "GetUp Alarm" : entity.label
        let alertPresentation = AlarmPresentation.Alert(
            title: LocalizedStringResource(stringLiteral: alertTitle),
            secondaryButtonBehavior: entity.snoozePolicy != .disabled ? .countdown : nil
        )
        
        let presentation = AlarmPresentation(
            alert: alertPresentation
        )
        
        // Create attributes with metadata
        let metadata = GetUpAlarmMetadata(
            alarmEntityId: entity.id.uuidString,
            label: entity.label,
            requiresNFC: entity.requiresNFC,
            tagHash: entity.tagIdentifierHash
        )
        
        let attributes = AlarmAttributes<GetUpAlarmMetadata>(
            presentation: presentation,
            metadata: metadata,
            tintColor: .cyan
        )
        
        // Create stop intent that opens the app
        let stopIntent = StopAlarmIntent(alarmId: alarmId.uuidString)
        
        // Create configuration
        let configuration = AlarmManager.AlarmConfiguration<GetUpAlarmMetadata>.alarm(
            schedule: schedule,
            attributes: attributes,
            stopIntent: stopIntent
        )
        
        // Schedule the alarm
        let alarm = try await manager.schedule(id: alarmId, configuration: configuration)
        
        print("⏰ Scheduled alarm \(alarm.id) for \(entity.hour):\(String(format: "%02d", entity.minute))")
        
        await refreshCount()
        return alarmId
    }
    
    /// Cancel a system alarm
    func cancelAlarm(id: UUID) throws {
        try manager.cancel(id: id)
        print("🗑️ Cancelled alarm \(id)")
        
        Task {
            await refreshCount()
        }
    }
    
    /// Cancel alarm by entity
    func cancelAlarm(for entity: AlarmEntity) throws {
        guard let systemId = entity.systemAlarmId else {
            print("⚠️ No system alarm ID for entity \(entity.id)")
            return
        }
        try cancelAlarm(id: systemId)
    }
    
    /// Cancel all system alarms
    func cancelAll() async {
        do {
            let alarms = try manager.alarms
            for alarm in alarms {
                try manager.cancel(id: alarm.id)
            }
            print("🗑️ Cancelled \(alarms.count) alarms")
        } catch {
            print("❌ Failed to cancel alarms: \(error)")
        }
        await refreshCount()
    }
    
    // MARK: - Sync with SwiftData
    
    /// Sync all enabled alarms from SwiftData to AlarmKit
    func syncAlarms(entities: [AlarmEntity]) async {
        // First cancel all existing alarms
        await cancelAll()
        
        // Schedule enabled alarms
        for entity in entities where entity.isEnabled {
            do {
                let systemId = try await scheduleAlarm(for: entity)
                entity.systemAlarmId = systemId
            } catch {
                print("❌ Failed to schedule alarm for \(entity.id): \(error)")
            }
        }
        
        print("✅ Synced \(entities.filter { $0.isEnabled }.count) alarms to AlarmKit")
    }
    
    // MARK: - Query
    
    /// Get all scheduled system alarms
    func getScheduledAlarms() throws -> [AlarmKit.Alarm] {
        return try manager.alarms
    }
    
    /// Refresh scheduled count
    private func refreshCount() async {
        do {
            let alarms = try manager.alarms
            scheduledCount = alarms.count
        } catch {
            print("❌ Failed to fetch alarms: \(error)")
            scheduledCount = 0
        }
    }
}
