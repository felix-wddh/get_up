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
                // Background
                DesignSystem.Colors.background
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
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.xl)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
            }
            .navigationTitle("New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DesignSystem.Colors.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveAlarm() }
                        .foregroundColor(DesignSystem.Colors.accent)
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
    
    private var timePickerSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack(spacing: 0) {
                // Hour picker
                Picker("Hour", selection: $hour) {
                    ForEach(0..<24, id: \.self) { h in
                        Text("\(h)").tag(h)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
                
                Text(":")
                    .font(DesignSystem.Typography.largeTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                // Minute picker
                Picker("Minute", selection: $minute) {
                    ForEach(0..<60, id: \.self) { m in
                        Text(String(format: "%02d", m)).tag(m)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
            }
            .frame(height: 150)
        }
    }
    
    // MARK: - Label Section
    
    private var labelSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeader("Label", icon: "tag")
            
            GlassCard(padding: DesignSystem.Spacing.md) {
                TextField("Alarm label", text: $label)
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .tint(DesignSystem.Colors.accent)
            }
        }
    }
    
    // MARK: - Repeat Section
    
    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            SectionHeader("Repeat", icon: "repeat")
            
            GlassCard {
                HStack(spacing: DesignSystem.Spacing.sm) {
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
            SectionHeader("NFC Tag", icon: "wave.3.right")
            
            GlassCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    if let tagHash = boundTagHash {
                        // Tag bound
                        HStack {
                            StatusIndicator(.active)
                            Text("Tag bound")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            Spacer()
                            Button("Change") {
                                scanForTag()
                            }
                            .font(DesignSystem.Typography.subheadline)
                            .foregroundColor(DesignSystem.Colors.accent)
                        }
                        
                        Text("ID: \(tagHash.prefix(12))...")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        // No tag bound
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "wave.3.right")
                                .font(.system(size: 32, weight: .light))
                                .foregroundColor(DesignSystem.Colors.textTertiary)
                            
                            Text("Bind an NFC tag to stop this alarm")
                                .font(DesignSystem.Typography.subheadline)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            GlassButton("Scan Tag", icon: "radiowaves.right") {
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
