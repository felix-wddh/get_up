import AppIntents
import AlarmKit
import ActivityKit

/// App Intent triggered when user taps stop on alarm
/// This opens the app and initiates NFC scanning
/// Must conform to LiveActivityIntent for AlarmKit integration
struct StopAlarmIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop GetUp Alarm"
    static var description = IntentDescription("Stop the alarm by scanning your NFC tag")
    
    /// This is crucial - opens the app when the intent runs
    static var openAppWhenRun: Bool = true
    
    /// The alarm ID to stop
    @Parameter(title: "Alarm ID")
    var alarmId: String
    
    init() {
        self.alarmId = ""
    }
    
    init(alarmId: String) {
        self.alarmId = alarmId
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        print("🔔 StopAlarmIntent triggered for alarm: \(alarmId)")
        
        // Trigger NFC scan in the app
        AppState.shared.triggerNFCScan(alarmId: alarmId)
        
        // Return result - the alarm UI will dismiss
        // but our app is now open with NFC scan view
        return .result()
    }
}
