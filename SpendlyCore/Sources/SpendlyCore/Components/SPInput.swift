import SwiftUI

public struct SPInput: View {
    private let placeholder: String
    private let icon: String?
    private let isSecure: Bool
    @Binding private var text: String
    @FocusState private var isFocused: Bool

    @Environment(\.colorScheme) private var colorScheme

    public init(
        _ placeholder: String,
        icon: String? = nil,
        text: Binding<String>,
        isSecure: Bool = false
    ) {
        self.placeholder = placeholder
        self.icon = icon
        self._text = text
        self.isSecure = isSecure
    }

    public var body: some View {
        HStack(spacing: SpendlySpacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(SpendlyColors.secondary)
                    .frame(width: 20)
            }

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(SpendlyFont.body())
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .font(SpendlyFont.body())
                    .focused($isFocused)
            }
        }
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .strokeBorder(
                    isFocused ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.2),
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: SpendlySpacing.lg) {
        SPInput("Email", icon: "envelope", text: .constant(""))
        SPInput("Password", icon: "lock", text: .constant(""), isSecure: true)
        SPInput("Search...", icon: "magnifyingglass", text: .constant("Hello"))
    }
    .padding()
}
