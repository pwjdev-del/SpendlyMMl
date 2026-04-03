import SwiftUI
import SpendlyCore

// MARK: - PushNotificationsRootView

public struct PushNotificationsRootView: View {

    @State private var viewModel = PushNotificationsViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header
                notificationHeader

                // MARK: - Filter Chips
                filterChips
                    .padding(.top, SpendlySpacing.sm)
                    .padding(.bottom, SpendlySpacing.md)

                // MARK: - Notification List
                if viewModel.filteredNotifications.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationBarHidden(true)
            .overlay(alignment: .bottom) {
                if viewModel.showActionConfirmation {
                    actionConfirmationBanner
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: viewModel.showActionConfirmation)
        }
    }

    // MARK: - Header

    private var notificationHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // Back button
                Button {} label: {
                    Image(systemName: SpendlyIcon.arrowBack.systemName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .frame(width: 40, height: 40)

                Spacer()

                // Title with unread badge
                HStack(spacing: SpendlySpacing.sm) {
                    Text("Notifications")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    if viewModel.unreadCount > 0 {
                        Text("\(viewModel.unreadCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(SpendlyColors.error)
                            .clipShape(Capsule())
                    }
                }

                Spacer()

                // Mark All Read button
                Button {
                    viewModel.markAllRead()
                } label: {
                    Text("Mark All Read")
                        .font(SpendlyFont.caption())
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.hasUnread ? SpendlyColors.primary : SpendlyColors.secondary)
                }
                .disabled(!viewModel.hasUnread)
                .opacity(viewModel.hasUnread ? 1.0 : 0.5)
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.md)
        }
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpendlySpacing.sm) {
                ForEach(NotificationFilter.allCases, id: \.self) { filter in
                    filterChip(filter)
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
        }
    }

    private func filterChip(_ filter: NotificationFilter) -> some View {
        let isSelected = viewModel.selectedFilter == filter

        return Button {
            viewModel.selectedFilter = filter
        } label: {
            Text(filter.rawValue)
                .font(SpendlyFont.caption())
                .fontWeight(.semibold)
                .foregroundStyle(isSelected ? .white : SpendlyColors.foreground(for: colorScheme))
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.sm)
                .background(
                    isSelected
                        ? SpendlyColors.primary
                        : SpendlyColors.surface(for: colorScheme)
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(
                            isSelected
                                ? Color.clear
                                : SpendlyColors.secondary.opacity(0.2),
                            lineWidth: 1
                        )
                )
        }
    }

    // MARK: - Notification List

    private var notificationList: some View {
        ScrollView {
            LazyVStack(spacing: SpendlySpacing.md) {
                ForEach(viewModel.filteredNotifications) { notification in
                    notificationCard(notification)
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.bottom, SpendlySpacing.xxxl)
        }
    }

    // MARK: - Notification Card

    private func notificationCard(_ notification: NotificationDisplayModel) -> some View {
        SPCard(elevation: notification.isRead ? .low : .medium) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                // Top row: icon, title, timestamp, read indicator
                HStack(alignment: .top, spacing: SpendlySpacing.md) {
                    // Type icon
                    typeIcon(for: notification)

                    // Title + body
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        HStack(alignment: .top) {
                            Text(notification.title)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                .lineLimit(2)

                            Spacer()

                            // Timestamp
                            Text(notification.timeAgo)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }

                        Text(notification.body)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            .lineLimit(3)
                    }

                    // Unread dot
                    if !notification.isRead {
                        Circle()
                            .fill(SpendlyColors.info)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                    }
                }

                // Priority badge (only for high / critical)
                if notification.priority.showBadge {
                    SPBadge(notification.priority.rawValue, style: notification.priority.badgeStyle)
                }

                // Location preview
                if let location = notification.locationPreview {
                    locationRow(location, tint: notification.type.tintColor)
                }

                // Quick action buttons
                if !notification.quickActions.isEmpty {
                    quickActionRow(notification)
                }
            }
        }
        .overlay(
            // Left accent bar for unread
            HStack {
                if !notification.isRead {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(notification.type.tintColor)
                        .frame(width: 4)
                        .padding(.vertical, SpendlySpacing.sm)
                }
                Spacer()
            }
        )
        .onTapGesture {
            viewModel.markRead(notification)
        }
    }

    // MARK: - Type Icon

    private func typeIcon(for notification: NotificationDisplayModel) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .fill(notification.type.tintColor.opacity(0.12))
                .frame(width: 40, height: 40)

            Image(systemName: notification.type.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(notification.type.tintColor)
        }
    }

    // MARK: - Location Row

    private func locationRow(_ location: LocationPreview, tint: Color) -> some View {
        HStack(spacing: SpendlySpacing.md) {
            Image(systemName: SpendlyIcon.location.systemName)
                .font(.system(size: 13))
                .foregroundStyle(tint.opacity(0.7))

            VStack(alignment: .leading, spacing: 2) {
                Text(location.label.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(tint)

                Text(location.address)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }

            Spacer()
        }
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.background(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
    }

    // MARK: - Quick Action Row

    private func quickActionRow(_ notification: NotificationDisplayModel) -> some View {
        HStack(spacing: SpendlySpacing.sm) {
            ForEach(notification.quickActions) { action in
                quickActionButton(action, notification: notification)
            }
        }
    }

    private func quickActionButton(
        _ action: NotificationQuickAction,
        notification: NotificationDisplayModel
    ) -> some View {
        Button {
            viewModel.performAction(action, on: notification)
        } label: {
            HStack(spacing: SpendlySpacing.xs) {
                if let icon = action.icon {
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(action.title)
                    .font(SpendlyFont.caption())
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.sm)
            .padding(.horizontal, SpendlySpacing.md)
            .foregroundStyle(actionForeground(action.style))
            .background(actionBackground(action.style))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .strokeBorder(actionBorder(action.style), lineWidth: 1)
            )
        }
    }

    private func actionForeground(_ style: NotificationQuickAction.QuickActionStyle) -> Color {
        switch style {
        case .accept:    return .white
        case .decline:   return .white
        case .primary:   return SpendlyColors.primary
        case .secondary: return SpendlyColors.secondary
        }
    }

    private func actionBackground(_ style: NotificationQuickAction.QuickActionStyle) -> Color {
        switch style {
        case .accept:    return SpendlyColors.success
        case .decline:   return SpendlyColors.error
        case .primary:   return SpendlyColors.primary.opacity(0.08)
        case .secondary: return Color.clear
        }
    }

    private func actionBorder(_ style: NotificationQuickAction.QuickActionStyle) -> Color {
        switch style {
        case .accept:    return Color.clear
        case .decline:   return Color.clear
        case .primary:   return SpendlyColors.primary.opacity(0.15)
        case .secondary: return SpendlyColors.secondary.opacity(0.2)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: SpendlySpacing.lg) {
            Spacer()

            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))

            Text("No Notifications")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Text("You're all caught up! Check back later.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(SpendlySpacing.xxxl)
    }

    // MARK: - Action Confirmation Banner

    private var actionConfirmationBanner: some View {
        HStack(spacing: SpendlySpacing.md) {
            Image(systemName: SpendlyIcon.checkCircle.systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)

            Text(viewModel.lastActionMessage)
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.primary)
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.bottom, SpendlySpacing.lg)
    }
}

// MARK: - Preview

#Preview {
    PushNotificationsRootView()
}
