import SwiftUI
import SpendlyCore

// MARK: - TerritoryRegionViewModel

@Observable
final class TerritoryRegionViewModel {

    // MARK: Data

    var territories: [TerritoryDisplayModel] = MockTerritoryData.territories

    // MARK: Search / Filter

    var searchText: String = ""

    var filteredTerritories: [TerritoryDisplayModel] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return territories
        }
        let query = searchText.lowercased()
        return territories.filter {
            $0.name.lowercased().contains(query)
            || $0.regionCode.lowercased().contains(query)
            || $0.stateList.lowercased().contains(query)
        }
    }

    // MARK: Navigation

    var selectedTerritory: TerritoryDisplayModel?
    var isAddingNew: Bool = false

    // MARK: Detail Editing State

    var editName: String = ""
    var editRegionCode: String = ""
    var editTimezone: String = ""
    var editTaxRate: String = ""
    var editCurrency: String = ""
    var editAssignedTechnicians: Set<UUID> = []

    // MARK: Available Options

    let timezoneOptions = MockTerritoryData.timezoneOptions
    let currencyOptions = MockTerritoryData.currencyOptions
    let allTechnicians = MockTechnicians.all

    // MARK: State

    var isSaving: Bool = false
    var showDeleteConfirmation: Bool = false
    var territoryToDelete: TerritoryDisplayModel?

    // MARK: - Actions

    /// Populate edit fields from an existing territory.
    func startEditing(_ territory: TerritoryDisplayModel) {
        selectedTerritory = territory
        editName = territory.name
        editRegionCode = territory.regionCode
        editTimezone = territory.timezone
        editTaxRate = String(format: "%.2f", territory.taxRate)
        editCurrency = territory.currency
        editAssignedTechnicians = Set(territory.assignedTechnicians.map(\.id))
        isAddingNew = false
    }

    /// Clear edit fields for a new territory.
    func startAddingNew() {
        selectedTerritory = nil
        editName = ""
        editRegionCode = ""
        editTimezone = timezoneOptions.first ?? ""
        editTaxRate = ""
        editCurrency = currencyOptions.first ?? ""
        editAssignedTechnicians = []
        isAddingNew = true
    }

    /// Save changes (create or update).
    func saveTerritory() {
        isSaving = true

        let assignedTechs = allTechnicians.filter { editAssignedTechnicians.contains($0.id) }
        let taxValue = Double(editTaxRate) ?? 0.0

        if let existing = selectedTerritory,
           let index = territories.firstIndex(where: { $0.id == existing.id }) {
            // Update existing
            territories[index].name = editName
            territories[index].regionCode = editRegionCode
            territories[index].timezone = editTimezone
            territories[index].taxRate = taxValue
            territories[index].currency = editCurrency
            territories[index].assignedTechnicians = assignedTechs
        } else {
            // Create new
            let newTerritory = TerritoryDisplayModel(
                id: UUID(),
                name: editName,
                regionCode: editRegionCode,
                timezone: editTimezone,
                taxRate: taxValue,
                currency: editCurrency,
                assignedTechnicians: assignedTechs,
                stateList: "",
                territoryCount: 0,
                isActive: true
            )
            territories.append(newTerritory)
        }

        isSaving = false
    }

    /// Delete a territory by id.
    func deleteTerritory(_ territory: TerritoryDisplayModel) {
        territories.removeAll { $0.id == territory.id }
    }

    /// Confirm deletion flow.
    func confirmDelete(_ territory: TerritoryDisplayModel) {
        territoryToDelete = territory
        showDeleteConfirmation = true
    }

    /// Execute pending deletion.
    func executeDelete() {
        if let territory = territoryToDelete {
            deleteTerritory(territory)
        }
        territoryToDelete = nil
        showDeleteConfirmation = false
    }

    // MARK: - Validation

    var isFormValid: Bool {
        !editName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !editRegionCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !editTimezone.isEmpty
        && !editCurrency.isEmpty
    }

    // MARK: - Helpers

    /// Human-readable timezone label.
    func timezoneLabel(for identifier: String) -> String {
        let tz = TimeZone(identifier: identifier)
        let abbreviation = tz?.abbreviation() ?? ""
        let city = identifier.components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") ?? identifier
        return abbreviation.isEmpty ? city : "\(city) (\(abbreviation))"
    }

    /// Summary stat: total territories count.
    var totalTerritoryCount: Int {
        territories.reduce(0) { $0 + $1.territoryCount }
    }

    /// Summary stat: active regions count.
    var activeRegionCount: Int {
        territories.filter(\.isActive).count
    }
}
