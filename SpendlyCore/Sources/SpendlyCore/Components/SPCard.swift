import SwiftUI

// MARK: - Elevation

public enum SPCardElevation {
    case low
    case medium
    case high

    var backgroundOpacityShift: Double {
        switch self {
        case .low:    return 0.02
        case .medium: return 0.05
        case .high:   return 0.09
        }
    }
}

// MARK: - SPCard

public struct SPCard<Content: View>: View {
    private let elevation: SPCardElevation
    private let padding: CGFloat
    private let content: () -> Content

    @Environment(\.colorScheme) private var colorScheme

    public init(
        elevation: SPCardElevation = .low,
        padding: CGFloat = SpendlySpacing.lg,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.elevation = elevation
        self.padding = padding
        self.content = content
    }

    public var body: some View {
        content()
            .padding(padding)
            .background(surfaceBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    private var surfaceBackground: Color {
        let base = SpendlyColors.surface(for: colorScheme)
        let shift = elevation.backgroundOpacityShift
        if colorScheme == .dark {
            return base.opacity(1.0 + shift)
        } else {
            return base.opacity(1.0 - shift)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: SpendlySpacing.lg) {
        SPCard(elevation: .low) {
            Text("Low elevation card")
                .font(SpendlyFont.body())
        }
        SPCard(elevation: .medium) {
            Text("Medium elevation card")
                .font(SpendlyFont.bodyMedium())
        }
        SPCard(elevation: .high) {
            Text("High elevation card")
                .font(SpendlyFont.bodySemibold())
        }
    }
    .padding()
    .background(SpendlyColors.backgroundLight)
}
