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
                // Headline + subtitle
                headlineBlock
                    .padding(.top, DesignSystem.Spacing.spacing3xl + DesignSystem.Spacing.lg)

                Spacer(minLength: DesignSystem.Spacing.lg)

                // Hero scan module — the heart of the screen.
                scanModule

                Spacer(minLength: DesignSystem.Spacing.lg)

                // Primary + secondary CTAs and optional emergency tertiary.
                actionStack
                    .padding(.horizontal, DesignSystem.Spacing.xl)

                trustLabel
                    .padding(.top, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.md)
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

            // Phone-top with dotted arrow peeking out of the ring's bottom.
            phoneWithArrow
                .offset(y: scanRingDiameter / 2 - 6)
        }
        .frame(width: scanRingDiameter, height: scanRingDiameter + 80)
    }

    private var scanRingDiameter: CGFloat { 280 }

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

            // End-cap dot at the leading edge of the arc, with halo.
            let radius = (scanRingDiameter - lineWidth) / 2
            let dotAngle = (arcLength * 2 * .pi) - .pi / 2
            Circle()
                .fill(arcColor)
                .frame(width: 16, height: 16)
                .overlay(
                    Circle()
                        .stroke(DesignSystem.Colors.white, lineWidth: 3)
                )
                .designShadow(.halo)
                .offset(
                    x: cos(dotAngle) * radius,
                    y: sin(dotAngle) * radius
                )
                .opacity(arcLength > 0 ? 1 : 0)
        }
        .rotationEffect(.degrees(ringRotation))
    }

    /// Three soft concentric circles behind the NFC card, sized to imply
    /// expanding scan waves. They share the page's ambient pulse so the
    /// "active scanning" feel reads even without continuous animation.
    private var ripples: some View {
        ZStack {
            ripple(diameter: 100, opacity: 0.45)
            ripple(diameter: 150, opacity: 0.30)
            ripple(diameter: 200, opacity: 0.15)
        }
        .allowsHitTesting(false)
    }

    private func ripple(diameter: CGFloat, opacity: Double) -> some View {
        Circle()
            .fill(DesignSystem.Colors.primary.opacity(opacity * (ambientPulse ? 0.6 : 1.0)))
            .frame(width: diameter, height: diameter)
            .blendMode(.normal)
            .animation(
                DesignSystem.Animation.ambientRingPulse.repeatForever(autoreverses: true),
                value: ambientPulse
            )
            .opacity(0.2 + opacity * 0.6)
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
    /// Sits on a `shadow/raised` so it reads as the strongest visual cue
    /// after the alarm time.
    private var nfcFloatingCard: some View {
        VStack(spacing: 2) {
            Image(systemName: "dot.radiowaves.left.and.right")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(DesignSystem.Colors.primary)
                .rotationEffect(.degrees(-90))
            Text("NFC")
                .font(.system(size: 11, weight: .heavy))
                .foregroundColor(DesignSystem.Colors.primary)
                .tracking(0.8)
        }
        .frame(width: 92, height: 92)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(DesignSystem.Colors.white)
        )
        .designShadow(.raised)
    }

    /// A small phone-top illustration (rounded rectangle with a dynamic
    /// island) with a vertical dotted arrow pointing up at the NFC card.
    private var phoneWithArrow: some View {
        VStack(spacing: 6) {
            // Dotted arrow
            VStack(spacing: 4) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundColor(DesignSystem.Colors.primary)
                ForEach(0..<3, id: \.self) { _ in
                    Circle()
                        .fill(DesignSystem.Colors.primary)
                        .frame(width: 3, height: 3)
                }
            }

            // Phone top (just the upper part — fades into white below).
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(DesignSystem.Colors.textPrimary)
                    .frame(width: 80, height: 40)
                Capsule()
                    .fill(.black)
                    .frame(width: 38, height: 10)
                    .padding(.top, 6)
            }
            .mask(
                LinearGradient(
                    colors: [.black, .black.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .accessibilityHidden(true)
    }

    /// CTAs: a vivid blue gradient "Ready to Scan" primary, a quiet
    /// white "Close" secondary, plus the existing 20-second emergency
    /// bypass exposed only when GetUp Mode is on and a tag is bound.
    private var actionStack: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            #if DEBUG
            if nfcService.scanState == .scanning {
                SecondaryPillButton("Mock NFC Scan", icon: "testtube.2") {
                    nfcService.mockScan()
                }
            }
            #endif

            readyToScanPill

            SecondaryPillButton("Close") {
                cancelScan()
            }

            if appState.getUpModeEnabled && expectedTagHash != nil {
                emergencyStopButton
                    .padding(.top, DesignSystem.Spacing.xs)
            }

            if !NFCService.isAvailable {
                #if DEBUG
                Text("NFC requires full release version / supported signing")
                    .font(DesignSystem.Font.caption)
                    .foregroundColor(DesignSystem.Colors.warning)
                    .multilineTextAlignment(.center)
                #else
                Text("NFC is not available on this device")
                    .font(DesignSystem.Font.caption)
                    .foregroundColor(DesignSystem.Colors.warning)
                    .multilineTextAlignment(.center)
                #endif
            }
        }
    }

    /// Primary "Ready to Scan" CTA — gradient pill, leading NFC icon, soft
    /// blue glow. Tapping (re)starts NFC verification.
    private var readyToScanPill: some View {
        Button(action: {
            DesignSystem.Haptics.triggerImpact(.medium)
            startVerification()
        }) {
            HStack(spacing: 10) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 17, weight: .bold))
                    .rotationEffect(.degrees(-90))
                Text("Ready to Scan")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(DesignSystem.Colors.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "#3D9BFF"),
                                DesignSystem.Colors.primary,
                                DesignSystem.Colors.primaryPressed
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .shadow(color: DesignSystem.Colors.primary.opacity(0.35), radius: 18, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Ready to scan")
    }

    private var trustLabel: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(DesignSystem.Colors.primary)
            Text("Secure · Private · Local Only")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textTertiary)
                .tracking(0.4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
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
