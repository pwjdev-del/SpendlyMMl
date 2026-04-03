import SwiftUI

// MARK: - Trend Direction

public enum SPTrendDirection {
    case up
    case down
    case flat

    public var icon: String {
        switch self {
        case .up:   return "arrow.up.right"
        case .down: return "arrow.down.right"
        case .flat: return "arrow.right"
        }
    }

    public var color: Color {
        switch self {
        case .up:   return SpendlyColors.success
        case .down: return SpendlyColors.error
        case .flat: return SpendlyColors.secondary
        }
    }
}

// MARK: - SPMetricCard

public struct SPMetricCard: View {
    private let title: String
    private let value: String
    private let trend: String?
    private let trendDirection: SPTrendDirection

    @Environment(\.colorScheme) private var colorScheme

    public init(
        title: String,
        value: String,
        trend: String? = nil,
        trendDirection: SPTrendDirection = .flat
    ) {
        self.title = title
        self.value = value
        self.trend = trend
        self.trendDirection = trendDirection
    }

    public var body: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text(title)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                Text(value)
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .monospacedDigit()

                if let trend {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: trendDirection.icon)
                            .font(.system(size: 12, weight: .semibold))
                        Text(trend)
                            .font(SpendlyFont.caption())
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(trendDirection.color)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: SpendlySpacing.md) {
        SPMetricCard(title: "Revenue", value: "$24,580", trend: "+12.5%", trendDirection: .up)
        SPMetricCard(title: "Open Jobs", value: "47", trend: "-3.2%", trendDirection: .down)
        SPMetricCard(title: "Completion Rate", value: "94%", trend: "0%", trendDirection: .flat)
    }
    .padding()
    .background(SpendlyColors.backgroundLight)
}
