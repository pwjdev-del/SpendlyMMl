import SwiftUI
import SpendlyCore

public struct MachineVaultRootView: View {

    @State private var viewModel = MachineVaultViewModel()
    @Environment(\.colorScheme) private var colorScheme

    // Grid columns
    private var gridColumns: [GridItem] {
        [GridItem(.flexible(), spacing: SpendlySpacing.md),
         GridItem(.flexible(), spacing: SpendlySpacing.md)]
    }

    public var body: some View {
        ZStack {
            SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: SpendlySpacing.lg) {
                    headerSection
                    statsRow
                    searchAndToolbar
                    machineContent
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.top, SpendlySpacing.sm)
                .padding(.bottom, SpendlySpacing.xxxl)
            }

            // Filter overlay
            SPFilterModal(
                isPresented: $viewModel.showFilterModal,
                sections: $viewModel.filterSections
            )
        }
        .sheet(isPresented: $viewModel.showDetail) {
            if let machine = viewModel.selectedMachine {
                MachineDetailView(machine: machine)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text("Machine Vault")
                .font(SpendlyFont.largeTitle())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Text("Manage and monitor your fleet assets")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, SpendlySpacing.sm)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: SpendlySpacing.sm) {
            miniStatCard(
                title: "Total Assets",
                value: "\(viewModel.totalMachines)",
                color: SpendlyColors.primary
            )
            miniStatCard(
                title: "Operational",
                value: "\(viewModel.operationalCount)",
                color: SpendlyColors.success
            )
            miniStatCard(
                title: "Avg Health",
                value: "\(viewModel.averageHealth)%",
                color: SpendlyColors.info
            )
        }
    }

    private func miniStatCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text(title)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                .textCase(.uppercase)
                .tracking(0.5)
            Text(value)
                .font(SpendlyFont.title())
                .foregroundStyle(color)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: - Search + Toolbar

    private var searchAndToolbar: some View {
        VStack(spacing: SpendlySpacing.sm) {
            HStack(spacing: SpendlySpacing.sm) {
                SPSearchBar(
                    searchText: $viewModel.searchText,
                    showFilterButton: true,
                    onFilterTap: {
                        withAnimation {
                            viewModel.showFilterModal = true
                        }
                    }
                )

                // Layout toggle
                Button {
                    viewModel.toggleLayout()
                } label: {
                    Image(systemName: viewModel.layoutMode.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(SpendlyColors.primary)
                        .frame(width: 40, height: 40)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }
            }

            // Active filter indicator + sort
            if viewModel.activeFilterCount > 0 || viewModel.sortOption != .nameAsc {
                HStack {
                    if viewModel.activeFilterCount > 0 {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.system(size: 12))
                            Text("\(viewModel.activeFilterCount) filter\(viewModel.activeFilterCount == 1 ? "" : "s") active")
                                .font(SpendlyFont.caption())
                        }
                        .foregroundStyle(SpendlyColors.accent)
                    }

                    Spacer()

                    Menu {
                        ForEach(MachineVaultSortOption.allCases, id: \.self) { option in
                            Button {
                                viewModel.sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if viewModel.sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 11))
                            Text(viewModel.sortOption.rawValue)
                                .font(SpendlyFont.caption())
                        }
                        .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Machine Content

    @ViewBuilder
    private var machineContent: some View {
        if viewModel.filteredMachines.isEmpty {
            SPEmptyState(
                icon: "gearshape.2",
                title: "No Machines Found",
                message: "Try adjusting your search or filters to find what you're looking for."
            )
            .padding(.top, SpendlySpacing.xxxl)
        } else {
            switch viewModel.layoutMode {
            case .grid:
                machineGrid
            case .list:
                machineList
            }
        }
    }

    private var machineGrid: some View {
        LazyVGrid(columns: gridColumns, spacing: SpendlySpacing.md) {
            ForEach(viewModel.filteredMachines) { machine in
                MachineGridCard(machine: machine)
                    .onTapGesture {
                        viewModel.selectMachine(machine)
                    }
            }
        }
    }

    private var machineList: some View {
        LazyVStack(spacing: SpendlySpacing.sm) {
            ForEach(viewModel.filteredMachines) { machine in
                MachineListRow(machine: machine)
                    .onTapGesture {
                        viewModel.selectMachine(machine)
                    }
            }
        }
    }
}

// MARK: - Machine Grid Card

private struct MachineGridCard: View {

    let machine: VaultMachine
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image / Placeholder
            machineImage
                .frame(height: 110)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    SPBadge(machine.statusLabel, style: machine.statusBadgeStyle)
                        .padding(SpendlySpacing.sm)
                }

            // Info
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text(machine.name)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .lineLimit(1)

                Text(machine.serialNumber)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(SpendlyColors.secondary)
                    .lineLimit(1)

                // Health bar
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    HStack {
                        Text("Health")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                        Spacer()
                        Text("\(machine.healthPercent)%")
                            .font(SpendlyFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(healthColor)
                            .monospacedDigit()
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(SpendlyColors.secondary.opacity(0.15))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(healthColor)
                                .frame(width: geo.size.width * machine.healthScore, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
            .padding(SpendlySpacing.md)
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    @ViewBuilder
    private var machineImage: some View {
        ZStack {
            SpendlyColors.primary.opacity(colorScheme == .dark ? 0.3 : 0.08)
            Image(systemName: sfSymbolForMachine)
                .font(.system(size: 36, weight: .thin))
                .foregroundStyle(SpendlyColors.primary.opacity(0.4))
        }
    }

    private var sfSymbolForMachine: String {
        let name = machine.name.lowercased()
        if name.contains("film") { return "film.stack" }
        if name.contains("sachet") { return "shippingbox" }
        if name.contains("convert") { return "scissors" }
        if name.contains("vega") || name.contains("pouch") { return "bag" }
        return "gearshape.2"
    }

    private var healthColor: Color {
        if machine.healthScore >= 0.8 { return SpendlyColors.success }
        if machine.healthScore >= 0.5 { return SpendlyColors.warning }
        return SpendlyColors.error
    }
}

// MARK: - Machine List Row

private struct MachineListRow: View {

    let machine: VaultMachine
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: SpendlySpacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(SpendlyColors.primary.opacity(colorScheme == .dark ? 0.25 : 0.08))
                    .frame(width: 48, height: 48)
                Image(systemName: sfSymbolForMachine)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(SpendlyColors.primary)
            }

            // Details
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                HStack {
                    Text(machine.name)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Spacer()
                    SPBadge(machine.statusLabel, style: machine.statusBadgeStyle)
                }

                HStack(spacing: SpendlySpacing.lg) {
                    Label {
                        Text(machine.serialNumber)
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                    } icon: {
                        Image(systemName: "barcode")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(SpendlyColors.secondary)

                    Spacer()

                    healthPill
                }
            }

            Image(systemName: SpendlyIcon.chevronRight.systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
        }
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    private var healthPill: some View {
        HStack(spacing: SpendlySpacing.xs) {
            Circle()
                .fill(healthColor)
                .frame(width: 6, height: 6)
            Text("\(machine.healthPercent)%")
                .font(SpendlyFont.caption())
                .fontWeight(.semibold)
                .foregroundStyle(healthColor)
                .monospacedDigit()
        }
    }

    private var sfSymbolForMachine: String {
        let name = machine.name.lowercased()
        if name.contains("film") { return "film.stack" }
        if name.contains("sachet") { return "shippingbox" }
        if name.contains("convert") { return "scissors" }
        if name.contains("vega") || name.contains("pouch") { return "bag" }
        return "gearshape.2"
    }

    private var healthColor: Color {
        if machine.healthScore >= 0.8 { return SpendlyColors.success }
        if machine.healthScore >= 0.5 { return SpendlyColors.warning }
        return SpendlyColors.error
    }
}

// MARK: - Preview

#Preview("Machine Vault - Light") {
    MachineVaultRootView()
        .preferredColorScheme(.light)
}

#Preview("Machine Vault - Dark") {
    MachineVaultRootView()
        .preferredColorScheme(.dark)
}
