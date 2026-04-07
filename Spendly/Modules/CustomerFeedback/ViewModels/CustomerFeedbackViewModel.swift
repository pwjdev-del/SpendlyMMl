import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Feedback Tab

enum FeedbackTab: String, CaseIterable {
    case responses = "Responses"
    case pending   = "Pending"
    case analytics = "Analytics"
}

// MARK: - ViewModel

@Observable
final class CustomerFeedbackViewModel {

    // MARK: Data

    var feedbackEntries: [FeedbackDisplayModel] = CustomerFeedbackMockData.feedbackEntries
    var pendingSurveys: [PendingSurvey] = CustomerFeedbackMockData.pendingSurveys

    // MARK: UI State

    var selectedTab: FeedbackTab = .responses
    var searchText: String = ""
    var selectedFeedback: FeedbackDisplayModel? = nil
    var showFeedbackDetail: Bool = false
    var showSurveyForm: Bool = false
    var selectedSurvey: PendingSurvey? = nil

    // MARK: Survey Form State

    var surveyOverallRating: Int = 0
    var surveyResponseTimeRating: Int = 0
    var surveyProfessionalismRating: Int = 0
    var surveyResolutionRating: Int = 0
    var surveyComments: String = ""
    var surveyWouldRecommend: Bool? = nil
    var isSubmittingSurvey: Bool = false
    var showSubmitSuccess: Bool = false

    // MARK: - Computed

    var filteredFeedback: [FeedbackDisplayModel] {
        var result = feedbackEntries

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.customerName.lowercased().contains(query) ||
                ($0.technicianName?.lowercased().contains(query) ?? false) ||
                $0.serviceSummary.lowercased().contains(query) ||
                ($0.ticketNumber?.lowercased().contains(query) ?? false) ||
                ($0.comments?.lowercased().contains(query) ?? false)
            }
        }

        return result.sorted { $0.submittedAt > $1.submittedAt }
    }

    // MARK: KPIs

    var averageOverallRating: Double {
        guard !feedbackEntries.isEmpty else { return 0 }
        return Double(feedbackEntries.reduce(0) { $0 + $1.overallRating }) / Double(feedbackEntries.count)
    }

    var csatScore: Int {
        guard !feedbackEntries.isEmpty else { return 0 }
        let satisfied = feedbackEntries.filter { $0.overallRating >= 4 }.count
        return Int(Double(satisfied) / Double(feedbackEntries.count) * 100)
    }

    var npsScore: Int {
        guard !feedbackEntries.isEmpty else { return 0 }
        let promoters = feedbackEntries.filter { $0.wouldRecommend == true }.count
        let detractors = feedbackEntries.filter { $0.wouldRecommend == false }.count
        let total = feedbackEntries.count
        return Int((Double(promoters) - Double(detractors)) / Double(total) * 100)
    }

    var totalResponses: Int { feedbackEntries.count }

    var pendingCount: Int { pendingSurveys.count }

    var averageResponseTimeRating: Double {
        let rated = feedbackEntries.compactMap(\.responseTimeRating)
        guard !rated.isEmpty else { return 0 }
        return Double(rated.reduce(0, +)) / Double(rated.count)
    }

    var averageProfessionalismRating: Double {
        let rated = feedbackEntries.compactMap(\.professionalismRating)
        guard !rated.isEmpty else { return 0 }
        return Double(rated.reduce(0, +)) / Double(rated.count)
    }

    var averageResolutionRating: Double {
        let rated = feedbackEntries.compactMap(\.resolutionRating)
        guard !rated.isEmpty else { return 0 }
        return Double(rated.reduce(0, +)) / Double(rated.count)
    }

    var ratingDistribution: [(Int, Int)] {
        (1...5).map { stars in
            (stars, feedbackEntries.filter { $0.overallRating == stars }.count)
        }
    }

    // MARK: - Actions

    func selectFeedback(_ feedback: FeedbackDisplayModel) {
        selectedFeedback = feedback
        showFeedbackDetail = true
    }

    func startSurvey(for survey: PendingSurvey) {
        selectedSurvey = survey
        resetSurveyForm()
        showSurveyForm = true
    }

    func submitSurvey() {
        guard let survey = selectedSurvey, surveyOverallRating > 0 else { return }
        isSubmittingSurvey = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }

            let feedback = FeedbackDisplayModel(
                ticketNumber: survey.ticketNumber,
                customerName: survey.customerName,
                technicianName: survey.technicianName,
                serviceSummary: survey.serviceSummary,
                overallRating: self.surveyOverallRating,
                responseTimeRating: self.surveyResponseTimeRating > 0 ? self.surveyResponseTimeRating : nil,
                professionalismRating: self.surveyProfessionalismRating > 0 ? self.surveyProfessionalismRating : nil,
                resolutionRating: self.surveyResolutionRating > 0 ? self.surveyResolutionRating : nil,
                comments: self.surveyComments.isEmpty ? nil : self.surveyComments,
                wouldRecommend: self.surveyWouldRecommend,
                submittedAt: Date()
            )

            self.feedbackEntries.insert(feedback, at: 0)
            self.pendingSurveys.removeAll { $0.id == survey.id }
            self.isSubmittingSurvey = false
            self.showSubmitSuccess = true
            self.showSurveyForm = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showSubmitSuccess = false
            }
        }
    }

    func resetSurveyForm() {
        surveyOverallRating = 0
        surveyResponseTimeRating = 0
        surveyProfessionalismRating = 0
        surveyResolutionRating = 0
        surveyComments = ""
        surveyWouldRecommend = nil
    }

    // MARK: - Formatting

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
