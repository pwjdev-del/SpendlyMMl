import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Technician Performance Model

struct TechnicianPerformance: Identifiable, Hashable {
    let id: UUID
    let name: String
    let specialty: String
    let status: TechnicianStatus
    let jobsCompleted: Int
    let avgRating: Double
    let revenue: Double
    let avgResponseMinutes: Int
    let region: String
    let skillScores: SkillScores
    let weeklyJobs: [Int]          // jobs per week for 4 weeks

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.dropFirst().first?.prefix(1) ?? ""
        return "\(first)\(last)"
    }

    var formattedRevenue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: revenue)) ?? "$0"
    }

    var statusBadgeStyle: SPBadgeStyle {
        switch status {
        case .onDuty:    return .success
        case .inTransit: return .warning
        case .offDuty:   return .neutral
        }
    }

    var statusLabel: String {
        switch status {
        case .onDuty:    return "On Duty"
        case .inTransit: return "In Transit"
        case .offDuty:   return "Off Duty"
        }
    }

    var statusDotColor: Color {
        switch status {
        case .onDuty:    return SpendlyColors.success
        case .inTransit: return SpendlyColors.warning
        case .offDuty:   return SpendlyColors.secondary
        }
    }
}

enum TechnicianStatus: String, CaseIterable, Hashable {
    case onDuty    = "On Duty"
    case inTransit = "In Transit"
    case offDuty   = "Off Duty"
}

struct SkillScores: Hashable {
    let speed: Double       // 0...1
    let quality: Double
    let compliance: Double
    let communication: Double

    var speedPercent: Int { Int(speed * 100) }
    var qualityPercent: Int { Int(quality * 100) }
    var compliancePercent: Int { Int(compliance * 100) }
    var communicationPercent: Int { Int(communication * 100) }
}

// MARK: - Weekly Jobs Data Point

struct WeeklyJobsDataPoint: Identifiable {
    let id = UUID()
    let label: String
    let currentValue: Int
    let previousValue: Int
}

// MARK: - ROI Asset Model

struct ROIAsset: Identifiable, Hashable {
    let id: UUID
    let assetID: String
    let serviceType: String
    let potentialRisk: String
    let valueGenerated: Double
    let uptimePercent: Double
    let healthStatus: AssetHealthStatus

    var formattedValue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: valueGenerated)) ?? "$0"
    }
}

enum AssetHealthStatus: String, CaseIterable, Hashable {
    case stable = "STABLE"
    case alert  = "ALERT"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .stable: return .success
        case .alert:  return .error
        }
    }
}

// MARK: - Comparison Group

struct ComparisonGroup: Identifiable, Hashable {
    let id: UUID
    let name: String
    let technicianIDs: [UUID]
    let createdDate: Date
}

// MARK: - Region Summary

struct RegionSummary: Identifiable, Hashable {
    let id: UUID
    let name: String
    let jobsCompleted: Int
    let avgRating: Double
    let revenue: Double
    let technicianCount: Int

    var formattedRevenue: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: revenue)) ?? "$0"
    }
}

// MARK: - Date Range Option

enum AnalyticsDateRange: String, CaseIterable {
    case last7Days   = "Last 7 Days"
    case last30Days  = "Last 30 Days"
    case last90Days  = "Last 90 Days"
    case thisYear    = "This Year"
    case custom      = "Custom"
}

// MARK: - Mock Data

enum AnalyticsDashboardsMockData {

    // MARK: - Date Helper

