import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Feedback Display Model

struct FeedbackDisplayModel: Identifiable, Hashable {
    let id: UUID
    let ticketNumber: String?
    let customerName: String
    let technicianName: String?
    let serviceSummary: String
    let overallRating: Int
    let responseTimeRating: Int?
    let professionalismRating: Int?
    let resolutionRating: Int?
    let comments: String?
    let wouldRecommend: Bool?
    let submittedAt: Date

    init(
        id: UUID = UUID(),
        ticketNumber: String? = nil,
        customerName: String,
        technicianName: String? = nil,
        serviceSummary: String,
        overallRating: Int,
        responseTimeRating: Int? = nil,
        professionalismRating: Int? = nil,
        resolutionRating: Int? = nil,
        comments: String? = nil,
        wouldRecommend: Bool? = nil,
        submittedAt: Date
    ) {
        self.id = id
        self.ticketNumber = ticketNumber
        self.customerName = customerName
        self.technicianName = technicianName
        self.serviceSummary = serviceSummary
        self.overallRating = overallRating
        self.responseTimeRating = responseTimeRating
        self.professionalismRating = professionalismRating
        self.resolutionRating = resolutionRating
        self.comments = comments
        self.wouldRecommend = wouldRecommend
        self.submittedAt = submittedAt
    }
}

// MARK: - Pending Survey

struct PendingSurvey: Identifiable {
    let id: UUID
    let ticketNumber: String
    let customerName: String
    let technicianName: String
    let serviceSummary: String
    let completedAt: Date

    init(
        id: UUID = UUID(),
        ticketNumber: String,
        customerName: String,
        technicianName: String,
        serviceSummary: String,
        completedAt: Date
    ) {
        self.id = id
        self.ticketNumber = ticketNumber
        self.customerName = customerName
        self.technicianName = technicianName
        self.serviceSummary = serviceSummary
        self.completedAt = completedAt
    }
}

// MARK: - Mock Data

enum CustomerFeedbackMockData {

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    static let feedbackEntries: [FeedbackDisplayModel] = [
        FeedbackDisplayModel(
            ticketNumber: "TK-2026-004",
            customerName: "Industrial Logistics Corp.",
            technicianName: "Mike Chen",
            serviceSummary: "PLC Program Upload Error - Firmware rollback and re-upload",
            overallRating: 5,
            responseTimeRating: 5,
            professionalismRating: 5,
            resolutionRating: 5,
            comments: "Excellent service! Mike diagnosed the issue quickly and had the system back online within hours. Very professional and knowledgeable.",
            wouldRecommend: true,
            submittedAt: daysAgo(12)
        ),
        FeedbackDisplayModel(
            ticketNumber: "TK-2025-098",
            customerName: "Pacific Foods Inc.",
            technicianName: "John D.",
            serviceSummary: "Conveyor belt motor replacement and alignment",
            overallRating: 4,
            responseTimeRating: 3,
            professionalismRating: 5,
            resolutionRating: 4,
            comments: "Great work on the repair. The motor runs smoothly now. Response time could have been a bit faster given the production impact.",
            wouldRecommend: true,
            submittedAt: daysAgo(20)
        ),
        FeedbackDisplayModel(
            ticketNumber: "TK-2025-091",
            customerName: "Global Wrap Solutions",
            technicianName: "Tom Brewer",
            serviceSummary: "Annual preventive maintenance on blown film line",
            overallRating: 5,
            responseTimeRating: 5,
            professionalismRating: 5,
            resolutionRating: 5,
            comments: "Tom is always thorough and professional. Preventive maintenance was completed on schedule with zero disruption to production.",
            wouldRecommend: true,
            submittedAt: daysAgo(35)
        ),
        FeedbackDisplayModel(
            ticketNumber: "TK-2025-087",
            customerName: "Midwest Manufacturing",
            technicianName: "Sarah Lopez",
            serviceSummary: "Emergency electrical panel repair",
            overallRating: 3,
            responseTimeRating: 2,
            professionalismRating: 4,
            resolutionRating: 3,
            comments: "The repair was adequate but took longer than expected. Had to wait 8 hours for a technician to arrive for what was marked as an emergency.",
            wouldRecommend: nil,
            submittedAt: daysAgo(45)
        ),
        FeedbackDisplayModel(
            customerName: "TechCorp Solutions",
            technicianName: "Marcus Chen",
            serviceSummary: "Sensor array firmware update and calibration",
            overallRating: 5,
            responseTimeRating: 4,
            professionalismRating: 5,
            resolutionRating: 5,
            comments: "Marcus updated all 12 sensors efficiently. Detection accuracy has noticeably improved. Highly recommended.",
            wouldRecommend: true,
            submittedAt: daysAgo(8)
        ),
    ]

    static let pendingSurveys: [PendingSurvey] = [
        PendingSurvey(
            ticketNumber: "TK-2026-002",
            customerName: "Pacific Foods Inc.",
            technicianName: "John D.",
            serviceSummary: "Hydraulic Seal Array Failure - Seal replacement",
            completedAt: daysAgo(2)
        ),
        PendingSurvey(
            ticketNumber: "TK-2026-003",
            customerName: "Global Wrap Solutions",
            technicianName: "Tom Brewer",
            serviceSummary: "Cylinder Pressure Drop - Pneumatic fitting replacement",
            completedAt: daysAgo(1)
        ),
    ]
}
