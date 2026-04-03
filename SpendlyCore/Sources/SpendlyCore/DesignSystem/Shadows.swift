import SwiftUI

// MARK: - Shadow Level

public enum SpendlyShadowLevel {
    case none
    case sm
    case md
    case lg
}

// MARK: - Shadow ViewModifier

public struct SpendlyShadow: ViewModifier {
    public let level: SpendlyShadowLevel
    @Environment(\.colorScheme) private var colorScheme

    public init(level: SpendlyShadowLevel) {
        self.level = level
    }

    public func body(content: Content) -> some View {
        switch level {
        case .none:
            content
        case .sm:
            content
                .background(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                        .fill(elevationColor(shift: 0.03))
                )
        case .md:
            content
                .background(
                    RoundedRectangle(cornerRadius: SpendlyRadius.large)
                        .fill(elevationColor(shift: 0.06))
                )
        case .lg:
            content
                .background(
                    RoundedRectangle(cornerRadius: SpendlyRadius.xl)
                        .fill(elevationColor(shift: 0.10))
                )
        }
    }

    private func elevationColor(shift: Double) -> Color {
        colorScheme == .dark
            ? Color.white.opacity(shift)
            : Color.black.opacity(shift * 0.5)
    }
}

// MARK: - View Extension

public extension View {
    func spendlyShadow(_ level: SpendlyShadowLevel) -> some View {
        modifier(SpendlyShadow(level: level))
    }
}
