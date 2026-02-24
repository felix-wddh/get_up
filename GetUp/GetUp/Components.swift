import SwiftUI

// MARK: - Glass Card

/// A Liquid Glass styled card container
struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = DesignSystem.CornerRadius.large
    var padding: CGFloat = DesignSystem.Spacing.lg
    
    init(
        cornerRadius: CGFloat = DesignSystem.CornerRadius.large,
        padding: CGFloat = DesignSystem.Spacing.lg,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        DesignSystem.Colors.glassHighlight,
                                        DesignSystem.Colors.glassBorder.opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
    }
}

// MARK: - Glass Button

/// A Liquid Glass styled button
struct GlassButton: View {
    let title: String
    let icon: String?
    let accessibilityLabel: String?
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary
        case secondary
        case danger
        
        var backgroundColor: Color {
            switch self {
            case .primary: return DesignSystem.Colors.accent
            case .secondary: return .clear
            case .danger: return DesignSystem.Colors.danger
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary: return .black
            case .secondary: return DesignSystem.Colors.textPrimary
            case .danger: return .white
            }
        }
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        accessibilityLabel: String? = nil,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.accessibilityLabel = accessibilityLabel
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            DesignSystem.Haptics.triggerImpact(style == .secondary ? .light : .medium)
            action()
        }) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(DesignSystem.Typography.headline)
            }
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .background(
                Group {
                    if style == .secondary {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                                    .stroke(DesignSystem.Colors.glassBorder)
                            )
                    } else {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                            .fill(style.backgroundColor)
                    }
                }
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(accessibilityLabel ?? title)
    }
}

// MARK: - Link CTA Button

/// A blue CTA box for linking the NFC tag (v1 requirement)
struct LinkCTAButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            DesignSystem.Haptics.triggerImpact(.medium)
            action()
        }) {
            HStack(spacing: DesignSystem.Spacing.lg) {
                // Icon with proper padding and background to avoid "cut off" look
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "sensor.tag.radiowaves.forward.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.1), radius: 2)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Link your GetUp")
                        .font(DesignSystem.Typography.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Securely connect your tag")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body.weight(.bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xlarge)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#007AFF"), Color(hex: "#0051AF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xlarge)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color(hex: "#007AFF").opacity(0.4), radius: 15, y: 10)
            .frame(height: 72)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Button Style

/// A button style that scales down on press for a "liquid" feel
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(DesignSystem.Animation.quick, value: configuration.isPressed)
    }
}

// MARK: - Glow Effect

/// A glowing circle background for emphasis
struct GlowCircle: View {
    let color: Color
    let size: CGFloat
    let blur: CGFloat
    
    init(color: Color = DesignSystem.Colors.accent, size: CGFloat = 200, blur: CGFloat = 60) {
        self.color = color
        self.size = size
        self.blur = blur
    }
    
    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.4), color.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .blur(radius: blur)
    }
}

// MARK: - Status Indicator

/// A small status dot indicator
struct StatusIndicator: View {
    enum Status {
        case active
        case inactive
        case warning
        case error
        
        var color: Color {
            switch self {
            case .active: return DesignSystem.Colors.success
            case .inactive: return DesignSystem.Colors.textTertiary
            case .warning: return DesignSystem.Colors.warning
            case .error: return DesignSystem.Colors.danger
            }
        }
    }
    
    let status: Status
    let size: CGFloat
    
    init(_ status: Status, size: CGFloat = 8) {
        self.status = status
        self.size = size
    }
    
    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .fill(status.color.opacity(0.5))
                    .frame(width: size * 2, height: size * 2)
                    .blur(radius: size / 2)
            )
    }
}

// MARK: - Section Header

/// A styled section header
struct SectionHeader: View {
    let title: String
    let icon: String?
    
    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundColor(DesignSystem.Colors.accent)
            }
            Text(title)
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .textCase(.uppercase)
                .tracking(1)
            
            Spacer()
        }
    }
}

// MARK: - Icon Button

/// A circular icon button with glass effect
struct IconButton: View {
    let icon: String
    let size: CGFloat
    let accessibilityLabel: String?
    let action: () -> Void
    
    init(_ icon: String, size: CGFloat = 44, accessibilityLabel: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            DesignSystem.Haptics.triggerImpact(.light)
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Circle()
                                .stroke(DesignSystem.Colors.glassBorder)
                        )
                )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(accessibilityLabel ?? "Icon button")
    }
}

// MARK: - User Guidance Card

/// A card explaining how to use GetUp
struct UserGuidanceCard: View {
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text("How to get started")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    GuidanceRow(number: 1, text: "Get a GetUp NFC Tag and place it >3m from your bed.")
                    GuidanceRow(number: 2, text: "Open GetUp → “Link your GetUp” and hold your iPhone near the tag.")
                    GuidanceRow(number: 3, text: "Create your first GetUp alarm and turn GetUp Mode ON. Done.")
                }
            }
        }
    }
}

private struct GuidanceRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
            Text("\(number)")
                .font(DesignSystem.Typography.caption)
                .bold()
                .foregroundColor(.black)
                .frame(width: 18, height: 18)
                .background(Circle().fill(DesignSystem.Colors.accent))
            
            Text(text)
                .font(DesignSystem.Typography.subheadline)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Previews

#Preview("Glass Card") {
    ZStack {
        DesignSystem.Colors.background.ignoresSafeArea()
        
        GlassCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Glass Card")
                    .font(DesignSystem.Typography.title3)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                Text("This is a Liquid Glass styled card")
                    .font(DesignSystem.Typography.body)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
            }
        }
        .padding()
    }
}

#Preview("Buttons") {
    ZStack {
        DesignSystem.Colors.background.ignoresSafeArea()
        
        VStack(spacing: DesignSystem.Spacing.md) {
            GlassButton("Primary Button", icon: "checkmark") {}
            GlassButton("Secondary Button", icon: "xmark", style: .secondary) {}
            GlassButton("Danger Button", icon: "trash", style: .danger) {}
        }
        .padding()
    }
}
