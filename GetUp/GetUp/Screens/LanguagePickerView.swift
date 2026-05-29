import SwiftUI

/// Five-row language selector. Used in onboarding step 0 and as a Settings
/// section so users can switch language any time. Each row shows the flag,
/// the language name written in its own language (so users find their
/// language even if the rest of the UI is currently in another), and a
/// checkmark when active. Writes through to `AppState.selectedLanguage`
/// which drives the root view's `.environment(\.locale, …)` injection.
struct LanguagePickerView: View {
    @EnvironmentObject private var appState: AppState

    /// Supported languages, in display order. The label is intentionally in
    /// the language itself (endonym) so it stays recognizable regardless
    /// of which UI language is currently active.
    static let supported: [Language] = [
        .init(code: "en", flag: "🇬🇧", endonym: "English"),
        .init(code: "de", flag: "🇩🇪", endonym: "Deutsch"),
        .init(code: "es", flag: "🇪🇸", endonym: "Español"),
        .init(code: "it", flag: "🇮🇹", endonym: "Italiano"),
        .init(code: "fr", flag: "🇫🇷", endonym: "Français"),
    ]

    struct Language: Identifiable, Hashable {
        let code: String
        let flag: String
        let endonym: String
        var id: String { code }
    }

    var body: some View {
        Card(padding: DesignSystem.Spacing.xs) {
            VStack(spacing: 0) {
                ForEach(Array(Self.supported.enumerated()), id: \.element.id) { index, lang in
                    languageRow(lang)
                    if index < Self.supported.count - 1 {
                        Rectangle()
                            .fill(DesignSystem.Colors.divider)
                            .frame(height: 1)
                            .padding(.leading, 56)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func languageRow(_ lang: Language) -> some View {
        let isSelected = appState.selectedLanguage == lang.code

        Button {
            DesignSystem.Haptics.selection()
            appState.selectedLanguage = lang.code
        } label: {
            HStack(spacing: DesignSystem.Spacing.md) {
                Text(lang.flag)
                    .font(.system(size: 26))
                    .frame(width: 32)

                Text(lang.endonym)
                    .font(DesignSystem.Font.headline)
                    .foregroundColor(DesignSystem.Colors.textPrimary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(lang.endonym)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    ZStack {
        DesignSystem.Colors.canvas.ignoresSafeArea()
        LanguagePickerView()
            .padding()
            .environmentObject(AppState.shared)
    }
}
