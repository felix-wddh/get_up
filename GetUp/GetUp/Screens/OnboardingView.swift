import SwiftUI

/// Onboarding View for GetUp
struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentStep = 0
    @State private var boundTagHash: String?
    @State private var isScanning = false
    @State private var alarmTime = Date()

    private var showsNavButton: Bool { currentStep == 0 || currentStep > 2 }

    var body: some View {
        VStack(spacing: 0) {
            if currentStep == 0 {
                // Welcome screen content
                Spacer()

                heroLogo
                    .padding(.bottom, DesignSystem.Spacing.lg)

                Text("Congrats 🎉")
                    .font(DesignSystem.Typography.title1)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .padding(.bottom, DesignSystem.Spacing.md)

                Text("You will get more\nout of your life now!")
                    .font(DesignSystem.Typography.title2)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, DesignSystem.Spacing.xl)

                Spacer()
            } else {
                // Progress bar for steps 1-4
                progressBar

                // TabView for steps 1-4
                TabView(selection: $currentStep) {
                    stepConnectionView.tag(1)
                    stepConfigurationView.tag(2)
                    stepPlacementView.tag(3)
                    stepVerificationView.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            // Navigation button at bottom
            if showsNavButton {
                navigationButton
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
            }
        }
        .background(DesignSystem.Colors.background.ignoresSafeArea())
        .animation(DesignSystem.Animation.smooth, value: currentStep)
    }

    // MARK: - Hero Logo

    private var heroLogo: some View {
        // NOTE: For best results, AppLogoInApp should be a tightly-cropped glyph
        // without pre-baked rounded corners. Current asset has built-in icon styling.
        Image("AppLogoInApp")
            .resizable()
            .scaledToFill()
            .frame(width: 180, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 16, y: 8)
    }

    // MARK: - Progress Bar

    @ViewBuilder
    private var progressBar: some View {
        if currentStep > 0 {
            HStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(1...4, id: \.self) { step in
                    Capsule()
                        .fill(step <= currentStep ? DesignSystem.Colors.accent : DesignSystem.Colors.glassFill)
                        .frame(width: 40, height: 4)
                }
            }
            .padding(.top, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
    }

    // MARK: - Step Views

    private var stepConnectionView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Connection")
                    .font(DesignSystem.Typography.title1)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("First, let's link your GetUp Tag to your iPhone.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.xl)

            if boundTagHash == nil {
                LinkCTAButton {
                    linkTag()
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            } else {
                GlassCard {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(DesignSystem.Colors.success)
                            .font(.title2)
                        Text("Tag successfully linked!")
                            .font(DesignSystem.Typography.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Spacer()
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        nextStep()
                    }
                }
            }

            Spacer()
        }
    }

    private var stepConfigurationView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Configuration")
                    .font(DesignSystem.Typography.title1)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("When do you want to start your day?")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.xl)

            DatePicker("", selection: $alarmTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .scaleEffect(1.2)
                .padding()

            GlassButton("Set Alarm Time") {
                nextStep()
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)

            Spacer()
        }
    }

    private var stepPlacementView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Placement")
                    .font(DesignSystem.Typography.title1)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("Place your tag ~3m away from your bed. You must walk to stop the alarm!")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.xl)

            UserGuidanceCard()
                .padding(.horizontal, DesignSystem.Spacing.xl)

            Spacer()
        }
    }

    private var stepVerificationView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("Verification")
                    .font(DesignSystem.Typography.title1)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("Ready? Let's verify everything works.")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.xl)

            ZStack {
                GlowCircle(color: DesignSystem.Colors.accent, size: 200, blur: 40)
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 80))
                    .foregroundColor(DesignSystem.Colors.accent)
            }

            Text("Test and Start")
                .font(DesignSystem.Typography.headline)
                .foregroundColor(DesignSystem.Colors.textPrimary)

            Spacer()
        }
    }

    // MARK: - Navigation Button

    private var navigationButton: some View {
        Button(action: nextStep) {
            HStack {
                Text(currentStep == 0 ? "Let's Go" : (currentStep == 4 ? "Start Getting Up" : "Next"))
                    .font(DesignSystem.Typography.headline)
                Image(systemName: "arrow.right")
            }
            .foregroundColor(.black)
            .padding(.vertical, DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(DesignSystem.Colors.accent)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Actions

    private func nextStep() {
        withAnimation {
            if currentStep < 4 {
                currentStep += 1
            } else {
                appState.hasCompletedOnboarding = true
            }
        }
    }

    private func linkTag() {
        isScanning = true
        NFCService.shared.startBindingScan { success, _, tagHash in
            isScanning = false
            if success, let hash = tagHash {
                self.boundTagHash = hash
                // Persist tag hash so new alarms auto-bind to this tag
                UserDefaults.standard.set(hash, forKey: "onboardingTagHash")
                DesignSystem.Haptics.triggerNotification(.success)
            } else {
                DesignSystem.Haptics.triggerNotification(.error)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState.shared)
}
