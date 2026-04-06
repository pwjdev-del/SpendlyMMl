import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Notification Display Model

struct NotificationDisplayModel: Identifiable {
    let id: UUID
    var title: String
    var body: String
    var type: NotificationCategory
    var priority: NotificationPriority
    var isRead: Bool
    var timestamp: Date
    var locationPreview: LocationPreview?
    var quickActions: [NotificationQuickAction]

    var timeAgo: String {
        let interval = Date().timeIntervalSince(timestamp)
        if interval < 60 {
            return "now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Notification Category

enum NotificationCategory: String, CaseIterable {
    case jobAssigned = "Job Assigned"
    case statusUpdate = "Status Update"
    case estimateApproved = "Estimate Approved"
    case scheduleChange = "Schedule Change"
    case systemAlert = "System Alert"
    case message = "Message"

    var icon: String {
        switch self {
        case .jobAssigned:      return "wrench.and.screwdriver"
        case .statusUpdate:     return "arrow.triangle.2.circlepath"
        case .estimateApproved: return "checkmark.seal"
        case .scheduleChange:   return "calendar.badge.exclamationmark"
        case .systemAlert:      return "exclamationmark.triangle"
        case .message:          return "message.fill"
        }
    }

    var tintColor: Color {
        switch self {
        case .jobAssigned:      return SpendlyColors.primary
        case .statusUpdate:     return SpendlyColors.info
        case .estimateApproved: return SpendlyColors.success
        case .scheduleChange:   return SpendlyColors.warning
        case .systemAlert:      return SpendlyColors.error
        case .message:          return SpendlyColors.accent
        }
    }
}

// MARK: - Notification Priority

enum NotificationPriority: String {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case critical = "CRITICAL"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .low:      return .neutral
        case .medium:   return .info
        case .high:     return .error
        case .critical: return .error
        }
    }

    var showBadge: Bool {
        self == .high || self == .critical
    }
}

// MARK: - Location Preview

struct LocationPreview: Identifiable {
    let id: UUID
    var label: String
    var address: String
}

// MARK: - Quick Action

struct NotificationQuickAction: Identifiable {
    let id: UUID
    var title: String
    var icon: String?
    var style: QuickActionStyle

    enum QuickActionStyle {
        case primary
        case secondary
        case accept
        case decline
    }
}

// MARK: - Tab Badge Model

struct TabBadgeModel {
    var notificationCount: Int
    var jobCount: Int
    var chatCount: Int

    var totalUnread: Int {
        notificationCount + jobCount + chatCount
    }
}

// MARK: - Filter Option

enum NotificationFilter: String, CaseIterable {
    case all = "All"
    case unread = "Unread"
    case jobs = "Jobs"
    case estimates = "Estimates"
    case alerts = "Alerts"
}

// MARK: - Mock Data

enum PushNotificationsMockData {

    static let sampleNotifications: [NotificationDisplayModel] = [
        // 1. New Job Assigned (unread, high priority, with Accept/Decline)
        NotificationDisplayModel(
            id: UUID(),
            title: "New Job Assigned",
            body: "You have a new service visit scheduled for Acme Corp at 2:00 PM today.",
            type: .jobAssigned,
            priority: .high,
            isRead: false,
            timestamp: Date(),
            locationPreview: LocationPreview(
                id: UUID(),
                label: "Location",
                address: "123 Maple Avenue, Springfield"
            ),
            quickActions: [
                NotificationQuickAction(
                    id: UUID(),
                    title: "Accept",
                    icon: "checkmark",
                    style: .accept
                ),
                NotificationQuickAction(
                    id: UUID(),
                    title: "Decline",
                    icon: "xmark",
                    style: .decline
                )
            ]
        ),

        // 2. Status Update (unread)
        NotificationDisplayModel(
            id: UUID(),
            title: "Issue #1234 Status Updated",
            body: "Technician is en route to Global Logistics Hub. Estimated arrival: 15 minutes.",
            type: .statusUpdate,
            priority: .medium,
            isRead: false,
            timestamp: Calendar.current.date(byAdding: .minute, value: -5, to: Date()) ?? Date(),
            locationPreview: nil,
            quickActions: [
                NotificationQuickAction(
                    id: UUID(),
                    title: "View Details",
                    icon: nil,
                    style: .primary
                )
            ]
        ),

        // 3. Estimate Approved (unread)
        NotificationDisplayModel(
            id: UUID(),
            title: "Estimate Approved",
            body: "Customer has approved the quote for Job #5678 - HVAC replacement at Metro Health Systems. Total: $4,250.00",
            type: .estimateApproved,
            priority: .medium,
            isRead: false,
            timestamp: Calendar.current.date(byAdding: .minute, value: -12, to: Date()) ?? Date(),
            locationPreview: nil,
            quickActions: [
                NotificationQuickAction(
                    id: UUID(),
                    title: "View Schedule",
                    icon: nil,
                    style: .primary
                ),
                NotificationQuickAction(
                    id: UUID(),
                    title: "Navigate",
                    icon: "location",
                    style: .secondary
                )
            ]
        ),

        // 4. Schedule Change (read, with Accept/Decline)
        NotificationDisplayModel(
            id: UUID(),
            title: "Schedule Change",
            body: "Your 3:00 PM appointment at Sunrise Manufacturing has been moved to 4:30 PM by the dispatcher.",
            type: .scheduleChange,
            priority: .high,
            isRead: true,
            timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            locationPreview: LocationPreview(
                id: UUID(),
                label: "Updated Location",
                address: "789 Factory Row, Phoenix"
            ),
            quickActions: [
                NotificationQuickAction(
                    id: UUID(),
                    title: "Accept",
                    icon: "checkmark",
                    style: .accept
                ),
                NotificationQuickAction(
                    id: UUID(),
                    title: "Decline",
                    icon: "xmark",
                    style: .decline
                )
            ]
        ),

        // 5. System Alert (read, critical)
        NotificationDisplayModel(
            id: UUID(),
            title: "Trip Report Overdue",
            body: "Your trip report for Acme Corp visit on March 28 is overdue. Please submit within 24 hours.",
            type: .systemAlert,
            priority: .critical,
            isRead: true,
            timestamp: Calendar.current.date(byAdding: .hour, value: -6, to: Date()) ?? Date(),
            locationPreview: nil,
            quickActions: [
                NotificationQuickAction(
                    id: UUID(),
                    title: "Submit Report",
                    icon: nil,
                    style: .primary
                )
            ]
        ),

        // 6. Message (unread)
        NotificationDisplayModel(
            id: UUID(),
            title: "New Message from Dispatch",
            body: "Hey, the customer at 456 Oak Street requested an earlier time slot. Can you arrive by 10 AM instead?",
            type: .message,
            priority: .medium,
            isRead: false,
            timestamp: Calendar.current.date(byAdding: .minute, value: -30, to: Date()) ?? Date(),
            locationPreview: nil,
            quickActions: [
                NotificationQuickAction(
                    id: UUID(),
                    title: "Reply",
                    icon: "arrowshape.turn.up.left",
                    style: .primary
                ),
                NotificationQuickAction(
                    id: UUID(),
                    title: "View Chat",
                    icon: nil,
                    style: .secondary
                )
            ]
        )
    ]

    static let sampleBadges = TabBadgeModel(
        notificationCount: 4,
        jobCount: 1,
        chatCount: 2
    )
}
