import SwiftUI
import SpendlyCore

// MARK: - ManagerDashboardRootView

public struct ManagerDashboardRootView: View {

    @State private var viewModel = ManagerDashboardViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.brandingConfiguration) private var branding

    public init() {}

    public var body: some View {
        ZStack(alignment: .top) {
            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.xl) {

                    // MARK: Header
                    dashboardHeader

                    // MARK: Project Status Cards (#300-#302)
                    projectStatusSection

                    // MARK: Urgent Jobs + Resource Allocation (#303-#308)
                    urgentJobsAndResourcesSection
                }
            }

            // MARK: Notification Overlay (#305, #307)
            if viewModel.showNotifications {
                notificationOverlay
            }
        }
    }

    // MARK: - Resolved Brand Color

    /// Returns custom primary color when white-label variant is active, otherwise design-system primary.
    private var resolvedPrimary: Color {
        if viewModel.isWhiteLabelVariant, let custom = branding.customPrimaryColor {
            return custom
        }
        return SpendlyColors.primary
    }

    // MARK: - Dashboard Header

    private var dashboardHeader: some View {
        HStack(alignment: .center, spacing: SpendlySpacing.md) {
            // Logo / icon block
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .fill(resolvedPrimary)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: SpendlyIcon.dashboard.systemName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                )

            Text(viewModel.isWhiteLabelVariant ? "FieldOps Manager" : "Manager Dashboard")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Spacer()

            // MARK: Notification Bell (#305)
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.showNotifications.toggle()
                }
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: SpendlyIcon.notifications.systemName)
                        .font(.system(size: 20))
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                    if viewModel.hasUnreadNotifications {
                        Circle()
                            .fill(SpendlyColors.error)
                            .frame(width: 8, height: 8)
                            .offset(x: 2, y: -2)
                    }
                }
                .frame(width: 36, height: 36)
            }

            // Manager avatar
            SPAvatar(
                initials: "MG",
                size: .sm,
                statusDot: SpendlyColors.success
            )
        }
    }

    // MARK: - Project Status Section (#300-#302)

    private var projectStatusSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Text("Project Status")
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                Text("Last updated: \(viewModel.lastUpdatedText)")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }

            // 3-column stat cards matching Stitch grid
            HStack(spacing: SpendlySpacing.md) {
                ForEach(viewModel.projectStatusCards) { card in
                    projectStatusCardView(card)
                }
            }
        }
    }

    private func projectStatusCardView(_ card: ProjectStatusCard) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                // Top row: label + icon
                HStack {
                    Text(card.title)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                    Spacer()

                    Image(systemName: card.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(card.iconColor.color)
                }

                // Big number
                Text("\(card.value)")
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .monospacedDigit()

                // Trend row
                HStack(spacing: SpendlySpacing.xs) {
                    Text(trendText(card.trendPercent))
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(card.trendDirection.color)

                    Text(card.trendLabel)
                        .font(.system(size: 10))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func trendText(_ percent: Double) -> String {
        let sign = percent >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.1f", percent))%"
    }

    // MARK: - Urgent Jobs + Resource Allocation Layout

    private var urgentJobsAndResourcesSection: some View {
        // On compact widths (iPhone) this stacks vertically.
        // On regular widths (iPad) it matches the Stitch 1:2 column split.
        VStack(spacing: SpendlySpacing.xl) {
            urgentJobsSection
            resourceAllocationSection
        }
    }

    // MARK: - Urgent Jobs Section (#303, #304)

    private var urgentJobsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Text("Urgent Jobs")
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                // MARK: View All Link (#304)
                Button {
                    viewModel.showAllUrgentJobs = true
                } label: {
                    Text("View All")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(resolvedPrimary)
                }
            }

            if viewModel.urgentJobs.isEmpty {
                SPCard(elevation: .low) {
                    VStack(spacing: SpendlySpacing.md) {
                        Image(systemName: "checkmark.seal")
                            .font(.system(size: 32))
                            .foregroundStyle(SpendlyColors.success)
                        Text("No urgent jobs")
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.lg)
                }
            } else {
                VStack(spacing: SpendlySpacing.md) {
                    ForEach(viewModel.urgentJobs) { job in
                        urgentJobCard(job)
                    }
                }
            }
        }
    }

    private func urgentJobCard(_ job: UrgentJob) -> some View {
        // Card with left priority border matching Stitch
        HStack(spacing: 0) {
            // Priority accent border
            Rectangle()
                .fill(job.priority.borderColor)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                // Title row + Priority badge
                HStack(alignment: .top) {
                    Text(job.title)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .lineLimit(1)

                    Spacer()

                    // MARK: Priority Badge (#303)
                    SPBadge(job.priority.rawValue.uppercased(), style: job.priority.badgeStyle)
                }

                // Description
                Text(job.description)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .lineLimit(2)

                // Bottom row: location + Assign Now button
                HStack {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: SpendlyIcon.location.systemName)
                            .font(.system(size: 12))
                            .foregroundStyle(SpendlyColors.secondary)

                        Text(job.location)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    Spacer()

                    // MARK: Assign Now Button (#303)
                    Button {
                        viewModel.assignJob(job)
                    } label: {
                        Text("Assign Now")
                            .font(SpendlyFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, SpendlySpacing.md)
                            .padding(.vertical, SpendlySpacing.sm)
                            .background(resolvedPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }
                }
                .padding(.top, SpendlySpacing.xs)
            }
            .padding(SpendlySpacing.lg)
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: - Resource Allocation Section (#305)

    private var resourceAllocationSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Text("Resource Allocation")
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                HStack(spacing: SpendlySpacing.sm) {
                    smallOutlineButton("Filter")
                    smallOutlineButton("Export")
                }
            }

            SPCard(elevation: .low, padding: 0) {
                VStack(spacing: 0) {
                    // Table header
                    resourceTableHeader

                    SPDivider()

                    // Table rows
                    ForEach(Array(viewModel.technicians.enumerated()), id: \.element.id) { index, tech in
                        technicianRow(tech)

                        if index < viewModel.technicians.count - 1 {
                            Divider()
                                .foregroundStyle(SpendlyColors.secondary.opacity(0.1))
                        }
                    }

                    SPDivider()

                    // Manage Fleet Allocation footer
                    Button {
                        // Navigate to full resource management
                    } label: {
                        HStack(spacing: SpendlySpacing.sm) {
                            Text("Manage Fleet Allocation")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(resolvedPrimary)

                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(resolvedPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SpendlySpacing.lg)
                    }
                }
            }
        }
    }

    private var resourceTableHeader: some View {
        HStack(spacing: 0) {
            Text("TECHNICIAN")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("ACTIVE PROJECT")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("STATUS")
                .frame(width: 80, alignment: .leading)

            Text("WORKLOAD")
                .frame(width: 80, alignment: .leading)
        }
        .font(.system(size: 10, weight: .semibold))
        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
        .tracking(0.5)
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(
            colorScheme == .dark
                ? SpendlyColors.surfaceDark.opacity(0.5)
                : SpendlyColors.backgroundLight
        )
    }

    private func technicianRow(_ tech: TechnicianResource) -> some View {
        HStack(spacing: 0) {
            // Technician avatar + info
            HStack(spacing: SpendlySpacing.sm) {
                SPAvatar(
                    initials: tech.initials,
                    size: .sm,
                    statusDot: tech.status.dotColor
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(tech.name)
                        .font(SpendlyFont.bodyMedium())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .lineLimit(1)

                    Text(tech.specialty)
                        .font(.system(size: 10))
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Active project
            Text(tech.activeProject)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Status indicator
            statusIndicator(tech.status)
                .frame(width: 80, alignment: .leading)

            // Workload bar
            SPProgressBar(progress: tech.workloadPercent, height: 6)
                .frame(width: 80)
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
    }

    private func statusIndicator(_ status: TechnicianFieldStatus) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Circle()
                .fill(status.dotColor)
                .frame(width: 6, height: 6)

            Text(status.rawValue)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(status.dotColor)
        }
    }

    private func smallOutlineButton(_ title: String) -> some View {
        Button {
            // Placeholder
        } label: {
            Text(title)
                .font(SpendlyFont.caption())
                .fontWeight(.medium)
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.sm)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                        .strokeBorder(
                            colorScheme == .dark
                                ? Color.white.opacity(0.1)
                                : Color.black.opacity(0.1),
                            lineWidth: 1
                        )
                )
        }
    }

    // MARK: - Notification Overlay (#305, #307)

    private var notificationOverlay: some View {
        ZStack(alignment: .topTrailing) {
            // Dimmed backdrop
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        viewModel.showNotifications = false
                    }
                }

            // Notification panel
            VStack(alignment: .leading, spacing: 0) {
                // Panel header
                HStack {
                    Text("Notifications")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    if viewModel.unreadNotificationCount > 0 {
                        SPBadge("\(viewModel.unreadNotificationCount)", style: .error)
                    }

                    Spacer()

                    if viewModel.hasUnreadNotifications {
                        Button {
                            viewModel.markAllNotificationsRead()
                        } label: {
                            Text("Mark all read")
                                .font(SpendlyFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(resolvedPrimary)
                        }
                    }

                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.showNotifications = false
                        }
                    } label: {
                        Image(systemName: SpendlyIcon.close.systemName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
                .padding(SpendlySpacing.lg)

                SPDivider()

                // Notification list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.notifications) { notification in
                            notificationRow(notification)
                            SPDivider()
                        }
                    }
                }
            }
            .frame(width: min(UIScreen.main.bounds.width - 32, 360))
            .frame(maxHeight: 420)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
            .padding(.top, SpendlySpacing.sm)
            .padding(.trailing, SpendlySpacing.lg)
        }
        .transition(.opacity)
    }

    private func notificationRow(_ notification: DashboardNotification) -> some View {
        HStack(alignment: .top, spacing: SpendlySpacing.md) {
            // Type icon
            Image(systemName: notification.type.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(notification.type.badgeStyle.foregroundColor)
                .frame(width: 28, height: 28)
                .background(notification.type.badgeStyle.foregroundColor.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                HStack {
                    Text(notification.title)
                        .font(SpendlyFont.bodyMedium())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .lineLimit(1)

                    Spacer()

                    if !notification.isRead {
                        Circle()
                            .fill(SpendlyColors.info)
                            .frame(width: 6, height: 6)
                    }
                }

                Text(notification.body)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .lineLimit(2)

                // Approval action buttons (#307)
                if notification.type == .approvalRequired && !notification.isRead {
                    HStack(spacing: SpendlySpacing.sm) {
                        Button {
                            viewModel.handleApproval(notification, approved: true)
                        } label: {
                            Text("Approve")
                                .font(SpendlyFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, SpendlySpacing.md)
                                .padding(.vertical, SpendlySpacing.xs + 2)
                                .background(SpendlyColors.success)
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
                        }

                        Button {
                            viewModel.handleApproval(notification, approved: false)
                        } label: {
                            Text("Reject")
                                .font(SpendlyFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(SpendlyColors.error)
                                .padding(.horizontal, SpendlySpacing.md)
                                .padding(.vertical, SpendlySpacing.xs + 2)
                                .background(SpendlyColors.error.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
                        }
                    }
                    .padding(.top, SpendlySpacing.xs)
                }

                Text(timeAgoText(notification.createdAt))
                    .font(.system(size: 10))
                    .foregroundStyle(SpendlyColors.secondary.opacity(0.6))
            }
        }
        .padding(SpendlySpacing.lg)
        .background(
            notification.isRead
                ? Color.clear
                : resolvedPrimary.opacity(0.03)
        )
        .onTapGesture {
            viewModel.markNotificationRead(notification)
        }
    }

    private func timeAgoText(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes)m ago" }
        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }
        return "\(hours / 24)d ago"
    }
}

// MARK: - Previews

#Preview("Manager Dashboard") {
    NavigationStack {
        ManagerDashboardRootView()
    }
}

#Preview("Manager Dashboard - Dark") {
    NavigationStack {
        ManagerDashboardRootView()
    }
    .preferredColorScheme(.dark)
}

#Preview("Manager Dashboard - White Label") {
    NavigationStack {
        ManagerDashboardRootView()
    }
    .brandingConfiguration(
        BrandingConfiguration(
            customPrimaryColor: .blue,
            customSecondaryColor: .purple,
            fontChoice: .sansSerif,
            cornerStyle: .rounded
        )
    )
}
