import SwiftUI

/// Onboarding for GetUp — v2 visual language.
///
/// Welcome slide: large title hero, body copy, primary pill at the bottom,
/// ghost button below. Subsequent steps reuse the same canvas + card style.
struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentStep = 0
    @State private var boundTagHash: String?
    @State private var isScanning = false
    @State private var alarmTime = Date()

    private var showsNavButton: Bool { currentStep == 0 || currentStep > 2 }

    var body: some View {
        VStack(spacing: 0) {
            // Top bar — back chevron visible on steps 1-4
            topBar

            if currentStep == 0 {
                welcomeScreen
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

            // Navigation actions at bottom
            if showsNavButton {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    PrimaryPillButton(
                        currentStep == 0 ? "Get started" :
                        (currentStep == 4 ? "Start getting up" : "Next"),
                        icon: currentStep == 4 ? nil : "arrow.right",
                        action: nextStep
                    )

                    if currentStep == 0 {
                        GhostButton("I already have an account") {
                            // Placeholder — wired up when account sync ships.
                            DesignSystem.Haptics.selection()
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
        .background(DesignSystem.Colors.canvas.ignoresSafeArea())
        .animation(DesignSystem.Animation.base, value: currentStep)
    }

    // MARK: - Welcome screen

    private var welcomeScreen: some View {
        VStack(spacing: 0) {
            Spacer(minLength: DesignSystem.Spacing.spacing2xl)

            heroLogo
                .padding(.bottom, DesignSystem.Spacing.spacing2xl)

            Text("Get out of bed.\nActually.")
                .font(DesignSystem.Font.largeTitle)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom, DesignSystem.Spacing.md)

            Text("GetUp only turns off when you walk\nyour phone to a tag in another room.")
                .font(DesignSystem.Font.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, DesignSystem.Spacing.xl)

            Spacer(minLength: DesignSystem.Spacing.spacing2xl)
        }
    }

    // MARK: - Top Bar (back navigation)

    @ViewBuilder
    private var topBar: some View {
        HStack {
            if currentStep > 0 {
                Button(action: previousStep) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                }
                .accessibilityLabel("Back")
            } else {
                Color.clear.frame(width: 44, height: 44)
            }
            Spacer()
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.top, DesignSystem.Spacing.xs)
    }

    // MARK: - Hero Logo
    //
    // The logo sits on a lifted "tile" — a soft primarySoft tinted surface
    // with a halo glow behind, so it reads as a contained brand mark with
    // depth rather than a sticker on the canvas. Matches the App-Cleaner-
    // style hero treatment from the v2 reference imagery.

    private var heroLogo: some View {
        ZStack {
            // Soft radial glow behind the tile — adds the "light source" feel.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            DesignSystem.Colors.primary.opacity(0.18),
                            DesignSystem.Colors.primary.opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 160
                    )
                )
                .frame(width: 320, height: 320)
                .blur(radius: 12)

            // Lifted tile holding the logo.
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.radius2xl)
                .fill(DesignSystem.Colors.primarySoft)
                .frame(width: 192, height: 192)
                .designShadow(.raised)

            Image("AppLogoInApp")
                .resizable()
                .scaledToFit()
                .frame(width: 152, height: 152)
        }
        .frame(width: 320, height: 240)
        .accessibilityHidden(true)
    }

    // MARK: - Progress Bar

    @ViewBuilder
    private var progressBar: some View {
        if currentStep > 0 {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(1...4, id: \.self) { step in
                    Capsule()
                        .fill(step <= currentStep ? DesignSystem.Colors.primary : DesignSystem.Colors.primaryLight)
                        .frame(width: 32, height: 4)
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

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Connection")
                    .font(DesignSystem.Font.screenTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("First, let's link your GetUp Tag to your iPhone.")
                    .font(DesignSystem.Font.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.xl)

            if boundTagHash == nil {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    LinkCTAButton {
                        linkTag()
                    }

                    GhostButton("Skip for now") {
                        skipStep()
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            } else {
                HeroCard {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        TintedIconContainer(
                            "checkmark",
                            size: 48,
                            tint: DesignSystem.Colors.successBg,
                            foreground: DesignSystem.Colors.success
                        )
                        Text("Tag successfully linked.")
                            .font(DesignSystem.Font.headline)
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

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Configuration")
                    .font(DesignSystem.Font.screenTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("When do you want to start your day?")
                    .font(DesignSystem.Font.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.xl)

            Card {
                DatePicker("", selection: $alarmTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)

            VStack(spacing: DesignSystem.Spacing.sm) {
                PrimaryPillButton("Set alarm time") {
                    nextStep()
                }

                GhostButton("Skip for now") {
                    skipStep()
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)

            Spacer()
        }
    }

    private var stepPlacementView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Placement")
                    .font(DesignSystem.Font.screenTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("Place your tag ~3m away from your bed. You must walk to stop the alarm.")
                    .font(DesignSystem.Font.body)
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

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Verification")
                    .font(DesignSystem.Font.screenTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Text("Ready? Let's verify everything works.")
                    .font(DesignSystem.Font.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.xl)

            HeroCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    TintedIconContainer("checkmark.seal.fill", size: 64)
                        .designShadow(.halo)

                    Text("Test and start")
                        .font(DesignSystem.Font.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)

            Spacer()
        }
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

    private func previousStep() {
        DesignSystem.Haptics.selection()
        withAnimation {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }

    /// Skip the current setup step. Used by the ghost "Skip for now" buttons
    /// on steps 1 (Connection) and 2 (Configuration) so the user can finish
    /// onboarding even if they don't have a tag yet or don't want to set an
    /// alarm time right now. Behaves like `nextStep` but plays a softer
    /// haptic to signal that the step was intentionally bypassed.
    private func skipStep() {
        DesignSystem.Haptics.selection()
        nextStep()
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
