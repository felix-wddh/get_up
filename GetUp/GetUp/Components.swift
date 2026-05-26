import SwiftUI

// =============================================================================
// MARK: - v2 Components
// =============================================================================
//
// All new code should reach for these. The legacy GlassCard/GlassButton/etc.
// further down render with the v2 visual language so they remain visually
// consistent for any call sites that haven't been migrated yet.
//
// See docs/design.md §6 for the spec.

// MARK: - Card (v2)

/// The default container of the v2 system. White surface, 24-px radius,
/// no border, soft halo shadow.
struct Card<Content: View>: View {
    private let cornerRadius: CGFloat
    private let padding: CGFloat
    private let background: Color
    private let content: Content

    init(
        cornerRadius: CGFloat = DesignSystem.CornerRadius.xl,
        padding: CGFloat = DesignSystem.Spacing.lg,
        background: Color = DesignSystem.Colors.white,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.background = background
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(background)
            )
            .designShadow(.card)
    }
}

// MARK: - HeroCard (v2)

/// Hero card: tinted `primarySoft` background, 28-px radius, 24-px padding.
/// Used for the home progress ring host, NFC setup, and success surfaces.
struct HeroCard<Content: View>: View {
    private let content: Content
    private let padding: CGFloat

    init(
        padding: CGFloat = DesignSystem.Spacing.xl,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.radius2xl, style: .continuous)
                    .fill(DesignSystem.Colors.primarySoft)
            )
            .designShadow(.card)
    }
}

// MARK: - Primary Pill Button (v2)

/// Signature primary action. 56-pt pill, primary-blue fill, `shadow/raised`.
struct PrimaryPillButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void

    init(_ title: String,
         icon: String? = nil,
         isLoading: Bool = false,
         isEnabled: Bool = true,
         action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button {
            DesignSystem.Haptics.triggerImpact(.medium)
            action()
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(DesignSystem.Colors.white)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    Text(title)
                        .font(DesignSystem.Font.button)
                }
            }
            .foregroundColor(isEnabled ? DesignSystem.Colors.white : DesignSystem.Colors.textDisabled)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 28)
            .background(
                Capsule(style: .continuous)
                    .fill(isEnabled ? DesignSystem.Colors.primary : DesignSystem.Colors.surface)
            )
        }
        .buttonStyle(PrimaryPillButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled || isLoading)
        .accessibilityLabel(title)
    }
}

/// Press behavior for `PrimaryPillButton`: scale 0.98, swap raised -> card.
private struct PrimaryPillButtonStyle: SwiftUI.ButtonStyle {
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .designShadow(isEnabled ? (configuration.isPressed ? .card : .raised) : .none)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Secondary Pill Button (v2)

/// White pill with thin border. Used alongside a primary action.
struct SecondaryPillButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button {
            DesignSystem.Haptics.triggerImpact(.light)
            action()
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(DesignSystem.Font.button)
            }
            .foregroundColor(DesignSystem.Colors.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 28)
            .background(
                Capsule(style: .continuous)
                    .fill(DesignSystem.Colors.white)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(title)
    }
}

// MARK: - Ghost Button (v2)

/// Inline action with low weight. No background, primary-blue label.
struct GhostButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button {
            DesignSystem.Haptics.selection()
            action()
        } label: {
            Text(title)
                .font(DesignSystem.Font.button)
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .accessibilityLabel(title)
    }
}

// MARK: - Tinted Icon Container (v2)

/// The signature visual idiom: a soft tinted rounded-square housing an icon.
///
/// Default shape is a 16-pt rounded-square — pass `.circle` for the
/// rounded-full variant used on accent badges per §4.4.
struct TintedIconContainer: View {
    enum ContainerShape { case rounded, circle }

    let icon: String
    let size: CGFloat
    let shape: ContainerShape
    let tint: Color
    let foreground: Color

    init(_ icon: String,
         size: CGFloat = 48,
         shape: ContainerShape = .rounded,
         tint: Color = DesignSystem.Colors.primaryLight,
         foreground: Color = DesignSystem.Colors.primary) {
        self.icon = icon
        self.size = size
        self.shape = shape
        self.tint = tint
        self.foreground = foreground
    }

