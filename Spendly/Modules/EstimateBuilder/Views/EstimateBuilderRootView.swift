import SwiftUI
import SpendlyCore

// MARK: - EstimateBuilderRootView (List View)

public struct EstimateBuilderRootView: View {

    @State private var viewModel = EstimateBuilderViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        ZStack {
            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.lg) {
                    // MARK: Header
                    headerSection

                    // MARK: Stats Row
                    statsRow

                    // MARK: Search Bar with Filter
                    SPSearchBar(
                        searchText: $viewModel.searchText,
                        showFilterButton: true,
                        onFilterTap: {
                            withAnimation {
                                viewModel.showFilterModal = true
                            }
                        }
                    )

                    // MARK: Active Filters Badge
                    if viewModel.activeFilterCount > 0 {
                        activeFiltersIndicator
                    }

                    // MARK: Estimate List
                    if viewModel.filteredEstimates.isEmpty {
                        SPEmptyState(
                            icon: "doc.text.magnifyingglass",
                            title: "No Estimates Found",
                            message: "Try adjusting your search or filters, or create a new estimate.",
                            actionTitle: "Create Estimate"
                        ) {
                            viewModel.startNewEstimate()
                        }
                    } else {
                        LazyVStack(spacing: SpendlySpacing.md) {
                            ForEach(viewModel.filteredEstimates) { estimate in
                                EstimateListCard(estimate: estimate) {
                                    viewModel.selectEstimate(estimate)
                                }
                            }
                        }
                    }
                }
            }

            // MARK: Filter Modal Overlay
            SPFilterModal(
                isPresented: $viewModel.showFilterModal,
                sections: $viewModel.filterSections
            )
        }
        .navigationDestination(isPresented: $viewModel.showEditor) {
            if let estimate = viewModel.selectedEstimate {
                EstimateEditorView(viewModel: viewModel, editingEstimate: estimate)
            }
        }
        .navigationDestination(isPresented: $viewModel.showCreateNew) {
            EstimateEditorView(viewModel: viewModel, editingEstimate: nil)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text("Estimates")
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text("Create and manage service estimates")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }

            Spacer()

            Button {
                viewModel.startNewEstimate()
            } label: {
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: SpendlyIcon.add.systemName)
                        .font(.system(size: 12, weight: .bold))
                    Text("New")
                        .font(SpendlyFont.bodySemibold())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.sm)
                .background(SpendlyColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: SpendlySpacing.md) {
            statCard(
                icon: "doc.text.fill",
                label: "Total",
                value: "\(viewModel.totalEstimates)"
            )
            statCard(
                icon: "pencil.circle.fill",
                label: "Drafts",
                value: "\(viewModel.draftCount)"
            )
            statCard(
                icon: "checkmark.seal.fill",
                label: "Approved",
                value: "\(viewModel.approvedCount)",
                valueColor: viewModel.approvedCount > 0 ? SpendlyColors.success : nil
            )
        }
    }

    private func statCard(
        icon: String,
        label: String,
        value: String,
        valueColor: Color? = nil
    ) -> some View {
        SPCard(elevation: .low, padding: SpendlySpacing.md) {
            VStack(spacing: SpendlySpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(SpendlyColors.accent)

                Text(value)
                    .font(SpendlyFont.headline())
                    .foregroundStyle(valueColor ?? SpendlyColors.foreground(for: colorScheme))

                Text(label)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Active Filters Indicator

    private var activeFiltersIndicator: some View {
        HStack(spacing: SpendlySpacing.sm) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(SpendlyColors.accent)

            Text("\(viewModel.activeFilterCount) filter\(viewModel.activeFilterCount == 1 ? "" : "s") applied")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.accent)

            Spacer()

            Button {
                for sectionIndex in viewModel.filterSections.indices {
                    for optionIndex in viewModel.filterSections[sectionIndex].options.indices {
                        viewModel.filterSections[sectionIndex].options[optionIndex].isSelected = false
                    }
                }
            } label: {
                Text("Clear")
                    .font(SpendlyFont.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(SpendlyColors.error)
            }
        }
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.vertical, SpendlySpacing.sm)
        .background(SpendlyColors.accent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
    }
}

// MARK: - Estimate List Card

private struct EstimateListCard: View {
    let estimate: EstimateDisplayModel
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTap) {
            SPCard(elevation: .medium, padding: 0) {
                VStack(spacing: 0) {
                    // Status color bar
                    Rectangle()
                        .fill(estimate.statusBadgeStyle.foregroundColor)
                        .frame(height: 3)

                    VStack(spacing: SpendlySpacing.md) {
                        // Top row: customer + badge
                        HStack(alignment: .top, spacing: SpendlySpacing.md) {
                            SPAvatar(
                                initials: estimate.customerInitials,
                                size: .lg,
                                statusDot: estimate.status == .approved
                                    ? SpendlyColors.success
                                    : nil
                            )

                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text(estimate.customerName)
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                    .lineLimit(1)

                                Text(estimate.estimateNumber)
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                                Text(estimate.customerAddress)
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.7))
                                    .lineLimit(1)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                                SPBadge(estimate.statusLabel, style: estimate.statusBadgeStyle)

                                Text(formatCurrency(estimate.grandTotal))
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            }
                        }

                        SPDivider()

                        // Quick info row
                        HStack(spacing: SpendlySpacing.md) {
                            quickInfoChip(
                                icon: "wrench.and.screwdriver",
                                text: "\(estimate.taskCount) Task\(estimate.taskCount == 1 ? "" : "s")"
                            )
                            quickInfoChip(
                                icon: "person",
                                text: estimate.technicianName
                            )
                            quickInfoChip(
                                icon: "mappin",
                                text: estimate.region
                            )
                        }

                        SPDivider()

                        // Bottom row: date + chevron
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Created")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)

                                Text(formatDate(estimate.createdAt))
                                    .font(SpendlyFont.bodyMedium())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            }

                            Spacer()

                            Text(estimate.projectType)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                                .padding(.horizontal, SpendlySpacing.sm)
                                .padding(.vertical, SpendlySpacing.xs)
                                .background(SpendlyColors.secondary.opacity(0.08))
                                .clipShape(Capsule())

                            Image(systemName: SpendlyIcon.chevronRight.systemName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                        }
                    }
                    .padding(SpendlySpacing.lg)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Quick Info Chip

    private func quickInfoChip(icon: String, text: String) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(SpendlyColors.accent)

            Text(text)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .lineLimit(1)
        }
        .padding(.horizontal, SpendlySpacing.sm)
        .padding(.vertical, SpendlySpacing.xs + 2)
        .background(SpendlyColors.accent.opacity(0.06))
        .clipShape(Capsule())
    }

    // MARK: - Formatters

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Previews

#Preview("Estimate List") {
    NavigationStack {
        EstimateBuilderRootView()
    }
}

#Preview("Estimate List - Dark") {
    NavigationStack {
        EstimateBuilderRootView()
    }
    .preferredColorScheme(.dark)
}
