import SwiftUI
import SwiftData
import AlarmKit

/// Alarms tab - main screen showing alarm list and global toggle
struct AlarmsTab: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\AlarmEntity.hour), SortDescriptor(\AlarmEntity.minute)]) 
    private var alarms: [AlarmEntity]
    
    @State private var showingCreateAlarm = false
    @State private var selectedAlarm: AlarmEntity?
    @State private var authState: AlarmManager.AuthorizationState = .notDetermined
    @State private var showAuthAlert = false
    @State private var showingSettings = false

    private let alarmService = AlarmService.shared

    var body: some View {
        NavigationStack {
            ZStack {
                // Background — v2 page canvas.
                DesignSystem.Colors.canvas
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        if authState == .denied {
                            authWarningCard
                        }

                        alarmsSection

                        addAlarmButton
                            .padding(.top, DesignSystem.Spacing.xs)

                        // Progress lives directly under the alarms section
                        // now that the dedicated tab is gone.
                        progressSection
                            .padding(.top, DesignSystem.Spacing.lg)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.spacing2xl)
                }
            }
            .navigationTitle("GetUp")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(DesignSystem.Colors.canvas, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingSettings = true
                        } label: {
                            Label("Settings", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .frame(width: 40, height: 40)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Menu")
                }
            }
            .sheet(isPresented: $showingCreateAlarm) {
                CreateAlarmSheet()
            }
            .sheet(item: $selectedAlarm) { alarm in
                EditAlarmSheet(alarm: alarm)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsTab()
            }
            .alert("Alarms Disabled", isPresented: $showAuthAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Please enable alarms in Settings to use GetUp.")
            }
            .task {
                authState = AlarmManager.shared.authorizationState
            }
        }
    }

    // MARK: - Progress section
    //
    // Combines the streak card (this week) with the month calendar
    // showing how often the user was woken with GetUp. Sits below the
    // alarms section on the main home screen.

    private var progressSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                SectionHeader("Progress")
                Spacer()
            }

            StreakCard(
                streakCount: 12,
                title: "Streak",
                subtitle: "Get up on time every day to build your streak.",
                weekDays: StreakCard.placeholderWeek()
            )

            MonthCalendarCard(
                wakeDates: MonthCalendarCard.placeholderWakeDates()
            )
        }
    }
    
    // MARK: - Authorization Warning

    private var authWarningCard: some View {
        Card {
            HStack(spacing: DesignSystem.Spacing.md) {
                TintedIconContainer(
                    "exclamationmark.triangle.fill",
                    size: 48,
                    tint: DesignSystem.Colors.warningBg,
                    foreground: DesignSystem.Colors.warning
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Alarms Disabled")
                        .font(DesignSystem.Font.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)

                    Text("Enable in Settings to receive alarms")
                        .font(DesignSystem.Font.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }

                Spacer()

                Button("Fix") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(DesignSystem.Font.headline)
                .foregroundColor(DesignSystem.Colors.primary)
            }
        }
    }

    private var alarmsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                SectionHeader("Your alarms")
                Spacer()
                if alarmService.scheduledCount > 0 {
                    Text("\(alarmService.scheduledCount) active")
                        .font(DesignSystem.Font.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }

            if alarms.isEmpty {
                // Empty state
                Card {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        TintedIconContainer("alarm", size: 64)

                        Text("No alarms yet")
                            .font(DesignSystem.Font.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)

                        Text("Add your first morning alarm to get started.")
                            .font(DesignSystem.Font.secondaryBody)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.md)
                }
            } else {
                // Alarm list
                ForEach(alarms) { alarm in
                    AlarmRow(alarm: alarm) {
                        selectedAlarm = alarm
                    } onToggle: {
                        toggleAlarm(alarm)
                    }
                }
            }
        }
    }

    // MARK: - Add Alarm Button

    private var addAlarmButton: some View {
        PrimaryPillButton("Add alarm", icon: "plus", action: handleAddAlarm)
            .accessibilityLabel("Add new alarm")
    }
    
    // MARK: - Actions
    
    private func handleAddAlarm() {
        // Check authorization first
        if authState == .notDetermined {
            Task {
                do {
                    authState = try await alarmService.requestAuthorization()
                    if authState == .authorized {
                        showingCreateAlarm = true
                    } else {
                        showAuthAlert = true
                    }
                } catch {
                    print("❌ Auth failed: \(error)")
                }
            }
        } else if authState == .denied {
            showAuthAlert = true
        } else {
            showingCreateAlarm = true
        }
    }
    
    private func toggleAlarm(_ alarm: AlarmEntity) {
        let wasEnabled = alarm.isEnabled
        alarm.isEnabled.toggle()
        alarm.update()
        
        Task {
            if alarm.isEnabled {
                // Schedule the alarm
                do {
                    let systemId = try await alarmService.scheduleAlarm(for: alarm)
                    alarm.systemAlarmId = systemId
                } catch {
                    print("❌ Failed to schedule: \(error)")
                    // Revert on failure
                    alarm.isEnabled = wasEnabled
                }
            } else {
                // Cancel the alarm
                do {
                    try alarmService.cancelAlarm(for: alarm)
                    alarm.systemAlarmId = nil
                } catch {
                    print("❌ Failed to cancel: \(error)")
                }
            }
            
            try? modelContext.save()
        }
    }
}

