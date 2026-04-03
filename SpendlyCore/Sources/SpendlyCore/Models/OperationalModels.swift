import Foundation
import SwiftData

// MARK: - Schedule Event

@Model
public class ScheduleEvent {
    public var id: UUID
    public var orgID: UUID
    public var userID: UUID
    public var title: String
    public var eventDescription: String?
    public var eventType: ScheduleEventType
    public var startDate: Date
    public var endDate: Date
    public var isAllDay: Bool
    public var relatedTripID: UUID?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        userID: UUID = UUID(),
        title: String = "",
        eventDescription: String? = nil,
        eventType: ScheduleEventType = .serviceTrip,
        startDate: Date = Date(),
        endDate: Date = Date(),
        isAllDay: Bool = false,
        relatedTripID: UUID? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.userID = userID
        self.title = title
        self.eventDescription = eventDescription
        self.eventType = eventType
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.relatedTripID = relatedTripID
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Timesheet Entry

@Model
public class TimesheetEntry {
    public var id: UUID
    public var orgID: UUID
    public var userID: UUID
    public var serviceTripID: UUID?
    public var date: Date
    public var hoursWorked: Double
    public var overtimeHours: Double
    public var notes: String?
    public var isApproved: Bool
    public var approvedByID: UUID?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        userID: UUID = UUID(),
        serviceTripID: UUID? = nil,
        date: Date = Date(),
        hoursWorked: Double = 0,
        overtimeHours: Double = 0,
        notes: String? = nil,
        isApproved: Bool = false,
        approvedByID: UUID? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.userID = userID
        self.serviceTripID = serviceTripID
        self.date = date
        self.hoursWorked = hoursWorked
        self.overtimeHours = overtimeHours
        self.notes = notes
        self.isApproved = isApproved
        self.approvedByID = approvedByID
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Territory

@Model
public class Territory {
    public var id: UUID
    public var orgID: UUID
    public var name: String
    public var territoryDescription: String?
    public var assignedUserIDs: [UUID]
    public var region: String?
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        name: String = "",
        territoryDescription: String? = nil,
        assignedUserIDs: [UUID] = [],
        region: String? = nil,
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.name = name
        self.territoryDescription = territoryDescription
        self.assignedUserIDs = assignedUserIDs
        self.region = region
        self.syncStatus = syncStatus
    }
}

// MARK: - Comparison Group

@Model
public class ComparisonGroup {
    public var id: UUID
    public var orgID: UUID
    public var name: String
    public var machineIDs: [UUID]
    public var createdByID: UUID
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        name: String = "",
        machineIDs: [UUID] = [],
        createdByID: UUID = UUID(),
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.name = name
        self.machineIDs = machineIDs
        self.createdByID = createdByID
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}
