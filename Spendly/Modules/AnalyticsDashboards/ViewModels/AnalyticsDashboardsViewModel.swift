import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Analytics Tab

enum AnalyticsTab: String, CaseIterable {
    case performance = "Performance"
    case roi         = "Customer ROI"

    var icon: String {
        switch self {
        case .performance: return "chart.bar.fill"
        case .roi:         return "dollarsign.arrow.circlepath"
        }
    }
}

// MARK: - Sort Options

enum TechnicianSortOption: String, CaseIterable {
    case nameAsc     = "Name (A-Z)"
    case nameDesc    = "Name (Z-A)"
    case jobsDesc    = "Jobs (High-Low)"
    case ratingDesc  = "Rating (High-Low)"
    case revenueDesc = "Revenue (High-Low)"
}

// MARK: - Bottom Nav Tab

enum AnalyticsBottomTab: String, CaseIterable {
    case dashboard = "Dashboard"
    case team      = "Team"
    case schedule  = "Schedule"
    case reports   = "Reports"

    var icon: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .team:      return "person.3"
        case .schedule:  return "calendar"
        case .reports:   return "chart.bar.doc.horizontal"
        }
    }

    var filledIcon: String {
        switch self {
        case .dashboard: return "square.grid.2x2.fill"
        case .team:      return "person.3.fill"
        case .schedule:  return "calendar"
        case .reports:   return "chart.bar.doc.horizontal.fill"
        }
    }
}

// MARK: - ViewModel

@Observable
final class AnalyticsDashboardsViewModel {

    // MARK: Data
    var technicians: [TechnicianPerformance] = AnalyticsDashboardsMockData.technicians
    var weeklyJobs: [WeeklyJobsDataPoint] = AnalyticsDashboardsMockData.weeklyJobs
    var roiAssets: [ROIAsset] = AnalyticsDashboardsMockData.roiAssets
    var regions: [RegionSummary] = AnalyticsDashboardsMockData.regions
    var savedComparisonGroups: [ComparisonGroup] = AnalyticsDashboardsMockData.savedComparisonGroups

    // MARK: UI State
    var selectedTab: AnalyticsTab = .performance
    var selectedBottomTab: AnalyticsBottomTab = .dashboard
    var searchText: String = ""
    var showFilterModal: Bool = false
    var selectedDateRange: AnalyticsDateRange = .last30Days
    var sortOption: TechnicianSortOption = .jobsDesc
    var selectedTechnician: TechnicianPerformance?
    var showTechDetail: Bool = false
    var showCompareSheet: Bool = false
    var selectedRegion: String = "All Regions"
    var selectedTechFilter: String = "All Technicians"

    // Compare
    var compareTechIDs: Set<UUID> = []
    var newGroupName: String = ""

    // MARK: Filter Sections

    var filterSections: [SPFilterSection] = [
        SPFilterSection(
            title: "Date Range",
            type: .radio,
            options: AnalyticsDateRange.allCases.dropLast().map { SPFilterOption(label: $0.rawValue) }
        ),
        SPFilterSection(
            title: "Region",
            type: .checkbox,
            options: [
                SPFilterOption(label: "North"),
                SPFilterOption(label: "South"),
                SPFilterOption(label: "East"),
                SPFilterOption(label: "West"),
            ]
        ),
        SPFilterSection(
            title: "Status",
            type: .checkbox,
            options: TechnicianStatus.allCases.map { SPFilterOption(label: $0.rawValue) }
        ),
        SPFilterSection(
            title: "Specialty",
            type: .checkbox,
            options: [
                SPFilterOption(label: "HVAC"),
                SPFilterOption(label: "Electrician"),
                SPFilterOption(label: "Plumbing"),
                SPFilterOption(label: "General"),
            ]
        ),
    ]

    // MARK: - KPIs (Platform)

    var totalJobsCompleted: String { "\(AnalyticsDashboardsMockData.totalJobsCompleted)" }
    var totalJobsTrend: String { AnalyticsDashboardsMockData.totalJobsTrend }
    var avgResponseTime: String { AnalyticsDashboardsMockData.avgResponseTime }
    var avgResponseTrend: String { AnalyticsDashboardsMockData.avgResponseTrend }
    var avgRating: String { AnalyticsDashboardsMockData.avgRating }
    var avgRatingTrend: String { AnalyticsDashboardsMockData.avgRatingTrend }
    var totalRevenue: String { AnalyticsDashboardsMockData.totalRevenue }
    var totalRevenueTrend: String { AnalyticsDashboardsMockData.totalRevenueTrend }

    // MARK: - KPIs (ROI)

