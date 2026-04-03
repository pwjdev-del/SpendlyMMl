import SwiftUI
import SpendlyCore

// MARK: - TerritoryRegionRootView

public struct TerritoryRegionRootView: View {
    @State private var viewModel = TerritoryRegionViewModel()
    @State private var showDetail = false
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        SPScreenWrapper {
            VStack(spacing: SpendlySpacing.lg) {
                // MARK: Header
                headerSection

                // MARK: Summary Stats
                statsRow

                // MARK: Search
                SPSearchBar(searchText: $viewModel.searchText)

                // MARK: Active Regions Header
                activeRegionsHeader

                // MARK: Territory Cards
                if viewModel.filteredTerritories.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: SpendlySpacing.md) {
                        ForEach(viewModel.filteredTerritories) { territory in
                            TerritoryCardView(
                                territory: territory,
                                onTap: {
                                    viewModel.startEditing(territory)
                                    showDetail = true
                                },
                                onDelete: {
                                    viewModel.confirmDelete(territory)
                                }
                            )
                        }
                    }
                }
            }
        }
        .navigationDestination(isPresented: $showDetail) {
            TerritoryDetailView(viewModel: viewModel, onDismiss: {
                showDetail = false
            })
        }
        .sheet(isPresented: $viewModel.isAddingNew) {
            NavigationStack {
                TerritoryDetailView(viewModel: viewModel, onDismiss: {
                    viewModel.isAddingNew = false
                })
            }
        }
        .alert("Delete Territory", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.executeDelete()
            }
        } message: {
            Text("Are you sure you want to delete \"\(viewModel.territoryToDelete?.name ?? "")\"? This action cannot be undone.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text("Regions & Territories")
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text("Manage geographical distribution and access scoping.")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }

            Spacer()

            Button {
                viewModel.startAddingNew()
            } label: {
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("Add")
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
                icon: "globe.americas",
                label: "Regions",
                value: "\(viewModel.territories.count)"
            )
            statCard(
                icon: "mappin.circle.fill",
                label: "Territories",
                value: "\(viewModel.totalTerritoryCount)"
            )
            statCard(
                icon: "checkmark.circle.fill",
                label: "Active",
                value: "\(viewModel.activeRegionCount)"
            )
        }
    }

    private func statCard(icon: String, label: String, value: String) -> some View {
        SPCard(elevation: .low, padding: SpendlySpacing.md) {
            VStack(spacing: SpendlySpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(SpendlyColors.accent)

                Text(value)
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text(label)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Active Regions Header

    private var activeRegionsHeader: some View {
        SPCard(elevation: .low, padding: SpendlySpacing.md) {
            HStack {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "globe")
                        .foregroundStyle(SpendlyColors.accent)
                        .font(.system(size: 16, weight: .semibold))

                    Text("Active Regions")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }

                Spacer()

                SPBadge(
                    "\(viewModel.territories.count) Regions Total",
                    style: .neutral
                )
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: SpendlySpacing.lg) {
            Image(systemName: "map")
                .font(.system(size: 48))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))

            Text("No territories found")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.secondary)

            Text("Try adjusting your search or add a new territory.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary.opacity(0.7))
                .multilineTextAlignment(.center)

            SPButton("Add Territory", icon: "plus", style: .primary) {
                viewModel.startAddingNew()
            }
            .frame(maxWidth: 200)
        }
        .padding(.vertical, SpendlySpacing.xxxl)
    }
}

// MARK: - Territory Card View

private struct TerritoryCardView: View {
    let territory: TerritoryDisplayModel
    let onTap: () -> Void
    let onDelete: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTap) {
            SPCard(elevation: .medium, padding: 0) {
                VStack(spacing: 0) {
                    // Top accent bar
                    Rectangle()
                        .fill(SpendlyColors.accent)
                        .frame(height: 3)

                    VStack(spacing: SpendlySpacing.md) {
                        // Header row: icon + name + actions
                        HStack(alignment: .top, spacing: SpendlySpacing.md) {
                            // Region icon
                            ZStack {
                                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                    .fill(SpendlyColors.accent.opacity(0.12))
                                    .frame(width: 48, height: 48)

                                Image(systemName: "safari")
                                    .font(.system(size: 22))
                                    .foregroundStyle(SpendlyColors.accent)
                            }

                            // Name and subtitle
                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text(territory.name)
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                    .lineLimit(1)

                                Text("\(territory.territoryCount) Territories \u{00B7} \(territory.stateList)")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                                    .lineLimit(1)
                            }

                            Spacer()

                            // Status badge
                            SPBadge(
                                territory.isActive ? "Active" : "Inactive",
                                style: territory.isActive ? .success : .neutral
                            )
                        }

                        SPDivider()

                        // Detail chips row
                        detailChipsRow

                        SPDivider()

                        // Bottom row: assigned techs + actions
                        HStack {
                            // Assigned tech avatars
                            assignedTechAvatars

                            Spacer()

                            // Action buttons
                            HStack(spacing: SpendlySpacing.sm) {
                                Button {
                                    onTap()
                                } label: {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 14))
                                        .foregroundStyle(SpendlyColors.secondary)
                                        .frame(width: 32, height: 32)
                                        .background(SpendlyColors.secondary.opacity(0.08))
                                        .clipShape(Circle())
                                }

                                Button {
                                    onDelete()
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14))
                                        .foregroundStyle(SpendlyColors.error)
                                        .frame(width: 32, height: 32)
                                        .background(SpendlyColors.error.opacity(0.08))
                                        .clipShape(Circle())
                                }

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                            }
                        }
                    }
                    .padding(SpendlySpacing.lg)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Detail Chips

    private var detailChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpendlySpacing.sm) {
                detailChip(icon: "mappin", text: territory.regionCode)
                detailChip(icon: "clock", text: timezoneAbbreviation)
                detailChip(icon: "percent", text: String(format: "%.2f%%", territory.taxRate))
                detailChip(icon: "dollarsign.circle", text: territory.currency)
            }
        }
    }

    private var timezoneAbbreviation: String {
        TimeZone(identifier: territory.timezone)?.abbreviation() ?? territory.timezone
    }

    private func detailChip(icon: String, text: String) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(SpendlyColors.accent)

            Text(text)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
        .padding(.horizontal, SpendlySpacing.sm)
        .padding(.vertical, SpendlySpacing.xs + 2)
        .background(SpendlyColors.accent.opacity(0.06))
        .clipShape(Capsule())
    }

    // MARK: - Assigned Tech Avatars

    private var assignedTechAvatars: some View {
        HStack(spacing: -6) {
            ForEach(Array(territory.assignedTechnicians.prefix(4).enumerated()), id: \.element.id) { index, tech in
                Text(tech.initials)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(avatarColor(for: index))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(SpendlyColors.surface(for: colorScheme), lineWidth: 2)
                    )
            }

            if territory.assignedTechnicians.count > 4 {
                Text("+\(territory.assignedTechnicians.count - 4)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(SpendlyColors.secondary)
                    .frame(width: 28, height: 28)
                    .background(SpendlyColors.secondary.opacity(0.12))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(SpendlyColors.surface(for: colorScheme), lineWidth: 2)
                    )
            }
        }
    }

    private func avatarColor(for index: Int) -> Color {
        let colors: [Color] = [SpendlyColors.accent, SpendlyColors.info, SpendlyColors.success, SpendlyColors.primary]
        return colors[index % colors.count]
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TerritoryRegionRootView()
    }
}
