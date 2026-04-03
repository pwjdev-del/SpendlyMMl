import Foundation
import SwiftData

// MARK: - Service Trip

@Model
public class ServiceTrip {
    public var id: UUID
    public var orgID: UUID
    public var ticketID: UUID?
    public var technicianID: UUID
    public var customerID: UUID
    public var machineID: UUID?
    public var status: TripStatus
    public var scheduledDate: Date
    public var startTime: Date?
    public var endTime: Date?
    public var summary: String?
    public var technicianNotes: String?
    public var customerSignatureURL: String?
    public var latitude: Double?
    public var longitude: Double?
    public var partsUsed: String?
    public var hoursWorked: Double?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        ticketID: UUID? = nil,
        technicianID: UUID = UUID(),
        customerID: UUID = UUID(),
        machineID: UUID? = nil,
        status: TripStatus = .scheduled,
        scheduledDate: Date = Date(),
        startTime: Date? = nil,
        endTime: Date? = nil,
        summary: String? = nil,
        technicianNotes: String? = nil,
        customerSignatureURL: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        partsUsed: String? = nil,
        hoursWorked: Double? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.ticketID = ticketID
        self.technicianID = technicianID
        self.customerID = customerID
        self.machineID = machineID
        self.status = status
        self.scheduledDate = scheduledDate
        self.startTime = startTime
        self.endTime = endTime
        self.summary = summary
        self.technicianNotes = technicianNotes
        self.customerSignatureURL = customerSignatureURL
        self.latitude = latitude
        self.longitude = longitude
        self.partsUsed = partsUsed
        self.hoursWorked = hoursWorked
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Ticket

@Model
public class Ticket {
    public var id: UUID
    public var orgID: UUID
    public var customerID: UUID
    public var machineID: UUID?
    public var assignedToID: UUID?
    public var title: String
    public var ticketDescription: String?
    public var status: TicketStatus
    public var priority: Int
    public var category: String?
    public var createdAt: Date
    public var updatedAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        customerID: UUID = UUID(),
        machineID: UUID? = nil,
        assignedToID: UUID? = nil,
        title: String = "",
        ticketDescription: String? = nil,
        status: TicketStatus = .open,
        priority: Int = 0,
        category: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.customerID = customerID
        self.machineID = machineID
        self.assignedToID = assignedToID
        self.title = title
        self.ticketDescription = ticketDescription
        self.status = status
        self.priority = priority
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Ticket Status History

@Model
public class TicketStatusHistory {
    public var id: UUID
    public var orgID: UUID
    public var ticketID: UUID
    public var fromStatus: TicketStatus?
    public var toStatus: TicketStatus
    public var changedByID: UUID
    public var notes: String?
    public var changedAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        ticketID: UUID = UUID(),
        fromStatus: TicketStatus? = nil,
        toStatus: TicketStatus = .open,
        changedByID: UUID = UUID(),
        notes: String? = nil,
        changedAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.ticketID = ticketID
        self.fromStatus = fromStatus
        self.toStatus = toStatus
        self.changedByID = changedByID
        self.notes = notes
        self.changedAt = changedAt
        self.syncStatus = syncStatus
    }
}
