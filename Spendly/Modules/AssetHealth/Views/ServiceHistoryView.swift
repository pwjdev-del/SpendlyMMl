import SwiftUI
import SpendlyCore

struct ServiceHistoryView: View {
    @Bindable var viewModel: AssetHealthViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {

                // MARK: - Header
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text("Service History")
                        .font(SpendlyFont.title())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Text("\(viewModel.completedServiceCount) completed -- Total \(viewModel.formattedTotalCost)")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                // MARK: - Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(SpendlyColors.secondary)
                    TextField("Search history...", text: $viewModel.historySearchText)
                        .font(SpendlyFont.body())
                }
                .padding(SpendlySpacing.sm)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                // MARK: - Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SpendlySpacing.xs) {
                        filterChip("All", isActive: viewModel.selectedHistoryFilter == nil) {
                            viewModel.setHistoryFilter(nil)
                        }
                        ForEach(ServiceHistoryStatus.allCases, id: \.rawValue) { status in
                            filterChip(status.rawValue, isActive: viewModel.selectedHistoryFilter == status) {
                                viewModel.setHistoryFilter(status)
                            }
                        }
                    }
                }

                // MARK: - Entries
                if viewModel.filteredServiceHistory.isEmpty {
                    ContentUnavailableView(
                        "No Records Found",
                        systemImage: "doc.text.magnifyingglass",
                        description: Text("Try adjusting your search or filter.")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, SpendlySpacing.xl)
                } else {
                    LazyVStack(spacing: SpendlySpacing.sm) {
                        ForEach(viewModel.filteredServiceHistory) { entry in
                            serviceEntryCard(entry)
                        }
                    }
                }

                // MARK: - Export
                Button {
                    viewModel.exportHistory()
                } label: {
                    Label("Export History", systemImage: "square.and.arrow.up")
                        .font(SpendlyFont.headline())
                        .frame(maxWidth: .infinity)
                        .padding(SpendlySpacing.sm)
                }
                .buttonStyle(.borderedProminent)
                .tint(SpendlyColors.primary)
            }
            .padding(SpendlySpacing.md)
        }
    }

    // MARK: - Filter Chip

    private func filterChip(_ title: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(SpendlyFont.caption())
                .padding(.horizontal, SpendlySpacing.sm)
                .padding(.vertical, SpendlySpacing.xs)
                .background(isActive ? SpendlyColors.primary.opacity(0.15) : SpendlyColors.surface(for: colorScheme))
                .foregroundStyle(isActive ? SpendlyColors.primary : SpendlyColors.foreground(for: colorScheme))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(isActive ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.3), lineWidth: 1))
        }
    }

    // MARK: - Entry Card

    private func serviceEntryCard(_ entry: ServiceHistoryEntry) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    if let subtitle = entry.subtitle {
                        Text(subtitle)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
                Spacer()
                SPBadge(entry.status.rawValue, style: entry.status.badgeStyle)
            }

            HStack(spacing: SpendlySpacing.md) {
                Label(viewModel.formattedDate(entry.date), systemImage: "calendar")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)

                Label(entry.technician, systemImage: "person")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)

                if let cost = entry.cost {
                    Label(String(format: "$%.0f", cost), systemImage: "dollarsign.circle")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }
            }

            if !entry.partsReplaced.isEmpty {
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.caption2)
                        .foregroundStyle(SpendlyColors.secondary)
                    Text(entry.partsReplaced.joined(separator: ", "))
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))
    }
}
