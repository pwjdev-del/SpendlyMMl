import Foundation
import SwiftData

// MARK: - Asset Transfer

@Model
public class AssetTransfer {
    public var id: UUID
    public var orgID: UUID
    public var machineID: UUID
    public var fromUserID: UUID?
    public var toUserID: UUID
    public var status: TransferStatus
    public var notes: String?
    public var requestedAt: Date
    public var completedAt: Date?
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        machineID: UUID = UUID(),
        fromUserID: UUID? = nil,
        toUserID: UUID = UUID(),
        status: TransferStatus = .pending,
        notes: String? = nil,
        requestedAt: Date = Date(),
        completedAt: Date? = nil,
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.machineID = machineID
        self.fromUserID = fromUserID
        self.toUserID = toUserID
        self.status = status
        self.notes = notes
        self.requestedAt = requestedAt
        self.completedAt = completedAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Custody Log

@Model
public class CustodyLog {
    public var id: UUID
    public var orgID: UUID
    public var machineID: UUID
    public var userID: UUID
    public var action: String
    public var location: String?
    public var latitude: Double?
    public var longitude: Double?
    public var timestamp: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        machineID: UUID = UUID(),
        userID: UUID = UUID(),
        action: String = "",
        location: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        timestamp: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.machineID = machineID
        self.userID = userID
        self.action = action
        self.location = location
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.syncStatus = syncStatus
    }
}
