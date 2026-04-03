import SwiftUI
import SpendlyCore

// MARK: - Root View

public struct MappingOversightRootView: View {
    @State private var viewModel = MappingOversightViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.xxl) {

                    // MARK: Header
                    sectionHeader

                    // MARK: Filters
                    filtersRow

                    // MARK: Bento Grid (Chart + Metrics)
                    bentoGrid

                    // MARK: Organization Map Status
                    organizationSection

                    // MARK: Global Node Density Placeholder
                    nodeDensityPlaceholder
                }
            }
            .sheet(isPresented: $viewModel.showDrillDown) {
                drillDownSheet
            }
            .alert("Emergency Broadcast", isPresented: $viewModel.showEmergencyAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm Broadcast", role: .destructive) { viewModel.confirmEmergency() }
            } message: {
                Text("This will send an emergency alert to all active mapping sessions. Continue?")
            }
            .alert("Deploy Mapping", isPresented: $viewModel.showDeployConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Deploy", role: .none) { viewModel.confirmDeploy() }
            } message: {
                Text("Deploy the current mapping configuration to all connected organizations?")
            }

            // MARK: Emergency FAB
            emergencyButton
        }
    }
}

// MARK: - Section Header

private extension MappingOversightRootView {

    var sectionHeader: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text("ARCHITECTURAL INTELLIGENCE")
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .tracking(0.8)

                    Text("Mapping Oversight")
                        .font(SpendlyFont.title())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Text("Monitoring 142 active customer field configurations across 12 regions.")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                }

                Spacer()

                Button {
                    viewModel.deployMapping()
                } label: {
                    Text("Deploy Mapping")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, SpendlySpacing.lg)
                        .padding(.vertical, SpendlySpacing.sm + 2)
                        .background(SpendlyColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous))
                }
            }
        }
        .padding(.bottom, SpendlySpacing.xs)
        .overlay(alignment: .bottom) {
            SPDivider()
        }
    }
}

// MARK: - Filters

private extension MappingOversightRootView {

    var filtersRow: some View {
        HStack(spacing: SpendlySpacing.sm) {
            filterChip(icon: "line.3.horizontal.decrease", label: viewModel.activeFilterLabel)
            filterChip(icon: "calendar", label: viewModel.dateFilterLabel)
            Spacer()
        }
    }

