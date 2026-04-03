import SwiftUI
import SpendlyCore

public struct ResourceManagementRootView: View {
    @State private var vm = ResourceManagementViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerSection

            // Tab Selector
            tabSelector

            // Content
            switch vm.selectedTab {
            case .workload:
                workloadDashboard
            case .compare:
                CompareTechniciansView(vm: vm)
            case .groups:
                SavedGroupsView(vm: vm)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: SpendlySpacing.md) {
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .fill(SpendlyColors.primary)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                )

            Text("Resource Management")
                .font(SpendlyFont.title())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Spacer()

            Menu {
                ForEach(vm.customerOptions, id: \.self) { option in
                    Button(option) {
                        vm.selectedCustomerFilter = option
                    }
                }
            } label: {
                HStack(spacing: SpendlySpacing.xs) {
                    Text(vm.selectedCustomerFilter)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.sm)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(ResourceDashboardTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: SpendlySpacing.sm) {
                        Text(tab.rawValue)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(
                                vm.selectedTab == tab
                                    ? SpendlyColors.primary
                                    : SpendlyColors.secondary
                            )

                        Rectangle()
                            .fill(vm.selectedTab == tab ? SpendlyColors.primary : .clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Workload Dashboard

    private var workloadDashboard: some View {
        SPScreenWrapper {
            VStack(spacing: SpendlySpacing.lg) {
                // KPI Cards
                kpiSection

                // Unassigned Requests
                unassignedRequestsSection

                // Technician Availability
                technicianAvailabilitySection

                // Prior Commitments
                priorCommitmentsSection

                // Regional Dashboard
                regionalDashboardSection
            }
        }
    }

    // MARK: - KPI Section

    private var kpiSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            HStack(spacing: SpendlySpacing.md) {
                kpiCard(
                    title: "Unassigned Jobs",
                    value: "\(vm.unassignedJobCount)",
                    icon: "doc.text.magnifyingglass",
                    iconColor: SpendlyColors.accent,
                    trend: "+2% from yesterday",
                    trendUp: true
                )
                kpiCard(
                    title: "Total Capacity",
                    value: "\(vm.totalCapacityPercent)%",
                    icon: "person.2",
                    iconColor: SpendlyColors.primary,
                    trend: "-5% vs target",
                    trendUp: false
                )
            }

            HStack(spacing: SpendlySpacing.md) {
                kpiCard(
                    title: "Priority Alerts",
                    value: "\(vm.priorityAlertCount)",
                    icon: "exclamationmark.circle",
                    iconColor: SpendlyColors.error,
                    trend: "+1 resolved today",
                    trendUp: true
                )
                kpiCard(
                    title: "Active Techs",
                    value: "\(vm.activeTechCount)/\(vm.technicians.count)",
                    icon: "person.badge.clock",
                    iconColor: SpendlyColors.success,
                    trend: "\(vm.availableTechCount) available",
                    trendUp: true
                )
            }
        }
    }

    private func kpiCard(
        title: String,
        value: String,
        icon: String,
        iconColor: Color,
        trend: String,
        trendUp: Bool
    ) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                HStack {
                    Text(title)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    Spacer()
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(iconColor)
                }

                Text(value)
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .monospacedDigit()

                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: trendUp ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 10, weight: .semibold))
                    Text(trend)
                        .font(SpendlyFont.caption())
                        .fontWeight(.medium)
                }
                .foregroundStyle(trendUp ? SpendlyColors.success : SpendlyColors.error)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Unassigned Requests Section

    private var unassignedRequestsSection: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                Image(systemName: "clock.badge.questionmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(SpendlyColors.accent)
                Text("Unassigned Requests")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
                SPBadge("\(vm.unassignedRequests.count) Total", style: .custom(SpendlyColors.accent))
            }
            .padding(SpendlySpacing.lg)
            .background(SpendlyColors.surface(for: colorScheme).opacity(0.6))
            .clipShape(
                .rect(topLeadingRadius: SpendlyRadius.large, topTrailingRadius: SpendlyRadius.large)
            )

            // Request cards
            VStack(spacing: SpendlySpacing.md) {
                ForEach(vm.unassignedRequests) { request in
                    requestCard(request)
                }
            }
            .padding(SpendlySpacing.lg)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(
                .rect(bottomLeadingRadius: SpendlyRadius.large, bottomTrailingRadius: SpendlyRadius.large)
            )
        }
    }

    private func requestCard(_ request: UnassignedRequest) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            HStack {
                SPBadge(request.priority.label, style: request.priority.badgeStyle)
                Spacer()
                Text(request.requestNumber)
                    .font(.system(size: 10))
                    .foregroundStyle(SpendlyColors.secondary)
            }

            Text(request.title)
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Text(request.customerName)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)

            HStack {
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                    Text(request.location)
                        .font(SpendlyFont.caption())
                }
                .foregroundStyle(SpendlyColors.secondary)

                Spacer()

                Text("Est. \(Int(request.estimatedHours))h")
                    .font(SpendlyFont.caption())
                    .fontWeight(.medium)
                    .foregroundStyle(SpendlyColors.primary)
            }
        }
        .padding(SpendlySpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.3))
        )
    }

    // MARK: - Technician Availability Section

    private var technicianAvailabilitySection: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                Image(systemName: "wrench.and.screwdriver")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(SpendlyColors.primary)
                Text("Technician Availability")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()

                HStack(spacing: SpendlySpacing.sm) {
                    ForEach(WorkloadTimeRange.allCases, id: \.self) { range in
                        Button {
                            vm.selectedTimeRange = range
                        } label: {
                            Text(range.rawValue)
                                .font(SpendlyFont.caption())
                                .fontWeight(.medium)
                                .padding(.horizontal, SpendlySpacing.md)
                                .padding(.vertical, SpendlySpacing.xs + 2)
                                .background(
                                    vm.selectedTimeRange == range
                                        ? SpendlyColors.secondary.opacity(0.15)
                                        : .clear
                                )
                                .foregroundStyle(
                                    vm.selectedTimeRange == range
                                        ? SpendlyColors.foreground(for: colorScheme)
                                        : SpendlyColors.secondary
                                )
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(SpendlySpacing.lg)

            // Technician rows
            VStack(spacing: 0) {
                ForEach(vm.technicians) { tech in
                    technicianRow(tech)

                    if tech.id != vm.technicians.last?.id {
                        Divider()
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.1))
                    }
                }
            }
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    private func technicianRow(_ tech: TechnicianDisplayItem) -> some View {
        VStack(spacing: SpendlySpacing.md) {
            // Info row
            HStack(spacing: SpendlySpacing.md) {
                SPAvatar(
                    initials: tech.initials,
                    size: .md,
                    statusDot: vm.statusDotColor(for: tech.status)
                )

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(tech.name)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Spacer()
                        SPBadge(tech.status.label, style: tech.status.badgeStyle)
                    }
                    Text(tech.specialty)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f / %.0fh", tech.workloadHours, tech.capacityHours))
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text("Workload")
                        .font(.system(size: 10))
                        .foregroundStyle(SpendlyColors.secondary)
                }
            }

            // Schedule timeline bar
            if tech.scheduleBlocks.isEmpty {
                emptyScheduleBar
            } else {
                scheduleBar(tech.scheduleBlocks)
            }
        }
        .padding(SpendlySpacing.lg)
    }

    private func scheduleBar(_ blocks: [ScheduleBlock]) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                    .fill(SpendlyColors.secondary.opacity(0.08))

                ForEach(blocks) { block in
                    let x = geo.size.width * block.startFraction
                    let w = geo.size.width * block.widthFraction

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            block.isTravel
                                ? SpendlyColors.accent.opacity(0.35)
                                : SpendlyColors.primary.opacity(0.25)
                        )
                        .frame(width: max(w, 0))
                        .offset(x: x)
                        .overlay(
                            Text(block.label)
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(
                                    block.isTravel
                                        ? SpendlyColors.accent
                                        : SpendlyColors.primary.opacity(0.7)
                                )
                                .offset(x: x)
                            , alignment: .leading
                        )
                }

                // Timeline markers at 25%, 50%, 75%
                ForEach([0.25, 0.50, 0.75], id: \.self) { frac in
                    Rectangle()
                        .fill(SpendlyColors.secondary.opacity(0.15))
                        .frame(width: 1)
                        .offset(x: geo.size.width * frac)
                }
            }
        }
        .frame(height: 44)
    }

    private var emptyScheduleBar: some View {
        RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
            .foregroundStyle(SpendlyColors.secondary.opacity(0.3))
            .frame(height: 44)
            .overlay(
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 12))
                    Text("Available for assignment")
                        .font(SpendlyFont.caption())
                }
                .foregroundStyle(SpendlyColors.secondary)
            )
    }

    // MARK: - Prior Commitments Section

    private var priorCommitmentsSection: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(SpendlyColors.primary)
                Text("Prior Commitments")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
            }
            .padding(SpendlySpacing.lg)
            .background(SpendlyColors.surface(for: colorScheme).opacity(0.6))

            VStack(spacing: 0) {
                // Table header
                HStack {
                    Text("Scheduled Job")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Technician")
                        .frame(width: 90, alignment: .leading)
                    Text("Time")
                        .frame(width: 80, alignment: .trailing)
                }
                .font(SpendlyFont.caption())
                .fontWeight(.semibold)
                .foregroundStyle(SpendlyColors.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.vertical, SpendlySpacing.sm)

                Divider()

                ForEach(vm.priorCommitments) { commitment in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(commitment.jobTitle)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text(commitment.customerName)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Text(commitment.technicianName)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .frame(width: 90, alignment: .leading)
                            .lineLimit(1)

                        Text(commitment.timeSlot)
                            .font(SpendlyFont.caption())
                            .fontWeight(.medium)
                            .foregroundStyle(SpendlyColors.secondary)
                            .frame(width: 80, alignment: .trailing)
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.vertical, SpendlySpacing.md)

                    if commitment.id != vm.priorCommitments.last?.id {
                        Divider()
                            .padding(.horizontal, SpendlySpacing.lg)
                    }
                }
            }
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: - Regional Dashboard Section

    private var regionalDashboardSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            HStack {
                Image(systemName: "map")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(SpendlyColors.primary)
                Text("Regional Overview")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
            }

            ForEach(vm.regionalSummaries) { region in
                SPCard(elevation: .low) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        HStack {
                            Text(region.regionName)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Spacer()
                            Text("\(region.utilizationPercent)%")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(
                                    region.utilizationPercent >= 85
                                        ? SpendlyColors.error
                                        : region.utilizationPercent >= 60
                                            ? SpendlyColors.warning
                                            : SpendlyColors.success
                                )
                                .monospacedDigit()
                        }

                        SPProgressBar(
                            progress: Double(region.utilizationPercent) / 100.0,
                            height: 6
                        )

                        HStack(spacing: SpendlySpacing.lg) {
                            HStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 10))
                                Text("\(region.technicianCount) Techs")
                                    .font(SpendlyFont.caption())
                            }
                            .foregroundStyle(SpendlyColors.secondary)

                            HStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: "wrench")
                                    .font(.system(size: 10))
                                Text("\(region.activeJobs) Active Jobs")
                                    .font(SpendlyFont.caption())
                            }
                            .foregroundStyle(SpendlyColors.secondary)

                            Spacer()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ResourceManagementRootView()
}
