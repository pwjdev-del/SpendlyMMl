import Foundation
import SwiftUI
import SpendlyCore

// MARK: - ViewModel

@Observable
final class ManagerDashboardViewModel {

    // MARK: Data
    var projectStatusCards: [ProjectStatusCard] = ManagerDashboardMockData.projectStatusCards
    var urgentJobs: [UrgentJob] = ManagerDashboardMockData.urgentJobs
    var technicians: [TechnicianResource] = ManagerDashboardMockData.technicians
    var notifications: [DashboardNotification] = ManagerDashboardMockData.notifications

    // MARK: UI State
    var showNotifications: Bool = false
    var showAllUrgentJobs: Bool = false
    var isWhiteLabelVariant: Bool = false
    var lastUpdated: Date = Date()

    // MARK: - Computed Properties

    /// Number of unread notifications (drives the bell badge).
    var unreadNotificationCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    /// Whether the notification bell should show a badge indicator.
    var hasUnreadNotifications: Bool {
        unreadNotificationCount > 0
    }

    /// Pending approval notifications specifically.
    var pendingApprovals: [DashboardNotification] {
        notifications.filter { $0.type == .approvalRequired && !$0.isRead }
    }

    /// How long ago the dashboard data was refreshed.
    var lastUpdatedText: String {
        let interval = Date().timeIntervalSince(lastUpdated)
        let minutes = Int(interval / 60)
        if minutes < 1 { return "Just now" }
        if minutes == 1 { return "1 min ago" }
        return "\(minutes) mins ago"
    }

    // MARK: Resource Summary Stats

    var totalTechnicians: Int { technicians.count }

    var availableTechnicians: Int {
        technicians.filter { $0.status == .available }.count
    }

    var onSiteTechnicians: Int {
        technicians.filter { $0.status == .onSite }.count
    }

    var averageWorkload: Double {
        guard !technicians.isEmpty else { return 0 }
        return technicians.reduce(0.0) { $0 + $1.workloadPercent } / Double(technicians.count)
    }

    // MARK: - Actions

    /// Assign a technician to an urgent job. Placeholder for real dispatch flow.
    func assignJob(_ job: UrgentJob) {
        // In production this would navigate to SchedulingDispatch or open an assignment modal.
        // For now we remove the job from the urgent list to show responsiveness.
        withAnimation(.easeInOut(duration: 0.3)) {
            urgentJobs.removeAll { $0.id == job.id }
        }
    }

    /// Mark a notification as read.
    func markNotificationRead(_ notification: DashboardNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            let updated = DashboardNotification(
                id: notification.id,
                title: notification.title,
                body: notification.body,
                type: notification.type,
                isRead: true,
                createdAt: notification.createdAt
            )
            notifications[index] = updated
        }
    }

    /// Mark all notifications as read.
    func markAllNotificationsRead() {
        notifications = notifications.map { notif in
            DashboardNotification(
                id: notif.id,
                title: notif.title,
                body: notif.body,
                type: notif.type,
                isRead: true,
                createdAt: notif.createdAt
            )
        }
    }

    /// Handle an approval action from a notification.
    func handleApproval(_ notification: DashboardNotification, approved: Bool) {
        markNotificationRead(notification)
        // In production this would call the API to approve/reject the estimate.
    }

    /// Simulate a data refresh.
    func refreshDashboard() {
        lastUpdated = Date()
        projectStatusCards = ManagerDashboardMockData.projectStatusCards
        urgentJobs = ManagerDashboardMockData.urgentJobs
        technicians = ManagerDashboardMockData.technicians
    }

    /// Toggle white-label variant styling.
    func toggleWhiteLabelVariant() {
        withAnimation(.easeInOut(duration: 0.25)) {
            isWhiteLabelVariant.toggle()
        }
    }
}
