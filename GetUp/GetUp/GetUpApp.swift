import SwiftUI
import SwiftData
import AlarmKit

/// Main app entry point
@main
struct GetUpApp: App {
    @StateObject private var appState = AppState.shared
    
    /// SwiftData model container
    let modelContainer: ModelContainer
    
    static var storeURL: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("GetUp.sqlite")
    }
    
    init() {
        do {
            // Ensure Application Support directory exists
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            if !FileManager.default.fileExists(atPath: appSupport.path) {
                try FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
            }
            
            let config = ModelConfiguration(url: Self.storeURL)
            modelContainer = try ModelContainer(for: AlarmEntity.self, configurations: config)
            print("📦 SwiftData initialized at: \(Self.storeURL.path)")
        } catch {
            print("❌ Failed to create ModelContainer: \(error)")
            // Fallback to in-memory for crashes if production, but for now fatalError as per initial code
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .modelContainer(modelContainer)
                .preferredColorScheme(.dark)
        }
    }
}

/// Root view handling navigation and NFC overlay
struct RootView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
                    .transition(.opacity)
            } else {
                // Main content
                MainTabView()
                
                // NFC Scan overlay (appears over everything)
                if appState.shouldShowNFCScan {
                    NFCScanView()
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                }
            }
        }
        .animation(DesignSystem.Animation.smooth, value: appState.hasCompletedOnboarding)
        .animation(DesignSystem.Animation.smooth, value: appState.shouldShowNFCScan)
    }
}

/// Main tab-based navigation
struct MainTabView: View {
    @State private var selectedTab: Tab = .alarms
    
    enum Tab: Hashable {
        case alarms
        case settings
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AlarmsTab()
                .tabItem {
                    Label("Alarms", systemImage: "alarm.fill")
                }
                .tag(Tab.alarms)
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
        .tint(DesignSystem.Colors.accent)
    }
}

// MARK: - Global App State

/// Global app state for navigation and alarm management
@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var shouldShowNFCScan = false
    @Published var pendingAlarmId: String?
    @Published var showDataResetAlert = false
    @Published var getUpModeEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(getUpModeEnabled, forKey: "getUpModeEnabled")
        }
    }
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        }
    }
    
    private init() {
        // Support UI test reset via launch argument
        if CommandLine.arguments.contains("--reset-onboarding") {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            self.hasCompletedOnboarding = false
        } else {
            self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }

        self.getUpModeEnabled = UserDefaults.standard.object(forKey: "getUpModeEnabled") as? Bool ?? true
    }
    
    func triggerNFCScan(alarmId: String) {
        pendingAlarmId = alarmId
        shouldShowNFCScan = true
    }
    
    func completeScan() {
        shouldShowNFCScan = false
        pendingAlarmId = nil
    }
    
    func resetData() {
        // Reset UserDefaults
        hasCompletedOnboarding = false
        getUpModeEnabled = true
        UserDefaults.standard.removeObject(forKey: "getUpModeEnabled")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        
        // Delete SwiftData store
        let storeURL = GetUpApp.storeURL
        let walURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
        let shmURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
        
        try? FileManager.default.removeItem(at: storeURL)
        try? FileManager.default.removeItem(at: walURL)
        try? FileManager.default.removeItem(at: shmURL)

        print("🧹 Data reset complete. Restart app to reinitialize store.")

        // The live ModelContainer still points at the deleted file. Surface
        // an alert telling the user to force-quit and relaunch instead of
        // letting the next write crash silently.
        showDataResetAlert = true
    }
}
