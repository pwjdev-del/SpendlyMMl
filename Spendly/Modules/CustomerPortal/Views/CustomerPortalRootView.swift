import SwiftUI
import SpendlyCore

public struct CustomerPortalRootView: View {

    @State private var viewModel = CustomerPortalViewModel()
    @State private var showAllTickets = false
    @State private var showAllFleet = false
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SpendlySpacing.lg) {
                        welcomeBanner
                        statsGrid
                        activeServiceTrackingSection
                        recentIssuesSection
                        machinesSection
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.top, SpendlySpacing.sm)
                    .padding(.bottom, SpendlySpacing.xxxl)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .navigationDestination(for: CustomerPortalDestination.self) { destination in
                switch destination {
                case .serviceTracker(let serviceID):
                    ServiceTrackerView(viewModel: viewModel, serviceID: serviceID)
                case .reportIssue:
                    reportIssuePlaceholder
                }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: SpendlySpacing.sm) {
                ZStack {
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .fill(SpendlyColors.primary)
                        .frame(width: 32, height: 32)
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Text(viewModel.portalTitle)
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                // notifications placeholder
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: SpendlyIcon.notifications.systemName)
                        .font(.system(size: 18))
                        .foregroundStyle(SpendlyColors.secondary)
                    Circle()
                        .fill(SpendlyColors.accent)
                        .frame(width: 8, height: 8)
                        .offset(x: 2, y: -2)
                }
            }
        }
    }

    // MARK: - Welcome Banner

    private var welcomeBanner: some View {
        SPCard(elevation: .low) {
            VStack(spacing: SpendlySpacing.lg) {
                HStack(spacing: SpendlySpacing.md) {
                    // Greeting icon
                    ZStack {
                        Circle()
                            .fill(SpendlyColors.accent.opacity(0.12))
                            .frame(width: 56, height: 56)
                        Image(systemName: "hand.wave.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(SpendlyColors.accent)
                    }

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("Welcome back, \(viewModel.customerName)")
                            .font(SpendlyFont.title())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        Text("Everything looks good with your fleet today.")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                        Text("Last login: \(viewModel.lastLogin)")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                    }

                    Spacer(minLength: 0)
                }

                // Report New Issue CTA
                SPButton("Report New Issue", icon: "plus.circle.fill", style: .accent) {
                    viewModel.navigationPath.append(.reportIssue)
                }
            }
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: SpendlySpacing.sm),
            GridItem(.flexible(), spacing: SpendlySpacing.sm)
        ], spacing: SpendlySpacing.sm) {
            statTile(
                label: "Active Issues",
                value: "\(viewModel.stats.activeIssues)",
                delta: viewModel.stats.activeIssuesDelta,
                deltaColor: SpendlyColors.error,
                icon: "exclamationmark.triangle.fill",
                footerText: "Requires attention",
                footerColor: SpendlyColors.primary
            )
            statTile(
                label: "Resolved (30d)",
                value: "\(viewModel.stats.resolvedCount)",
                delta: viewModel.stats.resolvedDelta,
                deltaColor: SpendlyColors.success,
                icon: "checkmark.circle.fill",
                footerText: "Operating normally",
                footerColor: SpendlyColors.success
            )
            statTile(
                label: "Scheduled Service",
                value: "\(viewModel.stats.scheduledService)",
                delta: nil,
                deltaColor: .clear,
                icon: "calendar",
                footerText: "Next: \(viewModel.stats.nextServiceDate)",
                footerColor: SpendlyColors.secondary
            )
            statTile(
                label: "Uptime Rate",
                value: viewModel.stats.uptimeRate,
                delta: nil,
                deltaColor: .clear,
                icon: "arrow.up.right",
                footerText: "Fleet average",
                footerColor: SpendlyColors.secondary
            )
        }
    }

    private func statTile(
        label: String,
        value: String,
        delta: String?,
        deltaColor: Color,
        icon: String,
        footerText: String,
        footerColor: Color
    ) -> some View {
        SPCard(elevation: .low, padding: SpendlySpacing.md) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                HStack {
                    Text(label)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    Spacer()
                    if let delta {
                        Text(delta)
                            .font(SpendlyFont.caption())
                            .fontWeight(.bold)
                            .foregroundStyle(deltaColor)
                            .padding(.horizontal, SpendlySpacing.sm)
                            .padding(.vertical, 2)
                            .background(deltaColor.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small))
                    }
                }

                Text(value)
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .monospacedDigit()

                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: icon)
                        .font(.system(size: 11))
                    Text(footerText)
                        .font(SpendlyFont.caption())
                        .fontWeight(.medium)
                }
                .foregroundStyle(footerColor)
            }
        }
    }

    // MARK: - Active Service Tracking (inline preview)

    @ViewBuilder
    private var activeServiceTrackingSection: some View {
        if let service = viewModel.primaryActiveService {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                HStack {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "location.fill")
                            .foregroundStyle(SpendlyColors.accent)
                        Text("Live Service Tracking")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                    Spacer()
                    SPBadge(service.currentStatus.rawValue, style: .custom(service.currentStatus.color))
                }

                Button {
                    viewModel.navigateToServiceTracker(serviceID: service.id)
                } label: {
                    SPCard(elevation: .medium, padding: SpendlySpacing.md) {
                        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                            // Ticket info
                            HStack {
                                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                    Text(service.title)
                                        .font(SpendlyFont.bodySemibold())
                                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                    Text("\(service.machineName) \u{2022} \(service.ticketNumber)")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondary)
                                }
                                Spacer()
                                Image(systemName: SpendlyIcon.chevronRight.systemName)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                            }

                            // Progress steps (compact)
                            serviceProgressSteps(currentStatus: service.currentStatus)

                            // Technician mini card
                            HStack(spacing: SpendlySpacing.md) {
                                SPAvatar(
                                    initials: service.technician.initials,
                                    size: .sm,
                                    statusDot: SpendlyColors.success
                                )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(service.technician.name)
                                        .font(SpendlyFont.bodySemibold())
                                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                    if let eta = service.technician.etaMinutes {
                                        Text("ETA: \(eta) min")
                                            .font(SpendlyFont.caption())
                                            .foregroundStyle(SpendlyColors.accent)
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// Compact inline progress indicator: 4 dots connected by a bar.
    private func serviceProgressSteps(currentStatus: ServiceJobStatus) -> some View {
        let steps = ServiceJobStatus.allCases
        let currentIdx = currentStatus.stepIndex

        return VStack(spacing: SpendlySpacing.xs) {
            // Bar + dots
            GeometryReader { geo in
                let stepWidth = geo.size.width / CGFloat(steps.count - 1)
                ZStack(alignment: .leading) {
                    // Background bar
                    RoundedRectangle(cornerRadius: 2)
                        .fill(SpendlyColors.secondary.opacity(0.15))
                        .frame(height: 3)

                    // Filled bar
                    RoundedRectangle(cornerRadius: 2)
                        .fill(SpendlyColors.accent)
                        .frame(width: stepWidth * CGFloat(currentIdx), height: 3)

                    // Dots
                    ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                        Circle()
                            .fill(idx <= currentIdx ? step.color : SpendlyColors.secondary.opacity(0.3))
                            .frame(width: idx == currentIdx ? 12 : 8, height: idx == currentIdx ? 12 : 8)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white, lineWidth: idx == currentIdx ? 2 : 0)
                            )
                            .offset(x: stepWidth * CGFloat(idx) - (idx == currentIdx ? 6 : 4))
                    }
                }
            }
            .frame(height: 14)

            // Labels
            HStack {
                ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                    Text(step.rawValue)
                        .font(.system(size: 9, weight: idx <= currentIdx ? .bold : .regular))
                        .foregroundStyle(idx <= currentIdx ? SpendlyColors.foreground(for: colorScheme) : SpendlyColors.secondary.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Recent Issues

    private var recentIssuesSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            HStack {
                Text("Recent Issue Status")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
                Button {
                    withAnimation { showAllTickets.toggle() }
                } label: {
                    Text(showAllTickets ? "Show Less" : "View All Tickets")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.primary)
                }
            }

            if showAllTickets {
                LazyVStack(spacing: SpendlySpacing.sm) {
                    ForEach(viewModel.recentIssues) { issue in
                        issueCard(issue)
                    }
                }
            } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpendlySpacing.sm) {
                    ForEach(viewModel.recentIssues) { issue in
                        issueCard(issue)
                    }
                }
            }
            }
        }
    }

    private func issueCard(_ issue: PortalIssue) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            HStack {
                SPBadge(issue.status.rawValue, style: issue.status.badgeStyle)
                Spacer()
                Text(issue.ticketNumber)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            Text(issue.title)
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .lineLimit(1)

            Text(issue.machineName)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)

            Spacer(minLength: SpendlySpacing.sm)

            VStack(spacing: SpendlySpacing.xs) {
                HStack {
                    Text(issue.progressLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(SpendlyColors.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    Spacer()
                    Text("\(Int(issue.progressPercent * 100))%")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(SpendlyColors.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(SpendlyColors.secondary.opacity(0.12))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(issue.status.color)
                            .frame(width: geo.size.width * issue.progressPercent, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(SpendlySpacing.md)
        .frame(width: 260)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: - Machines

    private var machinesSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            HStack {
                Text("My Machines")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
                Button {
                    withAnimation { showAllFleet.toggle() }
                } label: {
                    Text(showAllFleet ? "Show Less" : "View Fleet Details")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.primary)
                }
            }

            LazyVStack(spacing: SpendlySpacing.sm) {
                ForEach(showAllFleet ? viewModel.machines : Array(viewModel.machines.prefix(3))) { machine in
                    machineRow(machine)
                }
            }
        }
    }

    private func machineRow(_ machine: PortalMachine) -> some View {
        SPCard(elevation: .low, padding: SpendlySpacing.md) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(machine.name)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("ID: \(machine.machineID)")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                    Spacer()
                    SPBadge(machine.status.rawValue, style: machine.status.badgeStyle)
                }

                HStack {
                    Text(machine.detailLabel)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                    Spacer()
                    Text(machine.detailValue)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(
                            machine.status == .warning
                                ? SpendlyColors.accent
                                : SpendlyColors.foreground(for: colorScheme)
                        )
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(SpendlyColors.secondary.opacity(0.12))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(machine.status.color)
                            .frame(width: geo.size.width * machine.healthPercent, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
    }

    // MARK: - Report Issue Placeholder

    private var reportIssuePlaceholder: some View {
        ZStack {
            SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                .ignoresSafeArea()

            VStack(spacing: SpendlySpacing.lg) {
                Image(systemName: "plus.circle")
                    .font(.system(size: 48))
                    .foregroundStyle(SpendlyColors.accent)
                Text("Report New Issue")
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Text("Issue reporting form coming soon.")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondary)
            }
        }
        .navigationTitle("Report Issue")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview("Customer Portal - Light") {
    CustomerPortalRootView()
        .preferredColorScheme(.light)
}

#Preview("Customer Portal - Dark") {
    CustomerPortalRootView()
        .preferredColorScheme(.dark)
}
