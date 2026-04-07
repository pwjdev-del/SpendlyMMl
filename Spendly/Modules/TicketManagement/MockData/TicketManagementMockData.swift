import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Ticket Category

enum TicketCategory: String, CaseIterable, Hashable, Codable {
    case electrical    = "Electrical"
    case mechanical    = "Mechanical"
    case pneumatic     = "Pneumatic"
    case other         = "Other"

    var icon: String {
        switch self {
        case .electrical: return "bolt.fill"
        case .mechanical: return "gearshape.2.fill"
        case .pneumatic:  return "wind"
        case .other:      return "wrench.and.screwdriver.fill"
        }
    }

    var color: SwiftUI.Color {
        switch self {
        case .electrical: return SpendlyColors.info       // blue
        case .mechanical: return SpendlyColors.success    // green
        case .pneumatic:  return SpendlyColors.warning    // amber
        case .other:      return SpendlyColors.secondary  // slate
        }
    }
}

// MARK: - Ticket Urgency

enum TicketUrgency: String, CaseIterable, Hashable, Codable {
    case low      = "Low"
    case medium   = "Medium"
    case high     = "High"
    case critical = "Critical"

    var icon: String {
        switch self {
        case .low:      return "info.circle"
        case .medium:   return "exclamationmark.triangle"
        case .high:     return "exclamationmark.triangle.fill"
        case .critical: return "bolt.trianglebadge.exclamationmark.fill"
        }
    }

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .low:      return .success
        case .medium:   return .warning
        case .high:     return .error
        case .critical: return .custom(.black)
        }
    }
}

// MARK: - Ticket Display Status

enum TicketDisplayStatus: String, CaseIterable, Hashable, Codable {
    case all          = "All"
    case draft        = "Draft"
    case open         = "Open"
    case inProgress   = "In Progress"
    case onHold       = "On Hold"
    case resolved     = "Resolved"
    case closed       = "Closed"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .all:        return .neutral
        case .draft:      return .neutral
        case .open:       return .info
        case .inProgress: return .custom(SpendlyColors.accent)
        case .onHold:     return .warning
        case .resolved:   return .success
        case .closed:     return .neutral
        }
    }

    /// Maps to core TicketStatus (excluding .all)
    var coreStatus: TicketStatus? {
        switch self {
        case .all:        return nil
        case .draft:      return .draft
        case .open:       return .open
        case .inProgress: return .inProgress
        case .onHold:     return .onHold
        case .resolved:   return .resolved
        case .closed:     return .closed
        }
    }
}

// MARK: - Ticket Source

enum TicketSource: String, Hashable, Codable {
    case manual       = "Manual"
    case incomingCall = "Incoming Call"
    case diagnostic   = "Diagnostic"
    case offline      = "Offline Sync"
}

// MARK: - Timeline Event

struct TicketTimelineEvent: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let description: String?
    let date: Date
    let status: TicketDisplayStatus
    let performedBy: String?

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        date: Date,
        status: TicketDisplayStatus = .open,
        performedBy: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.status = status
        self.performedBy = performedBy
    }
}

// MARK: - Display Ticket

// MARK: - SLA Display Info

struct SLADisplayInfo: Hashable, Codable {
    let policyName: String
    let responseDeadline: Date
    let resolutionDeadline: Date
    let respondedAt: Date?
    let isResponseBreached: Bool
    let isResolutionBreached: Bool

    var responseRemainingMinutes: Int {
        if respondedAt != nil { return 0 }
        return max(0, Int(responseDeadline.timeIntervalSince(Date()) / 60))
    }

    var resolutionRemainingMinutes: Int {
        return max(0, Int(resolutionDeadline.timeIntervalSince(Date()) / 60))
    }

    var isAtRisk: Bool {
        (!isResponseBreached && respondedAt == nil && responseRemainingMinutes < 30) ||
        (!isResolutionBreached && resolutionRemainingMinutes < 60)
    }

