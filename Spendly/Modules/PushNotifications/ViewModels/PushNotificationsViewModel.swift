import SwiftUI
import SpendlyCore

// MARK: - PushNotificationsViewModel

@Observable
final class PushNotificationsViewModel {

    // MARK: - State

    var notifications: [NotificationDisplayModel] = PushNotificationsMockData.sampleNotifications
    var selectedFilter: NotificationFilter = .all
    var showActionConfirmation: Bool = false
    var lastActionMessage: String = ""

    // MARK: - Computed

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    var filteredNotifications: [NotificationDisplayModel] {
        switch selectedFilter {
        case .all:
            return notifications
        case .unread:
            return notifications.filter { !$0.isRead }
        case .jobs:
            return notifications.filter { $0.type == .jobAssigned }
        case .estimates:
            return notifications.filter { $0.type == .estimateApproved }
        case .alerts:
            return notifications.filter { $0.type == .systemAlert || $0.type == .scheduleChange }
        }
    }

    var hasUnread: Bool {
        unreadCount > 0
    }

    // MARK: - Mark Read

    func markRead(_ notification: NotificationDisplayModel) {
        guard let idx = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        notifications[idx].isRead = true
    }

    func markAllRead() {
        for idx in notifications.indices {
            notifications[idx].isRead = true
        }
    }

    // MARK: - Quick Actions

    func acceptJob(_ notification: NotificationDisplayModel) {
        guard let idx = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        notifications[idx].isRead = true
        lastActionMessage = "Job accepted: \(notification.title)"
        showActionConfirmation = true

        dismissConfirmation()
    }

    func declineJob(_ notification: NotificationDisplayModel) {
        guard let idx = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        notifications[idx].isRead = true
        lastActionMessage = "Job declined: \(notification.title)"
        showActionConfirmation = true

        dismissConfirmation()
    }

    func performAction(_ action: NotificationQuickAction, on notification: NotificationDisplayModel) {
        markRead(notification)

        switch action.style {
        case .accept:
            acceptJob(notification)
        case .decline:
            declineJob(notification)
        case .primary, .secondary:
            lastActionMessage = "\(action.title): \(notification.title)"
            showActionConfirmation = true
            dismissConfirmation()
        }
    }

    // MARK: - Delete

    func deleteNotification(_ notification: NotificationDisplayModel) {
        notifications.removeAll { $0.id == notification.id }
    }

    func deleteNotifications(at offsets: IndexSet) {
        let filtered = filteredNotifications
        let idsToRemove = offsets.map { filtered[$0].id }
        notifications.removeAll { idsToRemove.contains($0.id) }
    }

    // MARK: - Private

    private func dismissConfirmation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showActionConfirmation = false
        }
    }
}
