import Foundation
import SwiftData

/// Repository for alarm CRUD operations
@MainActor
final class AlarmRepository: ObservableObject {
    private let modelContext: ModelContext
    
    @Published var alarms: [AlarmEntity] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchAlarms()
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch all alarms sorted by time
    func fetchAlarms() {
        let descriptor = FetchDescriptor<AlarmEntity>(
            sortBy: [
                SortDescriptor(\.hour),
                SortDescriptor(\.minute)
            ]
        )
        
        do {
            alarms = try modelContext.fetch(descriptor)
        } catch {
            print("❌ Failed to fetch alarms: \(error)")
            alarms = []
        }
    }
    
    /// Create a new alarm
    func create(
        hour: Int,
        minute: Int,
        label: String = "",
        requiresNFC: Bool = true,
        tagIdentifierHash: String? = nil,
        repeatDays: RepeatDays = .never,
        snoozePolicy: SnoozePolicy = .disabled
    ) -> AlarmEntity {
        let alarm = AlarmEntity(
            hour: hour,
            minute: minute,
            label: label,
            isEnabled: true,
            requiresNFC: requiresNFC,
            tagIdentifierHash: tagIdentifierHash,
            repeatDays: repeatDays,
            snoozePolicy: snoozePolicy
        )
        
        modelContext.insert(alarm)
        save()
        fetchAlarms()
        
        print("✅ Created alarm: \(alarm.timeString)")
        return alarm
    }
    
    /// Update an existing alarm
    func update(_ alarm: AlarmEntity) {
        alarm.update()
        save()
        fetchAlarms()
        
        print("✅ Updated alarm: \(alarm.timeString)")
    }
    
    /// Delete an alarm
    func delete(_ alarm: AlarmEntity) {
        modelContext.delete(alarm)
        save()
        fetchAlarms()
        
        print("🗑️ Deleted alarm: \(alarm.timeString)")
    }
    
    /// Toggle alarm enabled state
    func toggleEnabled(_ alarm: AlarmEntity) {
        alarm.isEnabled.toggle()
        alarm.update()
        save()
        fetchAlarms()
        
        print("🔄 Toggled alarm \(alarm.timeString): \(alarm.isEnabled ? "ON" : "OFF")")
    }
    
    /// Bind NFC tag to alarm
    func bindTag(_ alarm: AlarmEntity, tagHash: String) {
        alarm.tagIdentifierHash = tagHash
        alarm.update()
        save()
        fetchAlarms()
        
        print("🏷️ Bound tag to alarm: \(alarm.timeString)")
    }
    
    /// Get enabled alarms
    var enabledAlarms: [AlarmEntity] {
        alarms.filter { $0.isEnabled }
    }
    
    /// Get alarms requiring NFC
    var nfcAlarms: [AlarmEntity] {
        alarms.filter { $0.requiresNFC && $0.isEnabled }
    }
    
    // MARK: - Persistence
    
    private func save() {
        do {
            try modelContext.save()
        } catch {
            print("❌ Failed to save: \(error)")
        }
    }
}

// MARK: - Preview Support

extension AlarmRepository {
    /// Create a preview repository with sample data
    static func preview() -> AlarmRepository {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: AlarmEntity.self, configurations: config)
        let repository = AlarmRepository(modelContext: container.mainContext)
        
        // Add sample alarms
        _ = repository.create(hour: 7, minute: 0, label: "Wake up")
        _ = repository.create(hour: 8, minute: 30, label: "Gym", repeatDays: .weekdays)
        _ = repository.create(hour: 22, minute: 0, label: "Wind down", requiresNFC: false)
        
        return repository
    }
}