    func filterChip(icon: String, label: String) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(SpendlyColors.secondary)
            Text(label)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.vertical, SpendlySpacing.sm)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .strokeBorder(
                    colorScheme == .dark
                        ? Color.white.opacity(0.08)
                        : Color.black.opacity(0.08),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Bento Grid

private extension MappingOversightRootView {

    var bentoGrid: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Bottleneck chart (full width)
            SPChartCard(
                title: "Common Mapping Bottlenecks",
                chartType: .bar,
                data: viewModel.bottleneckChartData
            )

            // Metric cards row
            HStack(spacing: SpendlySpacing.md) {
                totalRisksCard
                autoResolvedCard
            }
        }
    }

    // MARK: Total Risks (dark themed)

    var totalRisksCard: some View {
        SPCard(elevation: .low) {
            ZStack(alignment: .bottomTrailing) {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("TOTAL RISKS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(.white.opacity(0.6))

                    Text("\(viewModel.totalRisks)")
                        .font(SpendlyFont.largeTitle())
                        .foregroundStyle(.white)
                        .monospacedDigit()

                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "arrow.down.right")
                            .font(.system(size: 11, weight: .semibold))
                        Text(viewModel.totalRisksTrend)
                            .font(.system(size: 11, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.08))
                    .offset(x: 6, y: 6)
            }
        }
        .background(SpendlyColors.primary)
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: Auto-Resolved

    var autoResolvedCard: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("AUTO-RESOLVED")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                Text("\(viewModel.autoResolved)")
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .monospacedDigit()

                SPProgressBar(progress: viewModel.autoResolvedPercent, height: 4)

                Text("\(Int(viewModel.autoResolvedPercent * 100))% OF TOTAL SUGGESTIONS ACCEPTED")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(SpendlyColors.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Organization Section

private extension MappingOversightRootView {

    var organizationSection: some View {
        VStack(spacing: SpendlySpacing.lg) {
            // Section title + search
            HStack {
                Text("Organization Map Status")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
            }

            SPSearchBar(searchText: $viewModel.searchText)

            // Organization cards
            ForEach(viewModel.filteredOrganizations) { org in
                orgCard(org)
            }

            if viewModel.filteredOrganizations.isEmpty {
                Text("No organizations match your search.")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.md)
            }
        }
    }

    func orgCard(_ org: MappingOrganization) -> some View {
        Button {
            viewModel.selectOrganization(org)
        } label: {
            HStack(spacing: SpendlySpacing.md) {
                // Initials avatar
                Text(org.initials)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(SpendlyColors.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        colorScheme == .dark
                            ? Color.white.opacity(0.08)
                            : SpendlyColors.backgroundLight
                    )
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                // Name & details
                VStack(alignment: .leading, spacing: 2) {
                    Text(org.name)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Text("Last updated: \(org.lastUpdated) \u{2022} \(org.activeNodes) active nodes")
                        .font(.system(size: 11))
                        .foregroundStyle(SpendlyColors.secondary)
                }

                Spacer()

                // Status column
                VStack(alignment: .trailing, spacing: 2) {
                    statusBadge(for: org.status)

                    Text(org.statusDetail.uppercased())
                        .font(.system(size: 9))
                        .foregroundStyle(SpendlyColors.secondary)
                        .lineLimit(1)
                }

                // Chevron
                Image(systemName: SpendlyIcon.chevronRight.systemName)
                    .font(.system(size: 14))
                    .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
            }
            .padding(SpendlySpacing.lg)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(orgBorderColor(for: org.status), lineWidth: orgBorderWidth(for: org.status))
            )
        }
        .buttonStyle(.plain)
    }

    func statusBadge(for status: OrgStatus) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Circle()
                .fill(statusColor(for: status))
                .frame(width: 7, height: 7)
            Text(status.rawValue)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(statusColor(for: status))
        }
    }

    func statusColor(for status: OrgStatus) -> Color {
        switch status {
        case .critical: return SpendlyColors.error
        case .warning:  return SpendlyColors.warning
        case .stable:   return SpendlyColors.secondary
        }
    }

    func orgBorderColor(for status: OrgStatus) -> Color {
        switch status {
        case .critical:
            return colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.08)
        case .warning:
            return SpendlyColors.accent.opacity(0.4)
        case .stable:
            return colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.08)
        }
    }

    func orgBorderWidth(for status: OrgStatus) -> CGFloat {
        status == .warning ? 2 : 1
    }
}

// MARK: - Node Density Placeholder

private extension MappingOversightRootView {

    var nodeDensityPlaceholder: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("GLOBAL NODE DENSITY")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(SpendlyColors.secondary)

                Text("Mapping Hotspots")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .fill(
                            colorScheme == .dark
                                ? SpendlyColors.primary.opacity(0.15)
                                : SpendlyColors.primary.opacity(0.05)
                        )
                        .frame(height: 160)
                        .overlay {
                            VStack(spacing: SpendlySpacing.sm) {
                                Image(systemName: "globe")
                                    .font(.system(size: 40))
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.3))
                                Text("Live map visualization")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                            }
                        }

                    Text("LIVE OVERVIEW")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, SpendlySpacing.sm)
                        .padding(.vertical, SpendlySpacing.xs)
                        .background(SpendlyColors.primary)
                        .clipShape(Capsule())
                        .padding(SpendlySpacing.sm)
                }
            }
        }
        // Extra bottom padding so content doesn't hide behind the FAB
        .padding(.bottom, 60)
    }
}

// MARK: - Emergency Button

private extension MappingOversightRootView {

    var emergencyButton: some View {
        Button {
            viewModel.triggerEmergency()
        } label: {
            Image(systemName: "light.beacon.max.fill")
                .font(.system(size: 22))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(SpendlyColors.error)
                .clipShape(Circle())
                .shadow(color: SpendlyColors.error.opacity(0.35), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, SpendlySpacing.lg)
        .padding(.bottom, SpendlySpacing.xxl)
    }
}

// MARK: - Drill-Down Sheet

private extension MappingOversightRootView {

