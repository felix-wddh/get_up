import SwiftUI
import StoreKit
import SwiftData

/// Settings tab with app configuration and about info
struct SettingsTab: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @StateObject private var safetyService = SafetyService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Profile/App Header
                        appHeader
                        
                        // GetUp Mode Section
                        getUpModeSection
                        
                        // Emergency History Section
                        emergencyHistorySection
                        
                        // About Section
                        aboutSection
                        
                        // Support Section
                        supportSection
                        
                        // Footer
                        Text("Made with ❤️ for heavy sleepers")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .padding(.top, DesignSystem.Spacing.lg)
                            .padding(.bottom, DesignSystem.Spacing.xxl)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.md)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(DesignSystem.Colors.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert("Data reset complete", isPresented: $appState.showDataResetAlert) {
                Button("OK") {}
            } message: {
                Text("Force-quit and relaunch GetUp to start fresh. (Swipe up from the bottom and swipe the app away.)")
            }
        }
    }
    
    // MARK: - App Header
    
    private var appHeader: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                GlowCircle(color: DesignSystem.Colors.accent, size: 60, blur: 20)
                Image(systemName: "alarm.fill")
                    .font(.system(size: 30))
                    .foregroundColor(DesignSystem.Colors.accent)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("GetUp")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Text("Premium Alarm Utility")
                    .font(DesignSystem.Typography.subheadline)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.md)
    }
    
    // MARK: - GetUp Mode Section
    
    private var getUpModeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            SectionHeader("Enforcement", icon: "shield.fill")
            
            GlassCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Toggle row
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("GetUp Mode")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Require NFC scan to silence alarms")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $appState.getUpModeEnabled)
                            .tint(DesignSystem.Colors.accent)
                            .labelsHidden()
                            .accessibilityLabel("GetUp Mode")
                            .accessibilityHint("Require NFC scan to silence alarms")
                    }
                }
            }
        }
    }
    
    // MARK: - Emergency History Section
    
    private var emergencyHistorySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            SectionHeader("Emergency Bypasses", icon: "exclamationmark.shield.fill")
            
            GlassCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bypass History")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Last 30 days")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Text("\(safetyService.bypassCount)")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    
                    if let last = safetyService.lastBypassDate {
                        Divider().background(DesignSystem.Colors.glassBorder)
                        
                        HStack {
                            Text("Last Used")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            Spacer()
                            Text(last.formatted(date: .omitted, time: .shortened))
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    } else {
                        Divider().background(DesignSystem.Colors.glassBorder)
                        Text("No emergency stops used yet. Good job!")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            SectionHeader("About", icon: "info.circle.fill")
            
            UserGuidanceCard()
            
            GlassCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Version
                    HStack {
                        Text("Version")
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                    
                    Divider().background(DesignSystem.Colors.glassBorder)
                    
                    // Privacy Policy
                    Button(action: openPrivacyPolicy) {
                        HStack {
                            Text("Privacy Policy")
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            Spacer()
                            Image(systemName: "safari")
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Divider().background(DesignSystem.Colors.glassBorder)
                    
                    // Accessibility
                    HStack {
                        Text("Accessibility")
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Spacer()
                        StatusIndicator(.active)
                    }
                }
            }
        }
    }
    
    // MARK: - Support Section
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            SectionHeader("Support", icon: "help.circle.fill")
            
            GlassCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Button(action: contactSupport) {
                        HStack {
                            Text("Contact Support")
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            Spacer()
                            Image(systemName: "envelope.fill")
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Divider().background(DesignSystem.Colors.glassBorder)
                    
                    Button(action: rateApp) {
                        HStack {
                            Text("Rate GetUp")
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            Spacer()
                            Image(systemName: "heart.fill")
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    #if DEBUG
                    Divider().background(DesignSystem.Colors.glassBorder)

                    Button(action: triggerAlarmNow) {
                        HStack {
                            Text("Trigger Alarm Now (Debug)")
                                .foregroundColor(DesignSystem.Colors.accent)
                            Spacer()
                            Image(systemName: "bolt.fill")
                                .foregroundColor(DesignSystem.Colors.accent.opacity(0.7))
                        }
                    }
                    .buttonStyle(.plain)

                    Divider().background(DesignSystem.Colors.glassBorder)

                    Button(role: .destructive, action: { appState.resetData() }) {
                        HStack {
                            Text("Reset Local Data")
                                .foregroundColor(DesignSystem.Colors.danger)
                            Spacer()
                            Image(systemName: "trash.fill")
                                .foregroundColor(DesignSystem.Colors.danger.opacity(0.7))
                        }
                    }
                    .buttonStyle(.plain)
                    #endif
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func openPrivacyPolicy() {
        // TODO: Replace with hosted privacy policy URL before submission
        if let url = URL(string: "mailto:support@getupapp.de?subject=Privacy%20Policy%20Request") {
            UIApplication.shared.open(url)
        }
    }
    
    private func contactSupport() {
        if let url = URL(string: "mailto:support@getupapp.de?subject=GetUp%20Support") {
            UIApplication.shared.open(url)
        }
    }
    
    @MainActor
    private func rateApp() {
        if let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    #if DEBUG
    /// Debug-only: bypass AlarmKit wait and show the NFC dismiss overlay immediately.
    /// Uses the first enabled alarm's systemAlarmId if available so the verify-against-stored-tag
    /// flow runs; falls back to entity id, then to a fresh UUID (binding mode).
    private func triggerAlarmNow() {
        let descriptor = FetchDescriptor<AlarmEntity>(
            predicate: #Predicate { $0.isEnabled }
        )
        let alarmIdString: String
        if let alarm = try? modelContext.fetch(descriptor).first {
            alarmIdString = alarm.systemAlarmId?.uuidString ?? alarm.id.uuidString
        } else {
            alarmIdString = UUID().uuidString
        }
        DesignSystem.Haptics.triggerImpact(.medium)
        appState.triggerNFCScan(alarmId: alarmIdString)
    }
    #endif
}

// MARK: - Preview

#Preview {
    SettingsTab()
        .environmentObject(AppState.shared)
}
