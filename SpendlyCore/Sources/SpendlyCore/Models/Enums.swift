import Foundation

// MARK: - User Roles
public enum UserRole: String, Codable, Sendable, CaseIterable {
    case admin
    case serviceManager
    case technician
    case customer
}

// MARK: - Sync Status
public enum SyncStatus: String, Codable, Sendable {
    case synced
    case pending
    case failed
}

// MARK: - Ticket Status
public enum TicketStatus: String, Codable, Sendable, CaseIterable {
    case open
    case inProgress
    case onHold
    case resolved
    case closed
}

// MARK: - Trip Status
public enum TripStatus: String, Codable, Sendable, CaseIterable {
    case scheduled
    case enRoute
    case onSite
    case completed
    case cancelled
}

// MARK: - Estimate Status
public enum EstimateStatus: String, Codable, Sendable, CaseIterable {
    case draft
    case sent
    case approved
    case rejected
    case expired
}

// MARK: - Invoice Status
public enum InvoiceStatus: String, Codable, Sendable, CaseIterable {
    case draft
    case sent
    case paid
    case overdue
    case cancelled
}

// MARK: - Expense Status
public enum ExpenseStatus: String, Codable, Sendable, CaseIterable {
    case pending
    case approved
    case rejected
    case reimbursed
}

// MARK: - Machine Status
public enum MachineStatus: String, Codable, Sendable, CaseIterable {
    case operational
    case needsMaintenance
    case underRepair
    case decommissioned
}

// MARK: - Transfer Status
public enum TransferStatus: String, Codable, Sendable, CaseIterable {
    case pending
    case inTransit
    case completed
    case cancelled
}

// MARK: - Incident Severity
public enum IncidentSeverity: String, Codable, Sendable, CaseIterable {
    case low
    case medium
    case high
    case critical
}

// MARK: - Audit Status
public enum AuditStatus: String, Codable, Sendable, CaseIterable {
    case draft
    case inProgress
    case completed
    case reviewed
}

// MARK: - Article Status
public enum ArticleStatus: String, Codable, Sendable, CaseIterable {
    case draft
    case published
    case archived
}

// MARK: - Notification Type
public enum NotificationType: String, Codable, Sendable {
    case ticketAssigned
    case tripScheduled
    case invoicePaid
    case estimateApproved
    case systemAlert
    case chatMessage
}

// MARK: - Subscription Status
public enum SubscriptionStatus: String, Codable, Sendable {
    case active
    case pastDue
    case cancelled
    case trialing
}

// MARK: - Schedule Event Type
public enum ScheduleEventType: String, Codable, Sendable {
    case serviceTrip
    case meeting
    case reminder
    case timeOff
}

// MARK: - Chat Message Type
public enum ChatMessageType: String, Codable, Sendable {
    case text
    case image
    case file
    case system
}

// MARK: - Trip Type
public enum TripType: String, Codable, Sendable, CaseIterable {
    case preventive
    case corrective
    case audit
    case training
    case emergency
    case preWarrantyConversion
    case postWarrantyInspection
}

// MARK: - Ticket Priority
public enum TicketPriority: String, Codable, Sendable, CaseIterable {
    case low
    case medium
    case high
    case critical
}

// MARK: - Expense Category
public enum ExpenseCategory: String, Codable, Sendable, CaseIterable {
    case mileage
    case partsAndMaterials
    case mealsAndEntertainment
    case travel
    case other
}

// MARK: - Approval Status
public enum ApprovalStatus: String, Codable, Sendable, CaseIterable {
    case pending
    case approved
    case rejected
    case changesRequested
}

// MARK: - Permission Level
public enum PermissionLevel: String, Codable, Sendable, CaseIterable {
    case none
    case readOnly
    case readWrite
    case fullAccess
}

// MARK: - Font Choice (White-Label)
public enum FontChoice: String, Codable, Sendable, CaseIterable {
    case sansSerif
    case serif
    case mono
}

// MARK: - Corner Style (White-Label)
public enum CornerStyle: String, Codable, Sendable, CaseIterable {
    case square
    case rounded
    case extraRounded
}

// MARK: - Article Visibility
public enum ArticleVisibility: String, Codable, Sendable, CaseIterable {
    case privateOnly
    case organization
    case publicVisible
}

// MARK: - Portal
public enum Portal: String, Codable, Sendable {
    case admin
    case oem
    case customer
}
