import SwiftUI

public struct SPEmptyState: View {
    private let icon: String
    private let title: String
    private let message: String
    private let actionTitle: String?
    private let action: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    public init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: SpendlySpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.5))

            VStack(spacing: SpendlySpacing.sm) {
                Text(title)
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text(message)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                SPButton(actionTitle, style: .primary, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(SpendlySpacing.xxxl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

#Preview {
    SPEmptyState(
        icon: "doc.text",
        title: "No Work Orders",
        message: "You don't have any work orders yet. Create one to get started.",
        actionTitle: "Create Work Order"
    ) {
        // action
    }
}
