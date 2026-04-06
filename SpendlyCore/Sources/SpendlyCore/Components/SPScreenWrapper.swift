import SwiftUI

public struct SPScreenWrapper<Content: View>: View {
    private let theme: SpendlyTheme
    private let content: () -> Content

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var sizeClass

    public init(
        theme: SpendlyTheme = .blueprint,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.theme = theme
        self.content = content
    }

    public var body: some View {
        ZStack {
            theme.backgroundColor(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                content()
                    .padding(.horizontal, sizeClass == .regular ? AdaptiveSpacing.lg : SpendlySpacing.lg)
                    .padding(.top, SpendlySpacing.sm)
                    .padding(.bottom, SpendlySpacing.xxxl)
            }
        }
        .environment(\.spendlyTheme, theme)
    }
}

// MARK: - Preview

#Preview {
    SPScreenWrapper(theme: .blueprint) {
        VStack(spacing: SpendlySpacing.lg) {
            SPCard {
                Text("Blueprint Screen")
                    .font(SpendlyFont.headline())
            }
            SPCard {
                Text("Another Card")
                    .font(SpendlyFont.body())
            }
        }
    }
}
