import Foundation
import SwiftData

// MARK: - Machine Incident

@Model
public class MachineIncident {
    public var id: UUID
    public var orgID: UUID
    public var machineID: UUID
    public var reportedByID: UUID
    public var categoryID: UUID?
    public var title: String
    public var incidentDescription: String?
    public var severity: IncidentSeverity
    public var photoURLs: [String]
    public var resolution: String?
    public var resolvedAt: Date?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        machineID: UUID = UUID(),
        reportedByID: UUID = UUID(),
        categoryID: UUID? = nil,
        title: String = "",
        incidentDescription: String? = nil,
        severity: IncidentSeverity = .medium,
        photoURLs: [String] = [],
        resolution: String? = nil,
        resolvedAt: Date? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.machineID = machineID
        self.reportedByID = reportedByID
        self.categoryID = categoryID
        self.title = title
        self.incidentDescription = incidentDescription
        self.severity = severity
        self.photoURLs = photoURLs
        self.resolution = resolution
        self.resolvedAt = resolvedAt
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Incident Category

@Model
public class IncidentCategory {
    public var id: UUID
    public var orgID: UUID
    public var name: String
    public var categoryDescription: String?
    public var parentID: UUID?
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        name: String = "",
        categoryDescription: String? = nil,
        parentID: UUID? = nil,
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.name = name
        self.categoryDescription = categoryDescription
        self.parentID = parentID
        self.syncStatus = syncStatus
    }
}

// MARK: - Incident Template

@Model
public class IncidentTemplate {
    public var id: UUID
    public var orgID: UUID
    public var name: String
    public var templateDescription: String?
    public var categoryID: UUID?
    public var defaultSeverity: IncidentSeverity
    public var checklistItems: [String]
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        name: String = "",
        templateDescription: String? = nil,
        categoryID: UUID? = nil,
        defaultSeverity: IncidentSeverity = .medium,
        checklistItems: [String] = [],
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.name = name
        self.templateDescription = templateDescription
        self.categoryID = categoryID
        self.defaultSeverity = defaultSeverity
        self.checklistItems = checklistItems
        self.syncStatus = syncStatus
    }
}