    private static func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: y, month: m, day: d)) ?? Date()
    }

    // MARK: - Technicians (5 required: James Wilson, Sarah Chen, Marcus Kim, Emily Rodriguez, David Park)

    static let technicians: [TechnicianPerformance] = [
        TechnicianPerformance(
            id: UUID(),
            name: "James Wilson",
            specialty: "HVAC Specialist",
            status: .onDuty,
            jobsCompleted: 142,
            avgRating: 4.9,
            revenue: 12450,
            avgResponseMinutes: 18,
            region: "North",
            skillScores: SkillScores(speed: 0.95, quality: 0.92, compliance: 0.97, communication: 0.88),
            weeklyJobs: [34, 38, 32, 38]
        ),
        TechnicianPerformance(
            id: UUID(),
            name: "Sarah Chen",
            specialty: "Electrician",
            status: .inTransit,
            jobsCompleted: 128,
            avgRating: 4.7,
            revenue: 11200,
            avgResponseMinutes: 22,
            region: "South",
            skillScores: SkillScores(speed: 0.88, quality: 0.90, compliance: 0.93, communication: 0.91),
            weeklyJobs: [30, 35, 28, 35]
        ),
        TechnicianPerformance(
            id: UUID(),
            name: "Marcus Kim",
            specialty: "Plumbing Lead",
            status: .onDuty,
            jobsCompleted: 156,
            avgRating: 4.9,
            revenue: 14200,
            avgResponseMinutes: 15,
            region: "West",
            skillScores: SkillScores(speed: 0.96, quality: 0.94, compliance: 0.98, communication: 0.90),
            weeklyJobs: [38, 42, 36, 40]
        ),
        TechnicianPerformance(
            id: UUID(),
            name: "Emily Rodriguez",
            specialty: "General Maintenance",
            status: .offDuty,
            jobsCompleted: 105,
            avgRating: 4.8,
            revenue: 9850,
            avgResponseMinutes: 26,
            region: "East",
            skillScores: SkillScores(speed: 0.82, quality: 0.94, compliance: 0.96, communication: 0.85),
            weeklyJobs: [24, 28, 26, 27]
        ),
        TechnicianPerformance(
            id: UUID(),
            name: "David Park",
            specialty: "Electrical Lead",
            status: .onDuty,
            jobsCompleted: 135,
            avgRating: 4.8,
            revenue: 12800,
            avgResponseMinutes: 19,
            region: "West",
            skillScores: SkillScores(speed: 0.92, quality: 0.90, compliance: 0.95, communication: 0.87),
            weeklyJobs: [32, 36, 34, 33]
        ),
    ]

    // MARK: - Weekly Jobs

    static let weeklyJobs: [WeeklyJobsDataPoint] = [
        WeeklyJobsDataPoint(label: "W1", currentValue: 284, previousValue: 240),
        WeeklyJobsDataPoint(label: "W2", currentValue: 342, previousValue: 310),
        WeeklyJobsDataPoint(label: "W3", currentValue: 210, previousValue: 265),
        WeeklyJobsDataPoint(label: "W4", currentValue: 398, previousValue: 350),
    ]

    // MARK: - Team Skill Averages

    static var teamSkillAverage: SkillScores {
        let techs = technicians
        guard !techs.isEmpty else { return SkillScores(speed: 0, quality: 0, compliance: 0, communication: 0) }
        let count = Double(techs.count)
        return SkillScores(
            speed: techs.reduce(0) { $0 + $1.skillScores.speed } / count,
            quality: techs.reduce(0) { $0 + $1.skillScores.quality } / count,
            compliance: techs.reduce(0) { $0 + $1.skillScores.compliance } / count,
            communication: techs.reduce(0) { $0 + $1.skillScores.communication } / count
        )
    }

    // MARK: - ROI Assets

    static let roiAssets: [ROIAsset] = [
        ROIAsset(
            id: UUID(),
            assetID: "ASSET-9902",
            serviceType: "Predictive Lubrication",
            potentialRisk: "Bearing Seizure",
            valueGenerated: 12400,
            uptimePercent: 99.8,
            healthStatus: .stable
        ),
        ROIAsset(
            id: UUID(),
            assetID: "ASSET-1244",
            serviceType: "Vibration Calibration",
            potentialRisk: "Motor Overheat",
            valueGenerated: 8150,
            uptimePercent: 98.2,
            healthStatus: .stable
        ),
        ROIAsset(
            id: UUID(),
            assetID: "ASSET-8831",
            serviceType: "Thermal Imaging",
            potentialRisk: "Panel Arcing",
            valueGenerated: 45000,
            uptimePercent: 97.5,
            healthStatus: .stable
        ),
        ROIAsset(
            id: UUID(),
            assetID: "ASSET-5520",
            serviceType: "Pressure Monitoring",
            potentialRisk: "Hydraulic Failure",
            valueGenerated: 22800,
            uptimePercent: 94.1,
            healthStatus: .alert
        ),
        ROIAsset(
            id: UUID(),
            assetID: "ASSET-3371",
            serviceType: "Electrical Inspection",
            potentialRisk: "Short Circuit",
            valueGenerated: 18500,
            uptimePercent: 99.1,
            healthStatus: .stable
        ),
    ]

    // MARK: - ROI Work Ratio (Monthly Proactive vs Reactive)

    static let workRatioMonths: [(month: String, proactive: Double, reactive: Double)] = [
        ("JAN", 0.70, 0.20),
        ("FEB", 0.75, 0.15),
        ("MAR", 0.65, 0.25),
        ("APR", 0.85, 0.10),
        ("MAY", 0.82, 0.12),
        ("JUN", 0.88, 0.08),
    ]

    // MARK: - Regions

    static let regions: [RegionSummary] = [
        RegionSummary(id: UUID(), name: "North", jobsCompleted: 387, avgRating: 4.85, revenue: 32500, technicianCount: 4),
        RegionSummary(id: UUID(), name: "South", jobsCompleted: 310, avgRating: 4.60, revenue: 26200, technicianCount: 3),
        RegionSummary(id: UUID(), name: "East",  jobsCompleted: 342, avgRating: 4.65, revenue: 28800, technicianCount: 3),
        RegionSummary(id: UUID(), name: "West",  jobsCompleted: 425, avgRating: 4.85, revenue: 37200, technicianCount: 4),
    ]

    // MARK: - Saved Comparison Groups

    static let savedComparisonGroups: [ComparisonGroup] = [
        ComparisonGroup(
            id: UUID(),
            name: "Top HVAC Performers",
            technicianIDs: Array(technicians.filter { $0.specialty.contains("HVAC") }.map(\.id).prefix(3)),
            createdDate: date(2026, 3, 15)
        ),
        ComparisonGroup(
            id: UUID(),
            name: "West Region Team",
            technicianIDs: Array(technicians.filter { $0.region == "West" }.map(\.id)),
            createdDate: date(2026, 3, 20)
        ),
    ]

    // MARK: - Platform KPIs

    static let totalJobsCompleted = 1284
    static let totalJobsTrend = "+12.5%"
    static let avgResponseTime = "24 mins"
    static let avgResponseTrend = "-5%"
    static let avgRating = "4.8/5.0"
    static let avgRatingTrend = "+0.2%"
    static let totalRevenue = "$42,500"
    static let totalRevenueTrend = "+15.2%"

    // MARK: - ROI KPIs

    static let downtimePrevented = 412   // hours
    static let downtimeTrend = "+12%"
    static let estimatedSavings = "$184.2k"
    static let machineHealthScore = 94
    static let totalROIValue = "$106,850"
}
