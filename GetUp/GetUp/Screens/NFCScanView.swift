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
            // v2 canvas background with a very soft ambient pulse.
            DesignSystem.Colors.canvas
                .ignoresSafeArea()
                .overlay(
                    DesignSystem.Colors.primarySoft
                        .opacity(ambientPulse ? 0.40 : 0)
                        .ignoresSafeArea()
                        .animation(
                            DesignSystem.Animation.ambientPagePulse.repeatForever(autoreverses: true),
                            value: ambientPulse
                        )
                )

            VStack(spacing: 0) {
                // Small NFC status chip above the headline — matches the
                // reference's top-of-screen indicator that this screen is
                // about NFC.
                nfcStatusChip
                    .padding(.top, DesignSystem.Spacing.spacing3xl + DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.md)

                // Headline + subtitle
                headlineBlock

                Spacer(minLength: DesignSystem.Spacing.lg)

                // Hero scan module — the heart of the screen.
                scanModule

                Spacer(minLength: DesignSystem.Spacing.lg)

                // Primary + secondary CTAs and optional emergency tertiary.
                actionStack
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.bottom, DesignSystem.Spacing.xl)
            }
            .frame(maxWidth: .infinity)

            // Always-visible close button (top-left).
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

    // MARK: - Views (v3 — premium NFC scan layout)

    /// Glowing NFC waves glyph floating above the headline — no card
    /// container, just the icon with a soft radial halo behind it so it
    /// reads as a quiet "this is the NFC moment" anchor.
    private var nfcStatusChip: some View {
        ZStack {
            // Soft radial glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Colors.primary.opacity(0.28),
                            DesignSystem.Colors.primary.opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .blur(radius: 8)

            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(DesignSystem.Colors.primary)
                .rotationEffect(.degrees(-90))
        }
        .frame(height: 60)
        .accessibilityHidden(true)
    }

    private var headlineBlock: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Text(statusTitle)
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(statusSubtitle)
                .font(DesignSystem.Font.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)
        }
    }

    /// Hero scan module — outer ring with a partial blue arc, concentric
    /// ripple waves around a floating NFC card, the live alarm time, and
    /// a phone-top illustration with a dotted arrow pointing at the tag.
    private var scanModule: some View {
        ZStack {
            outerRing
                .frame(width: scanRingDiameter, height: scanRingDiameter)

            // Concentric soft ripples behind the NFC card.
            ripples
                .offset(y: 28)  // sit under the NFC card

            VStack(spacing: DesignSystem.Spacing.sm) {
                alarmPill
                Text(currentTimeString)
                    .font(.system(size: 56, weight: .heavy))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .monospacedDigit()
                    .tracking(-1)
                nfcFloatingCard
            }
        }
        .frame(width: scanRingDiameter, height: scanRingDiameter)
    }

    private var scanRingDiameter: CGFloat { 300 }

    /// Outer ring: a track + a partial blue arc with a round-cap end dot.
    /// The whole ring rotates slowly via `ringRotation` so the dot drifts
    /// like a continuous scan indicator.
    @ViewBuilder
    private var outerRing: some View {
        let lineWidth: CGFloat = 10
        ZStack {
            // Subtle halo around the ring.
            Circle()
                .fill(DesignSystem.Colors.primary.opacity(0.0001))
                .designShadow(.halo)

            // Track
            Circle()
                .stroke(DesignSystem.Colors.primaryLight, lineWidth: lineWidth)

            // Active arc with a gradient from primary → primary-light tip.
            Circle()
                .trim(from: 0, to: arcLength)
                .stroke(
                    AngularGradient(
                        colors: [
                            DesignSystem.Colors.primary.opacity(0.6),
                            DesignSystem.Colors.primary
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
        }
        .rotationEffect(.degrees(ringRotation))
    }

    /// Concentric primary-blue waves behind the NFC card. Mix soft fills
    /// with thin stroked rings to imply expanding scan ripples; the page's
    /// ambient pulse subtly modulates their opacity for an "active" feel.
    private var ripples: some View {
        ZStack {
            // Solid soft washes, biggest → smallest.
            rippleFill(diameter: 250, opacity: 0.08)
            rippleFill(diameter: 200, opacity: 0.12)
            rippleFill(diameter: 155, opacity: 0.18)
            rippleFill(diameter: 115, opacity: 0.28)

            // Thin stroked rings layered on top for the radar feel.
            rippleStroke(diameter: 230, opacity: 0.20)
            rippleStroke(diameter: 180, opacity: 0.28)
            rippleStroke(diameter: 135, opacity: 0.40)
        }
        .allowsHitTesting(false)
        .animation(
            DesignSystem.Animation.ambientRingPulse.repeatForever(autoreverses: true),
            value: ambientPulse
        )
    }

    private func rippleFill(diameter: CGFloat, opacity: Double) -> some View {
        Circle()
            .fill(DesignSystem.Colors.primary.opacity(opacity * (ambientPulse ? 0.85 : 1.0)))
            .frame(width: diameter, height: diameter)
    }

    private func rippleStroke(diameter: CGFloat, opacity: Double) -> some View {
        Circle()
            .stroke(
                DesignSystem.Colors.primary.opacity(opacity * (ambientPulse ? 0.7 : 1.0)),
                lineWidth: 1
            )
            .frame(width: diameter, height: diameter)
    }

    /// Small "Alarm" status pill — bell glyph + label, tinted primaryLight.
    private var alarmPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "bell.fill")
                .font(.system(size: 12, weight: .semibold))
            Text("Alarm")
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(DesignSystem.Colors.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            Capsule().fill(DesignSystem.Colors.primaryLight)
        )
    }

    /// Floating white NFC card with the radio-waves glyph and "NFC" label.
    /// Stronger 3D feel via a subtle top→bottom white→primarySoft gradient
    /// plus a dark "lifted" shadow ledge below it, so it reads as the
    /// strongest visual cue after the alarm time.
    private var nfcFloatingCard: some View {
        VStack(spacing: 4) {
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(DesignSystem.Colors.primary)
                .rotationEffect(.degrees(-90))
            Text("NFC")
                .font(.system(size: 13, weight: .heavy))
                .foregroundColor(DesignSystem.Colors.primary)
                .tracking(0.8)
        }
        .frame(width: 112, height: 112)
        .background(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.white,
                            DesignSystem.Colors.primarySoft.opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .overlay(
            // Subtle highlight along the top edge for the lifted-tile feel.
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.white.opacity(0.9),
                            DesignSystem.Colors.white.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: DesignSystem.Colors.primary.opacity(0.18), radius: 18, x: 0, y: 12)
        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
    }

    /// Action area — the real NFC scan kicks off automatically on appear
    /// and the top-left X handles dismissal, so production renders nothing
    /// here. DEBUG builds keep the Mock NFC Scan helper so the success
    /// flow can be exercised without a physical tag.
    private var actionStack: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            #if DEBUG
            if nfcService.scanState == .scanning {
                SecondaryPillButton("Mock NFC Scan", icon: "testtube.2") {
                    nfcService.mockScan()
                }
            }
            #endif
        }
    }

    private var arcLength: Double {
        switch nfcService.scanState {
        case .idle, .scanning: return 0.65
        case .success:          return 1.0
        case .failed:           return 0.20
        }
    }

    private var arcColor: Color {
        switch nfcService.scanState {
        case .idle, .scanning: return DesignSystem.Colors.primary
        case .success:          return DesignSystem.Colors.success
        case .failed:           return DesignSystem.Colors.error
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
        case .idle, .scanning: return "Scan to stop alarm"
        case .success:          return "You're up."
        case .failed:           return "That's not your tag."
        }
    }

    private var statusSubtitle: String {
        switch nfcService.scanState {
        case .idle, .scanning: return "Hold the top of your iPhone near your NFC tag."
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
