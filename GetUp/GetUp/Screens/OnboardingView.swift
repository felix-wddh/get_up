import SwiftUI

/// Four-page onboarding for GetUp — v2 visual language.
///
/// Pages, in order:
///   1. Welcome — hero logo + the GetUp promise.
///   2. Mission — short personal note from Felix & Georg explaining why.
///   3. Connect NFC tag — primary CTA to link the tag, "Skip for now"
///      ghost button so users without a tag can still complete onboarding.
///   4. Set up your alarm — copy explaining how alarms work in-app,
///      plus the "Finish" button that drops the user onto the home screen.
///
/// The Welcome page is the implicit "intro" — it doesn't show a progress
/// bar. Pages 2–4 share a 3-step progress indicator across the top.
struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState

    @State private var currentStep: Int = 0
    @State private var boundTagHash: String?
    @State private var isScanning: Bool = false

    /// Total number of "counted" steps after the welcome page (used by
    /// the progress bar). Welcome itself sits outside this count.
    private let countedSteps = 3

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if currentStep == 0 {
                pageWelcome
            } else {
                progressBar

                Group {
                    switch currentStep {
                    case 1: pageMission
                    case 2: pageConnect
                    case 3: pageAlarmSetup
                    default: EmptyView()
                    }
                }
            }

            bottomCTAs
        }
        .background(DesignSystem.Colors.canvas.ignoresSafeArea())
        .animation(DesignSystem.Animation.base, value: currentStep)
    }

    // MARK: - Top bar (back chevron)

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

    // MARK: - Progress bar (shown on steps 1–3)

    @ViewBuilder
    private var progressBar: some View {
        if currentStep > 0 {
            HStack(spacing: DesignSystem.Spacing.xs) {
                ForEach(1...countedSteps, id: \.self) { step in
                    Capsule()
                        .fill(step <= currentStep
                              ? DesignSystem.Colors.primary
                              : DesignSystem.Colors.primaryLight)
                        .frame(width: 32, height: 4)
                }
            }
            .padding(.top, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.md)
        }
    }

    // MARK: - Hero logo

    /// The lifted welcome-page logo: a primarySoft tile with `shadow/raised`
    /// and a soft radial halo behind, so the brand mark reads as a contained
    /// element with depth rather than a sticker on the canvas.
    private var heroLogo: some View {
        ZStack {
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

    // MARK: - Page 1: Welcome

    private var pageWelcome: some View {
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

    // MARK: - Page 2: Mission (Felix & Georg)

    /// Full-bleed mission page. The founders photo fills the top half of
    /// the screen edge-to-edge and dissolves softly into the canvas via a
    /// gradient overlay, so the photo's blue background continues into
    /// the page color without a visible seam. Title + copy sit below.
    private var pageMission: some View {
        VStack(spacing: 0) {
            foundersPhoto
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("From Felix & Georg")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.leading)

                Text("We're two people who could never trust ourselves to actually get up. Every snooze button felt like a tiny betrayal.")
                    .font(DesignSystem.Font.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("So we built GetUp — a clean, simple way to make mornings easier. Once your feet hit the floor, the day starts.")
                    .font(DesignSystem.Font.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.top, DesignSystem.Spacing.md)

            Spacer(minLength: 0)
        }
    }

    /// Full-bleed founders photo. Fills the screen width, scaled to fill,
    /// then masked with a soft top→bottom gradient that fades the lower
    /// edge into the canvas so the image's blue background continues
    /// seamlessly into the page color underneath the title.
    private var foundersPhoto: some View {
        Image("FoundersPhoto")
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 380)
            .clipped()
            .overlay(alignment: .bottom) {
                // Bottom fade into canvas — kills the seam between photo
                // and the title area.
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.canvas.opacity(0),
                        DesignSystem.Colors.canvas
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 90)
            }
            .accessibilityLabel("Felix and Georg, GetUp founders")
    }

    // MARK: - Page 3: Connect NFC tag

    private var pageConnect: some View {
        VStack(spacing: 0) {
            Spacer(minLength: DesignSystem.Spacing.lg)

            nfcHeroIcon
                .padding(.bottom, DesignSystem.Spacing.xl)

            Text("Connect your tag")
                .font(DesignSystem.Font.largeTitle)
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.bottom, DesignSystem.Spacing.md)

            Text("Pair your physical GetUp tag once.\nWe'll use it to know when you've\nactually walked to it.")
                .font(DesignSystem.Font.body)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xl)

            if boundTagHash == nil {
                LinkCTAButton {
                    linkTag()
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

    /// Lifted hero tile holding a large NFC glyph — mirrors the welcome
    /// page's logo treatment so the Connect step reads as a real "moment",
    /// not just a button.
    private var nfcHeroIcon: some View {
        ZStack {
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

            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.radius2xl)
                .fill(DesignSystem.Colors.primarySoft)
                .frame(width: 192, height: 192)
                .designShadow(.raised)

            Image(systemName: "sensor.tag.radiowaves.forward.fill")
                .font(.system(size: 88, weight: .regular))
                .foregroundColor(DesignSystem.Colors.primary)
        }
        .frame(width: 320, height: 240)
        .accessibilityHidden(true)
    }

    // MARK: - Page 4: Set up alarm

    private var pageAlarmSetup: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Spacer()

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Set up your alarm")
                    .font(DesignSystem.Font.largeTitle)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text("On the home screen, tap Add alarm to pick your wake time. We'll handle the rest — when it rings, walk to your tag.")
                    .font(DesignSystem.Font.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignSystem.Spacing.xl)

            Card {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    setupRow(
                        number: 1,
                        title: "Tap Add alarm",
                        subtitle: "From the home screen."
                    )
                    Rectangle()
                        .fill(DesignSystem.Colors.divider)
                        .frame(height: 1)
                    setupRow(
                        number: 2,
                        title: "Pick a time",
                        subtitle: "Whenever you want to wake up."
                    )
                    Rectangle()
                        .fill(DesignSystem.Colors.divider)
                        .frame(height: 1)
                    setupRow(
                        number: 3,
                        title: "Sleep tight",
                        subtitle: "When it rings, walk to your tag."
                    )
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)

            Spacer()
        }
    }

    private func setupRow(number: Int, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            Text("\(number)")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(DesignSystem.Colors.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(DesignSystem.Colors.primary))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Font.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Text(subtitle)
                    .font(DesignSystem.Font.secondaryBody)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
            Spacer()
        }
    }

    // MARK: - Bottom CTAs

    /// Renders the primary action + optional secondary (skip / account)
    /// for each page. Page 3 (Connect) intentionally hides the bottom
    /// primary since its action lives inside the screen via `LinkCTAButton`.
    @ViewBuilder
    private var bottomCTAs: some View {
        switch currentStep {
        case 0:
            // Welcome — start the flow.
            VStack(spacing: 0) {
                PrimaryPillButton("Get started", icon: "arrow.right", action: nextStep)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xl)

        case 1:
            // Mission — single primary to continue.
            VStack(spacing: 0) {
                PrimaryPillButton("Continue", icon: "arrow.right", action: nextStep)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xl)

        case 2:
            // Connect — primary action is inside the screen (LinkCTAButton).
            // Bottom slot only carries the skip ghost while no tag is linked.
            if boundTagHash == nil {
                VStack(spacing: 0) {
                    GhostButton("Skip for now", action: skipStep)
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xl)
            } else {
                Color.clear
                    .frame(height: 1)
                    .padding(.bottom, DesignSystem.Spacing.xl)
            }

        case 3:
            // Setup alarm — Finish lands the user on the home screen.
            VStack(spacing: 0) {
                PrimaryPillButton("Finish", action: finishOnboarding)
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xl)

        default:
            EmptyView()
        }
    }

    // MARK: - Actions

    private func nextStep() {
        withAnimation {
            if currentStep < countedSteps {
                currentStep += 1
            } else {
                finishOnboarding()
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

    /// Skip the current setup step. Currently only the Connect NFC step
    /// surfaces a skip button — users without a tag can still complete
    /// onboarding and link a tag later from the alarm editor.
    private func skipStep() {
        DesignSystem.Haptics.selection()
        nextStep()
    }

    private func finishOnboarding() {
        DesignSystem.Haptics.triggerNotification(.success)
        appState.hasCompletedOnboarding = true
    }

    private func linkTag() {
        isScanning = true
        NFCService.shared.startBindingScan { success, _, tagHash in
            isScanning = false
            if success, let hash = tagHash {
                self.boundTagHash = hash
                // Persist tag hash so new alarms auto-bind to this tag.
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
