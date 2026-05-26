import SwiftUI

// MARK: - Design Tokens (v2)
//
// GetUp design system — see docs/design.md for the canonical spec.
// v2 visual language: soft blue-gray canvas, pure-white cards with soft halo
// shadows, fully-rounded pill CTAs, and a signature circular progress ring.
//
// Legacy token names (e.g. `Colors.background`, `Spacing.xxs`,
// `CornerRadius.large`, `Animation.smooth`) are preserved as deprecated
// aliases so existing call sites keep compiling during the transition.
enum DesignSystem {

    // MARK: - Colors

    enum Colors {
        // Primary palette
        static let primary = Color(hex: "#0070E8")
        static let primaryPressed = Color(hex: "#005FC4")
        static let primaryLight = Color(hex: "#EAF4FF")
        static let primarySoft = Color(hex: "#F4F8FF")

        // Neutrals
        static let white = Color(hex: "#FFFFFF")
        static let canvas = Color(hex: "#EEF2F8")     // v2 page background
        static let offWhite = Color(hex: "#FAFBFC")
        static let surface = Color(hex: "#F5F7FA")
        static let border = Color(hex: "#E6EAF0")
        static let divider = Color(hex: "#EEF1F5")
        static let textPrimary = Color(hex: "#111111")
        static let textSecondary = Color(hex: "#5B6573")
        static let textTertiary = Color(hex: "#8A94A3")
        static let textDisabled = Color(hex: "#B8C0CC")

        // Functional
        static let success = Color(hex: "#18A957")
        static let successBg = Color(hex: "#E8F7EF")
        static let warning = Color(hex: "#FF9F0A")
        static let warningBg = Color(hex: "#FFF4E0")
        static let error = Color(hex: "#E5484D")
        static let errorBg = Color(hex: "#FFEEEF")

        // Accent badges — only valid inside small tinted icon containers.
        static let accentOrange = Color(hex: "#FF8A3D")
        static let accentViolet = Color(hex: "#8B5CF6")
        static let accentTeal = Color(hex: "#14B8A6")
        static let accentRose = Color(hex: "#F43F5E")

        static let backdrop = Color.black.opacity(0.32)

        // Floating-chrome glass edge highlight.
        static let glassEdge = Color.white.opacity(0.6)

        // MARK: Legacy aliases (kept so existing call sites keep compiling)
        static let background = canvas              // v1 used offWhite; v2 page bg is canvas
        static let backgroundSecondary = surface
        static let accent = primary
        static let danger = error
        static let glassFill = surface
        static let glassBorder = border
        static let glassHighlight = primaryLight
    }

    // MARK: - Typography
    //
    // The spec calls for Inter (and Inter Tight for the countdown). We use
    // SF Pro via `.system(...)` today; the `DesignSystem.Font` namespace is
    // shaped so we can swap to Inter without touching call sites.
    //
    // TODO: bundle Inter TTFs (Regular/Medium/Semibold/Bold) and Inter Tight
    //       (Semibold/Bold), register via Info.plist `UIAppFonts`, then point
    //       `Font.preferred(...)` at `Font.custom("Inter", size:relativeTo:)`
    //       so Dynamic Type still applies.

    enum Font {
        /// Preferred font for a token. Always returns SF Pro today; once Inter
        /// is bundled, swap this implementation to fall back to SF Pro only
        /// when the custom face fails to register.
        static func preferred(size: CGFloat,
                              weight: SwiftUI.Font.Weight,
                              relativeTo style: SwiftUI.Font.TextStyle,
                              design: SwiftUI.Font.Design = .default) -> SwiftUI.Font {
            // Future: Font.custom("Inter", size: size, relativeTo: style).weight(weight)
            return .system(size: size, weight: weight, design: design)
        }

        // v2 type scale (semantic).
        static let largeTitle      = preferred(size: 34, weight: .bold,     relativeTo: .largeTitle)
        static let screenTitle     = preferred(size: 28, weight: .bold,     relativeTo: .title)
        static let sectionHeader   = preferred(size: 20, weight: .semibold, relativeTo: .title3)
        static let headline        = preferred(size: 17, weight: .semibold, relativeTo: .headline)
        static let body            = preferred(size: 17, weight: .regular,  relativeTo: .body)
        static let secondaryBody   = preferred(size: 15, weight: .regular,  relativeTo: .subheadline)
        static let caption         = preferred(size: 13, weight: .regular,  relativeTo: .footnote)
        static let microCaption    = preferred(size: 11, weight: .medium,   relativeTo: .caption2)
        static let button          = preferred(size: 17, weight: .semibold, relativeTo: .headline)

        // Ring value — large bold number inside the progress ring.
        static let ringValue       = SwiftUI.Font.system(size: 56, weight: .bold, design: .default)
            .monospacedDigit()

        // Alarm countdown — the only token that does NOT scale with Dynamic Type.
        // (Spec: scales with the viewport.)
        static let countdown       = SwiftUI.Font.system(size: 96, weight: .semibold, design: .default)
            .monospacedDigit()
    }

    /// Legacy typography facade. New code should use `DesignSystem.Font.*`.
    enum Typography {
        static let largeTitle    = Font.largeTitle
        static let title1        = Font.screenTitle
        static let title2        = Font.preferred(size: 22, weight: .bold,     relativeTo: .title2)
        static let title3        = Font.sectionHeader
        static let headline      = Font.headline
        static let body          = Font.body
        static let callout       = Font.preferred(size: 16, weight: .regular,  relativeTo: .callout)
        static let subheadline   = Font.secondaryBody
        static let footnote      = Font.caption
        static let caption       = Font.caption
        static let caption2      = Font.microCaption
        static let button        = Font.button
        static let countdown     = Font.countdown
        static let clockTime     = countdown   // legacy alias
    }

