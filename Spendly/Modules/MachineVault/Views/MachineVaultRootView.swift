import SwiftUI
import SpendlyCore

public struct MachineVaultRootView: View {

    @State private var viewModel = MachineVaultViewModel()
    @State private var showAddMachine = false
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

            // FAB - Add Machine
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showAddMachine = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(SpendlyColors.primary)
                            .clipShape(Circle())
                            .shadow(color: SpendlyColors.primary.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, SpendlySpacing.lg)
                    .padding(.bottom, SpendlySpacing.xxl)
                }
            }
        }
        .sheet(item: $viewModel.selectedMachine) { machine in
            MachineDetailView(machine: machine, viewModel: viewModel)
        }
        .sheet(isPresented: $showAddMachine) {
            AddMachineView { newMachine in
                viewModel.addMachine(newMachine)
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

// MARK: - Add Machine View

private struct AddMachineView: View {

    var onSave: (VaultMachine) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var name = ""
    @State private var model = ""
    @State private var serialNumber = ""
    @State private var location = ""
    @State private var customer = ""
    @State private var division = ""
    @State private var notes = ""
    @State private var healthScore: Double = 0.85
    @State private var status: MachineStatus = .operational
    @State private var category: MachineTypeFilter = .ffs

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !serialNumber.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SpendlySpacing.lg) {
                        formSection(title: "Basic Information") {
                            formField(label: "Machine Name *", text: $name, placeholder: "e.g. M-200 FFS")
                            formField(label: "Model", text: $model, placeholder: "e.g. M-200-FFS-XL")
                            formField(label: "Serial Number *", text: $serialNumber, placeholder: "e.g. SN-M200-4821")
                        }

                        formSection(title: "Location & Customer") {
                            formField(label: "Location", text: $location, placeholder: "e.g. Plant A - Line 3")
                            formField(label: "Division", text: $division, placeholder: "e.g. Packaging Division")
                            formField(label: "Customer", text: $customer, placeholder: "e.g. Industrial Logistics Corp.")
                        }

                        formSection(title: "Machine Details") {
                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text("Category")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                                Picker("Category", selection: $category) {
                                    ForEach(MachineTypeFilter.allCases.filter { $0 != .all }, id: \.self) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text("Status")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                                Picker("Status", selection: $status) {
                                    Text("Operational").tag(MachineStatus.operational)
                                    Text("Needs Maintenance").tag(MachineStatus.needsMaintenance)
                                    Text("Under Repair").tag(MachineStatus.underRepair)
                                    Text("Decommissioned").tag(MachineStatus.decommissioned)
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                HStack {
                                    Text("Health Score")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondary)
                                    Spacer()
                                    Text("\(Int(healthScore * 100))%")
                                        .font(SpendlyFont.bodySemibold())
                                        .foregroundStyle(SpendlyColors.primary)
                                        .monospacedDigit()
                                }
                                Slider(value: $healthScore, in: 0...1, step: 0.01)
                                    .tint(SpendlyColors.primary)
                            }
                        }

                        formSection(title: "Notes") {
                            TextField("Additional notes...", text: $notes, axis: .vertical)
                                .font(SpendlyFont.body())
                                .lineLimit(3...6)
                                .padding(SpendlySpacing.md)
                                .background(SpendlyColors.background(for: colorScheme))
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        }
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.top, SpendlySpacing.sm)
                    .padding(.bottom, SpendlySpacing.xxxl)
                }
            }
            .navigationTitle("Add Machine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(SpendlyColors.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveMachine() }
                        .fontWeight(.semibold)
                        .foregroundStyle(isValid ? SpendlyColors.primary : SpendlyColors.secondary)
                        .disabled(!isValid)
                }
            }
        }
    }

    private func formSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            Text(title)
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            VStack(spacing: SpendlySpacing.md) {
                content()
            }
            .padding(SpendlySpacing.md)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        }
    }

    private func formField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text(label)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
            TextField(placeholder, text: text)
                .font(SpendlyFont.body())
                .padding(SpendlySpacing.md)
                .background(SpendlyColors.background(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
        }
    }

    private func saveMachine() {
        let machine = VaultMachine(
            id: UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            model: model.trimmingCharacters(in: .whitespaces),
            serialNumber: serialNumber.trimmingCharacters(in: .whitespaces),
            status: status,
            division: division.trimmingCharacters(in: .whitespaces),
            location: location.trimmingCharacters(in: .whitespaces),
            healthScore: healthScore,
            warrantyExpiry: nil,
            installDate: Date(),
            imageName: nil,
            customerName: customer.isEmpty ? nil : customer.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces),
            category: category,
            maintenanceHistory: [],
            scheduledMaintenance: []
        )
        onSave(machine)
        dismiss()
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
