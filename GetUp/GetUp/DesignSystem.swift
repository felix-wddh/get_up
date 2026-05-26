import SwiftUI

// MARK: - Design Tokens
//
// GetUp design system — see docs/design.md for the canonical spec.
// White is the canvas. Black is meaning. Blue is action.
enum DesignSystem {

    // MARK: - Colors

    enum Colors {
        // Primary palette
        static let primary = Color(hex: "#0070E8")
        static let primaryPressed = Color(hex: "#005FC4")
        static let primaryLight = Color(hex: "#EAF4FF")
        static let primarySoft = Color(hex: "#F3F8FF")

        // Neutrals
        static let white = Color(hex: "#FFFFFF")
        static let offWhite = Color(hex: "#FAFAFA")
        static let surface = Color(hex: "#F5F6F7")
        static let border = Color(hex: "#E5E7EB")
        static let divider = Color(hex: "#EEEEEE")
        static let textPrimary = Color(hex: "#111111")
        static let textSecondary = Color(hex: "#4A4A4A")
        static let textTertiary = Color(hex: "#7A7A7A")
        static let textDisabled = Color(hex: "#B8B8B8")

        // Functional
        static let success = Color(hex: "#19A463")
        static let successBg = Color(hex: "#EAF8F1")
        static let warning = Color(hex: "#FF9500")
        static let warningBg = Color(hex: "#FFF4E5")
        static let error = Color(hex: "#E5484D")
        static let errorBg = Color(hex: "#FFF0F0")

        static let backdrop = Color.black.opacity(0.32)

        // MARK: Legacy aliases (kept so existing call sites keep compiling)
        static let background = offWhite
        static let backgroundSecondary = surface
        static let accent = primary
        static let danger = error
        static let glassFill = surface
        static let glassBorder = border
        static let glassHighlight = primaryLight
    }

    // MARK: - Typography
    //
    // Mapped to SF Pro via .system(.style, design: .default).
    // Each style respects iOS Dynamic Type.

    enum Typography {
        static let largeTitle = Font.system(.largeTitle).weight(.bold)
        static let title1 = Font.system(.title).weight(.bold)
        static let title2 = Font.system(.title2).weight(.semibold)
        static let title3 = Font.system(.title3).weight(.semibold)
        static let headline = Font.system(.headline)
        static let body = Font.system(.body)
        static let callout = Font.system(.callout)
        static let subheadline = Font.system(.subheadline)
        static let footnote = Font.system(.footnote)
        static let caption = Font.system(.caption)
        static let caption2 = Font.system(.caption2).weight(.medium)
        static let button = Font.system(.body).weight(.semibold)

        // Alarm countdown — only place that scales independently of Dynamic Type.
        static let countdown = Font.system(size: 96, weight: .light, design: .default)
        static let clockTime = countdown   // legacy alias
    }

    // MARK: - Spacing
    //
    // 4-pt scale per §3. Old aliases (xxs/sm/lg/xl/xxl) point at the new values
    // to keep existing layouts compiling without a sweep.

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

    // MARK: - Corner Radius

    enum CornerRadius {
        static let xs: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 10
        static let large: CGFloat = 14
        static let xlarge: CGFloat = 20
        static let pill: CGFloat = 999
        static let full: CGFloat = 999  // alias
    }

    // MARK: - Motion

    enum Animation {
        static let fast = SwiftUI.Animation.timingCurve(0.2, 0, 0, 1, duration: 0.15)
        static let base = SwiftUI.Animation.timingCurve(0.2, 0, 0, 1, duration: 0.22)
        static let slow = SwiftUI.Animation.timingCurve(0, 0, 0, 1, duration: 0.30)
        static let hero = SwiftUI.Animation.timingCurve(0.2, 0, 0, 1, duration: 0.50)
        static let decelerate = SwiftUI.Animation.timingCurve(0, 0, 0, 1, duration: 0.22)
        static let accelerate = SwiftUI.Animation.timingCurve(0.3, 0, 1, 1, duration: 0.22)

        // Legacy aliases
        static let quick = fast
        static let standard = base
        static let smooth = base
        static let spring = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.7)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
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