    var slaStatusLabel: String {
        if isResponseBreached || isResolutionBreached { return "Breached" }
        if isAtRisk { return "At Risk" }
        return "On Track"
    }

    var slaBadgeStyle: SPBadgeStyle {
        if isResponseBreached || isResolutionBreached { return .error }
        if isAtRisk { return .warning }
        return .success
    }

    init(
        policyName: String = "Standard SLA",
        responseDeadline: Date,
        resolutionDeadline: Date,
        respondedAt: Date? = nil,
        isResponseBreached: Bool = false,
        isResolutionBreached: Bool = false
    ) {
        self.policyName = policyName
        self.responseDeadline = responseDeadline
        self.resolutionDeadline = resolutionDeadline
        self.respondedAt = respondedAt
        self.isResponseBreached = isResponseBreached
        self.isResolutionBreached = isResolutionBreached
    }
}

struct DisplayTicket: Identifiable, Hashable, Codable {
    let id: UUID
    let ticketNumber: String
    let title: String
    let description: String
    let category: TicketCategory
    let urgency: TicketUrgency
    let status: TicketDisplayStatus
    let source: TicketSource
    let customerName: String
    let machineName: String?
    let machineSerial: String?
    let location: String?
    let assignedTechnician: String?
    let createdAt: Date
    let updatedAt: Date
    let scheduledDate: Date?
    let photoCount: Int
    let timeline: [TicketTimelineEvent]
    let isSyncedOffline: Bool
    let sla: SLADisplayInfo?

    init(
        id: UUID = UUID(),
        ticketNumber: String,
        title: String,
        description: String,
        category: TicketCategory,
        urgency: TicketUrgency,
        status: TicketDisplayStatus,
        source: TicketSource = .manual,
        customerName: String,
        machineName: String? = nil,
        machineSerial: String? = nil,
        location: String? = nil,
        assignedTechnician: String? = nil,
        createdAt: Date,
        updatedAt: Date,
        scheduledDate: Date? = nil,
        photoCount: Int = 0,
        timeline: [TicketTimelineEvent] = [],
        isSyncedOffline: Bool = true,
        sla: SLADisplayInfo? = nil
    ) {
        self.id = id
        self.ticketNumber = ticketNumber
        self.title = title
        self.description = description
        self.category = category
        self.urgency = urgency
        self.status = status
        self.source = source
        self.customerName = customerName
        self.machineName = machineName
        self.machineSerial = machineSerial
        self.location = location
        self.assignedTechnician = assignedTechnician
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.scheduledDate = scheduledDate
        self.photoCount = photoCount
        self.timeline = timeline
        self.isSyncedOffline = isSyncedOffline
        self.sla = sla
    }
}

// MARK: - Mock Data

enum TicketManagementMockData {

