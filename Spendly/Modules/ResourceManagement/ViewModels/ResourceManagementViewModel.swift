import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Dashboard Tab

enum ResourceDashboardTab: String, CaseIterable {
    case workload = "Workload"
    case compare = "Compare"
    case groups = "Groups"
}

// MARK: - Time Range Filter

enum WorkloadTimeRange: String, CaseIterable {
    case today = "Today"
    case weekly = "Weekly"
}

// MARK: - Compare Sort Metric

enum CompareSortMetric: String, CaseIterable {
    case jobsCompleted = "Jobs Completed"
    case rating = "Avg Rating"
    case onTime = "On-Time %"
    case responseTime = "Resp. Time"
    case revenue = "Revenue"
}

// MARK: - View Model

@Observable
final class ResourceManagementViewModel {

    // MARK: Dashboard State

    var selectedTab: ResourceDashboardTab = .workload
    var selectedTimeRange: WorkloadTimeRange = .today
    var selectedCustomerFilter: String = "All Customers"

    let customerOptions = ["All Customers", "Global Industries", "TechCorp Solutions", "Stellar Logistics"]

    // MARK: Technician Data

    var technicians: [TechnicianDisplayItem] = ResourceManagementMockData.technicians
    var unassignedRequests: [UnassignedRequest] = ResourceManagementMockData.unassignedRequests
    var priorCommitments: [PriorCommitment] = ResourceManagementMockData.priorCommitments
    var regionalSummaries: [RegionalSummary] = ResourceManagementMockData.regionalSummaries

    // MARK: Comparison State

    var selectedTechIDs: Set<UUID> = []
    var compareSortMetric: CompareSortMetric = .jobsCompleted
    var compareSearchText: String = ""

    var maxCompareSlots: Int { 2 }

    var selectedTechnicians: [TechnicianDisplayItem] {
        technicians.filter { selectedTechIDs.contains($0.id) }
    }

    var compareCandidates: [TechnicianDisplayItem] {
        let query = compareSearchText.lowercased()
        let filtered = query.isEmpty ? technicians : technicians.filter {
            $0.name.lowercased().contains(query) ||
            $0.specialty.lowercased().contains(query) ||
            $0.region.lowercased().contains(query)
        }
        return filtered
    }

    func toggleTechForComparison(_ tech: TechnicianDisplayItem) {
        if selectedTechIDs.contains(tech.id) {
            selectedTechIDs.remove(tech.id)
        } else if selectedTechIDs.count < maxCompareSlots {
            selectedTechIDs.insert(tech.id)
        }
    }

    func isTechSelected(_ tech: TechnicianDisplayItem) -> Bool {
        selectedTechIDs.contains(tech.id)
    }

    func clearComparison() {
        selectedTechIDs.removeAll()
    }

    // MARK: Saved Groups State

    var savedGroups: [SavedTechGroup] = ResourceManagementMockData.savedGroups
    var groupSearchText: String = ""
    var expandedGroupID: UUID?
    var showingCreateGroup: Bool = false
    var newGroupName: String = ""

    var filteredGroups: [SavedTechGroup] {
        guard !groupSearchText.isEmpty else { return savedGroups }
        let query = groupSearchText.lowercased()
        return savedGroups.filter { $0.name.lowercased().contains(query) }
    }

    func toggleGroupExpansion(_ group: SavedTechGroup) {
        if expandedGroupID == group.id {
            expandedGroupID = nil
        } else {
            expandedGroupID = group.id
        }
    }

    func deleteGroup(_ group: SavedTechGroup) {
        savedGroups.removeAll { $0.id == group.id }
        if expandedGroupID == group.id {
            expandedGroupID = nil
        }
    }

    func createGroup() {
        guard !newGroupName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let group = SavedTechGroup(
            id: UUID(),
            name: newGroupName.trimmingCharacters(in: .whitespaces),
            technicianCount: 0,
            memberIDs: [],
            updatedAt: Date()
        )
        savedGroups.insert(group, at: 0)
        newGroupName = ""
        showingCreateGroup = false
    }

    func membersForGroup(_ group: SavedTechGroup) -> [TechnicianDisplayItem] {
        technicians.filter { group.memberIDs.contains($0.id) }
    }

    // MARK: KPI Computed Properties

    var unassignedJobCount: Int { unassignedRequests.count }

    var totalCapacityPercent: Int {
        let totalWork = technicians.reduce(0.0) { $0 + $1.workloadHours }
        let totalCap = technicians.reduce(0.0) { $0 + $1.capacityHours }
        guard totalCap > 0 else { return 0 }
        return Int((totalWork / totalCap) * 100)
    }

    var priorityAlertCount: Int {
        unassignedRequests.filter { $0.priority == .high }.count + 3
    }

    var activeTechCount: Int {
        technicians.filter { $0.status == .onSite || $0.status == .travel }.count
    }

    var availableTechCount: Int {
        technicians.filter { $0.status == .available }.count
    }

    // MARK: Formatting

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f
    }()

    func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    func formatCurrency(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "$%.1fk", value / 1000)
        }
        return String(format: "$%.0f", value)
    }

    func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? (parts.last?.prefix(1) ?? "") : ""
        return "\(first)\(last)".uppercased()
    }

    func statusDotColor(for status: RMTechnicianStatus) -> Color {
        switch status {
        case .onSite:    return SpendlyColors.success
        case .travel:    return SpendlyColors.info
        case .available: return SpendlyColors.secondary
        case .offDuty:   return SpendlyColors.warning
        }
    }

    func workloadColor(for fraction: Double) -> Color {
        if fraction >= 0.85 { return SpendlyColors.error }
        if fraction >= 0.60 { return SpendlyColors.warning }
        return SpendlyColors.success
    }
}
