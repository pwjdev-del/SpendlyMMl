import Foundation
import SwiftData

// MARK: - SLA Policy

@Model
public class SLAPolicy {
    public var id: UUID
    public var orgID: UUID
    public var name: String
    public var policyDescription: String?
    public var responseTimeMinutes: Int
    public var resolutionTimeMinutes: Int
    public var priority: String
    public var isActive: Bool
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        name: String = "",
        policyDescription: String? = nil,
        responseTimeMinutes: Int = 240,
        resolutionTimeMinutes: Int = 1440,
        priority: String = "medium",
        isActive: Bool = true,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.name = name
        self.policyDescription = policyDescription
        self.responseTimeMinutes = responseTimeMinutes
        self.resolutionTimeMinutes = resolutionTimeMinutes
        self.priority = priority
        self.isActive = isActive
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - SLA Tracker

@Model
public class SLATracker {
    public var id: UUID
    public var orgID: UUID
    public var ticketID: UUID
    public var slaPolicyID: UUID
    public var responseDeadline: Date
    public var resolutionDeadline: Date
    public var respondedAt: Date?
    public var resolvedAt: Date?
    public var isResponseBreached: Bool
    public var isResolutionBreached: Bool
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        ticketID: UUID = UUID(),
        slaPolicyID: UUID = UUID(),
        responseDeadline: Date = Date(),
        resolutionDeadline: Date = Date(),
        respondedAt: Date? = nil,
        resolvedAt: Date? = nil,
        isResponseBreached: Bool = false,
        isResolutionBreached: Bool = false,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.ticketID = ticketID
        self.slaPolicyID = slaPolicyID
        self.responseDeadline = responseDeadline
        self.resolutionDeadline = resolutionDeadline
        self.respondedAt = respondedAt
        self.resolvedAt = resolvedAt
        self.isResponseBreached = isResponseBreached
        self.isResolutionBreached = isResolutionBreached
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}