    var downtimePrevented: String { "\(AnalyticsDashboardsMockData.downtimePrevented) Hours" }
    var downtimeTrend: String { AnalyticsDashboardsMockData.downtimeTrend }
    var estimatedSavings: String { AnalyticsDashboardsMockData.estimatedSavings }
    var machineHealthScore: Int { AnalyticsDashboardsMockData.machineHealthScore }
    var totalROIValue: String { AnalyticsDashboardsMockData.totalROIValue }

    // MARK: - Team Skill Averages

    var teamSkills: SkillScores { AnalyticsDashboardsMockData.teamSkillAverage }

    // MARK: - Computed

    var filteredTechnicians: [TechnicianPerformance] {
        var result = technicians

        // Search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.specialty.lowercased().contains(query) ||
                $0.region.lowercased().contains(query)
            }
        }

        // Region filter
        let regionSection = filterSections.first(where: { $0.title == "Region" })
        let selectedRegions = regionSection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedRegions.isEmpty {
            result = result.filter { selectedRegions.contains($0.region) }
        }

        // Status filter
        let statusSection = filterSections.first(where: { $0.title == "Status" })
        let selectedStatuses = statusSection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedStatuses.isEmpty {
            result = result.filter { selectedStatuses.contains($0.statusLabel) }
        }

        // Specialty filter
        let specSection = filterSections.first(where: { $0.title == "Specialty" })
        let selectedSpecs = specSection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedSpecs.isEmpty {
            result = result.filter { tech in
                selectedSpecs.contains(where: { tech.specialty.lowercased().contains($0.lowercased()) })
            }
        }

        // Sort
        switch sortOption {
        case .nameAsc:
            result.sort { $0.name < $1.name }
        case .nameDesc:
            result.sort { $0.name > $1.name }
        case .jobsDesc:
            result.sort { $0.jobsCompleted > $1.jobsCompleted }
        case .ratingDesc:
            result.sort { $0.avgRating > $1.avgRating }
        case .revenueDesc:
            result.sort { $0.revenue > $1.revenue }
        }

        return result
    }

    var activeFilterCount: Int {
        filterSections.flatMap(\.options).filter(\.isSelected).count
    }

    var jobsPerWeekChartData: [SPChartDataPoint] {
        weeklyJobs.map { SPChartDataPoint(label: $0.label, value: Double($0.currentValue)) }
    }

    var teamSkillChartData: [SPChartDataPoint] {
        [
            SPChartDataPoint(label: "Speed", value: teamSkills.speed * 100),
            SPChartDataPoint(label: "Quality", value: teamSkills.quality * 100),
            SPChartDataPoint(label: "Compliance", value: teamSkills.compliance * 100),
            SPChartDataPoint(label: "Comm", value: teamSkills.communication * 100),
        ]
    }

    // MARK: - Compare

    var comparedTechnicians: [TechnicianPerformance] {
        technicians.filter { compareTechIDs.contains($0.id) }
    }

    var canSaveGroup: Bool {
        compareTechIDs.count >= 2 && !newGroupName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Actions

    func selectTechnician(_ tech: TechnicianPerformance) {
        selectedTechnician = tech
        showTechDetail = true
    }

    func toggleCompare(_ techID: UUID) {
        if compareTechIDs.contains(techID) {
            compareTechIDs.remove(techID)
        } else {
            compareTechIDs.insert(techID)
        }
    }

    func saveComparisonGroup() {
        guard canSaveGroup else { return }
        let group = ComparisonGroup(
            id: UUID(),
            name: newGroupName.trimmingCharacters(in: .whitespaces),
            technicianIDs: Array(compareTechIDs),
            createdDate: Date()
        )
        savedComparisonGroups.append(group)
        newGroupName = ""
    }

    func loadComparisonGroup(_ group: ComparisonGroup) {
        compareTechIDs = Set(group.technicianIDs)
        showCompareSheet = true
    }

    func deleteComparisonGroup(_ group: ComparisonGroup) {
        savedComparisonGroups.removeAll { $0.id == group.id }
    }

    func regionTechnicians(for region: String) -> [TechnicianPerformance] {
        technicians.filter { $0.region == region }
    }

    // MARK: - ROI Computed

    var roiBreakdownRows: [SPDataRow] {
        roiAssets.map { asset in
            SPDataRow(cells: [asset.assetID, asset.serviceType, asset.potentialRisk, asset.formattedValue])
        }
    }

    var workRatioChartData: [SPChartDataPoint] {
        AnalyticsDashboardsMockData.workRatioMonths.map {
            SPChartDataPoint(label: $0.month, value: $0.proactive * 100)
        }
    }
}
