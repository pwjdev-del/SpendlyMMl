import SwiftUI
import Combine
import SpendlyCore

// MARK: - AssetHealthTab

enum AssetHealthTab: String, CaseIterable {
    case overview = "Overview"
    case predictor = "Predictor"
    case history = "History"
    case pmSchedule = "PM Schedule"
}

// MARK: - AssetHealthViewModel

@Observable
final class AssetHealthViewModel {

    // MARK: - Tab State

    var selectedTab: AssetHealthTab = .overview

    // MARK: - Fleet Metrics

    var fleetMetrics: [FleetMetric] = AssetHealthMockData.fleetMetrics
    var modelName: String = "Model XJ-900 Heavy Industrial"

    // MARK: - Lifecycle Data

    var lifecyclePhases: [LifecyclePhase] = AssetHealthMockData.lifecyclePhases
    var totalUnitsForLifecycle: Int = 1_482

    // MARK: - Failure Analysis

    var failureCauses: [FailureCause] = AssetHealthMockData.failureCauses

    // MARK: - Regional Data

    var regionalSummaries: [RegionalAssetSummary] = AssetHealthMockData.regionalSummaries

    // MARK: - Predictor Data

    var predictedFailures: [PredictedFailure] = AssetHealthMockData.predictedFailures
    var recommendations: [MaintenanceRecommendation] = AssetHealthMockData.recommendations
    var healthInsight: PredictiveHealthInsight = AssetHealthMockData.healthInsight
    var fleetHealthScore: Double = AssetHealthMockData.predictorFleetHealth
    var fleetHealthTrend: String = AssetHealthMockData.predictorFleetHealthTrend
    var projectedROISaved: String = AssetHealthMockData.projectedROISaved
    var criticalFailuresPredicted: Int = AssetHealthMockData.criticalFailuresPredicted

    // MARK: - Service History

    var serviceHistory: [ServiceHistoryEntry] = AssetHealthMockData.serviceHistory
    var historySearchText: String = ""
    var selectedHistoryFilter: ServiceHistoryStatus? = nil

    // MARK: - Chart Data

    var lifecycleChartData: [SPChartDataPoint] = AssetHealthMockData.lifecycleChartData
    var maintenanceTrendData: [SPChartDataPoint] = AssetHealthMockData.maintenanceTrendData

    // MARK: - Action State

    var showExportSheet: Bool = false
    var showRecallConfirmation: Bool = false
    var isExporting: Bool = false

    // MARK: - Computed Properties

    var filteredServiceHistory: [ServiceHistoryEntry] {
        var results = serviceHistory

        if let filter = selectedHistoryFilter {
            results = results.filter { $0.status == filter }
        }

        if !historySearchText.isEmpty {
            let query = historySearchText.lowercased()
            results = results.filter {
                $0.title.lowercased().contains(query)
                || ($0.subtitle?.lowercased().contains(query) ?? false)
                || $0.technician.lowercased().contains(query)
            }
        }

        return results.sorted { $0.date > $1.date }
    }

    var totalServiceCost: Double {
        serviceHistory
            .compactMap(\.cost)
            .reduce(0, +)
    }

    var completedServiceCount: Int {
        serviceHistory.filter { $0.status == .completed }.count
    }

    var activeRecommendations: [MaintenanceRecommendation] {
        recommendations.filter { !$0.isDismissed }
    }

    var criticalPredictions: [PredictedFailure] {
        predictedFailures.filter { $0.riskLevel == .critical || $0.riskLevel == .high }
    }

    // MARK: - Formatted Values

    var formattedTotalCost: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: totalServiceCost)) ?? "$0"
    }

    // MARK: - Actions

    func exportReport() {
        isExporting = true
        // Simulate export delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isExporting = false
            self?.showExportSheet = false
        }
    }

    func initiateRecall() {
        showRecallConfirmation = true
    }

    func confirmRecall() {
        showRecallConfirmation = false
        // In production: trigger recall workflow via API
    }

    func acceptRecommendation(_ recommendation: MaintenanceRecommendation) {
        guard let index = recommendations.firstIndex(where: { $0.id == recommendation.id }) else { return }
        recommendations[index].isAccepted = true
    }

    func dismissRecommendation(_ recommendation: MaintenanceRecommendation) {
        guard let index = recommendations.firstIndex(where: { $0.id == recommendation.id }) else { return }
        recommendations[index].isDismissed = true
    }

    func exportHistory() {
        showExportSheet = true
        exportReport()
    }

    func scheduleMaintenance(for failure: PredictedFailure) {
        // In production: navigate to scheduling flow
    }

    func setHistoryFilter(_ status: ServiceHistoryStatus?) {
        if selectedHistoryFilter == status {
            selectedHistoryFilter = nil
        } else {
            selectedHistoryFilter = status
        }
    }

    // MARK: - Date Formatting

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
