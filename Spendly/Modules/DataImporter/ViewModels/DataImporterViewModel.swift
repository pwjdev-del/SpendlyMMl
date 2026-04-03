import SwiftUI
import SpendlyCore

// MARK: - DataImporterViewModel

@Observable
final class DataImporterViewModel {

    // MARK: - State

    var selectedEntity: ImportEntityType = .machineFleet
    var hasFileAttached: Bool = false
    var attachedFileName: String? = nil
    var records: [ImportRecord] = DataImporterMockData.sampleRecords
    var importPhase: ImportPhase = .idle
    var showImportComplete: Bool = false
    var selectedTabIndex: Int = 0

    // MARK: - Tab Items

    let tabItems: [SPTabItem] = [
        SPTabItem(icon: "square.and.arrow.down", activeIcon: "square.and.arrow.down.fill", title: "Import"),
        SPTabItem(icon: "clock.arrow.circlepath", activeIcon: "clock.arrow.circlepath", title: "Logs"),
        SPTabItem(icon: "gearshape", activeIcon: "gearshape.fill", title: "Settings")
    ]

    // MARK: - Computed Properties

    var totalRecordCount: Int {
        DataImporterMockData.totalRecordCount
    }

    var warningCount: Int {
        records.filter { $0.status == .warning }.count
    }

    var validCount: Int {
        records.filter { $0.status == .valid }.count
    }

    var isReadyToImport: Bool {
        hasFileAttached && importPhase == .idle
    }

    var importProgress: Double {
        switch importPhase {
        case .importing(let progress): return progress
        case .complete:                return 1.0
        default:                       return 0.0
        }
    }

    var progressPercentage: Int {
        Int(importProgress * 100)
    }

    var isImporting: Bool {
        if case .importing = importPhase { return true }
        return false
    }

    // MARK: - Actions

    func selectEntity(_ entity: ImportEntityType) {
        selectedEntity = entity
    }

    func simulateFileAttach() {
        hasFileAttached = true
        attachedFileName = "fleet_ledger_2026_Q2.csv"
        records = DataImporterMockData.sampleRecords
        importPhase = .idle
        showImportComplete = false
    }

    func downloadTemplate() {
        // Placeholder: in production this would trigger a file download
    }

    @MainActor
    func startImport() async {
        guard isReadyToImport else { return }

        importPhase = .importing(progress: 0.0)

        // Simulate import progress over ~3 seconds
        let steps = 20
        for step in 1...steps {
            try? await Task.sleep(for: .milliseconds(150))
            let progress = Double(step) / Double(steps)
            importPhase = .importing(progress: progress)
        }

        importPhase = .complete
        showImportComplete = true
    }

    func resetImport() {
        importPhase = .idle
        hasFileAttached = false
        attachedFileName = nil
        showImportComplete = false
    }
}
