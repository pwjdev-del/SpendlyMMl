import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Project Status Card Model

struct ProjectStatusCard: Identifiable {
    let id: UUID
    let title: String
    let value: Int
    let trendPercent: Double
    let trendLabel: String
    let trendDirection: SPTrendDirection
    let icon: String
    let iconColor: IconColor

    enum IconColor {
        case primary
        case orange
        case emerald

        var color: SwiftUI.Color {
            switch self {
            case .primary: return SpendlyColors.primary
            case .orange:  return SpendlyColors.warning
            case .emerald: return SpendlyColors.success
            }
        }
    }
}

// MARK: - Job Priority

enum JobPriority: String {
    case high     = "High Priority"
    case medium   = "Medium Priority"
    case routine  = "Routine"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .high:    return .error
        case .medium:  return .warning
        case .routine: return .info
        }
    }

    /// Left-border accent color matching Stitch design
    var borderColor: SwiftUI.Color {
        switch self {
        case .high:    return SpendlyColors.error
        case .medium:  return SpendlyColors.warning
        case .routine: return SpendlyColors.primary
        }
    }
}

// MARK: - Urgent Job Model

struct UrgentJob: Identifiable {
    let id: UUID
    let title: String
    let description: String
    let location: String
    let priority: JobPriority
}

// MARK: - Technician Status

enum TechnicianFieldStatus: String {
    case onSite    = "On-Site"
    case inTransit = "In Transit"
    case onBreak   = "Break"
    case available = "Available"

    var dotColor: SwiftUI.Color {
        switch self {
        case .onSite:    return SpendlyColors.success
        case .inTransit: return SpendlyColors.info
        case .onBreak:   return SpendlyColors.warning
        case .available: return SpendlyColors.secondary
        }
    }

    var isPulsing: Bool {
        self == .onSite
    }
}

// MARK: - Technician Resource Model

struct TechnicianResource: Identifiable {
    let id: UUID
    let name: String
    let initials: String
    let specialty: String
    let activeProject: String
    let status: TechnicianFieldStatus
    let workloadPercent: Double  // 0.0 ... 1.0
}

// MARK: - Dashboard Notification Model

struct DashboardNotification: Identifiable {
    let id: UUID
    let title: String
    let body: String
    let type: DashboardNotificationType
    let isRead: Bool
    let createdAt: Date
}

enum DashboardNotificationType {
    case approvalRequired
    case jobEscalation
    case systemAlert
    case resourceWarning

    var icon: String {
        switch self {
        case .approvalRequired: return "checkmark.circle"
        case .jobEscalation:    return "exclamationmark.triangle"
        case .systemAlert:      return "bell.badge"
        case .resourceWarning:  return "person.badge.clock"
        }
    }

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .approvalRequired: return .info
        case .jobEscalation:    return .error
        case .systemAlert:      return .warning
        case .resourceWarning:  return .neutral
        }
    }
}

// MARK: - Mock Data

enum ManagerDashboardMockData {

    // MARK: Project Status Cards

    static let projectStatusCards: [ProjectStatusCard] = [
        ProjectStatusCard(
            id: UUID(),
            title: "In Progress",
            value: 12,
            trendPercent: 2.4,
            trendLabel: "from last week",
            trendDirection: .up,
            icon: "bolt.horizontal.circle",
            iconColor: .primary
        ),
        ProjectStatusCard(
            id: UUID(),
            title: "Pending Assignment",
            value: 5,
            trendPercent: -1.2,
            trendLabel: "from last week",
            trendDirection: .down,
            icon: "hourglass",
            iconColor: .orange
        ),
        ProjectStatusCard(
            id: UUID(),
            title: "Completed (MoM)",
            value: 28,
            trendPercent: 5.1,
            trendLabel: "above target",
            trendDirection: .up,
            icon: "checkmark.circle.fill",
            iconColor: .emerald
        ),
    ]

    // MARK: Urgent Jobs

    static let urgentJobs: [UrgentJob] = [
        UrgentJob(
            id: UUID(),
            title: "HVAC Failure - Terminal 2",
            description: "Complete system outage reported at airport terminal. Requires immediate technician dispatch.",
            location: "Chicago, IL",
            priority: .high
        ),
        UrgentJob(
            id: UUID(),
            title: "Fiber Repair - North St",
            description: "Underground cable damage due to construction. Service disrupted for 12 residential units.",
            location: "Oak Park",
            priority: .medium
        ),
        UrgentJob(
            id: UUID(),
            title: "Solar Array Audit",
            description: "Annual efficiency check for the downtown array. Must be completed by end of week.",
            location: "Downtown",
            priority: .routine
        ),
    ]

    // MARK: Technician Resources

    static let technicians: [TechnicianResource] = [
        TechnicianResource(
            id: UUID(),
            name: "James Dalton",
            initials: "JD",
            specialty: "Senior Electrician",
            activeProject: "Skyline Tower Elevators",
            status: .onSite,
            workloadPercent: 0.85
        ),
        TechnicianResource(
            id: UUID(),
            name: "Sarah Miller",
            initials: "SM",
            specialty: "Network Specialist",
            activeProject: "Mainframe Upgrade v4",
            status: .inTransit,
            workloadPercent: 0.40
        ),
        TechnicianResource(
            id: UUID(),
            name: "Marcus Kim",
            initials: "MK",
            specialty: "HVAC Tech",
            activeProject: "Retail Hub Maintenance",
            status: .onBreak,
            workloadPercent: 0.65
        ),
        TechnicianResource(
            id: UUID(),
            name: "Linda Rossi",
            initials: "LR",
            specialty: "Safety Auditor",
            activeProject: "None",
            status: .available,
            workloadPercent: 0.0
        ),
    ]

    // MARK: Notifications

    static let notifications: [DashboardNotification] = [
        DashboardNotification(
            id: UUID(),
            title: "Estimate Approval Required",
            body: "Skyline Tower elevator repair estimate ($14,200) awaiting your approval.",
            type: .approvalRequired,
            isRead: false,
            createdAt: Date().addingTimeInterval(-300)
        ),
        DashboardNotification(
            id: UUID(),
            title: "Job Escalated - HVAC Terminal 2",
            body: "HVAC failure at Terminal 2 has been escalated to critical priority by dispatch.",
            type: .jobEscalation,
            isRead: false,
            createdAt: Date().addingTimeInterval(-900)
        ),
        DashboardNotification(
            id: UUID(),
            title: "Resource Capacity Warning",
            body: "3 of 4 technicians are at 65%+ workload. Consider reassigning upcoming jobs.",
            type: .resourceWarning,
            isRead: true,
            createdAt: Date().addingTimeInterval(-3600)
        ),
        DashboardNotification(
            id: UUID(),
            title: "System Maintenance Window",
            body: "Scheduled maintenance tonight 2:00 AM - 4:00 AM CST. Sync may be temporarily unavailable.",
            type: .systemAlert,
            isRead: true,
            createdAt: Date().addingTimeInterval(-7200)
        ),
    ]
}