    var drillDownSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpendlySpacing.xl) {
                    // Configuration Viewer
                    configurationViewer

                    // AI Suggestions
                    aiSuggestionsSection

                    // View Optimization Plan
                    optimizationPlanRow
                }
                .padding(SpendlySpacing.lg)
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationTitle("Active Drill-down: \(viewModel.selectedOrganization?.name ?? "")")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        viewModel.closeDrillDown()
                    } label: {
                        Image(systemName: SpendlyIcon.close.systemName)
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }
        }
        .presentationDetents([.large, .medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: Configuration Viewer

    var configurationViewer: some View {
        SPCard(elevation: .medium) {
            VStack(spacing: SpendlySpacing.md) {
                ForEach(viewModel.drillDownNodes) { node in
                    nodeRow(node)
                    if node.id != viewModel.drillDownNodes.last?.id {
                        // Connector line
                        HStack {
                            Spacer()
                            Rectangle()
                                .fill(
                                    colorScheme == .dark
                                        ? Color.white.opacity(0.12)
                                        : Color.black.opacity(0.12)
                                )
                                .frame(width: 1, height: 24)
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    func nodeRow(_ node: DrillDownNode) -> some View {
        HStack {
            Image(systemName: node.isError ? "link" : "folder")
                .font(.system(size: 14))
                .foregroundStyle(node.isError ? SpendlyColors.error : SpendlyColors.primary)

            Text(node.name)
                .font(.system(size: 13, weight: node.isError ? .bold : .semibold))
                .foregroundStyle(
                    node.isError
                        ? SpendlyColors.error
                        : SpendlyColors.foreground(for: colorScheme)
                )

            Spacer()

            Text(node.label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(node.isError ? SpendlyColors.error : SpendlyColors.secondary)
        }
        .padding(SpendlySpacing.md)
        .background(
            node.isError
                ? SpendlyColors.error.opacity(0.08)
                : (colorScheme == .dark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .strokeBorder(
                    node.isError
                        ? SpendlyColors.error.opacity(0.3)
                        : (colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.08)),
                    lineWidth: 1
                )
        )
        .overlay(alignment: .leading) {
            if node.isError {
                Rectangle()
                    .fill(SpendlyColors.error)
                    .frame(width: 3)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: SpendlyRadius.medium,
                            bottomLeadingRadius: SpendlyRadius.medium,
                            style: .continuous
                        )
                    )
            } else {
                Rectangle()
                    .fill(SpendlyColors.accent)
                    .frame(width: 2)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: SpendlyRadius.medium,
                            bottomLeadingRadius: SpendlyRadius.medium,
                            style: .continuous
                        )
                    )
            }
        }
    }

    // MARK: AI Suggestions

    var aiSuggestionsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 14))
                    .foregroundStyle(SpendlyColors.accent)
                Text("SUPPORT SUGGESTIONS")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(SpendlyColors.accent)
            }

            ForEach(viewModel.suggestions) { suggestion in
                suggestionCard(suggestion)
            }
        }
    }

    func suggestionCard(_ suggestion: AISuggestion) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                Text(suggestion.description)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                if let path = suggestion.proposedPath {
                    HStack(spacing: SpendlySpacing.sm) {
                        Text("PROPOSED PATH")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(SpendlyColors.secondary)
                            .padding(.horizontal, SpendlySpacing.sm)
                            .padding(.vertical, 3)
                            .background(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.06)
                                    : Color.black.opacity(0.04)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                            .foregroundStyle(SpendlyColors.secondary)

                        Text(path)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(SpendlyColors.accent)
                            .padding(.horizontal, SpendlySpacing.sm)
                            .padding(.vertical, 3)
                            .background(SpendlyColors.accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
                    }
                }

                if let note = suggestion.optimizationNote {
                    Text(note)
                        .font(.system(size: 11))
                        .foregroundStyle(SpendlyColors.secondary)
                }

                if !suggestion.isSecondary {
                    // Primary suggestion: action buttons
                    HStack(spacing: SpendlySpacing.sm) {
                        Button {
                            viewModel.proposeSolution(for: suggestion)
                        } label: {
                            Text("Propose Solution")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, SpendlySpacing.sm + 2)
                                .background(SpendlyColors.accent)
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        }

                        Button {
                            viewModel.dismissSuggestion(suggestion)
                        } label: {
                            Text("Dismiss")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                .padding(.horizontal, SpendlySpacing.lg)
                                .padding(.vertical, SpendlySpacing.sm + 2)
                                .background(
                                    colorScheme == .dark
                                        ? Color.white.opacity(0.06)
                                        : Color.black.opacity(0.04)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        }
                    }
                }
            }
        }
        .opacity(suggestion.isSecondary ? 0.65 : 1.0)
    }

    // MARK: Optimization Plan

    var optimizationPlanRow: some View {
        Group {
            if viewModel.suggestions.contains(where: { $0.isSecondary }) {
                Button {} label: {
                    Text("View Optimization Plan")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(SpendlyColors.primary)
                        .underline()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    MappingOversightRootView()
        .environment(\.colorScheme, .light)
}

#Preview("Dark") {
    MappingOversightRootView()
        .environment(\.colorScheme, .dark)
}
