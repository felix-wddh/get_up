import SwiftUI
import SwiftData
import AlarmKit

/// Sheet for creating a new alarm
struct CreateAlarmSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    private let alarmService = AlarmService.shared
    
    @State private var hour: Int = 7
    @State private var minute: Int = 0
    @State private var label: String = ""
    @State private var repeatDays: RepeatDays = .never
    @State private var snoozePolicy: SnoozePolicy = .disabled
    @State private var requiresNFC: Bool = true
    @State private var boundTagHash: String?
    
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background — v2 canvas.
                DesignSystem.Colors.canvas
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Time Picker
                        timePickerSection

                        // Label
                        labelSection

                        // Repeat
                        repeatSection

                        // NFC Binding
                        if appState.getUpModeEnabled && requiresNFC {
                            nfcBindingSection
                        }

                        // Save (primary pill, full width)
                        PrimaryPillButton(
                            "Save alarm",
                            isLoading: isSaving,
                            isEnabled: !(appState.getUpModeEnabled && requiresNFC && boundTagHash == nil),
                            action: { saveAlarm() }
                        )
                        .padding(.top, DesignSystem.Spacing.sm)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.xl)
                    .padding(.bottom, DesignSystem.Spacing.spacing3xl)
                }
            }
            .navigationTitle("New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DesignSystem.Colors.canvas, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAlarm() }
                        .foregroundColor(DesignSystem.Colors.primary)
                        .disabled(isSaving || (appState.getUpModeEnabled && requiresNFC && boundTagHash == nil))
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Set initial time to current + round to nearest 5 min
                let now = Date()
                let calendar = Calendar.current
                hour = calendar.component(.hour, from: now)
                minute = ((calendar.component(.minute, from: now) / 5) + 1) * 5
                if minute >= 60 {
                    minute = 0
                    hour = (hour + 1) % 24
                }
                
                // Auto-bind NFC tag from onboarding if available
                if boundTagHash == nil,
                   let savedHash = UserDefaults.standard.string(forKey: "onboardingTagHash") {
                    boundTagHash = savedHash
                }
            }
        }
    }
    
    // MARK: - Time Picker Section

    private var formattedTime: String {
        String(format: "%02d:%02d", hour, minute)
    }

    private var ringsInText: String {
        let now = Date()
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0

        guard var target = calendar.date(from: components) else { return "" }
        if target <= now {
            target = calendar.date(byAdding: .day, value: 1, to: target) ?? target
        }

        let diff = calendar.dateComponents([.hour, .minute], from: now, to: target)
        let h = diff.hour ?? 0
        let m = diff.minute ?? 0

        if h == 0 && m == 0 {
            return "Rings any moment now"
        } else if h == 0 {
            return "Rings in \(m)m"
        } else if m == 0 {
            return "Rings in \(h)h"
        } else {
            return "Rings in \(h)h \(m)m"
        }
    }

    private var timePickerSection: some View {
        HeroCard(padding: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                // Large time preview
                Text(formattedTime)
                    .font(DesignSystem.Font.preferred(size: 64, weight: .bold, relativeTo: .largeTitle))
                    .monospacedDigit()
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .accessibilityLabel("Selected alarm time: \(formattedTime)")
                    .frame(height: 76)

                // "Rings in..." subtitle
                Text(ringsInText)
                    .font(DesignSystem.Font.secondaryBody)
                    .foregroundColor(DesignSystem.Colors.primary)

                // Wheel pickers
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Picker("Hour", selection: $hour) {
                        ForEach(0..<24, id: \.self) { h in
                            Text(String(format: "%02d", h))
                                .font(DesignSystem.Font.sectionHeader)
                                .tag(h)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 96)

                    Text(":")
                        .font(DesignSystem.Font.sectionHeader)
                        .foregroundColor(DesignSystem.Colors.textSecondary)

                    Picker("Minute", selection: $minute) {
                        ForEach(0..<60, id: \.self) { m in
                            Text(String(format: "%02d", m))
                                .font(DesignSystem.Font.sectionHeader)
                                .tag(m)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 96)
                }
                .frame(height: 120)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Label Section

    private var labelSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeader("Label")

            Card(padding: DesignSystem.Spacing.md) {
                TextField("Alarm label", text: $label)
                    .font(DesignSystem.Font.body)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .tint(DesignSystem.Colors.primary)
                    .frame(minHeight: 28)
            }
        }
    }

    // MARK: - Repeat Section

    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeader("Repeat")

            Card {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    RepeatDayButton(label: "S", fullName: "Sunday", isSelected: repeatDays.sunday) { repeatDays.sunday.toggle() }
                    RepeatDayButton(label: "M", fullName: "Monday", isSelected: repeatDays.monday) { repeatDays.monday.toggle() }
                    RepeatDayButton(label: "T", fullName: "Tuesday", isSelected: repeatDays.tuesday) { repeatDays.tuesday.toggle() }
                    RepeatDayButton(label: "W", fullName: "Wednesday", isSelected: repeatDays.wednesday) { repeatDays.wednesday.toggle() }
                    RepeatDayButton(label: "T", fullName: "Thursday", isSelected: repeatDays.thursday) { repeatDays.thursday.toggle() }
                    RepeatDayButton(label: "F", fullName: "Friday", isSelected: repeatDays.friday) { repeatDays.friday.toggle() }
                    RepeatDayButton(label: "S", fullName: "Saturday", isSelected: repeatDays.saturday) { repeatDays.saturday.toggle() }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - NFC Binding Section

    private var nfcBindingSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeader("NFC Tag")

            Card {
                VStack(spacing: DesignSystem.Spacing.md) {
                    if let tagHash = boundTagHash {
                        // Tag bound
                        HStack(spacing: DesignSystem.Spacing.md) {
                            TintedIconContainer(
                                "checkmark",
                                size: 40,
                                tint: DesignSystem.Colors.successBg,
                                foreground: DesignSystem.Colors.success
                            )
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tag bound")
                                    .font(DesignSystem.Font.headline)
                                    .foregroundColor(DesignSystem.Colors.textPrimary)
                                Text("ID: \(tagHash.prefix(12))…")
                                    .font(DesignSystem.Font.caption)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                            Spacer()
                            Button("Change") {
                                scanForTag()
                            }
                            .font(DesignSystem.Font.button)
                            .foregroundColor(DesignSystem.Colors.primary)
                        }
                    } else {
                        // No tag bound
                        VStack(spacing: DesignSystem.Spacing.md) {
                            TintedIconContainer("wave.3.right", size: 48)

                            Text("Bind an NFC tag to stop this alarm")
                                .font(DesignSystem.Font.secondaryBody)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)

                            PrimaryPillButton("Scan tag", icon: "wave.3.right") {
                                scanForTag()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func scanForTag() {
        NFCService.shared.startBindingScan { success, tagId, tagHash in
            if success, let hash = tagHash {
                self.boundTagHash = hash
                print("✅ Tag bound: \(hash)")
            } else if let error = NFCService.shared.errorMessage {
                self.errorMessage = error
                self.showError = true
            }
        }
    }
    
    private func saveAlarm() {
        isSaving = true
        
        // Create the alarm entity
        let alarm = AlarmEntity(
            hour: hour,
            minute: minute,
            label: label,
            isEnabled: true,
            requiresNFC: requiresNFC && appState.getUpModeEnabled,
            tagIdentifierHash: boundTagHash,
            repeatDays: repeatDays,
            snoozePolicy: snoozePolicy
        )
        
        modelContext.insert(alarm)
        
        Task {
            do {
                // Schedule with AlarmKit
                let systemId = try await alarmService.scheduleAlarm(for: alarm)
                alarm.systemAlarmId = systemId
                
                try modelContext.save()
                print("✅ Created and scheduled alarm: \(alarm.timeString)")
                dismiss()
            } catch {
                errorMessage = "Failed to schedule alarm: \(error.localizedDescription)"
                showError = true
                isSaving = false
                
                // Remove the entity on failure
                modelContext.delete(alarm)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CreateAlarmSheet()
        .environmentObject(AppState.shared)
        .modelContainer(for: AlarmEntity.self, inMemory: true)
}
