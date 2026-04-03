import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Service Job Status

enum ServiceJobStatus: String, CaseIterable {
    case dispatched = "Dispatched"
    case enRoute = "En Route"
    case onSite = "On-Site"
    case completed = "Completed"

    var icon: String {
        switch self {
        case .dispatched: return "paperplane.fill"
        case .enRoute:    return "car.fill"
        case .onSite:     return "wrench.and.screwdriver.fill"
        case .completed:  return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .dispatched: return SpendlyColors.info
        case .enRoute:    return SpendlyColors.warning
        case .onSite:     return SpendlyColors.accent
        case .completed:  return SpendlyColors.success
        }
    }

    /// 0-based step index used for progress tracking.
    var stepIndex: Int {
        switch self {
        case .dispatched: return 0
        case .enRoute:    return 1
        case .onSite:     return 2
        case .completed:  return 3
        }
    }
}

// MARK: - Issue Status

enum IssueStatus: String {
    case inProgress = "In Progress"
    case scheduled  = "Scheduled"
    case reviewing  = "Reviewing"
    case resolved   = "Resolved"

    var color: Color {
        switch self {
        case .inProgress: return SpendlyColors.warning
        case .scheduled:  return SpendlyColors.info
        case .reviewing:  return SpendlyColors.success
        case .resolved:   return SpendlyColors.success
        }
    }

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .inProgress: return .warning
        case .scheduled:  return .info
        case .reviewing:  return .custom(SpendlyColors.success)
        case .resolved:   return .success
        }
    }
}

// MARK: - Machine Status (Portal)

enum PortalMachineStatus: String {
    case online  = "Online"
    case warning = "Warning"
    case offline = "Offline"

    var color: Color {
        switch self {
        case .online:  return SpendlyColors.success
        case .warning: return SpendlyColors.accent
        case .offline: return SpendlyColors.secondary
        }
    }

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .online:  return .success
        case .warning: return .custom(SpendlyColors.accent)
        case .offline: return .neutral
        }
    }
}

// MARK: - Portal Issue

struct PortalIssue: Identifiable {
    let id: UUID
    let ticketNumber: String
    let title: String
    let machineName: String
    let status: IssueStatus
    let progressLabel: String
    let progressPercent: Double
}

// MARK: - Portal Machine

struct PortalMachine: Identifiable {
    let id: UUID
    let name: String
    let machineID: String
    let status: PortalMachineStatus
    let detailLabel: String
    let detailValue: String
    let healthPercent: Double
}

// MARK: - Portal Technician

struct PortalTechnician: Identifiable {
    let id: UUID
    let name: String
    let initials: String
    let specialty: String
    let phone: String
    let rating: Double
    let avatarURL: String?
    let etaMinutes: Int?
}

// MARK: - Active Service

struct ActiveService: Identifiable {
    let id: UUID
    let ticketNumber: String
    let title: String
    let machineName: String
    let machineID: String
    let address: String
    let currentStatus: ServiceJobStatus
    let technician: PortalTechnician
    let scheduledDate: Date
    let timeline: [ServiceTimelineEntry]
}

// MARK: - Service Timeline Entry

struct ServiceTimelineEntry: Identifiable {
    let id: UUID
    let step: ServiceJobStatus
    let time: String
    let subtitle: String?
    let isCompleted: Bool
    let isActive: Bool
}

// MARK: - Portal Dashboard Stats

struct PortalDashboardStats {
    let activeIssues: Int
    let activeIssuesDelta: String
    let resolvedCount: Int
    let resolvedDelta: String
    let scheduledService: Int
    let nextServiceDate: String
    let uptimeRate: String
}

// MARK: - Self-Service Field Map Entry

struct SelfServiceFieldMap: Identifiable {
    let id: UUID
    let fieldLabel: String
    let mappedKey: String
    let sampleValue: String
}

// MARK: - Mock Data

enum CustomerPortalMockData {

    // MARK: Dashboard Stats

    static let stats = PortalDashboardStats(
        activeIssues: 3,
        activeIssuesDelta: "+1",
        resolvedCount: 128,
        resolvedDelta: "+5%",
        scheduledService: 2,
        nextServiceDate: "Oct 24",
        uptimeRate: "99.2%"
    )

    // MARK: Technician

