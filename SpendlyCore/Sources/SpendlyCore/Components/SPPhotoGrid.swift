import SwiftUI

// MARK: - Photo Item

public struct SPPhotoItem: Identifiable {
    public let id = UUID()
    public let image: Image

    public init(image: Image) {
        self.image = image
    }
}

// MARK: - SPPhotoGrid

public struct SPPhotoGrid: View {
    private let images: [SPPhotoItem]
    private let onAdd: (() -> Void)?
    private let onRemove: ((SPPhotoItem) -> Void)?

    private let columns = [
        GridItem(.flexible(), spacing: SpendlySpacing.sm),
        GridItem(.flexible(), spacing: SpendlySpacing.sm),
        GridItem(.flexible(), spacing: SpendlySpacing.sm),
    ]

    @Environment(\.colorScheme) private var colorScheme

    public init(
        images: [SPPhotoItem],
        onAdd: (() -> Void)? = nil,
        onRemove: ((SPPhotoItem) -> Void)? = nil
    ) {
        self.images = images
        self.onAdd = onAdd
        self.onRemove = onRemove
    }

    public var body: some View {
        LazyVGrid(columns: columns, spacing: SpendlySpacing.sm) {
            // Add button
            if let onAdd {
                Button(action: onAdd) {
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .fill(SpendlyColors.surface(for: colorScheme))
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            VStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: SpendlyIcon.camera.systemName)
                                    .font(.system(size: 24))
                                Text("Add")
                                    .font(SpendlyFont.caption())
                            }
                            .foregroundStyle(SpendlyColors.secondary)
                        )
                }
            }

            // Photo items
            ForEach(images) { item in
                ZStack(alignment: .topTrailing) {
                    item.image
                        .resizable()
                        .scaledToFill()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                    if onRemove != nil {
                        Button {
                            onRemove?(item)
                        } label: {
                            Image(systemName: SpendlyIcon.close.systemName)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 22, height: 22)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(SpendlySpacing.xs)
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SPPhotoGrid(
        images: [
            SPPhotoItem(image: Image(systemName: "photo")),
            SPPhotoItem(image: Image(systemName: "photo.fill")),
        ],
        onAdd: {},
        onRemove: { _ in }
    )
    .padding()
}
