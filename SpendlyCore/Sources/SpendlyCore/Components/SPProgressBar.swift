import SwiftUI

public struct SPProgressBar: View {
    private let progress: Double
    private let height: CGFloat
    private let showLabel: Bool

    @Environment(\.colorScheme) private var colorScheme

    public init(
        progress: Double,
        height: CGFloat = 8,
        showLabel: Bool = false
    ) {
        self.progress = min(max(progress, 0), 1)
        self.height = height
        self.showLabel = showLabel
    }

    public var body: some View {
        VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(SpendlyColors.secondary.opacity(0.15))
                        .frame(height: height)

                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(SpendlyColors.primary)
                        .frame(width: geo.size.width * progress, height: height)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: height)

            if showLabel {
                Text("\(Int(progress * 100))%")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .monospacedDigit()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: SpendlySpacing.xl) {
        SPProgressBar(progress: 0.75, showLabel: true)
        SPProgressBar(progress: 0.3, height: 12, showLabel: true)
        SPProgressBar(progress: 1.0)
    }
    .padding()
}
