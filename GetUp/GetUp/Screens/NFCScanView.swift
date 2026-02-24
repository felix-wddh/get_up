import SwiftUI
import CoreNFC
import SwiftData

/// Full-screen NFC scan view for alarm unlock
struct NFCScanView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var nfcService = NFCService.shared
    @StateObject private var safetyService = SafetyService.shared
    
    @State private var expectedTagHash: String?
    @State private var showEmergencyAlert = false
    @State private var isPressingEmergency = false
    @State private var emergencyProgress: CGFloat = 0
    
    // Animation for the emergency progress bar - updated to 20 seconds for high friction
    private let emergencyDuration: Double = 20.0
    
    // Timer for emergency hold
    @State private var emergencyTimer: Timer?
    @State private var startTime: Date?
    
    // Timer to track haptic feedback during hold
    @State private var hapticTimer: Timer?
    
    var body: some View {
        ZStack {
            // Background with blur
            DesignSystem.Colors.background
                .ignoresSafeArea()
            
            // Glass overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            VStack(spacing: DesignSystem.Spacing.xxl) {
                Spacer()
                
                // Animated NFC icon
                nfcIconView
                    .frame(maxWidth: 240) // Narrower
                
                // Status text
                statusView
                    .frame(maxWidth: 300) // Centered and narrow
                
                Spacer()
                
                // Action buttons
                actionButtonsView
            }
            .frame(maxWidth: .infinity) // Center content
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xxl)
        }
        .onAppear {
            loadExpectedTagHash()
            startVerification()
        }
        .onDisappear {
            nfcService.reset()
            stopEmergencyTimer()
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
    
    private var nfcIconView: some View {
        ZStack {
            // Outer glow
            GlowCircle(color: statusColor, size: 280, blur: 60)
            
            // Inner circle with icon
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 160, height: 160)
                .overlay(
                    Circle()
                        .stroke(DesignSystem.Colors.glassBorder, lineWidth: 1)
                )
                .overlay(
                    Image(systemName: nfcIcon)
                        .font(.system(size: 60, weight: .light))
                        .foregroundColor(statusColor)
                        .symbolEffect(.pulse, options: .repeating, isActive: nfcService.isScanning)
                )
        }
    }
    
    private var statusView: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            Text(statusTitle)
                .font(DesignSystem.Typography.title2)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            Text(statusSubtitle)
                .font(DesignSystem.Typography.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            // Mock Scan button for DEBUG
            #if DEBUG
            if nfcService.scanState == .scanning {
                GlassButton("Mock NFC Scan", icon: "testtube.2", style: .secondary) {
                    nfcService.mockScan()
                }
            }
            #endif
            
            // Retry button (if failed)
            if nfcService.scanState == .failed {
                GlassButton("Try Again", icon: "arrow.clockwise", style: .primary) {
                    startVerification()
                }
            }
            
            // Emergency Stop / Cancel
            VStack(spacing: DesignSystem.Spacing.sm) {
                if !NFCService.isAvailable {
                    #if DEBUG
                    Text("NFC requires full release version /\nsupported signing")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.warning)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 8)
                    #else
                    Text("NFC is not available on this device")
                        .font(DesignSystem.Typography.caption)
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
                    GlassButton(NFCService.isAvailable ? "Dismiss" : "Close", style: .secondary) {
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
                    // Background
                    Capsule()
                        .fill(DesignSystem.Colors.glassFill)
                        .frame(height: 56)
                        .overlay(
                            Capsule()
                                .stroke(DesignSystem.Colors.glassBorder, lineWidth: 1)
                        )
                    
                    // Progress bar
                    Capsule()
                        .fill(DesignSystem.Colors.danger.opacity(0.3))
                        .frame(width: max(0, emergencyProgress * geometry.size.width), height: 56)
                    
                    // Text
                    HStack {
                        Spacer()
                        Text(isPressingEmergency ? "Hold for \(Int(ceil(max(0, emergencyDuration - abs(startTime?.timeIntervalSinceNow ?? 0)))))s..." : "Emergency Stop")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Spacer()
                    }
                }
            }
            .frame(height: 56)
            .contentShape(Rectangle())
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
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.textTertiary)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
    }
    
    // MARK: - Computed Properties
    
    private var nfcIcon: String {
        switch nfcService.scanState {
        case .idle, .scanning: return "wave.3.right"
        case .success: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch nfcService.scanState {
        case .idle, .scanning: return DesignSystem.Colors.accent
        case .success: return DesignSystem.Colors.success
        case .failed: return DesignSystem.Colors.danger
        }
    }
    
    private var statusTitle: String {
        switch nfcService.scanState {
        case .idle: return "Scan to Stop Alarm"
        case .scanning: return "Scanning..."
        case .success: return "Alarm Stopped!"
        case .failed: return "Wrong Tag"
        }
    }
    
    private var statusSubtitle: String {
        switch nfcService.scanState {
        case .idle: return "Hold your NFC tag near the top of your iPhone"
        case .scanning: return "Hold your NFC tag near the top of your iPhone"
        case .success: return "Great job getting up! Have a wonderful day."
        case .failed: return nfcService.errorMessage ?? "Please scan your registered GetUp tag"
        }
    }
    
    // MARK: - Actions
    
    private func loadExpectedTagHash() {
        guard let alarmIdString = appState.pendingAlarmId,
              let alarmId = UUID(uuidString: alarmIdString) else {
            print("⚠️ No pending alarm ID")
            return
        }
        
        // Find the alarm entity with this system ID
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
