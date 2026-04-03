import Foundation
import SwiftUI
import SpendlyCore

// MARK: - View Layout Mode

enum MachineVaultLayoutMode: String, CaseIterable {
    case grid
    case list

    var icon: String {
        switch self {
        case .grid: return "square.grid.2x2"
        case .list: return "list.bullet"
        }
    }
}

// MARK: - Sort Option

enum MachineVaultSortOption: String, CaseIterable {
    case nameAsc     = "Name (A-Z)"
    case nameDesc    = "Name (Z-A)"
    case healthAsc   = "Health (Low-High)"
    case healthDesc  = "Health (High-Low)"
    case newest      = "Newest First"
    case oldest      = "Oldest First"
}

// MARK: - ViewModel

@Observable
final class MachineVaultViewModel {

    // MARK: Data
    var allMachines: [VaultMachine] = MachineVaultMockData.machines
    var selectedMachine: VaultMachine?

    // MARK: UI State
    var searchText: String = ""
    var layoutMode: MachineVaultLayoutMode = .grid
    var showFilterModal: Bool = false
    var showDetail: Bool = false
    var sortOption: MachineVaultSortOption = .nameAsc

    // MARK: Filter Sections
    var filterSections: [SPFilterSection] = [
        SPFilterSection(
            title: "Machine Type",
            type: .checkbox,
            options: [
                SPFilterOption(label: "FFS"),
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
                SPFilterOption(label: "Decommissioned"),
            ]
        ),
        SPFilterSection(
            title: "Warranty",
            type: .checkbox,
            options: [
                SPFilterOption(label: "Warranty Active"),
                SPFilterOption(label: "Expiring Soon"),
                SPFilterOption(label: "Warranty Expired"),
            ]
        ),
        SPFilterSection(
            title: "Health Score",
            type: .range(min: 0, max: 100),
            options: []
        ),
    ]

    // MARK: - Computed

    var filteredMachines: [VaultMachine] {
        var result = allMachines

        // Search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { machine in
                machine.name.lowercased().contains(query) ||
                machine.model.lowercased().contains(query) ||
                machine.serialNumber.lowercased().contains(query) ||
                machine.location.lowercased().contains(query) ||
                machine.division.lowercased().contains(query) ||
                (machine.customerName?.lowercased().contains(query) ?? false)
            }
        }

        // Status filter
        let statusSection = filterSections.first(where: { $0.title == "Status" })
        let selectedStatuses = statusSection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedStatuses.isEmpty {
            result = result.filter { machine in
                selectedStatuses.contains(machine.statusLabel)
            }
        }

        // Warranty filter
        let warrantySection = filterSections.first(where: { $0.title == "Warranty" })
        let selectedWarranty = warrantySection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedWarranty.isEmpty {
            result = result.filter { machine in
                selectedWarranty.contains(machine.warrantyStatus.label)
            }
        }

        // Type filter
        let typeSection = filterSections.first(where: { $0.title == "Machine Type" })
        let selectedTypes = typeSection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedTypes.isEmpty {
            result = result.filter { machine in
                selectedTypes.contains(where: { machine.name.lowercased().contains($0.lowercased()) ||
                    machine.division.lowercased().contains($0.lowercased()) })
            }
        }

        // Sort
        switch sortOption {
        case .nameAsc:
            result.sort { $0.name < $1.name }
        case .nameDesc:
            result.sort { $0.name > $1.name }
        case .healthAsc:
            result.sort { $0.healthScore < $1.healthScore }
        case .healthDesc:
            result.sort { $0.healthScore > $1.healthScore }
        case .newest:
            result.sort { ($0.installDate ?? .distantPast) > ($1.installDate ?? .distantPast) }
        case .oldest:
            result.sort { ($0.installDate ?? .distantPast) < ($1.installDate ?? .distantPast) }
        }

        return result
    }

    var activeFilterCount: Int {
        filterSections.flatMap(\.options).filter(\.isSelected).count
    }

    // MARK: - Summary Stats

    var totalMachines: Int { allMachines.count }

    var operationalCount: Int {
        allMachines.filter { $0.status == .operational }.count
    }

    var averageHealth: Int {
        guard !allMachines.isEmpty else { return 0 }
        let total = allMachines.reduce(0.0) { $0 + $1.healthScore }
        return Int(total / Double(allMachines.count) * 100)
    }

    var needsAttentionCount: Int {
        allMachines.filter { $0.status == .needsMaintenance || $0.status == .underRepair }.count
    }

    // MARK: - Actions

    func selectMachine(_ machine: VaultMachine) {
        selectedMachine = machine
        showDetail = true
    }

    func toggleLayout() {
        withAnimation(.easeInOut(duration: 0.25)) {
            layoutMode = layoutMode == .grid ? .list : .grid
        }
    }
}