    private static func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 9, _ min: Int = 0) -> Date {
        Calendar.current.date(from: DateComponents(year: y, month: m, day: d, hour: h, minute: min)) ?? Date()
    }

    static let tickets: [DisplayTicket] = [
        // 1 - Electrical, Critical, Open
        DisplayTicket(
            ticketNumber: "TK-2026-001",
            title: "Servo Drive Fault on CNC-900",
            description: "Servo drive throwing E-45 fault code during high-speed cutting cycle. Machine stops mid-operation causing scrap. Affects production line 4 output by approximately 30%.",
            category: .electrical,
            urgency: .critical,
            status: .open,
            source: .incomingCall,
            customerName: "Industrial Logistics Corp.",
            machineName: "CNC-900 Machining Center",
            machineSerial: "SN-CNC900-4821",
            location: "Plant A - Line 4",
            assignedTechnician: nil,
            createdAt: date(2026, 4, 2, 14, 30),
            updatedAt: date(2026, 4, 2, 14, 30),
            scheduledDate: nil,
            photoCount: 2,
            timeline: [
                TicketTimelineEvent(
                    title: "Ticket Created",
                    description: "Incoming call from John Doe (Senior PM). AI transcription detected servo & drive fault keywords.",
                    date: date(2026, 4, 2, 14, 30),
                    status: .open,
                    performedBy: "System (Call)"
                ),
            ],
            isSyncedOffline: true,
            sla: SLADisplayInfo(
                policyName: "Critical SLA",
                responseDeadline: date(2026, 4, 2, 15, 30),
                resolutionDeadline: date(2026, 4, 3, 14, 30),
                respondedAt: nil,
                isResponseBreached: true,
                isResolutionBreached: false
            )
        ),

        // 2 - Mechanical, High, In Progress
        DisplayTicket(
            ticketNumber: "TK-2026-002",
            title: "Hydraulic Seal Array Failure",
            description: "Primary hydraulic pump interface leaking. Seal array on the main cylinder has degraded. Machine halted to prevent further damage. Hydraulic seal kit (PN-900-SEAL) has been ordered.",
            category: .mechanical,
            urgency: .high,
            status: .inProgress,
            source: .diagnostic,
            customerName: "Pacific Foods Inc.",
            machineName: "Vega 285 PM",
            machineSerial: "SN-V285-1190-PM",
            location: "Plant B - Bay 7",
            assignedTechnician: "John D.",
            createdAt: date(2026, 3, 28, 9, 0),
            updatedAt: date(2026, 4, 1, 14, 15),
            scheduledDate: date(2026, 4, 5, 8, 0),
            photoCount: 3,
            timeline: [
                TicketTimelineEvent(
                    title: "Submitted",
                    description: "Ticket created by Operator Sarah Jenkins.",
                    date: date(2026, 3, 28, 9, 0),
                    status: .open,
                    performedBy: "Sarah Jenkins"
                ),
                TicketTimelineEvent(
                    title: "Assigned",
                    description: "Assigned to John D. (Lead Technician).",
                    date: date(2026, 3, 28, 10, 30),
                    status: .inProgress,
                    performedBy: "Dispatch"
                ),
                TicketTimelineEvent(
                    title: "In Progress",
                    description: "Technician on site. Initial diagnosis complete.",
                    date: date(2026, 3, 29, 8, 15),
                    status: .inProgress,
                    performedBy: "John D."
                ),
                TicketTimelineEvent(
                    title: "Parts Ordered",
                    description: "Hydraulic seal kit (SKU: PN-900-SEAL) ordered. ETA 2 days.",
                    date: date(2026, 3, 29, 14, 0),
                    status: .onHold,
                    performedBy: "John D."
                ),
            ],
            isSyncedOffline: true,
            sla: SLADisplayInfo(
                policyName: "High Priority SLA",
                responseDeadline: date(2026, 3, 28, 13, 0),
                resolutionDeadline: date(2026, 4, 4, 9, 0),
                respondedAt: date(2026, 3, 28, 10, 30),
                isResponseBreached: false,
                isResolutionBreached: false
            )
        ),

        // 3 - Pneumatic, Medium, On Hold
        DisplayTicket(
            ticketNumber: "TK-2026-003",
            title: "Cylinder Pressure Drop - Sealing Station",
            description: "Intermittent pressure drop detected in pneumatic cylinder bank at the sealing station. Air supply pressure reads normal at main manifold but drops to 60 PSI at the cylinder. Possible leak in distribution lines.",
            category: .pneumatic,
            urgency: .medium,
            status: .onHold,
            source: .manual,
            customerName: "Global Wrap Solutions",
            machineName: "BF-3200 Blown Film Line",
            machineSerial: "SN-BF32-0078-CX",
            location: "Plant C - Hall 2",
            assignedTechnician: "Tom Brewer",
            createdAt: date(2026, 3, 25, 11, 0),
            updatedAt: date(2026, 3, 30, 16, 0),
            scheduledDate: date(2026, 4, 8, 9, 0),
            photoCount: 1,
            timeline: [
                TicketTimelineEvent(
                    title: "Submitted",
                    description: "Issue reported during routine inspection.",
                    date: date(2026, 3, 25, 11, 0),
                    status: .open,
                    performedBy: "Tom Brewer"
                ),
                TicketTimelineEvent(
                    title: "Assigned",
                    description: "Assigned to Tom Brewer.",
                    date: date(2026, 3, 25, 12, 0),
                    status: .inProgress,
                    performedBy: "Dispatch"
                ),
                TicketTimelineEvent(
                    title: "On Hold",
                    description: "Waiting for replacement pneumatic fittings (backordered).",
                    date: date(2026, 3, 30, 16, 0),
                    status: .onHold,
                    performedBy: "Tom Brewer"
                ),
            ],
            isSyncedOffline: true,
            sla: SLADisplayInfo(
                policyName: "Standard SLA",
                responseDeadline: date(2026, 3, 25, 15, 0),
                resolutionDeadline: date(2026, 4, 1, 11, 0),
                respondedAt: date(2026, 3, 25, 12, 0),
                isResponseBreached: false,
                isResolutionBreached: true
            )
        ),

        // 4 - Electrical, Low, Resolved
        DisplayTicket(
            ticketNumber: "TK-2026-004",
            title: "PLC Program Upload Error",
            description: "Control logic upload fails on HMI panel after firmware update. Error code CL-12 displayed. Rolled back firmware and re-uploaded program successfully.",
            category: .electrical,
            urgency: .low,
            status: .resolved,
            source: .manual,
            customerName: "Industrial Logistics Corp.",
            machineName: "ConvertPro 750P",
            machineSerial: "SN-CP750-3305-TRB",
            location: "Plant A - Line 1",
            assignedTechnician: "Mike Chen",
            createdAt: date(2026, 3, 20, 8, 0),
            updatedAt: date(2026, 3, 22, 17, 0),
            scheduledDate: nil,
            photoCount: 0,
            timeline: [
                TicketTimelineEvent(
                    title: "Submitted",
                    description: "Operator reported HMI upload failure.",
                    date: date(2026, 3, 20, 8, 0),
                    status: .open,
                    performedBy: "Operator"
                ),
                TicketTimelineEvent(
                    title: "Assigned",
                    description: "Assigned to Mike Chen.",
                    date: date(2026, 3, 20, 9, 0),
                    status: .inProgress,
                    performedBy: "Dispatch"
                ),
                TicketTimelineEvent(
                    title: "In Progress",
                    description: "Remote diagnosis started. Firmware rollback initiated.",
                    date: date(2026, 3, 21, 10, 0),
                    status: .inProgress,
                    performedBy: "Mike Chen"
                ),
                TicketTimelineEvent(
                    title: "Resolved",
                    description: "Firmware rolled back to v3.7.2. Program uploaded successfully. Root cause: incompatible firmware version.",
                    date: date(2026, 3, 22, 17, 0),
                    status: .resolved,
                    performedBy: "Mike Chen"
                ),
            ],
            isSyncedOffline: true
        ),

        // 5 - Other, Medium, Open (Offline)
        DisplayTicket(
            ticketNumber: "TK-2026-005",
            title: "Operator Cabin Door Latch Broken",
            description: "Door latch mechanism on operator cabin is broken. Door does not lock securely. Safety concern - operator reports the door swings open during vibration. Temporary zip-tie fix in place.",
            category: .other,
            urgency: .medium,
            status: .open,
            source: .offline,
            customerName: "Pacific Foods Inc.",
            machineName: "SP-60 Sachet Machine",
            machineSerial: "SN-SP60-5512-ML",
            location: "Plant B - Line 5",
            assignedTechnician: nil,
            createdAt: date(2026, 4, 1, 7, 30),
            updatedAt: date(2026, 4, 1, 7, 30),
            scheduledDate: nil,
            photoCount: 1,
            timeline: [
                TicketTimelineEvent(
                    title: "Submitted (Offline)",
                    description: "Created offline by field technician. Synced when connectivity restored.",
                    date: date(2026, 4, 1, 7, 30),
                    status: .open,
                    performedBy: "Sarah Lopez"
                ),
            ],
            isSyncedOffline: false
        ),
    ]
}
