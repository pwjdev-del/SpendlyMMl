import SwiftUI

public struct SPSearchBar: View {
    @Binding private var searchText: String
    private let showFilterButton: Bool
    private let onFilterTap: (() -> Void)?

    @Environment(\.colorScheme) private var colorScheme

    public init(
        searchText: Binding<String>,
        showFilterButton: Bool = false,
        onFilterTap: (() -> Void)? = nil
    ) {
        self._searchText = searchText
        self.showFilterButton = showFilterButton
        self.onFilterTap = onFilterTap
    }

    public var body: some View {
        HStack(spacing: SpendlySpacing.sm) {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: SpendlyIcon.search.systemName)
                    .foregroundStyle(SpendlyColors.secondary)

                TextField("Search...", text: $searchText)
                    .font(SpendlyFont.body())

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: SpendlyIcon.close.systemName)
                            .foregroundStyle(SpendlyColors.secondary)
                            .font(.system(size: 12, weight: .semibold))
                    }
                }
            }
            .padding(.horizontal, SpendlySpacing.md)
            .padding(.vertical, SpendlySpacing.sm + 2)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

            if showFilterButton {
                Button {
                    onFilterTap?()
                } label: {
                    Image(systemName: SpendlyIcon.tune.systemName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(SpendlyColors.primary)
                        .frame(width: 40, height: 40)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        SPSearchBar(searchText: .constant(""), showFilterButton: true)
        SPSearchBar(searchText: .constant("Plumbing"))
    }
    .padding()
    .background(SpendlyColors.backgroundLight)
}
