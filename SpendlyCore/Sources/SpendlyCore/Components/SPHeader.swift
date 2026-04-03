import SwiftUI

public struct SPHeader<Trailing: View>: View {
    private let title: String
    private let showBackButton: Bool
    private let backAction: (() -> Void)?
    private let trailing: () -> Trailing

    @Environment(\.colorScheme) private var colorScheme

    public init(
        title: String,
        showBackButton: Bool = false,
        backAction: (() -> Void)? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.showBackButton = showBackButton
        self.backAction = backAction
        self.trailing = trailing
    }

    public var body: some View {
        HStack(spacing: SpendlySpacing.md) {
            if showBackButton {
                Button {
                    backAction?()
                } label: {
                    Image(systemName: SpendlyIcon.arrowBack.systemName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }

            Text(title)
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Spacer()

            trailing()
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        SPHeader(title: "Work Orders", showBackButton: true) {
            Button {} label: {
                Image(systemName: SpendlyIcon.notifications.systemName)
            }
        }
        Spacer()
    }
}
