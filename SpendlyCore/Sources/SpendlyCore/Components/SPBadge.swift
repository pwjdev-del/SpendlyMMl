import SwiftUI

// MARK: - Badge Style

public enum SPBadgeStyle {
    case success
    case warning
    case error
    case info
    case neutral
    case custom(Color)

    var backgroundColor: Color {
        switch self {
        case .success:        return SpendlyColors.success.opacity(0.15)
        case .warning:        return SpendlyColors.warning.opacity(0.15)
        case .error:          return SpendlyColors.error.opacity(0.15)
        case .info:           return SpendlyColors.info.opacity(0.15)
        case .neutral:        return SpendlyColors.secondary.opacity(0.15)
        case .custom(let c):  return c.opacity(0.15)
        }
    }

    public var foregroundColor: Color {
        switch self {
        case .success:        return SpendlyColors.success
        case .warning:        return SpendlyColors.warning
        case .error:          return SpendlyColors.error
        case .info:           return SpendlyColors.info
        case .neutral:        return SpendlyColors.secondary
        case .custom(let c):  return c
        }
    }
}

// MARK: - SPBadge

public struct SPBadge: View {
    private let text: String
    private let style: SPBadgeStyle

    public init(_ text: String, style: SPBadgeStyle = .neutral) {
        self.text = text
        self.style = style
    }

    public var body: some View {
        Text(text)
            .font(SpendlyFont.caption())
            .fontWeight(.semibold)
            .foregroundStyle(style.foregroundColor)
            .padding(.horizontal, SpendlySpacing.sm)
            .padding(.vertical, SpendlySpacing.xs)
            .background(style.backgroundColor)
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: SpendlySpacing.sm) {
        SPBadge("Active", style: .success)
        SPBadge("Pending", style: .warning)
        SPBadge("Overdue", style: .error)
        SPBadge("Info", style: .info)
        SPBadge("Draft", style: .neutral)
    }
    .padding()
}
