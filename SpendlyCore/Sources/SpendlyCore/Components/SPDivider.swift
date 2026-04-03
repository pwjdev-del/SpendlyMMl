import SwiftUI

public struct SPDivider: View {
    private let thickness: CGFloat

    @Environment(\.colorScheme) private var colorScheme

    public init(thickness: CGFloat = 1) {
        self.thickness = thickness
    }

    public var body: some View {
        Rectangle()
            .fill(dividerColor)
            .frame(height: thickness)
            .frame(maxWidth: .infinity)
    }

    /// Uses a subtle background color shift instead of a hard 1px border, per design spec.
    private var dividerColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.06)
            : Color.black.opacity(0.06)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: SpendlySpacing.lg) {
        Text("Section A")
            .font(SpendlyFont.body())
        SPDivider()
        Text("Section B")
            .font(SpendlyFont.body())
        SPDivider(thickness: 2)
        Text("Section C")
            .font(SpendlyFont.body())
    }
    .padding()
}
