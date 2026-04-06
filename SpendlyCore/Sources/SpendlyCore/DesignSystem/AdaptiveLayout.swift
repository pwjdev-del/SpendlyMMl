import SwiftUI

// MARK: - Device Idiom Detection

public enum SpendlyDevice {
    /// True when running on iPad (any size class)
    public static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

// MARK: - Adaptive Spacing

/// Provides spacing values that scale up on iPad so the UI doesn't feel cramped on a larger screen.
public enum AdaptiveSpacing {
    public static var xs: CGFloat  { SpendlyDevice.isPad ? 6 : SpendlySpacing.xs }
    public static var sm: CGFloat  { SpendlyDevice.isPad ? 12 : SpendlySpacing.sm }
    public static var md: CGFloat  { SpendlyDevice.isPad ? 16 : SpendlySpacing.md }
    public static var lg: CGFloat  { SpendlyDevice.isPad ? 24 : SpendlySpacing.lg }
    public static var xl: CGFloat  { SpendlyDevice.isPad ? 28 : SpendlySpacing.xl }
    public static var xxl: CGFloat { SpendlyDevice.isPad ? 32 : SpendlySpacing.xxl }
    public static var xxxl: CGFloat { SpendlyDevice.isPad ? 40 : SpendlySpacing.xxxl }
}

// MARK: - Adaptive Content Width Modifier

/// Centers content with a max width on iPad so forms and narrow content
/// don't stretch edge-to-edge. Uses a generous default that works well
/// inside a NavigationSplitView detail pane.
public struct AdaptiveContentWidth: ViewModifier {
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let maxWidth: CGFloat

    public init(maxWidth: CGFloat = 600) {
        self.maxWidth = maxWidth
    }

    public func body(content: Content) -> some View {
        if sizeClass == .regular {
            content
                .frame(maxWidth: maxWidth)
                .frame(maxWidth: .infinity)
        } else {
            content
        }
    }
}

public extension View {
    /// On iPad (regular width), constrains content to a max width and centers it.
    /// Best for forms/login screens. For dashboard content, use `.adaptiveFullWidth()`.
    func adaptiveContentWidth(_ maxWidth: CGFloat = 600) -> some View {
        modifier(AdaptiveContentWidth(maxWidth: maxWidth))
    }

    /// Lets content use full available width on iPad. Use this for dashboards,
    /// tables, and multi-column layouts that should fill the detail pane.
    func adaptiveFullWidth() -> some View {
        self
    }
}

// MARK: - Adaptive Two-Column Layout

/// A layout that shows content side-by-side on iPad (regular width) and stacked on iPhone.
public struct AdaptiveColumns<Leading: View, Trailing: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    private let leading: () -> Leading
    private let trailing: () -> Trailing
    private let leadingRatio: CGFloat

    public init(
        leadingRatio: CGFloat = 0.4,
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.leadingRatio = leadingRatio
        self.leading = leading
        self.trailing = trailing
    }

    public var body: some View {
        if sizeClass == .regular {
            HStack(alignment: .top, spacing: AdaptiveSpacing.lg) {
                leading()
                    .frame(maxWidth: .infinity)

                trailing()
                    .frame(maxWidth: .infinity)
            }
        } else {
            VStack(spacing: SpendlySpacing.lg) {
                leading()
                trailing()
            }
        }
    }
}
