import SwiftUI

public struct SPSelect: View {
    private let title: String
    private let options: [String]
    @Binding private var selection: String

    @Environment(\.colorScheme) private var colorScheme

    public init(
        _ title: String,
        options: [String],
        selection: Binding<String>
    ) {
        self.title = title
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            if !title.isEmpty {
                Text(title)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        HStack {
                            Text(option)
                            if option == selection {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? "Select..." : selection)
                        .font(SpendlyFont.body())
                        .foregroundStyle(
                            selection.isEmpty
                                ? SpendlyColors.secondary
                                : SpendlyColors.foreground(for: colorScheme)
                        )
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.md)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: SpendlySpacing.xl) {
        SPSelect(
            "Priority",
            options: ["Low", "Medium", "High", "Critical"],
            selection: .constant("Medium")
        )
        SPSelect(
            "Category",
            options: ["Plumbing", "Electrical", "HVAC", "General"],
            selection: .constant("")
        )
    }
    .padding()
}