    var body: some View {
        ZStack {
            background
            Image(systemName: icon)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(foreground)
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private var background: some View {
        switch shape {
        case .rounded:
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                .fill(tint)
        case .circle:
            Circle()
                .fill(tint)
        }
    }
}

// MARK: - Progress Ring (v2 signature component)

/// The hero of the home and active-alarm screens. Tracks progress 0…1, with
/// a 14-px stroke, round caps, an end-cap blue dot with halo, and a center
/// label composed of a large value + small caption.
struct ProgressRing: View {
    let progress: Double          // 0.0 ... 1.0
    let diameter: CGFloat
    let value: String
    let caption: String?
    let lineWidth: CGFloat
    let showTickDots: Bool
    let isPulsing: Bool

    init(progress: Double,
         diameter: CGFloat = 240,
         value: String,
         caption: String? = nil,
         lineWidth: CGFloat = 14,
         showTickDots: Bool = true,
         isPulsing: Bool = false) {
        self.progress = max(0, min(1, progress))
        self.diameter = diameter
        self.value = value
        self.caption = caption
        self.lineWidth = lineWidth
        self.showTickDots = showTickDots
        self.isPulsing = isPulsing
    }

    @State private var pulse: Bool = false

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(DesignSystem.Colors.primaryLight, lineWidth: lineWidth)
                .frame(width: diameter, height: diameter)

            // Tick dots at 25/50/75% (optional)
            if showTickDots {
                ForEach([0.25, 0.5, 0.75], id: \.self) { fraction in
                    tickDot(at: fraction)
                }
            }

            // Progress arc
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    DesignSystem.Colors.primary,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: diameter, height: diameter)

            // End cap dot — sits at the tip of the arc, with halo shadow.
            endCapDot

            // Center label
            VStack(spacing: 4) {
                Text(value)
                    .font(DesignSystem.Font.ringValue)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                if let caption = caption {
                    Text(caption)
                        .font(DesignSystem.Font.secondaryBody)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .frame(width: diameter, height: diameter)
        .onAppear {
            guard isPulsing else { return }
            withAnimation(DesignSystem.Animation.ambientRingPulse.repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private var endCapDot: some View {
        let radius = diameter / 2
        let angleRad = (progress * 2 * .pi) - .pi / 2  // start at -90°
        let dotSize: CGFloat = 14 * (isPulsing && pulse ? 1.25 : 1.0)
        return Circle()
            .fill(DesignSystem.Colors.primary)
            .frame(width: dotSize, height: dotSize)
            .designShadow(.halo)
            .offset(
                x: cos(angleRad) * radius,
                y: sin(angleRad) * radius
            )
            .opacity(progress > 0 ? 1 : 0)
            .animation(DesignSystem.Animation.base, value: progress)
    }

    private func tickDot(at fraction: Double) -> some View {
        let radius = diameter / 2
        let angleRad = (fraction * 2 * .pi) - .pi / 2
        return Circle()
            .fill(DesignSystem.Colors.primary.opacity(0.4))
            .frame(width: 4, height: 4)
            .offset(
                x: cos(angleRad) * radius,
                y: sin(angleRad) * radius
            )
    }
}

// MARK: - Floating Tab Bar (v2)

/// Custom floating pill tab bar. Sits 16-pt above the bottom safe area,
/// `ultraThinMaterial` background, glass-edge highlight, soft shadow.
struct FloatingTabBar<Tab: Hashable>: View {
    struct Item: Identifiable {
        let id: Tab
        let icon: String
        let label: String
    }

    @Binding var selection: Tab
    let items: [Item]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                tabButton(for: item)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, 10)
        .frame(height: 64)
        .background(
            Capsule(style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .background(
            // White wash so the chrome stays luminous on top of the canvas.
            Capsule(style: .continuous)
                .fill(DesignSystem.Colors.white.opacity(0.72))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(DesignSystem.Colors.glassEdge, lineWidth: 1)
        )
        .designShadow(.glass)
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }

    @ViewBuilder
    private func tabButton(for item: Item) -> some View {
        let isActive = item.id == selection
        Button {
            DesignSystem.Haptics.selection()
            withAnimation(DesignSystem.Animation.base) {
                selection = item.id
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: item.icon)
                    .font(.system(size: 22, weight: .semibold))
                Text(item.label)
                    .font(DesignSystem.Font.microCaption)
            }
            .foregroundColor(isActive ? DesignSystem.Colors.primary : DesignSystem.Colors.textTertiary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isActive ? DesignSystem.Colors.primaryLight : Color.clear)
                    .padding(.horizontal, 4)
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.label)
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

// MARK: - Scroll-to-hide tab bar

/// Drives the floating tab bar's visibility from a scrollable view.
///
/// Watches the host scroll view's content offset via
/// `onScrollGeometryChange`. When the user pulls content upward past a
/// small initial threshold, sets `isHidden = true` so `MainTabView` can
/// slide the bar off-screen. A downward pan brings it back. Tiny
/// movements (jitter, rubber-banding) are ignored.
private struct HidesTabBarOnScroll: ViewModifier {
    @Binding var isHidden: Bool
    @State private var lastOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content.onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.y
        } action: { _, newValue in
            let delta = newValue - lastOffset
            defer { lastOffset = newValue }

            // Ignore micro-movements (jitter) and rubber-banding past top.
            guard abs(delta) > 4 else { return }

            if delta > 0 && newValue > 24 {
                // Content is moving up (user wants to read more below) — hide.
                if !isHidden { isHidden = true }
            } else if delta < 0 {
                // Content is moving down (user pulled back) — reveal.
                if isHidden { isHidden = false }
            }
        }
    }
}

extension View {
    /// Hide the floating tab bar while the user scrolls content upward;
    /// reveal it on the next downward pan. Apply to a `ScrollView`.
    func hidesTabBarOnScroll(_ isHidden: Binding<Bool>) -> some View {
        modifier(HidesTabBarOnScroll(isHidden: isHidden))
    }
}

// MARK: - Streak Card (Duolingo-style, brand blue)

/// A horizontal streak card: large flame icon with the streak count inside,
/// title + subtitle on the right, and a 7-day completion row at the bottom.
/// Uses the GetUp brand blue rather than orange — same visual cadence as
/// Duolingo's streak widget, repurposed for habit-style consistency.
struct StreakCard: View {
    let streakCount: Int
    let title: String
    let subtitle: String
    /// 7 entries, left-to-right, oldest → today.
    let weekDays: [DayEntry]

    struct DayEntry {
        let label: String
        let isCompleted: Bool
        let isToday: Bool
    }

    var body: some View {
        Card {
            VStack(spacing: DesignSystem.Spacing.lg) {
                HStack(alignment: .center, spacing: DesignSystem.Spacing.md) {
                    flameWithNumber

                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(DesignSystem.Font.screenTitle)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        Text(subtitle)
                            .font(DesignSystem.Font.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }

                weekRow
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(streakCount) day streak. \(title). \(subtitle)")
    }

    // MARK: Flame with overlaid count

    private var flameWithNumber: some View {
        ZStack {
            Image(systemName: "flame.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 110)
                .foregroundColor(DesignSystem.Colors.primary)

            Text("\(streakCount)")
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundColor(DesignSystem.Colors.white)
                .offset(y: 10)
        }
        .frame(width: 96, height: 110)
        .accessibilityHidden(true)
    }

    // MARK: Weekly checkmark row

    private var weekRow: some View {
        HStack(spacing: 0) {
            ForEach(0..<weekDays.count, id: \.self) { i in
                let day = weekDays[i]
                VStack(spacing: 8) {
                    Text(day.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(
                            day.isToday
                                ? DesignSystem.Colors.textPrimary
                                : DesignSystem.Colors.textTertiary
                        )

                    ZStack {
                        Circle()
                            .fill(day.isCompleted
                                  ? DesignSystem.Colors.primary
                                  : DesignSystem.Colors.border)
                            .frame(width: 36, height: 36)

                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(
                                day.isCompleted
                                    ? DesignSystem.Colors.white
                                    : DesignSystem.Colors.textTertiary.opacity(0.55)
                            )
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

extension StreakCard {
    /// Build a placeholder 7-day window (oldest → today) where all past days
    /// read as completed and today reads as pending. Uses Duolingo-style
    /// 1–2-letter day labels (M, Tu, W, Th, F, Sa, Su) so each label is
    /// visually distinct without ambiguity.
    static func placeholderWeek(today: Date = Date()) -> [DayEntry] {
        let calendar = Calendar.current
        // weekday: 1=Sun, 2=Mon, 3=Tue, 4=Wed, 5=Thu, 6=Fri, 7=Sat
        let abbrevs = ["Su", "M", "Tu", "W", "Th", "F", "Sa"]
        var entries: [DayEntry] = []

        for offset in (-6...0) {
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            let weekday = calendar.component(.weekday, from: date)
            let label = abbrevs[weekday - 1]
            let isToday = (offset == 0)
            // Placeholder data: past = completed, today = pending.
            entries.append(DayEntry(label: label, isCompleted: !isToday, isToday: isToday))
        }
        return entries
    }
}

// MARK: - Month Calendar Card

/// A single-month calendar card. Renders the month's days in a 6×7 grid
/// with soft warm row backgrounds. Days the user was woken with GetUp get
/// a filled brand-blue badge with white number; other days show the day
/// number in `accent/orange`. Header has prev / next chevrons and a count
/// of GetUp wake-ups within the displayed month.
///
/// Pass a `Set<Date>` of wake dates (normalized to day granularity); the
/// component handles month navigation internally and counts wakes within
/// the currently displayed month.
struct MonthCalendarCard: View {
    let wakeDates: Set<Date>

    @State private var displayedMonth: Date = Date()

    private let calendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1  // Sunday — matches the reference layout
        return cal
    }()

    var body: some View {
        Card(padding: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.md) {
                header
                wakeCountLine
                weekdayHeader
                grid
            }
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Previous month")

            Spacer()

            Text(monthTitle)
                .font(.system(size: 16, weight: .heavy, design: .rounded))
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .tracking(1.2)

            Spacer()

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Next month")
        }
    }

    // MARK: Wake count

    private var wakeCountLine: some View {
        let count = wakeCountForDisplayedMonth
        let monthName = displayedMonth.formatted(.dateTime.month(.wide))
        let isCurrent = calendar.isDate(displayedMonth, equalTo: Date(), toGranularity: .month)
        let suffix = isCurrent ? "this month" : "in \(monthName)"
        return Text("Woken with GetUp \(count) time\(count == 1 ? "" : "s") \(suffix).")
            .font(DesignSystem.Font.secondaryBody)
            .foregroundColor(DesignSystem.Colors.textSecondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    // MARK: Weekday header row

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdayLetters, id: \.self) { letter in
                Text(letter)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.textTertiary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
    }

    private var weekdayLetters: [String] {
        // Sun-first to match the visual reference.
        ["S", "M", "T", "W", "T", "F", "S"]
    }

    // MARK: Day grid (6 rows × 7 cols)

    private var grid: some View {
        VStack(spacing: 6) {
            ForEach(0..<6, id: \.self) { row in
                calendarRow(row: row)
            }
        }
    }

    @ViewBuilder
    private func calendarRow(row: Int) -> some View {
        let days = daysInRow(row)
        let leadingEmpty = days.prefix(while: { $0 == nil }).count
        let trailingEmpty = days.reversed().prefix(while: { $0 == nil }).count
        let occupied = 7 - leadingEmpty - trailingEmpty

        // Row is fully empty when the month is short — skip rendering.
        if occupied > 0 {
            GeometryReader { proxy in
                let cellWidth = proxy.size.width / 7
                ZStack(alignment: .leading) {
                    // Warm cream capsule behind the days that exist in this row.
                    Capsule()
                        .fill(DesignSystem.Colors.warningBg)
                        .frame(
                            width: max(0, CGFloat(occupied) * cellWidth),
                            height: 36
                        )
                        .offset(x: CGFloat(leadingEmpty) * cellWidth)

                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { col in
                            dayCell(day: days[col])
                                .frame(width: cellWidth, height: 36)
                        }
                    }
                }
                .frame(height: 36)
            }
            .frame(height: 36)
        }
    }

    @ViewBuilder
    private func dayCell(day: Date?) -> some View {
        if let date = day {
            let dayNumber = calendar.component(.day, from: date)
            let isWakeDay = wakeDates.contains(where: { calendar.isDate($0, inSameDayAs: date) })

            if isWakeDay {
                ZStack {
                    Circle()
                        .fill(DesignSystem.Colors.primary)
                        .frame(width: 32, height: 32)
                    Text("\(dayNumber)")
                        .font(.system(size: 14, weight: .heavy, design: .rounded))
                        .foregroundColor(DesignSystem.Colors.white)
                }
            } else {
                Text("\(dayNumber)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#FF8A3D"))  // accent/orange
            }
        } else {
            Color.clear
        }
    }

    // MARK: Month math

    private var monthTitle: String {
        displayedMonth
            .formatted(.dateTime.month(.wide).year())
            .uppercased()
    }

    private var wakeCountForDisplayedMonth: Int {
        wakeDates.filter {
            calendar.isDate($0, equalTo: displayedMonth, toGranularity: .month)
        }.count
    }

    /// Returns 7 optional dates for the given row index (0–5). nil entries
    /// represent empty leading/trailing cells outside the displayed month.
    private func daysInRow(_ row: Int) -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else {
            return Array(repeating: nil, count: 7)
        }

        let firstOfMonth = monthInterval.start
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)  // 1=Sun
        let leadingBlanks = firstWeekday - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: firstOfMonth)?.count ?? 30

        var cells: [Date?] = []
        for col in 0..<7 {
            let cellIndex = row * 7 + col
            let dayNumber = cellIndex - leadingBlanks + 1
            if dayNumber < 1 || dayNumber > daysInMonth {
                cells.append(nil)
            } else if let date = calendar.date(byAdding: .day, value: dayNumber - 1, to: firstOfMonth) {
                cells.append(date)
            } else {
                cells.append(nil)
            }
        }
        return cells
    }

    private func previousMonth() {
        DesignSystem.Haptics.selection()
        withAnimation(DesignSystem.Animation.base) {
            if let new = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
                displayedMonth = new
            }
        }
    }

    private func nextMonth() {
        DesignSystem.Haptics.selection()
        withAnimation(DesignSystem.Animation.base) {
            if let new = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
                displayedMonth = new
            }
        }
    }
}

extension MonthCalendarCard {
    /// Placeholder wake-date set covering several days in the current month
    /// so the calendar visually reads correctly until the real habit data
    /// layer ships. Picks roughly every-other-day through today.
    static func placeholderWakeDates(today: Date = Date()) -> Set<Date> {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 1
        guard let monthInterval = cal.dateInterval(of: .month, for: today) else { return [] }

        var set: Set<Date> = []
        let todayDay = cal.component(.day, from: today)
        for offset in 0..<todayDay where offset % 2 == 0 {
            if let date = cal.date(byAdding: .day, value: offset, to: monthInterval.start) {
                set.insert(cal.startOfDay(for: date))
            }
        }
        return set
    }
}

// =============================================================================
// MARK: - Legacy / preserved components (now rendered in v2 language)
// =============================================================================

// MARK: - Glass Card (legacy → renders as v2 Card)

/// Legacy white card container. Internally now uses the v2 `Card` look
/// (no border, soft halo shadow). Kept for binary compatibility with the
/// existing call sites that pass `cornerRadius:` / `padding:`.
struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat
    var padding: CGFloat

    init(
        cornerRadius: CGFloat = DesignSystem.CornerRadius.xl,
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
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(DesignSystem.Colors.white)
            )
            .designShadow(.card)
    }
}

// MARK: - Glass Button (legacy → v2 pill)

/// Legacy `GlassButton` API. Internally renders as a v2 pill so existing call
/// sites pick up the new visual language without code changes.
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
        switch style {
        case .primary:
            PrimaryPillButton(title, icon: icon, action: action)
                .accessibilityLabel(accessibilityLabel ?? title)
        case .secondary:
            SecondaryPillButton(title, icon: icon, action: action)
                .accessibilityLabel(accessibilityLabel ?? title)
        case .danger:
            DestructivePillButton(title, icon: icon, action: action)
                .accessibilityLabel(accessibilityLabel ?? title)
        }
    }
}

// MARK: - Destructive Pill (used by legacy `.danger` style)

struct DestructivePillButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button {
            DesignSystem.Haptics.triggerImpact(.light)
            action()
        } label: {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(DesignSystem.Font.button)
            }
            .foregroundColor(DesignSystem.Colors.error)
            .frame(maxWidth: .infinity, minHeight: 56)
            .padding(.horizontal, 28)
            .background(
                Capsule(style: .continuous)
                    .fill(DesignSystem.Colors.white)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(DesignSystem.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Link CTA Button (preserved)

/// Onboarding-screen CTA used to start linking the NFC tag. Repainted in
/// the v2 visual language: rounded-xl primary surface with soft shadow.
struct LinkCTAButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            DesignSystem.Haptics.triggerImpact(.medium)
            action()
        }) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Tinted icon container repainted with white-on-white tint
                // for primary-blue background contrast.
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 48, height: 48)
                    Image(systemName: "sensor.tag.radiowaves.forward.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Link your GetUp")
                        .font(DesignSystem.Font.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                    Text("Securely connect your tag")
                        .font(DesignSystem.Font.caption)
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                }

                Spacer(minLength: DesignSystem.Spacing.xs)

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.vertical, DesignSystem.Spacing.md)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                    .fill(DesignSystem.Colors.primary)
            )
            .designShadow(.raised)
            .frame(minHeight: 72)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Button Style (legacy press scale)