    // MARK: - Spacing
    //
    // 4-pt scale per §5. Legacy aliases preserved.

    enum Spacing {
        static let spacing2xs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let spacing2xl: CGFloat = 32
        static let spacing3xl: CGFloat = 40
        static let spacing4xl: CGFloat = 56

        // Legacy aliases
        static let xxs: CGFloat = spacing2xs
        static let xxl: CGFloat = spacing2xl
    }

    // MARK: - Corner Radius (v2)
    //
    // New tokens follow the spec's xs/sm/md/lg/xl/2xl/full ladder. The old
    // xs/small/medium/large/xlarge/pill names are preserved as deprecated
    // aliases pointing at the closest new value.

    enum CornerRadius {
        // v2 scale
        static let xs: CGFloat   = 6
        static let sm: CGFloat   = 12
        static let md: CGFloat   = 16
        static let lg: CGFloat   = 20
        static let xl: CGFloat   = 24
        static let radius2xl: CGFloat = 28
        static let full: CGFloat = 999

        // Legacy aliases (v1 -> closest v2 value)
        static let small: CGFloat   = sm          // was 8 → 12
        static let medium: CGFloat  = md          // was 10 → 16
        static let large: CGFloat   = lg          // was 14 → 20
        static let xlarge: CGFloat  = xl          // was 20 → 24
        static let pill: CGFloat    = full
    }

    // MARK: - Shadows
    //
    // v2 shadows are large, soft, and cool-toned. Apply as a chain of
    // `.shadow(...)` modifiers via the `View.designShadow(...)` extension
    // below — that's the recommended call site for components.

    enum Shadow {
        case none
        case card
        case raised
        case sheet
        case glass
        case halo

        /// The cool blue-gray shadow tint used across the system.
        static var tint: Color { Color(red: 31/255, green: 77/255, blue: 138/255) }
        /// The saturated primary-blue tint used for the halo glow.
        static var haloTint: Color { Color(red: 0/255, green: 112/255, blue: 232/255) }
    }

    // MARK: - Motion

    enum Animation {
        static let fast       = SwiftUI.Animation.timingCurve(0.2, 0, 0, 1, duration: 0.15)
        static let base       = SwiftUI.Animation.timingCurve(0.2, 0, 0, 1, duration: 0.22)
        static let slow       = SwiftUI.Animation.timingCurve(0, 0, 0, 1, duration: 0.30)
        static let hero       = SwiftUI.Animation.timingCurve(0.2, 0, 0, 1, duration: 0.50)
        static let decelerate = SwiftUI.Animation.timingCurve(0, 0, 0, 1, duration: 0.22)
        static let accelerate = SwiftUI.Animation.timingCurve(0.3, 0, 1, 1, duration: 0.22)

        // Ambient loops (page pulse, ring rotation, halo pulse).
        static let ambientPagePulse  = SwiftUI.Animation.easeInOut(duration: 2.4)
        static let ambientRingPulse  = SwiftUI.Animation.easeInOut(duration: 1.6)
        static let ambientRingSpin   = SwiftUI.Animation.linear(duration: 8.0)

        // Tactile spring used for button press, toggles, capsule slides.
        // Spec: stiffness 380, damping 30 → ≈ response 0.32, dampingFraction 0.78.
        static let spring  = SwiftUI.Animation.spring(response: 0.32, dampingFraction: 0.78)

        // Legacy aliases
        static let quick    = fast
        static let standard = base
        static let smooth   = base
        static let bouncy   = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
        static let ambient  = ambientPagePulse
    }

    // MARK: - Haptics

    enum Haptics {
        static func triggerImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }

        static func triggerNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }

        static func selection() {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Shadow modifier

extension View {
    /// Applies a v2 design-system shadow token. Each token corresponds
    /// directly to the spec's `shadow/*` definitions in §2.4.
    @ViewBuilder
    func designShadow(_ shadow: DesignSystem.Shadow) -> some View {
        switch shadow {
        case .none:
            self
        case .card:
            // 0 4px 24px rgba(31,77,138,0.06), 0 1px 2px rgba(31,77,138,0.04)
            self
                .shadow(color: DesignSystem.Shadow.tint.opacity(0.06), radius: 12, x: 0, y: 4)
                .shadow(color: DesignSystem.Shadow.tint.opacity(0.04), radius: 1,  x: 0, y: 1)
        case .raised:
            // 0 12px 36px rgba(31,77,138,0.10), 0 2px 6px rgba(31,77,138,0.06)
            self
                .shadow(color: DesignSystem.Shadow.tint.opacity(0.10), radius: 18, x: 0, y: 12)
                .shadow(color: DesignSystem.Shadow.tint.opacity(0.06), radius: 3,  x: 0, y: 2)
        case .sheet:
            // 0 -8px 32px rgba(31,77,138,0.08)
            self.shadow(color: DesignSystem.Shadow.tint.opacity(0.08), radius: 16, x: 0, y: -8)
        case .glass:
            // 0 8px 24px rgba(31,77,138,0.08)
            self.shadow(color: DesignSystem.Shadow.tint.opacity(0.08), radius: 12, x: 0, y: 8)
        case .halo:
            // 0 0 64px rgba(0,112,232,0.18)
            self.shadow(color: DesignSystem.Shadow.haloTint.opacity(0.18), radius: 32, x: 0, y: 0)
        }
    }
}
