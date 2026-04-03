import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Risk Level

enum AssetRiskLevel: String, CaseIterable {
    case critical = "Critical"
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .critical: return .error
        case .high:     return .warning
        case .medium:   return .info
        case .low:      return .success
        }
    }

    var color: Color {
        switch self {
        case .critical: return SpendlyColors.error
        case .high:     return SpendlyColors.warning
        case .medium:   return SpendlyColors.info
        case .low:      return SpendlyColors.success
        }
    }

    var numericScore: Double {
        switch self {
        case .critical: return 0.95
        case .high:     return 0.75
        case .medium:   return 0.45
        case .low:      return 0.15
        }
    }
}

// MARK: - Lifecycle Phase

enum LifecyclePhase: String {
    case warranty = "Warranty"
    case peakPerformance = "Peak Performance"
    case aging = "Aging"
    case endOfLife = "End of Life"

    var color: Color {
        switch self {
        case .warranty:        return SpendlyColors.primary
        case .peakPerformance: return SpendlyColors.accent
        case .aging:           return SpendlyColors.secondary
        case .endOfLife:       return SpendlyColors.error
        }
    }

    var proportion: Double {
        switch self {
        case .warranty:        return 0.25
        case .peakPerformance: return 0.55
        case .aging:           return 0.15
        case .endOfLife:       return 0.05
        }
    }

    var rangeLabel: String {
        switch self {
        case .warranty:        return "0-12 Mo"
        case .peakPerformance: return "1-4 Yrs"
        case .aging:           return "4-5 Yrs"
        case .endOfLife:       return "5+ Yrs"
        }
    }
}

// MARK: - Failure Cause

struct FailureCause: Identifiable {
    let id = UUID()
    let name: String
    let percentage: Double
    let color: Color
}

// MARK: - Regional Asset Summary

struct RegionalAssetSummary: Identifiable {
    let id = UUID()
    let abbreviation: String
    let name: String
    let assetCount: Int
    let healthPercentage: Double
    let isHealthy: Bool
}

// MARK: - Predicted Failure

struct PredictedFailure: Identifiable {
    let id = UUID()
    let assetName: String
    let issueType: String
    let probability: Double
    let estimatedWindow: String
    let riskLevel: AssetRiskLevel
    let icon: String
}

// MARK: - Maintenance Recommendation

struct MaintenanceRecommendation: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let riskLevel: AssetRiskLevel
    let estimatedSavings: String
    var isAccepted: Bool
    var isDismissed: Bool

    init(
        title: String,
        detail: String,
        riskLevel: AssetRiskLevel,
        estimatedSavings: String,
        isAccepted: Bool = false,
        isDismissed: Bool = false
    ) {
        self.title = title
        self.detail = detail
        self.riskLevel = riskLevel
        self.estimatedSavings = estimatedSavings
        self.isAccepted = isAccepted
        self.isDismissed = isDismissed
    }
}

// MARK: - Predictive Health Insight

struct PredictiveHealthInsight: Identifiable {
    let id = UUID()
    let title: String
    let body: String
    let correlation: Double
}

// MARK: - Service History Entry

struct ServiceHistoryEntry: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let technician: String
    let date: Date
    let cost: Double?
    let status: ServiceHistoryStatus
    let partsReplaced: [String]
    let notes: String?
}

// MARK: - Service History Status

enum ServiceHistoryStatus: String, CaseIterable {
    case completed = "Completed"
    case scheduled = "Scheduled"
    case inProgress = "In Progress"
    case cancelled = "Cancelled"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .completed:  return .success
        case .scheduled:  return .info
        case .inProgress: return .custom(SpendlyColors.primary)
        case .cancelled:  return .error
        }
    }

    var timelineStatus: SPTimelineStatus {
        switch self {
        case .completed:  return .completed
        case .scheduled:  return .upcoming
        case .inProgress: return .active
        case .cancelled:  return .default
        }
    }
}

// MARK: - Fleet Metric

struct FleetMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let trend: String?
    let trendDirection: SPTrendDirection
}

// MARK: - Mock Data

enum AssetHealthMockData {

    // MARK: - Fleet Metrics

    static let fleetMetrics: [FleetMetric] = [
        FleetMetric(
            title: "Total Units Deployed",
            value: "1,482",
            trend: "+12% YoY",
            trendDirection: .up
        ),
        FleetMetric(
            title: "Model Health Score",
            value: "94.2%",
            trend: "Stable",
            trendDirection: .flat
        ),
        FleetMetric(
            title: "Average Asset Age",
            value: "3.4 Yrs",
            trend: "Mid-Cycle",
            trendDirection: .flat
        ),
        FleetMetric(
            title: "Avg. Maintenance Cycle",
            value: "182d",
            trend: "-4% efficiency",
            trendDirection: .down
        ),
    ]