/// A button style that scales down on press. Preserved for call sites that
/// reach for it directly; primary CTAs use `PrimaryPillButtonStyle` instead.
struct ScaleButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Glow Circle (preserved)

/// Decorative glow disc. Still used by the old time-picker preview area;
/// new code should prefer `shadow/halo` via `designShadow(.halo)`.
struct GlowCircle: View {
    let color: Color
    let size: CGFloat
    let blur: CGFloat

    init(color: Color = DesignSystem.Colors.primary, size: CGFloat = 200, blur: CGFloat = 60) {
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

// MARK: - Status Indicator (preserved)

struct StatusIndicator: View {
    enum Status {
        case active, inactive, warning, error
        var color: Color {
            switch self {
            case .active:   return DesignSystem.Colors.success
            case .inactive: return DesignSystem.Colors.textTertiary
            case .warning:  return DesignSystem.Colors.warning
            case .error:    return DesignSystem.Colors.error
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

// MARK: - Section Header (preserved → v2 styling)

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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(DesignSystem.Colors.primary)
            }
            Text(title)
                .font(DesignSystem.Font.sectionHeader)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            Spacer()
        }
    }
}

// MARK: - Icon Button (preserved → v2 rounded-square)

/// 44×44 utility button. v2 uses a 16-px rounded-square background — not
/// a circle — to match the tinted icon container language.
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
                .font(.system(size: size * 0.42, weight: .semibold))
                .foregroundColor(DesignSystem.Colors.textPrimary)
                .frame(width: size, height: size)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                        .fill(DesignSystem.Colors.white)
                )
                .designShadow(.card)
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel(accessibilityLabel ?? "Icon button")
    }
}