// MARK: - Alarm Row

struct AlarmRow: View {
    let alarm: AlarmEntity
    let onTap: () -> Void
    let onToggle: () -> Void

    var body: some View {
        Button(action: onTap) {
            Card(padding: DesignSystem.Spacing.lg) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Time
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%d:%02d", alarm.time12Hour.hour, alarm.time12Hour.minute))
                                .font(DesignSystem.Font.screenTitle)
                                .monospacedDigit()
                                .foregroundColor(alarm.isEnabled ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textDisabled)

                            Text(alarm.time12Hour.isPM ? "PM" : "AM")
                                .font(DesignSystem.Font.secondaryBody)
                                .foregroundColor(alarm.isEnabled ? DesignSystem.Colors.textSecondary : DesignSystem.Colors.textDisabled)
                        }

                        HStack(spacing: DesignSystem.Spacing.xs) {
                            if !alarm.label.isEmpty {
                                Text(alarm.label)
                                    .font(DesignSystem.Font.secondaryBody)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }

                            if alarm.repeatDays.isRepeating {
                                Text(alarm.repeatDays.displayText)
                                    .font(DesignSystem.Font.caption)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                        }
                    }

                    Spacer()

                    // NFC indicator
                    if alarm.requiresNFC {
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(alarm.isEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
                    }

                    // Toggle
                    Toggle("", isOn: Binding(
                        get: { alarm.isEnabled },
                        set: { _ in onToggle() }
                    ))
                    .tint(DesignSystem.Colors.primary)
                    .labelsHidden()
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Edit Alarm Sheet

struct EditAlarmSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    let alarm: AlarmEntity
    private let alarmService = AlarmService.shared
    
    @State private var hour: Int
    @State private var minute: Int
    @State private var label: String
    @State private var repeatDays: RepeatDays
    @State private var snoozePolicy: SnoozePolicy
    @State private var requiresNFC: Bool
    @State private var boundTagHash: String?
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    init(alarm: AlarmEntity) {
        self.alarm = alarm
        _hour = State(initialValue: alarm.hour)
        _minute = State(initialValue: alarm.minute)
        _label = State(initialValue: alarm.label)
        _repeatDays = State(initialValue: alarm.repeatDays)
        _snoozePolicy = State(initialValue: alarm.snoozePolicy)
        _requiresNFC = State(initialValue: alarm.requiresNFC)
        _boundTagHash = State(initialValue: alarm.tagIdentifierHash)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.canvas.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Time picker
                        timePicker

                        // Label
                        labelSection

                        // Repeat
                        repeatSection

                        // NFC Binding (only if enabled globally)
                        if appState.getUpModeEnabled && requiresNFC {
                            nfcBindingSection
                        }

                        // Delete button
                        deleteButton
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.xl)
                    .padding(.bottom, DesignSystem.Spacing.spacing3xl)
                }
            }
            .navigationTitle("Edit Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DesignSystem.Colors.canvas, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
                        .foregroundColor(DesignSystem.Colors.primary)
                        .disabled(isSaving || (appState.getUpModeEnabled && requiresNFC && boundTagHash == nil))
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }

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
    
    private var formattedTime: String {
        String(format: "%02d:%02d", hour, minute)
    }

    private var timePicker: some View {
        Card(padding: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(formattedTime)
                    .font(DesignSystem.Font.preferred(size: 64, weight: .bold, relativeTo: .largeTitle))
                    .monospacedDigit()
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .frame(height: 80)

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

    private var deleteButton: some View {
        DestructivePillButton("Delete alarm", icon: "trash") {
            deleteAlarm()
        }
    }
    
    private func saveChanges() {
        isSaving = true
        
        // Update entity
        alarm.hour = hour
        alarm.minute = minute
        alarm.label = label
        alarm.repeatDays = repeatDays
        alarm.snoozePolicy = snoozePolicy
        alarm.requiresNFC = requiresNFC
        alarm.tagIdentifierHash = boundTagHash
        alarm.update()
        
        Task {
            // Reschedule if enabled
            if alarm.isEnabled {
                // Cancel old alarm
                if let oldId = alarm.systemAlarmId {
                    try? alarmService.cancelAlarm(id: oldId)
                }
                
                // Schedule new
                do {
                    let newId = try await alarmService.scheduleAlarm(for: alarm)
                    alarm.systemAlarmId = newId
                } catch {
                    print("❌ Failed to reschedule: \(error)")
                }
            }
            
            try? modelContext.save()
            dismiss()
        }
    }
    
    private func deleteAlarm() {
        // Cancel system alarm
        if let systemId = alarm.systemAlarmId {
            try? alarmService.cancelAlarm(id: systemId)
        }
        
        modelContext.delete(alarm)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Repeat Day Button

struct RepeatDayButton: View {
    let label: String
    let fullName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: {
            DesignSystem.Haptics.selection()
            action()
        }) {
            Text(label)
                .font(DesignSystem.Font.secondaryBody.weight(.semibold))
                .foregroundColor(isSelected ? DesignSystem.Colors.white : DesignSystem.Colors.textPrimary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.surface)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(fullName), \(isSelected ? "selected" : "not selected")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview {
    AlarmsTab()
        .environmentObject(AppState.shared)
        .modelContainer(for: AlarmEntity.self, inMemory: true)
}
