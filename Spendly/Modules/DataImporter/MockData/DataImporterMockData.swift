import Foundation
import SpendlyCore

// MARK: - Import Record Status

enum ImportRecordStatus: String, CaseIterable {
    case valid
    case warning

    var icon: String {
        switch self {
        case .valid:   return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - Import Record

struct ImportRecord: Identifiable {
    let id = UUID()
    let status: ImportRecordStatus
    let serialID: String
    let model: String
    let siteLocation: String

    var isModelMissing: Bool {
        model == "MISSING_VAL"
    }
}

// MARK: - Entity Type

enum ImportEntityType: String, CaseIterable, Identifiable {
    case machineFleet = "Machine Fleet"
    case customerAccounts = "Customer Accounts"
    case fieldTechnicians = "Field Technicians"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .machineFleet:      return "gearshape.2.fill"
        case .customerAccounts:  return "person.2.fill"
        case .fieldTechnicians:  return "wrench.and.screwdriver.fill"
        }
    }
}

// MARK: - Import Phase

enum ImportPhase: Equatable {
    case idle
    case validating
    case importing(progress: Double)
    case complete
}

// MARK: - Mock Data

enum DataImporterMockData {

    /// Five mock import records matching the Stitch design preview table.
    /// One record has a warning (missing model value).
    static let sampleRecords: [ImportRecord] = [
        ImportRecord(
            status: .valid,
            serialID: "MCH-90821-X",
            model: "Titan Drill-4",
            siteLocation: "Zone A-12"
        ),
        ImportRecord(
            status: .valid,
            serialID: "MCH-90822-X",
            model: "Titan Drill-4",
            siteLocation: "Zone B-04"
        ),
        ImportRecord(
            status: .warning,
            serialID: "MCH-90823-X",
            model: "MISSING_VAL",
            siteLocation: "Zone C-01"
        ),
        ImportRecord(
            status: .valid,
            serialID: "MCH-90824-X",
            model: "Atlas-P90",
            siteLocation: "Zone D-09"
        ),
        ImportRecord(
            status: .valid,
            serialID: "MCH-90825-X",
            model: "Atlas-P90",
            siteLocation: "Zone A-05"
        )
    ]

    static var totalRecordCount: Int { 124 }

    static var warningCount: Int {
        sampleRecords.filter { $0.status == .warning }.count
    }
}
