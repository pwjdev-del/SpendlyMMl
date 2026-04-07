import Foundation
import SwiftData

// MARK: - PM Schedule (Preventive Maintenance)

@Model
public class PMSchedule {
    public var id: UUID
    public var orgID: UUID
    public var machineID: UUID
    public var title: String
    public var scheduleDescription: String?
    public var frequencyDays: Int
    public var lastCompletedAt: Date?
    public var nextDueAt: Date
    public var assignedTechnicianID: UUID?
    public var checklistItems: [String]
    public var isActive: Bool
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        machineID: UUID = UUID(),
        title: String = "",
        scheduleDescription: String? = nil,
        frequencyDays: Int = 90,
        lastCompletedAt: Date? = nil,
        nextDueAt: Date = Date(),
        assignedTechnicianID: UUID? = nil,
        checklistItems: [String] = [],
        isActive: Bool = true,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.machineID = machineID
        self.title = title
        self.scheduleDescription = scheduleDescription
        self.frequencyDays = frequencyDays
        self.lastCompletedAt = lastCompletedAt
        self.nextDueAt = nextDueAt
        self.assignedTechnicianID = assignedTechnicianID
        self.checklistItems = checklistItems
        self.isActive = isActive
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - PM Completion Record

@Model
public class PMCompletionRecord {
    public var id: UUID
    public var orgID: UUID
    public var pmScheduleID: UUID
    public var technicianID: UUID
    public var completedAt: Date
    public var hoursSpent: Double
    public var notes: String?
    public var checklistResults: [String]
    public var partsUsed: [String]
    public var nextDueAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        pmScheduleID: UUID = UUID(),
        technicianID: UUID = UUID(),
        completedAt: Date = Date(),
        hoursSpent: Double = 0,
        notes: String? = nil,
        checklistResults: [String] = [],
        partsUsed: [String] = [],
        nextDueAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.pmScheduleID = pmScheduleID
        self.technicianID = technicianID
        self.completedAt = completedAt
        self.hoursSpent = hoursSpent
        self.notes = notes
        self.checklistResults = checklistResults
        self.partsUsed = partsUsed
        self.nextDueAt = nextDueAt
        self.syncStatus = syncStatus
    }
}
