import SwiftUI
import StoreKit
import SwiftData

/// Settings tab — v2 grouped cards. Each group is one card; rows inside it
/// are separated by hairline `divider` color.
struct SettingsTab: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @StateObject private var safetyService = SafetyService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                // Background — v2 canvas
                DesignSystem.Colors.canvas
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Profile/App Header
                        appHeader

                        // GetUp Mode Section
                        getUpModeSection

                        // Language Section
                        languageSection

                        // Emergency History Section
                        emergencyHistorySection

                        // About Section
                        aboutSection

                        // Support Section
                        supportSection

                        // Footer
                        Text("Made for heavy sleepers.")
                            .font(DesignSystem.Font.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .padding(.top, DesignSystem.Spacing.lg)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.spacing2xl)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(DesignSystem.Colors.canvas, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
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
            TintedIconContainer("alarm.fill", size: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text("GetUp")
                    .font(DesignSystem.Font.screenTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Text("Premium alarm utility")
                    .font(DesignSystem.Font.secondaryBody)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }

            Spacer()
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
    }

    // MARK: - GetUp Mode Section

    private var getUpModeSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            SectionHeader("Enforcement")

            Card(padding: DesignSystem.Spacing.lg) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    TintedIconContainer("shield.fill", size: 40, shape: .circle)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("GetUp Mode")
                            .font(DesignSystem.Font.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Text("Require NFC scan to silence alarms")
                            .font(DesignSystem.Font.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }

                    Spacer()

                    Toggle("", isOn: $appState.getUpModeEnabled)
                        .tint(DesignSystem.Colors.primary)
                        .labelsHidden()
                        .accessibilityLabel("GetUp Mode")
                        .accessibilityHint("Require NFC scan to silence alarms")
                }
            }
        }
    }

    // MARK: - Language Section

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            SectionHeader("Language")
            LanguagePickerView()
        }
    }

    // MARK: - Emergency History Section

    private var emergencyHistorySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            SectionHeader("Emergency bypasses")

            Card(padding: DesignSystem.Spacing.lg) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        TintedIconContainer(
                            "exclamationmark.shield.fill",
                            size: 40,
                            shape: .circle,
                            tint: DesignSystem.Colors.warningBg,
                            foreground: DesignSystem.Colors.warning
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bypass history")
                                .font(DesignSystem.Font.headline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            Text("Last 30 days")
                                .font(DesignSystem.Font.caption)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }

                        Spacer()

                        Text("\(safetyService.bypassCount)")
                            .font(DesignSystem.Font.sectionHeader)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }

                    settingsDivider

                    if let last = safetyService.lastBypassDate {
                        HStack {
                            Text("Last used")
                                .font(DesignSystem.Font.body)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                            Spacer()
                            Text(last.formatted(date: .omitted, time: .shortened))
                                .font(DesignSystem.Font.body)
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                        }
                    } else {
                        Text("No emergency stops used yet. Good job.")
                            .font(DesignSystem.Font.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            SectionHeader("About")

            Card(padding: DesignSystem.Spacing.lg) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    rowVersion

                    settingsDivider

                    Button(action: openPrivacyPolicy) {
                        settingsRow(title: "Privacy policy", trailing: "safari")
                    }
                    .buttonStyle(.plain)

                    settingsDivider

                    HStack {
                        Text("Accessibility")
                            .font(DesignSystem.Font.body)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Spacer()
                        StatusIndicator(.active)
                    }
                }
            }
        }
    }

    private var rowVersion: some View {
        HStack {
            Text("Version")
                .font(DesignSystem.Font.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
            Spacer()
            Text("1.0.0 (Build 1)")
                .font(DesignSystem.Font.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            SectionHeader("Support")

            Card(padding: DesignSystem.Spacing.lg) {
                VStack(spacing: DesignSystem.Spacing.md) {
                    Button(action: contactSupport) {
                        settingsRow(title: "Contact support", trailing: "envelope.fill")
                    }
                    .buttonStyle(.plain)

                    settingsDivider

                    Button(action: rateApp) {
                        settingsRow(title: "Rate GetUp", trailing: "heart.fill")
                    }
                    .buttonStyle(.plain)

                    #if DEBUG
                    settingsDivider

                    Button(action: triggerAlarmNow) {
                        HStack {
                            Text("Trigger Alarm Now (Debug)")
                                .font(DesignSystem.Font.body)
                                .foregroundColor(DesignSystem.Colors.primary)
                            Spacer()
                            Image(systemName: "bolt.fill")
                                .foregroundColor(DesignSystem.Colors.primary.opacity(0.7))
                        }
                    }
                    .buttonStyle(.plain)

                    settingsDivider

                    Button(role: .destructive, action: { appState.resetData() }) {
                        HStack {
                            Text("Reset local data")
                                .font(DesignSystem.Font.body)
                                .foregroundColor(DesignSystem.Colors.error)
                            Spacer()
                            Image(systemName: "trash.fill")
                                .foregroundColor(DesignSystem.Colors.error.opacity(0.7))
                        }
                    }
                    .buttonStyle(.plain)
                    #endif
                }
            }
        }
    }

    // MARK: - Settings row helpers

    private var settingsDivider: some View {
        Rectangle()
            .fill(DesignSystem.Colors.divider)
            .frame(height: 1)
    }

    private func settingsRow(title: String, trailing icon: String) -> some View {
        HStack {
            Text(title)
                .font(DesignSystem.Font.body)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignSystem.Colors.textTertiary)
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
