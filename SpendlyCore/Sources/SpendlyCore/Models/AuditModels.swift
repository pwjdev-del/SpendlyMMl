import Foundation
import SwiftData

// MARK: - Audit Report

@Model
public class AuditReport {
    public var id: UUID
    public var orgID: UUID
    public var machineID: UUID
    public var auditorID: UUID
    public var title: String
    public var status: AuditStatus
    public var overallScore: Double?
    public var notes: String?
    public var completedAt: Date?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        machineID: UUID = UUID(),
        auditorID: UUID = UUID(),
        title: String = "",
        status: AuditStatus = .draft,
        overallScore: Double? = nil,
        notes: String? = nil,
        completedAt: Date? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.machineID = machineID
        self.auditorID = auditorID
        self.title = title
        self.status = status
        self.overallScore = overallScore
        self.notes = notes
        self.completedAt = completedAt
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Audit Section

@Model
public class AuditSection {
    public var id: UUID
    public var orgID: UUID
    public var auditReportID: UUID
    public var title: String
    public var score: Double?
    public var maxScore: Double
    public var findings: String?
    public var photoURLs: [String]
    public var sortOrder: Int
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        auditReportID: UUID = UUID(),
        title: String = "",
        score: Double? = nil,
        maxScore: Double = 10,
        findings: String? = nil,
        photoURLs: [String] = [],
        sortOrder: Int = 0,
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.auditReportID = auditReportID
        self.title = title
        self.score = score
        self.maxScore = maxScore
        self.findings = findings
        self.photoURLs = photoURLs
        self.sortOrder = sortOrder
        self.syncStatus = syncStatus
    }
}