    // MARK: - Lifecycle Phases

    static let lifecyclePhases: [LifecyclePhase] = [
        .warranty,
        .peakPerformance,
        .aging,
        .endOfLife,
    ]

    // MARK: - Failure Causes

    static let failureCauses: [FailureCause] = [
        FailureCause(name: "Mechanical Stress", percentage: 0.42, color: SpendlyColors.accent),
        FailureCause(name: "Electrical Fault", percentage: 0.28, color: SpendlyColors.primary),
        FailureCause(name: "Software Sync", percentage: 0.18, color: SpendlyColors.secondary),
        FailureCause(name: "Human Interaction", percentage: 0.12, color: SpendlyColors.secondary.opacity(0.5)),
    ]

    // MARK: - Regional Breakdown

    static let regionalSummaries: [RegionalAssetSummary] = [
        RegionalAssetSummary(abbreviation: "NE", name: "NorthEast Logistics", assetCount: 82, healthPercentage: 98, isHealthy: true),
        RegionalAssetSummary(abbreviation: "GC", name: "Gulf Coast Energy", assetCount: 142, healthPercentage: 84, isHealthy: false),
        RegionalAssetSummary(abbreviation: "PC", name: "Pacific Creative", assetCount: 28, healthPercentage: 92, isHealthy: true),
        RegionalAssetSummary(abbreviation: "MW", name: "Midwest Industrial", assetCount: 310, healthPercentage: 91, isHealthy: true),
        RegionalAssetSummary(abbreviation: "SE", name: "Southeast Manufacturing", assetCount: 198, healthPercentage: 87, isHealthy: false),
    ]

    // MARK: - Predicted Failures

    static let predictedFailures: [PredictedFailure] = [
        PredictedFailure(
            assetName: "Unit XR-904 (Conveyor)",
            issueType: "Bearing Thermal Stress",
            probability: 0.98,
            estimatedWindow: "48 Hours",
            riskLevel: .critical,
            icon: "gearshape.2.fill"
        ),
        PredictedFailure(
            assetName: "Main Transformer B-2",
            issueType: "Voltage Fluctuation Alert",
            probability: 0.84,
            estimatedWindow: "5 Days",
            riskLevel: .high,
            icon: "bolt.fill"
        ),
        PredictedFailure(
            assetName: "Cooling Tower Alpha",
            issueType: "Pump Cavitation Risk",
            probability: 0.71,
            estimatedWindow: "12 Days",
            riskLevel: .medium,
            icon: "drop.fill"
        ),
        PredictedFailure(
            assetName: "Compressor Unit C-7",
            issueType: "Vibration Anomaly",
            probability: 0.55,
            estimatedWindow: "21 Days",
            riskLevel: .medium,
            icon: "waveform.path.ecg"
        ),
        PredictedFailure(
            assetName: "Generator Set D-1",
            issueType: "Oil Degradation Warning",
            probability: 0.32,
            estimatedWindow: "30 Days",
            riskLevel: .low,
            icon: "fuelpump.fill"
        ),
    ]

    // MARK: - Maintenance Recommendations

    static let recommendations: [MaintenanceRecommendation] = [
        MaintenanceRecommendation(
            title: "Replace Bearing Assembly on XR-904",
            detail: "Current vibration patterns indicate 89% correlation with historical failure mode 'Bearing Fatigue 04'. Proactive replacement will save approx. 18 hours of unscheduled downtime.",
            riskLevel: .critical,
            estimatedSavings: "$12,400"
        ),
        MaintenanceRecommendation(
            title: "Recalibrate Voltage Regulator B-2",
            detail: "Voltage spikes detected 3x in past 48 hours. Sensor data suggests regulator drift beyond acceptable tolerance. Schedule calibration within 5 business days.",
            riskLevel: .high,
            estimatedSavings: "$8,200"
        ),
        MaintenanceRecommendation(
            title: "Schedule Pump Impeller Inspection",
            detail: "Flow rate metrics trending 7% below baseline. Early-stage cavitation signatures detected. Inspection recommended within 2 weeks.",
            riskLevel: .medium,
            estimatedSavings: "$4,600"
        ),
        MaintenanceRecommendation(
            title: "Update Firmware on C-7 Sensors",
            detail: "Firmware version 2.1.4 has known vibration calculation drift. Updating to 3.0.1 will improve anomaly detection accuracy by 23%.",
            riskLevel: .low,
            estimatedSavings: "$1,200"
        ),
    ]

    // MARK: - Predictive Health Insight

    static let healthInsight = PredictiveHealthInsight(
        title: "Anomaly detected in Thermal Cycle B.",
        body: "Current vibration patterns indicate a 89% correlation with historical failure mode 'Bearing Fatigue 04'. Proactive replacement will save approx. 18 hours of unscheduled downtime next week.",
        correlation: 0.89
    )