// MARK: - User Guidance Card (preserved)

struct UserGuidanceCard: View {
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    TintedIconContainer("lightbulb.fill", size: 40)
                    Text("How to get started")
                        .font(DesignSystem.Font.headline)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    GuidanceRow(number: 1, text: "Get a GetUp NFC Tag and place it >3m from your bed.")
                    GuidanceRow(number: 2, text: "Open GetUp → \u{201C}Link your GetUp\u{201D} and hold your iPhone near the tag.")
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
                .font(DesignSystem.Font.caption)
                .bold()
                .foregroundColor(DesignSystem.Colors.white)
                .frame(width: 20, height: 20)
                .background(Circle().fill(DesignSystem.Colors.primary))

            Text(text)
                .font(DesignSystem.Font.secondaryBody)
                .foregroundColor(DesignSystem.Colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Previews

#Preview("Cards") {
    ZStack {
        DesignSystem.Colors.canvas.ignoresSafeArea()
        VStack(spacing: DesignSystem.Spacing.md) {
            Card {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Default card")
                        .font(DesignSystem.Font.headline)
                    Text("Used for list rows and grouped content.")
                        .font(DesignSystem.Font.secondaryBody)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            HeroCard {
                VStack(spacing: DesignSystem.Spacing.md) {
                    ProgressRing(progress: 0.72, diameter: 200, value: "47", caption: "on time")
                    Text("12-day streak")
                        .font(DesignSystem.Font.headline)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
    }
}

#Preview("Buttons") {
    ZStack {
        DesignSystem.Colors.canvas.ignoresSafeArea()
        VStack(spacing: DesignSystem.Spacing.md) {
            PrimaryPillButton("Get started", icon: "arrow.right") {}
            SecondaryPillButton("Maybe later") {}
            GhostButton("I already have an account") {}
            DestructivePillButton("Delete alarm", icon: "trash") {}
        }
        .padding()
    }
}
