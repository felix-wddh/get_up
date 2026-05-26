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
    @State private var showingOnboarding = false
    @State private var selectedAlarm: AlarmEntity?
    @State private var authState: AlarmManager.AuthorizationState = .notDetermined
    @State private var showAuthAlert = false
    
    private let alarmService = AlarmService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                DesignSystem.Colors.background
                    .ignoresSafeArea()
                
                // Decorative glow
                VStack {
                    GlowCircle(color: DesignSystem.Colors.accent, size: 300, blur: 100)
                        .offset(y: -100)
                    Spacer()
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Authorization warning if needed
                        if authState == .denied {
                            authWarningCard
                        }
                        
                        // GetUp Mode Toggle
                        getUpModeCard
                        
                        // Onboarding Info Card
                        if !alarms.isEmpty {
                            onboardingInfoCard
                        }
                        
                        // Alarms Section
                        alarmsSection
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.md)
                    .padding(.bottom, 100) // Space for FAB
                }
                
                // Floating Action Button — kept clear of the floating tab bar
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        addAlarmButton
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, 100) // Clear the iOS 26 floating tab bar
                }
            }
            .navigationTitle("GetUp")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(DesignSystem.Colors.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showingCreateAlarm) {
                CreateAlarmSheet()
            }
            .sheet(item: $selectedAlarm) { alarm in
                EditAlarmSheet(alarm: alarm)
            }
            .sheet(isPresented: $showingOnboarding) {
                OnboardingView()
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
    
    // MARK: - Authorization Warning
    
    private var authWarningCard: some View {
        GlassCard {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(DesignSystem.Colors.warning)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Alarms Disabled")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text("Enable in Settings to receive alarms")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                Button("Fix") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.accent)
            }
        }
    }
    
    // MARK: - GetUp Mode Card
    
    private var getUpModeCard: some View {
        GlassCard {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(appState.getUpModeEnabled ? DesignSystem.Colors.accent : DesignSystem.Colors.textTertiary)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(appState.getUpModeEnabled ? .black : .white)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("GetUp Mode")
                        .font(DesignSystem.Typography.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(appState.getUpModeEnabled ? "NFC required to stop alarms" : "Alarms stop normally")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                Spacer()
                
                // Toggle
                Toggle("", isOn: $appState.getUpModeEnabled)
                    .tint(DesignSystem.Colors.accent)
                    .labelsHidden()
            }
        }
    }
    
    // MARK: - Onboarding Info Card
    
    private var onboardingInfoCard: some View {
        Button(action: { showingOnboarding = true }) {
            GlassCard {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(DesignSystem.Colors.accent)
                        .font(.system(size: 20))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("How it works")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Text("Review the 3-step GetUp guide")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private var alarmsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                SectionHeader("Alarms", icon: "alarm.fill")
                Spacer()
                if alarmService.scheduledCount > 0 {
                    Text("\(alarmService.scheduledCount) active")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
            
            if alarms.isEmpty {
                // Empty state
                GlassCard {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "alarm")
                            .font(.system(size: 48, weight: .light))
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        Text("No alarms yet")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                        
                        Text("Tap + to create your first GetUp alarm")
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xl)
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
        Button(action: handleAddAlarm) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(DesignSystem.Colors.accent)
                        .shadow(color: DesignSystem.Colors.accent.opacity(0.5), radius: 12, y: 4)
                )
        }
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
            GlassCard(padding: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Time
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(String(format: "%d:%02d", alarm.time12Hour.hour, alarm.time12Hour.minute))
                                .font(.system(size: 36, weight: .light, design: .rounded))
                                .foregroundColor(alarm.isEnabled ? DesignSystem.Colors.textPrimary : DesignSystem.Colors.textTertiary)
                            
                            Text(alarm.time12Hour.isPM ? "PM" : "AM")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(alarm.isEnabled ? DesignSystem.Colors.textSecondary : DesignSystem.Colors.textTertiary)
                        }
                        
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            if !alarm.label.isEmpty {
                                Text(alarm.label)
                                    .font(DesignSystem.Typography.subheadline)
                                    .foregroundColor(DesignSystem.Colors.textSecondary)
                            }
                            
                            if alarm.repeatDays.isRepeating {
                                Text(alarm.repeatDays.displayText)
                                    .font(DesignSystem.Typography.caption)
                                    .foregroundColor(DesignSystem.Colors.textTertiary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // NFC indicator
                    if alarm.requiresNFC {
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 16))
                            .foregroundColor(alarm.isEnabled ? DesignSystem.Colors.accent : DesignSystem.Colors.textTertiary)
                    }
                    
                    // Toggle
                    Toggle("", isOn: Binding(
                        get: { alarm.isEnabled },
                        set: { _ in onToggle() }
                    ))
                    .tint(DesignSystem.Colors.accent)
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
                DesignSystem.Colors.background.ignoresSafeArea()
                
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
                }
            }
            .navigationTitle("Edit Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(DesignSystem.Colors.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
                        .foregroundColor(DesignSystem.Colors.accent)
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
        GlassCard(padding: DesignSystem.Spacing.md) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                ZStack {
                    GlowCircle(color: DesignSystem.Colors.accent, size: 160, blur: 60)
                        .opacity(0.45)

                    Text(formattedTime)
                        .font(.system(size: 72, weight: .thin, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .monospacedDigit()
                }
                .frame(height: 80)

                HStack(spacing: DesignSystem.Spacing.xs) {
                    Picker("Hour", selection: $hour) {
                        ForEach(0..<24, id: \.self) { h in
                            Text(String(format: "%02d", h))
                                .font(DesignSystem.Typography.title3)
                                .tag(h)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80)

                    Text(":")
                        .font(DesignSystem.Typography.title2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)

                    Picker("Minute", selection: $minute) {
                        ForEach(0..<60, id: \.self) { m in
                            Text(String(format: "%02d", m))
                                .font(DesignSystem.Typography.title3)
                                .tag(m)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 80)
                }
                .frame(height: 110)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
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
    
    private var deleteButton: some View {
        GlassButton("Delete Alarm", icon: "trash", style: .danger) {
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
        Button(action: action) {
            Text(label)
                .font(DesignSystem.Typography.headline)
                .foregroundColor(isSelected ? .black : DesignSystem.Colors.textSecondary)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ? DesignSystem.Colors.accent : DesignSystem.Colors.glassFill)
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
