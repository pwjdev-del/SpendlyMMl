import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Sort Option

enum IncidentSortOption: String, CaseIterable {
    case newest      = "Newest First"
    case oldest      = "Oldest First"
    case severityAsc = "Severity (Low-High)"
    case severityDesc = "Severity (High-Low)"
}

// MARK: - ViewModel

@Observable
final class IncidentAnalysisViewModel {

    // MARK: Data

    var allIncidents: [AnalysisIncident] = IncidentAnalysisMockData.incidents
    var selectedIncident: AnalysisIncident?

    // MARK: UI State

    var searchText: String = ""
    var showDetail: Bool = false
    var showFilterModal: Bool = false
    var showExportConfirmation: Bool = false
    var sortOption: IncidentSortOption = .newest

    // MARK: Filter Sections

    var filterSections: [SPFilterSection] = [
        SPFilterSection(
            title: "Status",
            type: .checkbox,
            options: IncidentAnalysisStatus.allCases.map { SPFilterOption(label: $0.rawValue) }
        ),
        SPFilterSection(
            title: "Severity",
            type: .checkbox,
            options: IncidentSeverity.allCases.map { SPFilterOption(label: $0.rawValue.capitalized) }
        ),
        SPFilterSection(
            title: "Category",
            type: .checkbox,
            options: IncidentAnalysisCategory.allCases.map { SPFilterOption(label: $0.rawValue) }
        ),
    ]

    // MARK: - Computed Properties

    var filteredIncidents: [AnalysisIncident] {
        var result = allIncidents

        // Search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { incident in
                incident.title.lowercased().contains(query) ||
                incident.code.lowercased().contains(query) ||
                incident.category.rawValue.lowercased().contains(query) ||
                incident.assignedTo.lowercased().contains(query) ||
                incident.machineID.lowercased().contains(query) ||
                incident.companyName.lowercased().contains(query)
            }
        }

        // Status filter
        let statusSection = filterSections.first(where: { $0.title == "Status" })
        let selectedStatuses = statusSection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedStatuses.isEmpty {
            result = result.filter { incident in
                selectedStatuses.contains(incident.status.rawValue)
            }
        }

        // Severity filter
        let severitySection = filterSections.first(where: { $0.title == "Severity" })
        let selectedSeverities = severitySection?.options.filter(\.isSelected).map { $0.label.lowercased() } ?? []
        if !selectedSeverities.isEmpty {
            result = result.filter { incident in
                selectedSeverities.contains(incident.severity.rawValue)
            }
        }

        // Category filter
        let categorySection = filterSections.first(where: { $0.title == "Category" })
        let selectedCategories = categorySection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedCategories.isEmpty {
            result = result.filter { incident in
                selectedCategories.contains(incident.category.rawValue)
            }
        }

        // Sort
        switch sortOption {
        case .newest:
            result.sort { $0.reportedDate > $1.reportedDate }
        case .oldest:
            result.sort { $0.reportedDate < $1.reportedDate }
        case .severityAsc:
            result.sort { severityOrder($0.severity) < severityOrder($1.severity) }
        case .severityDesc:
            result.sort { severityOrder($0.severity) > severityOrder($1.severity) }
        }

        return result
    }

    var activeFilterCount: Int {
        filterSections.flatMap(\.options).filter(\.isSelected).count
    }

    // MARK: - Summary Stats

    var totalIncidents: Int { allIncidents.count }

    var activeIssuesCount: Int {
        allIncidents.filter { $0.status == .open || $0.status == .inProgress }.count
    }

    var resolutionRate: Int {
        guard !allIncidents.isEmpty else { return 0 }
        let resolved = allIncidents.filter { $0.status == .resolved || $0.status == .closed }.count
        return Int(Double(resolved) / Double(allIncidents.count) * 100)
    }

    var averageFailureProbability: Int {
        guard !allIncidents.isEmpty else { return 0 }
        let activeIncidents = allIncidents.filter { $0.status == .open || $0.status == .inProgress }
        guard !activeIncidents.isEmpty else { return 0 }
        let total = activeIncidents.reduce(0.0) { $0 + $1.failureProbability }
        return Int(total / Double(activeIncidents.count) * 100)
    }

    // MARK: - Actions

    func selectIncident(_ incident: AnalysisIncident) {
        selectedIncident = incident
        showDetail = true
    }

    func exportReport(for incident: AnalysisIncident) {
        // In production this would generate a PDF via PDFGenerator
        showExportConfirmation = true
    }

    // MARK: - Helpers

    private func severityOrder(_ severity: IncidentSeverity) -> Int {
        switch severity {
        case .low:      return 0
        case .medium:   return 1
        case .high:     return 2
        case .critical: return 3
        }
    }

    func severityBadgeStyle(for severity: IncidentSeverity) -> SPBadgeStyle {
        switch severity {
        case .low:      return .info
        case .medium:   return .warning
        case .high:     return .custom(SpendlyColors.accent)
        case .critical: return .error
        }
    }

    func failurePredictionColor(for probability: Double) -> Color {
        if probability >= 0.7 { return SpendlyColors.error }
        if probability >= 0.4 { return SpendlyColors.warning }
        return SpendlyColors.success
    }
}
