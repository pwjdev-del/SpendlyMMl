import SwiftUI
import SpendlyCore

/// A wrapper view that provides filter access for the Machine Vault.
/// Uses `SPFilterModal` with pre-configured sections for machine-specific filtering.
///
/// This can be presented standalone or embedded, but the primary usage
/// is via `MachineVaultRootView` which drives `SPFilterModal` directly
/// through the view model's `filterSections` binding.
struct MachineFilterView: View {

    @Binding var isPresented: Bool
    @Binding var filterSections: [SPFilterSection]
    var sortOption: Binding<MachineVaultSortOption>

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
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
                    // Handle
                    Capsule()
                        .fill(SpendlyColors.secondary.opacity(0.3))
                        .frame(width: 36, height: 5)
                        .padding(.top, SpendlySpacing.sm)

                    // Header
                    HStack {
                        Text("Filter Machines")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Spacer()
                        Button("Reset All") {
                            resetAll()
                        }
                        .font(SpendlyFont.bodyMedium())
                        .foregroundStyle(SpendlyColors.accent)
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.top, SpendlySpacing.md)

                    SPDivider()
                        .padding(.vertical, SpendlySpacing.sm)

                    ScrollView {
                        VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
                            // Sort section
                            sortSection

                            // Filter sections from SPFilterModal
                            ForEach($filterSections) { $section in
                                filterSectionView(section: $section)
                            }
                        }
                        .padding(.horizontal, SpendlySpacing.lg)
                        .padding(.bottom, SpendlySpacing.lg)
                    }
                    .frame(maxHeight: 450)

                    // Apply
                    SPButton("Apply Filters", icon: SpendlyIcon.checkCircle.systemName, style: .primary) {
                        withAnimation {
                            isPresented = false
                        }
                    }
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

    // MARK: - Sort Section

    private var sortSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("Sort By")
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: SpendlySpacing.sm) {
                ForEach(MachineVaultSortOption.allCases, id: \.self) { option in
                    Button {
                        sortOption.wrappedValue = option
                    } label: {
                        Text(option.rawValue)
                            .font(SpendlyFont.caption())
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.vertical, SpendlySpacing.sm)
                            .padding(.horizontal, SpendlySpacing.md)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(
                                sortOption.wrappedValue == option
                                    ? Color.white
                                    : SpendlyColors.foreground(for: colorScheme)
                            )
                            .background(
                                sortOption.wrappedValue == option
                                    ? SpendlyColors.primary
                                    : SpendlyColors.background(for: colorScheme)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }
                }
            }
        }
    }

    // MARK: - Filter Section

    @ViewBuilder
    private func filterSectionView(section: Binding<SPFilterSection>) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(section.wrappedValue.title)
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            switch section.wrappedValue.type {
            case .checkbox:
                FlowLayout(spacing: SpendlySpacing.sm) {
                    ForEach(section.options) { $option in
                        chipButton(option: $option)
                    }
                }

            case .range(let min, let max):
                Text("Slider filter available in full filter modal")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)

            default:
                ForEach(section.options) { $option in
                    checkboxRow(option: $option)
                }
            }
        }
    }

    private func chipButton(option: Binding<SPFilterOption>) -> some View {
        Button {
            option.wrappedValue.isSelected.toggle()
        } label: {
            HStack(spacing: SpendlySpacing.xs) {
                if option.wrappedValue.isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                }
                Text(option.wrappedValue.label)
                    .font(SpendlyFont.caption())
                    .fontWeight(.medium)
            }
            .padding(.vertical, SpendlySpacing.sm)
            .padding(.horizontal, SpendlySpacing.md)
            .foregroundStyle(
                option.wrappedValue.isSelected
                    ? Color.white
                    : SpendlyColors.foreground(for: colorScheme)
            )
            .background(
                option.wrappedValue.isSelected
                    ? SpendlyColors.primary
                    : SpendlyColors.background(for: colorScheme)
            )
            .clipShape(Capsule())
        }
    }

    private func checkboxRow(option: Binding<SPFilterOption>) -> some View {
        Button {
            option.wrappedValue.isSelected.toggle()
        } label: {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: option.wrappedValue.isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(option.wrappedValue.isSelected ? SpendlyColors.primary : SpendlyColors.secondary)
                Text(option.wrappedValue.label)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
            }
            .padding(.vertical, SpendlySpacing.xs)
        }
    }

    // MARK: - Reset

    private func resetAll() {
        for i in filterSections.indices {
            for j in filterSections[i].options.indices {
                filterSections[i].options[j].isSelected = false
            }
        }
        sortOption.wrappedValue = .nameAsc
    }
}

// MARK: - Flow Layout

/// Simple horizontal wrapping layout for filter chips.
private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layoutSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layoutSubviews(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            if index < result.positions.count {
                let position = result.positions[index]
                subview.place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
            }
        }
    }

    private func layoutSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

// MARK: - Preview

#Preview("Machine Filter - Light") {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()

        MachineFilterView(
            isPresented: .constant(true),
            filterSections: .constant([
                SPFilterSection(
                    title: "Machine Type",
                    type: .checkbox,
                    options: [
                        SPFilterOption(label: "FFS", isSelected: true),
                        SPFilterOption(label: "Pouch Maker"),
                        SPFilterOption(label: "Converter"),
                        SPFilterOption(label: "Blown Film"),
                        SPFilterOption(label: "Sachet"),
                    ]
                ),
                SPFilterSection(
                    title: "Status",
                    type: .checkbox,
                    options: [
                        SPFilterOption(label: "In Service"),
                        SPFilterOption(label: "Needs Maintenance"),
                        SPFilterOption(label: "Under Repair"),
                    ]
                ),
            ]),
            sortOption: .constant(.nameAsc)
        )
    }
}

#Preview("Machine Filter - Dark") {
    ZStack {
        Color.black.opacity(0.3)
            .ignoresSafeArea()

        MachineFilterView(
            isPresented: .constant(true),
            filterSections: .constant([
                SPFilterSection(
                    title: "Status",
                    type: .checkbox,
                    options: [
                        SPFilterOption(label: "In Service", isSelected: true),
                        SPFilterOption(label: "Under Repair", isSelected: true),
                    ]
                ),
            ]),
            sortOption: .constant(.healthDesc)
        )
    }
    .preferredColorScheme(.dark)
}
