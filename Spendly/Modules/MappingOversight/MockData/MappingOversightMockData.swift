import Foundation

// MARK: - Org Status

enum OrgStatus: String {
    case critical = "CRITICAL ERROR"
    case warning = "WARNING"
    case stable = "STABLE"
}

// MARK: - Bottleneck

struct BottleneckItem: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
    /// Normalized 0-1 for display height
    let normalizedValue: Double
    let isHighlighted: Bool
}

// MARK: - Organization

struct MappingOrganization: Identifiable {
    let id = UUID()
    let initials: String
    let name: String
    let lastUpdated: String
    let activeNodes: Int
    let status: OrgStatus
    let statusDetail: String
}

// MARK: - Drill-Down Node

struct DrillDownNode: Identifiable {
    let id = UUID()
    let name: String
    let label: String          // e.g. "SOURCE", "MAPPING ERROR"
    let isError: Bool
}

// MARK: - AI Suggestion

struct AISuggestion: Identifiable {
    let id = UUID()
    let description: String
    let proposedPath: String?
    let isSecondary: Bool      // dimmed / lower priority
    let optimizationNote: String?
}

// MARK: - Mock Data

enum MappingOversightMockData {

    // MARK: Bottlenecks

    static let bottlenecks: [BottleneckItem] = [
        BottleneckItem(label: "Schema Mismatch", value: 60, normalizedValue: 0.60, isHighlighted: false),
        BottleneckItem(label: "Type Conflict", value: 45, normalizedValue: 0.45, isHighlighted: false),
        BottleneckItem(label: "Null Violations", value: 92, normalizedValue: 0.92, isHighlighted: true),
        BottleneckItem(label: "Circular Logic", value: 30, normalizedValue: 0.30, isHighlighted: false),
        BottleneckItem(label: "Broken Path", value: 55, normalizedValue: 0.55, isHighlighted: false),
    ]

    // MARK: Organizations

    static let organizations: [MappingOrganization] = [
        MappingOrganization(
            initials: "NV",
            name: "Nova Ventures Corp",
            lastUpdated: "2h ago",
            activeNodes: 45,
            status: .critical,
            statusDetail: "Circular reference detected"
        ),
        MappingOrganization(
            initials: "AL",
            name: "Apex Logistics",
            lastUpdated: "14h ago",
            activeNodes: 128,
            status: .warning,
            statusDetail: "Field type mismatch (Float -> Int)"
        ),
        MappingOrganization(
            initials: "SI",
            name: "Skyline Industrials",
            lastUpdated: "1d ago",
            activeNodes: 22,
            status: .stable,
            statusDetail: "No active mapping issues"
        ),
    ]

    // MARK: Drill-Down Nodes (Nova Ventures example)

    static let drillDownNodes: [DrillDownNode] = [
        DrillDownNode(name: "User_Data_Master", label: "SOURCE", isError: false),
        DrillDownNode(name: "auth_token_ref", label: "MAPPING ERROR", isError: true),
    ]

    // MARK: AI Suggestions

    static let suggestions: [AISuggestion] = [
        AISuggestion(
            description: "AI detected that auth_token_ref is attempting to map back to its own parent User_Data_Master.",
            proposedPath: "Secure_Key_Storage.v2",
            isSecondary: false,
            optimizationNote: nil
        ),
        AISuggestion(
            description: "Redundant mapping in Email_Proxy",
            proposedPath: nil,
            isSecondary: true,
            optimizationNote: "Could consolidate 3 fields into a single object."
        ),
    ]
}
