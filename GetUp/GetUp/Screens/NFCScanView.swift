import SwiftUI
import CoreNFC
import SwiftData

/// Full-screen NFC scan view for alarm unlock — v2 signature screen.
///
/// Canvas background with an ambient pulse, a 280-pt progress ring with a
/// halo glow behind it, current time shown in the countdown font at the
/// ring's center.
struct NFCScanView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    @StateObject private var nfcService = NFCService.shared
    @StateObject private var safetyService = SafetyService.shared

    @State private var expectedTagHash: String?
    @State private var showEmergencyAlert = false
    @State private var isPressingEmergency = false
    @State private var emergencyProgress: CGFloat = 0

    // Live clock for the center countdown display.
    @State private var now = Date()
    private let clockTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // Animation for the emergency progress bar - 20 seconds for high friction
    private let emergencyDuration: Double = 20.0

    // Timer for emergency hold
    @State private var emergencyTimer: Timer?
    @State private var startTime: Date?

    // Timer to track haptic feedback during hold
    @State private var hapticTimer: Timer?

    // Animation state for ambient ring rotation and end-cap pulse.
    @State private var ringRotation: Double = 0
    @State private var ambientPulse: Bool = false

    var body: some View {
        ZStack(alignment: .topLeading) {
            // v2 canvas background.
            DesignSystem.Colors.canvas
                .ignoresSafeArea()
                .overlay(
                    // Soft ambient pulse cued by the secondary tint.
                    DesignSystem.Colors.primarySoft
                        .opacity(ambientPulse ? 0.55 : 0)
                        .ignoresSafeArea()
                        .animation(
                            DesignSystem.Animation.ambientPagePulse.repeatForever(autoreverses: true),
                            value: ambientPulse
                        )
                )

            VStack(spacing: DesignSystem.Spacing.xl) {
                // Top header — calm urgency.
                topHeader
                    .padding(.top, DesignSystem.Spacing.spacing2xl)

                Spacer()

                // Signature progress ring with halo + live time.
                progressRingHero

                Spacer()

                // Action area — emergency stop only.
                actionButtonsView
                    .frame(maxWidth: 360)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xl)

            // Always-visible close button.
            Button(action: cancelScan) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                            .fill(DesignSystem.Colors.white)
                    )
                    .designShadow(.card)
            }
            .accessibilityLabel("Close NFC scan")
            .padding(.leading, DesignSystem.Spacing.md)
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .onAppear {
            loadExpectedTagHash()
            startVerification()
            startAmbientMotion()
        }
        .onDisappear {
            nfcService.reset()
            stopEmergencyTimer()
        }
        .onReceive(clockTimer) { date in
            now = date
        }
        .alert("Emergency Stop", isPresented: $showEmergencyAlert) {
            Button("Stop Alarm", role: .destructive) {
                performEmergencyStop()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Alright sleepyhead, due to regulations you do have a way out here. If your GetUp Tag is broken, you do not find it or you are unable to move, then there is a way. Hold the button for 20 seconds to stop the alarm. Use it wisely sleepyhead!")
        }
    }

    // MARK: - Views

    private var topHeader: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(statusTitle)
                .font(DesignSystem.Font.screenTitle)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text(statusSubtitle)
                .font(DesignSystem.Font.secondaryBody)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
    }

    /// The 280-pt progress ring sitting on a halo. Center shows current
    /// device time using the countdown font.
    private var progressRingHero: some View {
        ZStack {
            // Halo glow behind the ring.
            Circle()
                .fill(DesignSystem.Colors.primary.opacity(0.0001)) // keep tappable bounds tidy
                .frame(width: 280, height: 280)
                .designShadow(.halo)

            // Animated stroked ring — the arc itself is the indeterminate
            // indicator: we sweep it continuously while scanning.
            indeterminateRing
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(ringRotation))

            // Center label: current time + 'Alarm' watermark.
            VStack(spacing: 4) {
                Text(currentTimeString)
                    .font(DesignSystem.Font.countdown)
                    .monospacedDigit()
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .minimumScaleFactor(0.6)

                Text(centerSubcaption)
                    .font(DesignSystem.Font.secondaryBody)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .frame(width: 280, height: 280)
    }

    /// Continuous ring: a 14-px stroke track with a primary-blue arc that
    /// rotates. While scanning, the arc covers ~33% so the rotation is
    /// visibly indeterminate; on success/failure we replace it with a full
    /// (success) or interrupted (failure) state.
    @ViewBuilder
    private var indeterminateRing: some View {
        let lineWidth: CGFloat = 14

        ZStack {
            Circle()
                .stroke(DesignSystem.Colors.primaryLight, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: arcLength)
                .stroke(
                    arcColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // End-cap dot — `arcLength` * 360 degrees ahead of the top.
            let radius = (280 - lineWidth) / 2
            let dotAngle = (arcLength * 2 * .pi) - .pi / 2
            Circle()
                .fill(arcColor)
                .frame(width: 14, height: 14)
                .designShadow(.halo)
                .offset(
                    x: cos(dotAngle) * radius,
                    y: sin(dotAngle) * radius
                )
                .opacity(arcLength > 0 ? 1 : 0)
        }
    }

    private var arcLength: Double {
        switch nfcService.scanState {
        case .idle, .scanning: return 0.33
        case .success:          return 1.0
        case .failed:           return 0.15
        }
    }

    private var arcColor: Color {
        switch nfcService.scanState {
        case .idle, .scanning: return DesignSystem.Colors.primary
        case .success:          return DesignSystem.Colors.success
        case .failed:           return DesignSystem.Colors.error
        }
    }

    private var actionButtonsView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Mock Scan button for DEBUG
            #if DEBUG
            if nfcService.scanState == .scanning {
                SecondaryPillButton("Mock NFC Scan", icon: "testtube.2") {
                    nfcService.mockScan()
                }
            }
            #endif

            // Retry button (if failed)
            if nfcService.scanState == .failed {
                PrimaryPillButton("Try again", icon: "arrow.clockwise") {
                    startVerification()
                }
            }

            // Emergency Stop / Cancel
            VStack(spacing: DesignSystem.Spacing.sm) {
                if !NFCService.isAvailable {
                    #if DEBUG
                    Text("NFC requires full release version /\nsupported signing")
                        .font(DesignSystem.Font.caption)
                        .foregroundColor(DesignSystem.Colors.warning)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                    #else
                    Text("NFC is not available on this device")
                        .font(DesignSystem.Font.caption)
                        .foregroundColor(DesignSystem.Colors.warning)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                    #endif
                }

                if appState.getUpModeEnabled && expectedTagHash != nil {
                    // Emergency bypass button with long press
                    emergencyStopButton
                } else {
                    // Regular cancel if GetUp mode is off or no tag bound
                    SecondaryPillButton(NFCService.isAvailable ? "Dismiss" : "Close") {
                        cancelScan()
                    }
                }
            }
        }
    }

    private var emergencyStopButton: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background pill
                    Capsule()
                        .fill(DesignSystem.Colors.white)
                        .overlay(
                            Capsule()
                                .stroke(DesignSystem.Colors.border, lineWidth: 1)
                        )
                        .frame(height: 56)

                    // Progress fill — error tint, since this is the bypass.
                    Capsule()
                        .fill(DesignSystem.Colors.error.opacity(0.18))
                        .frame(width: max(0, emergencyProgress * geometry.size.width), height: 56)

                    // Label
                    HStack {
                        Spacer()
                        Text(isPressingEmergency
                             ? "Hold for \(Int(ceil(max(0, emergencyDuration - abs(startTime?.timeIntervalSinceNow ?? 0)))))s…"
                             : "Emergency stop")
                            .font(DesignSystem.Font.button)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Spacer()
                    }
                }
            }
            .frame(height: 56)
            .contentShape(Capsule())
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressingEmergency {
                            startEmergencyTimer()
                        }
                    }
                    .onEnded { _ in
                        stopEmergencyTimer()
                    }
            )

            Text("Continuous 20-second hold required")
                .font(DesignSystem.Font.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
    }

    // MARK: - Computed Properties

    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: now)
    }

    private var centerSubcaption: String {
        switch nfcService.scanState {
        case .idle, .scanning: return "Alarm"
        case .success:          return "Unlocked"
        case .failed:           return "Try again"
        }
    }

    private var statusTitle: String {
        switch nfcService.scanState {
        case .idle, .scanning: return "Go scan your tag."
        case .success:          return "You're up."
        case .failed:           return "That's not your tag."
        }
    }

    private var statusSubtitle: String {
        switch nfcService.scanState {
        case .idle, .scanning: return "Hold the top of your phone against the tag."
        case .success:          return "Have a good morning."
        case .failed:           return nfcService.errorMessage ?? "Try again."
        }
    }

    // MARK: - Actions

    private func startAmbientMotion() {
        // Continuous ring rotation per §9.4.
        withAnimation(DesignSystem.Animation.ambientRingSpin.repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
        // Ambient page pulse.
        ambientPulse = true
    }

    private func loadExpectedTagHash() {
        guard let alarmIdString = appState.pendingAlarmId,
              let alarmId = UUID(uuidString: alarmIdString) else {
            print("⚠️ No pending alarm ID")
            return
        }

        let descriptor = FetchDescriptor<AlarmEntity>(
            predicate: #Predicate { alarm in
                alarm.systemAlarmId == alarmId
            }
        )

        do {
            let results = try modelContext.fetch(descriptor)
            expectedTagHash = results.first?.tagIdentifierHash
            print("🔐 Expected tag hash: \(expectedTagHash?.prefix(16) ?? "none")")
        } catch {
            print("❌ Failed to fetch alarm: \(error)")
        }
    }

    private func startVerification() {
        guard let hash = expectedTagHash else {
            // No tag bound - just verify any tag was scanned
            nfcService.startBindingScan { success, tagId, tagHash in
                handleScanResult(success: success, tagId: tagId, tagHash: tagHash)
            }
            return
        }

        nfcService.startVerificationScan(expectedHash: hash) { success, tagId, tagHash in
            handleScanResult(success: success, tagId: tagId, tagHash: tagHash)
        }
    }

    private func handleScanResult(success: Bool, tagId: String?, tagHash: String?) {
        if success {
            print("✅ Tag verified successfully")

            // Dismiss after short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                appState.completeScan()
            }
        }
    }

    private func cancelScan() {
        nfcService.stopScanning()
        appState.completeScan()
    }

    // MARK: - Emergency Bypass

    private func startEmergencyTimer() {
        isPressingEmergency = true
        startTime = Date()

        withAnimation(.linear(duration: emergencyDuration)) {
            emergencyProgress = 1.0
        }

        // Setup haptic feedback every second
        hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DesignSystem.Haptics.triggerImpact(.light)
        }

        // Completion timer
        emergencyTimer = Timer.scheduledTimer(withTimeInterval: emergencyDuration, repeats: false) { _ in
            Task { @MainActor in
                if self.isPressingEmergency {
                    self.showEmergencyAlert = true
                    self.stopEmergencyTimer()
                }
            }
        }
    }

    private func stopEmergencyTimer() {
        isPressingEmergency = false
        startTime = nil

        emergencyTimer?.invalidate()
        emergencyTimer = nil

        hapticTimer?.invalidate()
        hapticTimer = nil

        withAnimation(.easeOut(duration: 0.2)) {
            emergencyProgress = 0
        }
    }

    private func performEmergencyStop() {
        safetyService.registerBypass()
        nfcService.stopScanning()
        appState.completeScan()
    }
}

// MARK: - Preview

#Preview {
    NFCScanView()
        .environmentObject(AppState.shared)
        .modelContainer(for: AlarmEntity.self, inMemory: true)
}
