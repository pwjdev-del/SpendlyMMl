import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Drawing Path Model

private struct DrawingPath: Identifiable {
    let id = UUID()
    var points: [CGPoint]
}

// MARK: - SPSignatureCapture

#if canImport(UIKit)
public struct SPSignatureCapture: View {
    @Binding private var signature: UIImage?
    private let onClear: (() -> Void)?

    @State private var paths: [DrawingPath] = []
    @State private var currentPath: DrawingPath = DrawingPath(points: [])

    @Environment(\.colorScheme) private var colorScheme

    public init(
        signature: Binding<UIImage?>,
        onClear: (() -> Void)? = nil
    ) {
        self._signature = signature
        self.onClear = onClear
    }

    public var body: some View {
        VStack(spacing: SpendlySpacing.sm) {
            Text("Signature")
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(SpendlyColors.surface(for: colorScheme))

                Canvas { context, _ in
                    for path in paths {
                        var bezier = Path()
                        guard let first = path.points.first else { continue }
                        bezier.move(to: first)
                        for point in path.points.dropFirst() {
                            bezier.addLine(to: point)
                        }
                        context.stroke(
                            bezier,
                            with: .color(SpendlyColors.foreground(for: colorScheme)),
                            lineWidth: 2
                        )
                    }

                    // Current drawing path
                    if !currentPath.points.isEmpty {
                        var bezier = Path()
                        bezier.move(to: currentPath.points[0])
                        for point in currentPath.points.dropFirst() {
                            bezier.addLine(to: point)
                        }
                        context.stroke(
                            bezier,
                            with: .color(SpendlyColors.foreground(for: colorScheme)),
                            lineWidth: 2
                        )
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            currentPath.points.append(value.location)
                        }
                        .onEnded { _ in
                            paths.append(currentPath)
                            currentPath = DrawingPath(points: [])
                            renderSignature()
                        }
                )

                if paths.isEmpty && currentPath.points.isEmpty {
                    Text("Sign here")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                }
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

            HStack {
                Spacer()
                Button {
                    paths.removeAll()
                    currentPath = DrawingPath(points: [])
                    signature = nil
                    onClear?()
                } label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: SpendlyIcon.delete.systemName)
                        Text("Clear")
                    }
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.error)
                }
            }
        }
    }

    @MainActor
    private func renderSignature() {
        let renderer = ImageRenderer(content:
            Canvas { context, _ in
                for path in paths {
                    var bezier = Path()
                    guard let first = path.points.first else { continue }
                    bezier.move(to: first)
                    for point in path.points.dropFirst() {
                        bezier.addLine(to: point)
                    }
                    context.stroke(bezier, with: .color(.black), lineWidth: 2)
                }
            }
            .frame(width: 300, height: 150)
            .background(.white)
        )
        signature = renderer.uiImage
    }
}

// MARK: - Preview

#Preview {
    SPSignatureCapture(signature: .constant(nil))
        .padding()
}
#endif
