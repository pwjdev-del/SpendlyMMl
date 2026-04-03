import SwiftUI
import SpendlyCore

// MARK: - EstimateFilterView
//
// A convenience wrapper that configures SPFilterModal with all estimate-specific
// filter sections. This view provides quick-access filter chips (horizontal scroll)
// at the top of the list, matching the white-label Stitch design.

struct EstimateFilterView: View {

    @Binding var showFilterModal: Bool
    @Binding var filterSections: [SPFilterSection]

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: SpendlySpacing.md) {
            // MARK: Horizontal Filter Chips
            filterChipsRow

            // MARK: Active Filter Tags
            if activeFilterCount > 0 {
                activeFilterTags
            }
        }
    }

    // MARK: - Filter Chips Row

    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpendlySpacing.sm) {
                ForEach(Array(filterSections.enumerated()), id: \.offset) { index, section in
                    filterChip(for: section, index: index)
                }

                // Divider
                Rectangle()
                    .fill(SpendlyColors.secondary.opacity(0.2))
                    .frame(width: 1, height: 24)

                // More Filters button
                Button {
                    withAnimation {
                        showFilterModal = true
                    }
                } label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Text("All Filters")
                            .font(SpendlyFont.bodyMedium())
                        if activeFilterCount > 0 {
                            Text("(\(activeFilterCount))")
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundStyle(SpendlyColors.primary)
                    .padding(.horizontal, SpendlySpacing.md)
                    .padding(.vertical, SpendlySpacing.sm)
                    .background(SpendlyColors.primary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                            .strokeBorder(SpendlyColors.primary.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, SpendlySpacing.xs)
        }
    }

    // MARK: - Filter Chip

    private func filterChip(for section: SPFilterSection, index: Int) -> some View {
        let isActive = section.options.contains(where: \.isSelected)
        let selectedCount = section.options.filter(\.isSelected).count

        return Button {
            withAnimation {
                showFilterModal = true
            }
        } label: {
            HStack(spacing: SpendlySpacing.xs) {
                Text(section.title)
                    .font(SpendlyFont.bodyMedium())

                if selectedCount > 0 {
                    Text("\(selectedCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 18, height: 18)
                        .background(SpendlyColors.accent)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                }
            }
            .foregroundStyle(
                isActive
                ? SpendlyColors.primary
                : SpendlyColors.foreground(for: colorScheme)
            )
            .padding(.horizontal, SpendlySpacing.md)
            .padding(.vertical, SpendlySpacing.sm)
            .background(
                isActive
                ? SpendlyColors.primary.opacity(0.08)
                : SpendlyColors.surface(for: colorScheme)
            )
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .strokeBorder(
                        isActive
                        ? SpendlyColors.primary.opacity(0.3)
                        : SpendlyColors.secondary.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
    }

    // MARK: - Active Filter Tags

    private var activeFilterTags: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpendlySpacing.sm) {
                ForEach(allActiveFilters, id: \.self) { filterLabel in
                    activeFilterTag(filterLabel)
                }

                Button {
                    clearAllFilters()
                } label: {
                    Text("Clear All")
                        .font(SpendlyFont.caption())
                        .fontWeight(.semibold)
                        .foregroundStyle(SpendlyColors.error)
                        .padding(.horizontal, SpendlySpacing.sm)
                        .padding(.vertical, SpendlySpacing.xs)
                }
            }
            .padding(.horizontal, SpendlySpacing.xs)
        }
    }

    private func activeFilterTag(_ label: String) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Text(label)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.primary)

            Button {
                removeFilter(label)
            } label: {
                Image(systemName: SpendlyIcon.close.systemName)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(SpendlyColors.secondary)
            }
        }
        .padding(.horizontal, SpendlySpacing.sm)
        .padding(.vertical, SpendlySpacing.xs + 2)
        .background(SpendlyColors.primary.opacity(0.06))
        .clipShape(Capsule())
    }

    // MARK: - Computed

    private var activeFilterCount: Int {
        filterSections.reduce(0) { total, section in
            total + section.options.filter(\.isSelected).count
        }
    }

    private var allActiveFilters: [String] {
        filterSections.flatMap { section in
            section.options.filter(\.isSelected).map { "\(section.title): \($0.label)" }
        }
    }

    // MARK: - Actions

    private func removeFilter(_ label: String) {
        let parts = label.split(separator: ": ", maxSplits: 1)
        guard parts.count == 2 else { return }
        let sectionTitle = String(parts[0])
        let optionLabel = String(parts[1])

        for sectionIndex in filterSections.indices {
            if filterSections[sectionIndex].title == sectionTitle {
                for optionIndex in filterSections[sectionIndex].options.indices {
                    if filterSections[sectionIndex].options[optionIndex].label == optionLabel {
                        filterSections[sectionIndex].options[optionIndex].isSelected = false
                    }
                }
            }
        }
    }

    private func clearAllFilters() {
        for sectionIndex in filterSections.indices {
            for optionIndex in filterSections[sectionIndex].options.indices {
                filterSections[sectionIndex].options[optionIndex].isSelected = false
            }
        }
    }
}

// MARK: - Preview

#Preview("Filter Chips") {
    EstimateFilterView(
        showFilterModal: .constant(false),
        filterSections: .constant([
            SPFilterSection(
                title: "Status",
                type: .checkbox,
                options: [
                    SPFilterOption(label: "Draft", isSelected: true),
                    SPFilterOption(label: "Sent"),
                    SPFilterOption(label: "Approved", isSelected: true)
                ]
            ),
            SPFilterSection(
                title: "Project",
                type: .checkbox,
                options: [
                    SPFilterOption(label: "Installation"),
                    SPFilterOption(label: "Maintenance")
                ]
            ),
            SPFilterSection(
                title: "Region",
                type: .checkbox,
                options: [
                    SPFilterOption(label: "North"),
                    SPFilterOption(label: "South")
                ]
            ),
            SPFilterSection(
                title: "Technician",
                type: .checkbox,
                options: [
                    SPFilterOption(label: "Amit Shah")
                ]
            )
        ])
    )
    .padding()
}

#Preview("Filter Chips - Dark") {
    EstimateFilterView(
        showFilterModal: .constant(false),
        filterSections: .constant([
            SPFilterSection(
                title: "Status",
                type: .checkbox,
                options: [
                    SPFilterOption(label: "Draft"),
                    SPFilterOption(label: "Sent")
                ]
            )
        ])
    )
    .padding()
    .preferredColorScheme(.dark)
}
