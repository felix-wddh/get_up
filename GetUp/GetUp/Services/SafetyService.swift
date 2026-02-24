import Foundation

/// Service for handling emergency alarm dismissal history
@MainActor
final class SafetyService: ObservableObject {
    static let shared = SafetyService()
    
    @Published var bypassCount: Int = 0
    @Published var lastBypassDate: Date?
    
    private let bypassHistoryKey = "bypassHistory"
    
    private init() {
        loadHistory()
    }
    
    /// Register a bypass event (unlimited but logged)
    func registerBypass() {
        var history = getHistory()
        history.append(Date())
        saveHistory(history)
        
        bypassCount = history.count
        lastBypassDate = history.last
        
        print("⚠️ Emergency bypass used. Total: \(bypassCount)")
    }
    
    // MARK: - Private Methods
    
    private func loadHistory() {
        cleanupHistory()
        let history = getHistory()
        bypassCount = history.count
        lastBypassDate = history.last
    }
    
    private func getHistory() -> [Date] {
        guard let data = UserDefaults.standard.array(forKey: bypassHistoryKey) as? [Date] else {
            return []
        }
        return data
    }
    
    private func saveHistory(_ history: [Date]) {
        UserDefaults.standard.set(history, forKey: bypassHistoryKey)
    }
    
    private func cleanupHistory() {
        let history = getHistory()
        // We keep the last 30 days of history for the user's information
        let thirtyDaysAgo = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        
        let recentHistory = history.filter { $0 > thirtyDaysAgo }
        
        if recentHistory.count != history.count {
            saveHistory(recentHistory)
        }
    }
}
