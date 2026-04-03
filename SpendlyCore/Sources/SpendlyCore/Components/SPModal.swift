import SwiftUI

public struct SPModal<Content: View>: View {
    @Binding private var isPresented: Bool
    private let content: () -> Content

    @Environment(\.colorScheme) private var colorScheme

    public init(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isPresented = isPresented
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isPresented = false
                        }
                    }

                VStack(spacing: 0) {
                    // Handle bar
                    Capsule()
                        .fill(SpendlyColors.secondary.opacity(0.3))
                        .frame(width: 36, height: 5)
                        .padding(.top, SpendlySpacing.sm)
                        .padding(.bottom, SpendlySpacing.lg)

                    content()
                        .padding(.horizontal, SpendlySpacing.lg)
                        .padding(.bottom, SpendlySpacing.xxl)
                }
                .frame(maxWidth: .infinity)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: SpendlyRadius.xl,
                        topTrailingRadius: SpendlyRadius.xl,
                        style: .continuous
                    )
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - View Extension

public extension View {
    func spModal<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            SPModal(isPresented: isPresented, content: content)
        }
    }
}

// MARK: - Preview

#Preview {
    SPModal(isPresented: .constant(true)) {
        VStack(spacing: SpendlySpacing.lg) {
            Text("Modal Title")
                .font(SpendlyFont.headline())
            Text("This is a bottom sheet modal with a handle bar.")
                .font(SpendlyFont.body())
            SPButton("Confirm", style: .primary) {}
        }
    }
}
