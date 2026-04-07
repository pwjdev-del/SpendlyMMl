import Foundation
import SwiftData

// MARK: - Customer Feedback (CSAT)

@Model
public class CustomerFeedback {
    public var id: UUID
    public var orgID: UUID
    public var ticketID: UUID?
    public var serviceTripID: UUID?
    public var customerID: UUID
    public var technicianID: UUID?
    public var overallRating: Int
    public var responseTimeRating: Int?
    public var professionalismRating: Int?
    public var resolutionRating: Int?
    public var comments: String?
    public var wouldRecommend: Bool?
    public var submittedAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        ticketID: UUID? = nil,
        serviceTripID: UUID? = nil,
        customerID: UUID = UUID(),
        technicianID: UUID? = nil,
        overallRating: Int = 0,
        responseTimeRating: Int? = nil,
        professionalismRating: Int? = nil,
        resolutionRating: Int? = nil,
        comments: String? = nil,
        wouldRecommend: Bool? = nil,
        submittedAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.ticketID = ticketID
        self.serviceTripID = serviceTripID
        self.customerID = customerID
        self.technicianID = technicianID
        self.overallRating = overallRating
        self.responseTimeRating = responseTimeRating
        self.professionalismRating = professionalismRating
        self.resolutionRating = resolutionRating
        self.comments = comments
        self.wouldRecommend = wouldRecommend
        self.submittedAt = submittedAt
        self.syncStatus = syncStatus
    }
}