    // MARK: - Predictor Summary Metrics

    static let predictorFleetHealth: Double = 94.2
    static let predictorFleetHealthTrend: String = "+1.4%"
    static let projectedROISaved: String = "$142.8k"
    static let criticalFailuresPredicted: Int = 8

    // MARK: - Service History Entries

    static let serviceHistory: [ServiceHistoryEntry] = [
        ServiceHistoryEntry(
            title: "Bearing Replacement",
            subtitle: "Unit XR-904 -- Conveyor System",
            technician: "Marcus Chen",
            date: makeDate(daysAgo: 3),
            cost: 2_450.00,
            status: .completed,
            partsReplaced: ["SKF 6208-2RS Bearing", "Seal Kit A-12"],
            notes: "Replaced main drive bearing. Vibration levels returned to normal operating range."
        ),
        ServiceHistoryEntry(
            title: "Voltage Regulator Calibration",
            subtitle: "Main Transformer B-2",
            technician: "Sarah Mitchel",
            date: makeDate(daysAgo: 7),
            cost: 1_180.00,
            status: .completed,
            partsReplaced: ["Voltage Regulator Module VRM-22"],
            notes: "Recalibrated output. Voltage variance reduced from 4.2% to 0.3%."
        ),
        ServiceHistoryEntry(
            title: "Pump Inspection & Cleaning",
            subtitle: "Cooling Tower Alpha",
            technician: "David Park",
            date: makeDate(daysAgo: 14),
            cost: 890.00,
            status: .completed,
            partsReplaced: ["Impeller gasket"],
            notes: "Cleaned cavitation deposits. Flow rate restored to 97% of baseline."
        ),
        ServiceHistoryEntry(
            title: "Scheduled Preventive Maintenance",
            subtitle: "Compressor Unit C-7",
            technician: "Emily Rodriguez",
            date: makeDate(daysAgo: 0),
            cost: nil,
            status: .scheduled,
            partsReplaced: [],
            notes: "Quarterly vibration analysis and oil sampling."
        ),
        ServiceHistoryEntry(
            title: "Emergency Motor Rewind",
            subtitle: "Conveyor Drive Motor M-3",
            technician: "James Wilson",
            date: makeDate(daysAgo: 21),
            cost: 5_600.00,
            status: .completed,
            partsReplaced: ["Stator winding assembly", "Thermal overload relay"],
            notes: "Motor overheated due to blocked cooling vent. Root cause addressed."
        ),
        ServiceHistoryEntry(
            title: "Firmware Update",
            subtitle: "Sensor Array -- Zone B",
            technician: "Priya Sharma",
            date: makeDate(daysAgo: 30),
            cost: 320.00,
            status: .completed,
            partsReplaced: [],
            notes: "Updated 12 sensors from v2.1.4 to v3.0.1. Anomaly detection accuracy improved."
        ),
        ServiceHistoryEntry(
            title: "Hydraulic Line Replacement",
            subtitle: "Press Unit H-9",
            technician: "Marcus Chen",
            date: makeDate(daysAgo: 45),
            cost: 3_200.00,
            status: .completed,
            partsReplaced: ["High-pressure hose assembly", "Quick-connect fittings x4"],
            notes: "Micro-leak detected at fitting junction. Full line replaced as preventive measure."
        ),
        ServiceHistoryEntry(
            title: "Oil Analysis & Change",
            subtitle: "Generator Set D-1",
            technician: "David Park",
            date: makeDate(daysAgo: 60),
            cost: 680.00,
            status: .completed,
            partsReplaced: ["Oil filter", "15W-40 synthetic (20L)"],
            notes: "Oil analysis showed elevated iron particulate. Changed oil and filter ahead of schedule."
        ),
    ]

    // MARK: - Lifecycle Distribution Chart Data

    static let lifecycleChartData: [SPChartDataPoint] = [
        SPChartDataPoint(label: "0-1Y", value: 370),
        SPChartDataPoint(label: "1-2Y", value: 312),
        SPChartDataPoint(label: "2-3Y", value: 285),
        SPChartDataPoint(label: "3-4Y", value: 220),
        SPChartDataPoint(label: "4-5Y", value: 182),
        SPChartDataPoint(label: "5+Y", value: 113),
    ]

    // MARK: - Monthly Maintenance Trend

    static let maintenanceTrendData: [SPChartDataPoint] = [
        SPChartDataPoint(label: "Oct", value: 24),
        SPChartDataPoint(label: "Nov", value: 18),
        SPChartDataPoint(label: "Dec", value: 31),
        SPChartDataPoint(label: "Jan", value: 22),
        SPChartDataPoint(label: "Feb", value: 16),
        SPChartDataPoint(label: "Mar", value: 27),
    ]

    // MARK: - Helpers

    private static func makeDate(daysAgo: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
    }
}