    static let technicianMike = PortalTechnician(
        id: UUID(),
        name: "Mike Johnson",
        initials: "MJ",
        specialty: "Hydraulics Specialist",
        phone: "(555) 234-5678",
        rating: 4.9,
        avatarURL: nil,
        etaMinutes: 12
    )

    static let technicianSarah = PortalTechnician(
        id: UUID(),
        name: "Sarah Chen",
        initials: "SC",
        specialty: "Electrical & Industrial",
        phone: "(555) 876-5432",
        rating: 4.8,
        avatarURL: nil,
        etaMinutes: nil
    )

    // MARK: Recent Issues

    static let recentIssues: [PortalIssue] = [
        PortalIssue(
            id: UUID(),
            ticketNumber: "#TK-442",
            title: "Hydraulic Fluid Leak",
            machineName: "Press Brake HP-22",
            status: .inProgress,
            progressLabel: "Tech En Route",
            progressPercent: 0.45
        ),
        PortalIssue(
            id: UUID(),
            ticketNumber: "#TK-445",
            title: "Sensor Calibration",
            machineName: "Industrial CNC-900",
            status: .scheduled,
            progressLabel: "Pending Dispatch",
            progressPercent: 0.15
        ),
        PortalIssue(
            id: UUID(),
            ticketNumber: "#TK-439",
            title: "Filter Replacement",
            machineName: "Cooling Unit RX-5",
            status: .reviewing,
            progressLabel: "Final Review",
            progressPercent: 0.90
        ),
    ]

    // MARK: Machines

    static let machines: [PortalMachine] = [
        PortalMachine(
            id: UUID(),
            name: "Industrial CNC-900",
            machineID: "#MCH-8829",
            status: .online,
            detailLabel: "Last Service",
            detailValue: "12 Days ago",
            healthPercent: 0.85
        ),
        PortalMachine(
            id: UUID(),
            name: "Press Brake HP-22",
            machineID: "#MCH-4410",
            status: .warning,
            detailLabel: "Vibration Level",
            detailValue: "High Alert",
            healthPercent: 0.40
        ),
        PortalMachine(
            id: UUID(),
            name: "Cooling Unit RX-5",
            machineID: "#MCH-1192",
            status: .offline,
            detailLabel: "Maintenance",
            detailValue: "Scheduled Oct 24",
            healthPercent: 0.10
        ),
    ]

    // MARK: Active Service (for tracker)

    static let activeService = ActiveService(
        id: UUID(),
        ticketNumber: "#TK-442",
        title: "Hydraulic Fluid Leak",
        machineName: "Press Brake HP-22",
        machineID: "#MCH-4410",
        address: "456 Industrial Blvd, Springfield, IL",
        currentStatus: .enRoute,
        technician: technicianMike,
        scheduledDate: Date(),
        timeline: [
            ServiceTimelineEntry(
                id: UUID(),
                step: .dispatched,
                time: "09:15 AM",
                subtitle: "Technician assigned & notified",
                isCompleted: true,
                isActive: false
            ),
            ServiceTimelineEntry(
                id: UUID(),
                step: .enRoute,
                time: "09:42 AM",
                subtitle: "ETA: 12 min away",
                isCompleted: false,
                isActive: true
            ),
            ServiceTimelineEntry(
                id: UUID(),
                step: .onSite,
                time: "Pending",
                subtitle: "Technician will check in on arrival",
                isCompleted: false,
                isActive: false
            ),
            ServiceTimelineEntry(
                id: UUID(),
                step: .completed,
                time: "Pending",
                subtitle: nil,
                isCompleted: false,
                isActive: false
            ),
        ]
    )

    // MARK: Self-Service Field Mappings

    static let selfServiceFieldMaps: [SelfServiceFieldMap] = [
        SelfServiceFieldMap(id: UUID(), fieldLabel: "Customer Name", mappedKey: "customer.name", sampleValue: "Acme Corp"),
        SelfServiceFieldMap(id: UUID(), fieldLabel: "Machine ID", mappedKey: "machine.serial_number", sampleValue: "#MCH-8829"),
        SelfServiceFieldMap(id: UUID(), fieldLabel: "Contact Email", mappedKey: "customer.email", sampleValue: "alex@acme.com"),
        SelfServiceFieldMap(id: UUID(), fieldLabel: "Issue Category", mappedKey: "ticket.category", sampleValue: "Hydraulic"),
        SelfServiceFieldMap(id: UUID(), fieldLabel: "Priority", mappedKey: "ticket.priority", sampleValue: "High"),
    ]
}
