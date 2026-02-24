import SwiftUI

/// GetUp logo - vector recreation matching the official app icon
struct AppLogo: View {
    var size: CGFloat = 200

    var body: some View {
        ZStack(alignment: .center) {
            // Arrow body - drawn first so head appears on top
            ArrowShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#0055DD"), Color(hex: "#007AFF"), Color(hex: "#5AC8FF")],
                        startPoint: .bottomLeading,
                        endPoint: .topTrailing
                    )
                )
                .frame(width: size * 0.85, height: size * 0.85)
                .offset(x: -size * 0.02, y: size * 0.08)

            // Head circle - positioned above arrow
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#5AC8FF"), Color(hex: "#007AFF")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.16, height: size * 0.16)
                .offset(x: size * 0.05, y: -size * 0.28)
        }
        .frame(width: size, height: size)
        .shadow(color: Color(hex: "#007AFF").opacity(0.4), radius: size / 6, y: size / 12)
    }
}

/// Custom shape for the arrow body
private struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height

        var path = Path()

        // Start at bottom-left
        path.move(to: CGPoint(x: w * 0.15, y: h * 0.88))

        // Outer curve - left edge going up
        path.addCurve(
            to: CGPoint(x: w * 0.48, y: h * 0.28),
            control1: CGPoint(x: w * 0.08, y: h * 0.58),
            control2: CGPoint(x: w * 0.25, y: h * 0.32)
        )

        // Arrow tip - pointing to upper right
        path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.34))

        // Inner V notch of arrowhead
        path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.50))

        // Lower prong of arrowhead
        path.addLine(to: CGPoint(x: w * 0.70, y: h * 0.60))

        // Inner curve - right edge going down
        path.addCurve(
            to: CGPoint(x: w * 0.30, y: h * 0.82),
            control1: CGPoint(x: w * 0.50, y: h * 0.62),
            control2: CGPoint(x: w * 0.34, y: h * 0.72)
        )

        path.closeSubpath()
        return path
    }
}

#Preview {
    VStack(spacing: 40) {
        // Dark background (app style)
        ZStack {
            Color(hex: "#051C2C")
            AppLogo(size: 200)
        }
        .frame(width: 300, height: 300)
        .cornerRadius(40)

        // Light background (icon style)
        ZStack {
            Color.white
            AppLogo(size: 200)
        }
        .frame(width: 300, height: 300)
        .cornerRadius(40)
        .shadow(radius: 10)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
