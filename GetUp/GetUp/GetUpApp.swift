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
                .preferredColorScheme(.light)
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
                // Main content — two tabs: Home (alarms + progress) and
                // Analytics. Settings still lives behind the burger menu
                // inside the Home tab toolbar.
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

/// Two-tab navigation — Home (alarms + progress sections) and Analytics.
/// Uses the custom floating pill tab bar that slides off-screen when the
/// active tab's ScrollView is pulled upward and reappears on a downward
/// pan. Tab switches always reveal the bar.
struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: Tab = .home

    enum Tab: Hashable {
        case home
        case analytics
    }

    private var items: [FloatingTabBar<Tab>.Item] {
        [
            .init(id: .home,      icon: "house.fill",     label: "Home"),
            .init(id: .analytics, icon: "chart.bar.fill", label: "Analytics"),
        ]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Both tabs mounted simultaneously so SwiftData queries
            // and the home tab's NavigationStack don't unwind on switch.
            ZStack {
                AlarmsTab()
                    .opacity(selectedTab == .home ? 1 : 0)
                    .allowsHitTesting(selectedTab == .home)
                AnalyticsTab()
                    .opacity(selectedTab == .analytics ? 1 : 0)
                    .allowsHitTesting(selectedTab == .analytics)
            }
            .animation(DesignSystem.Animation.fast, value: selectedTab)

            FloatingTabBar(selection: $selectedTab, items: items)
                .padding(.bottom, DesignSystem.Spacing.md)
                .offset(y: appState.isTabBarHidden ? 160 : 0)
                .opacity(appState.isTabBarHidden ? 0 : 1)
                .animation(.easeInOut(duration: 0.28), value: appState.isTabBarHidden)
        }
        .background(DesignSystem.Colors.canvas.ignoresSafeArea())
        .onChange(of: selectedTab) { _, _ in
            // Landing on a tab should always reveal the bar.
            if appState.isTabBarHidden {
                appState.isTabBarHidden = false
            }
        }
        // Single Settings sheet — triggered by the burger menu in either
        // tab via appState.showingSettings.
        .sheet(isPresented: $appState.showingSettings) {
            SettingsTab()
        }
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
    /// Shared sheet trigger so any tab's burger menu can open Settings.
    @Published var showingSettings: Bool = false
    /// Toggled by scrollable tabs via the `hidesTabBarOnScroll(_:)` modifier.
    /// `MainTabView` watches this to slide the floating pill tab bar off
    /// screen while the user pulls more content up, then reveal it again
    /// on a downward pan.
    @Published var isTabBarHidden: Bool = false
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
