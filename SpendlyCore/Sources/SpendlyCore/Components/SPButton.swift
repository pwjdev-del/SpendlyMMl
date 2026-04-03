import SwiftUI

// MARK: - Button Style

public enum SPButtonStyle {
    case primary
    case secondary
    case accent
    case destructive
    case ghost
}

// MARK: - SPButton

public struct SPButton: View {
    private let title: String
    private let icon: String?
    private let style: SPButtonStyle
    private let isLoading: Bool
    private let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    public init(
        _ title: String,
        icon: String? = nil,
        style: SPButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: SpendlySpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Text(title)
                        .font(SpendlyFont.bodySemibold())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.md)
            .padding(.horizontal, SpendlySpacing.lg)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: style == .secondary ? 1.5 : 0)
            )
        }
        .disabled(isLoading)
    }

    private var backgroundColor: Color {
        switch style {
        case .primary:     return SpendlyColors.primary
        case .secondary:   return .clear
        case .accent:      return SpendlyColors.accent
        case .destructive: return SpendlyColors.error
        case .ghost:       return .clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary:     return .white
        case .secondary:   return SpendlyColors.primary
        case .accent:      return .white
        case .destructive: return .white
        case .ghost:       return colorScheme == .dark ? .white : SpendlyColors.primary
        }
    }

    private var borderColor: Color {
        switch style {
        case .secondary: return SpendlyColors.primary.opacity(0.3)
        default:         return .clear
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: SpendlySpacing.md) {
        SPButton("Primary", icon: "plus", style: .primary) {}
        SPButton("Secondary", style: .secondary) {}
        SPButton("Accent", icon: "star.fill", style: .accent) {}
        SPButton("Destructive", icon: "trash", style: .destructive) {}
        SPButton("Ghost", style: .ghost) {}
        SPButton("Loading...", style: .primary, isLoading: true) {}
    }
    .padding()
}
