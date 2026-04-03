import SwiftUI
import SpendlyCore

// MARK: - ViewModel

@Observable
final class MappingOversightViewModel {

    // MARK: Data

    var bottlenecks: [BottleneckItem] = []
    var organizations: [MappingOrganization] = []
    var drillDownNodes: [DrillDownNode] = []
    var suggestions: [AISuggestion] = []

    // MARK: Metrics

    var totalRisks: Int = 24
    var totalRisksTrend: String = "-12% from last week"
    var autoResolved: Int = 182
    var autoResolvedPercent: Double = 0.75

    // MARK: Search & Filters

    var searchText: String = ""
    var activeFilterLabel: String = "Active Risks"
    var dateFilterLabel: String = "Last 30 Days"

    // MARK: State

    var selectedOrganization: MappingOrganization?
    var showDrillDown: Bool = false
    var showEmergencyAlert: Bool = false
    var showDeployConfirmation: Bool = false

    // MARK: Filtered Data

    var filteredOrganizations: [MappingOrganization] {
        guard !searchText.isEmpty else { return organizations }
        let query = searchText.lowercased()
        return organizations.filter {
            $0.name.lowercased().contains(query)
            || $0.initials.lowercased().contains(query)
            || $0.statusDetail.lowercased().contains(query)
        }
    }

    // MARK: Chart Data

    var bottleneckChartData: [SPChartDataPoint] {
        bottlenecks.map { SPChartDataPoint(label: $0.label, value: $0.value) }
    }

    // MARK: Init

    init() {
        loadMockData()
    }

    // MARK: Actions

    func selectOrganization(_ org: MappingOrganization) {
        selectedOrganization = org
        showDrillDown = true
    }

    func closeDrillDown() {
        showDrillDown = false
        selectedOrganization = nil
    }

    func proposeSolution(for suggestion: AISuggestion) {
        // In production this would trigger the AI resolution flow
    }

    func dismissSuggestion(_ suggestion: AISuggestion) {
        suggestions.removeAll { $0.id == suggestion.id }
    }

    func triggerEmergency() {
        showEmergencyAlert = true
    }

    func confirmEmergency() {
        showEmergencyAlert = false
    }

    func deployMapping() {
        showDeployConfirmation = true
    }

    func confirmDeploy() {
        showDeployConfirmation = false
    }

    // MARK: Mock Data

    private func loadMockData() {
        bottlenecks = MappingOversightMockData.bottlenecks
        organizations = MappingOversightMockData.organizations
        drillDownNodes = MappingOversightMockData.drillDownNodes
        suggestions = MappingOversightMockData.suggestions
    }
}
