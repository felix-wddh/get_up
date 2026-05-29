import SwiftUI

/// Analytics tab — shows how much time the user has saved by scanning
/// their NFC tag instead of snoozing, how they compare to other GetUp
/// users, and a few playful "what you could've done with that time"
/// insights. Everything here is mock data today; the real data layer
/// (scan times, dismiss latency, user cohorts) ships later.
struct AnalyticsTab: View {
    @EnvironmentObject private var appState: AppState

    // MARK: - Mock data

    /// Total hours reclaimed since first GetUp morning.
    private let savedHours: Int = 27
    private let savedMinutes: Int = 14
    /// Average time from alarm fire → tag scan in seconds.
    private let avgScanToday: String = "38s"
    private let avgScanWeek: String = "42s"
    private let avgScanAllTime: String = "47s"
    /// Percentile rank — lower = better.
    private let percentileRank: Int = 12
    private let beatPercentage: Int = 88

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.canvas.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        heroSavedCard
                        scanTimesCard
                        percentileCard
                        insightsSection
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.md)
                    // Clearance for the floating tab bar.
                    .padding(.bottom, 120)
                }
                .hidesTabBarOnScroll($appState.isTabBarHidden)
            }
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(DesignSystem.Colors.canvas, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    SettingsBurgerButton()
                }
            }
        }
    }

    // MARK: - Hero: total time saved

    private var heroSavedCard: some View {
        HeroCard {
            VStack(spacing: DesignSystem.Spacing.md) {
                Text("TIME SAVED IN YOUR LIFE")
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .tracking(1.4)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(savedHours)")
                        .font(.system(size: 88, weight: .heavy, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.primary)
                        .tracking(-4)
                    Text("h")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.primary)
                        .offset(y: -8)
                    Text("\(savedMinutes)")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.primary)
                        .tracking(-1)
                        .padding(.leading, 4)
                    Text("m")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.primary)
                        .offset(y: -4)
                }

                Text("Versus the average sleep-in. Every morning you scan, you save your future self real minutes.")
                    .font(DesignSystem.Font.secondaryBody)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Scan times — today / week / all time

    private var scanTimesCard: some View {
        Card {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack {
                    Text("Time to scan")
                        .font(DesignSystem.Font.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    Spacer()
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundColor(DesignSystem.Colors.primary)
                }

                HStack(spacing: DesignSystem.Spacing.md) {
                    scanColumn(value: avgScanToday, label: "Today")
                    Rectangle()
                        .fill(DesignSystem.Colors.divider)
                        .frame(width: 1, height: 44)
                    scanColumn(value: avgScanWeek, label: "This week")
                    Rectangle()
                        .fill(DesignSystem.Colors.divider)
                        .frame(width: 1, height: 44)
                    scanColumn(value: avgScanAllTime, label: "All-time")
                }
            }
        }
    }

    private func scanColumn(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .tracking(-1)
            Text(LocalizedStringKey(label))
                .font(DesignSystem.Font.caption)
                .foregroundColor(DesignSystem.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Percentile / leaderboard comparison

    private var percentileCard: some View {
        Card {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    TintedIconContainer(
                        "trophy.fill",
                        size: 48,
                        tint: Color(hex: "#FF8A3D").opacity(0.15),
                        foreground: Color(hex: "#FF8A3D")
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Top \(percentileRank)% of GetUp users")
                            .font(DesignSystem.Font.headline)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Text("Faster than \(beatPercentage)% of users this week.")
                            .font(DesignSystem.Font.secondaryBody)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                    }
                    Spacer(minLength: 0)
                }

                percentileBar(progress: Double(beatPercentage) / 100.0)

                HStack {
                    Text("Slowest")
                        .font(DesignSystem.Font.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                    Spacer()
                    Text("Fastest")
                        .font(DesignSystem.Font.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                }
            }
        }
    }

    /// A horizontal progress strip with a small marker showing where the
    /// user sits relative to the population.
    private func percentileBar(progress: Double) -> some View {
        GeometryReader { proxy in
            let clamped = max(0.04, min(0.96, progress))
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DesignSystem.Colors.surface)
                    .frame(height: 10)

                Capsule()
                    .fill(DesignSystem.Colors.primary)
                    .frame(width: proxy.size.width * clamped, height: 10)

                // "You are here" marker
                Circle()
                    .fill(DesignSystem.Colors.white)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Circle()
                            .stroke(DesignSystem.Colors.primary, lineWidth: 4)
                    )
                    .designShadow(.card)
                    .offset(x: proxy.size.width * clamped - 9)
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 22)
    }

    // MARK: - Insights — playful comparisons

    private var insightsSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                SectionHeader("What you could've done with that time")
                Spacer()
            }

            InsightCard(
                icon: "book.fill",
                accent: Color(hex: "#8B5CF6"),   // violet
                title: "Read 3 Harry Potter books",
                detail: "27 hours is roughly enough to finish books 1, 2, and 3 cover-to-cover."
            )

            InsightCard(
                icon: "cup.and.saucer.fill",
                accent: Color(hex: "#FF8A3D"),   // orange
                title: "162 mornings of coffee",
                detail: "Brewing and actually enjoying a cup takes ~10 minutes. You reclaimed 162 of them."
            )

            InsightCard(
                icon: "film.fill",
                accent: Color(hex: "#14B8A6"),   // teal
                title: "Watched 13 movies",
                detail: "27 hours is a 13-movie marathon. Or one Lord of the Rings extended trilogy with snack breaks."
            )

            InsightCard(
                icon: "figure.run",
                accent: Color(hex: "#F43F5E"),   // rose
                title: "Ran an extra 130 km",
                detail: "At a steady 5 min/km pace, you could have run roughly 3 marathons in the time you saved."
            )
        }
    }
}

// MARK: - Insight Card

/// A simple horizontal card: tinted accent icon container on the left,
/// title + body copy on the right. Used in the Analytics tab to compare
/// time-saved to relatable real-world activities.
struct InsightCard: View {
    let icon: String
    let accent: Color
    let title: String
    let detail: String

    var body: some View {
        Card {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                TintedIconContainer(
                    icon,
                    size: 48,
                    tint: accent.opacity(0.15),
                    foreground: accent
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(LocalizedStringKey(title))
                        .font(DesignSystem.Font.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    Text(LocalizedStringKey(detail))
                        .font(DesignSystem.Font.secondaryBody)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    AnalyticsTab()
        .environmentObject(AppState.shared)
}
