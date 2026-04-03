import SwiftUI
import SpendlyCore

// MARK: - Incident Analysis Root View (Dashboard)

public struct IncidentAnalysisRootView: View {

    @State private var viewModel = IncidentAnalysisViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        NavigationStack {
            ZStack {
                SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SpendlySpacing.xl) {
                        headerSection
                        metricCardsSection
                        chartsSection
                        incidentListSection
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.top, SpendlySpacing.sm)
                    .padding(.bottom, SpendlySpacing.xxxl * 2)
                }

                // Filter modal overlay
                SPFilterModal(
                    isPresented: $viewModel.showFilterModal,
                    sections: $viewModel.filterSections
                )
            }
            .navigationTitle("Incident Analysis")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showDetail) {
                if let incident = viewModel.selectedIncident {
                    IncidentDetailView(incident: incident, viewModel: viewModel)
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("Dashboard Overview")
                .font(SpendlyFont.largeTitle())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Text("Hierarchical breakdown of factory floor performance")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Metric Cards

    private var metricCardsSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            HStack(spacing: SpendlySpacing.md) {
                SPMetricCard(
                    title: "Total Incidents",
                    value: "\(viewModel.totalIncidents)",
                    trend: "+5%",
                    trendDirection: .up
                )

                SPMetricCard(
                    title: "Active Issues",
                    value: "\(viewModel.activeIssuesCount)",
                    trend: "-2%",
                    trendDirection: .down
                )
            }

            HStack(spacing: SpendlySpacing.md) {
                SPMetricCard(
                    title: "Resolution Rate",
                    value: "\(viewModel.resolutionRate)%",
                    trend: "+10%",
                    trendDirection: .up
                )

                failurePredictionCard
            }
        }
    }

    private var failurePredictionCard: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Failure Risk")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                Text("\(viewModel.averageFailureProbability)%")
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(viewModel.failurePredictionColor(for: Double(viewModel.averageFailureProbability) / 100.0))
                    .monospacedDigit()

                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Active avg.")
                        .font(SpendlyFont.caption())
                        .fontWeight(.medium)
                }
                .foregroundStyle(viewModel.failurePredictionColor(for: Double(viewModel.averageFailureProbability) / 100.0))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Charts Section

    private var chartsSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            SPChartCard(
                title: "Incidents by Category",
                chartType: .bar,
                data: IncidentAnalysisMockData.incidentsByCategory
            )

            SPChartCard(
                title: "Monthly Incident Trend",
                chartType: .line,
                data: IncidentAnalysisMockData.incidentTrend
            )

            SPChartCard(
                title: "Severity Distribution",
                chartType: .pie,
                data: IncidentAnalysisMockData.severityDistribution
            )
        }
    }

    // MARK: - Incident List Section

    private var incidentListSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Section header
            HStack {
                Text("Recent Incident Logs")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
                Text("\(viewModel.filteredIncidents.count) results")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            // Search + filter
            SPSearchBar(
                searchText: $viewModel.searchText,
                showFilterButton: true,
                onFilterTap: {
                    withAnimation {
                        viewModel.showFilterModal = true
                    }
                }
            )

            // Sort picker
            HStack {
                Text("Sort by:")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)

                Menu {
                    ForEach(IncidentSortOption.allCases, id: \.self) { option in
                        Button {
                            viewModel.sortOption = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if viewModel.sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Text(viewModel.sortOption.rawValue)
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.primary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(SpendlyColors.primary)
                    }
                }

                Spacer()

                if viewModel.activeFilterCount > 0 {
                    SPBadge("\(viewModel.activeFilterCount) filters", style: .info)
                }
            }

            // Incident cards
            if viewModel.filteredIncidents.isEmpty {
                SPCard(elevation: .low) {
                    VStack(spacing: SpendlySpacing.md) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                        Text("No incidents match your search or filters.")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.xl)
                }
            } else {
                ForEach(viewModel.filteredIncidents) { incident in
                    incidentRow(incident)
                }
            }
        }
    }

    // MARK: - Incident Row Card

    private func incidentRow(_ incident: AnalysisIncident) -> some View {
        Button {
            viewModel.selectIncident(incident)
        } label: {
            SPCard(elevation: .low) {
                VStack(spacing: SpendlySpacing.md) {
                    // Top row: Code + Status
                    HStack {
                        Text(incident.code)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(SpendlyColors.secondary)

                        Spacer()

                        SPBadge(incident.status.rawValue, style: incident.status.badgeStyle)
                    }

                    // Title + Category
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text(incident.title)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                .multilineTextAlignment(.leading)

                            HStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: incident.category.icon)
                                    .font(.system(size: 11))
                                Text(incident.category.rawValue)
                                    .font(SpendlyFont.caption())
                            }
                            .foregroundStyle(SpendlyColors.secondary)
                        }

                        Spacer()

                        SPBadge(
                            incident.severity.rawValue.uppercased(),
                            style: severityBadgeStyle(for: incident.severity)
                        )
                    }

                    SPDivider()

                    // Bottom row: Assignee + Failure prediction
                    HStack {
                        // Assignee
                        HStack(spacing: SpendlySpacing.sm) {
                            Text(incident.assignedInitials)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(SpendlyColors.primary)
                                .frame(width: 24, height: 24)
                                .background(SpendlyColors.primary.opacity(0.15))
                                .clipShape(Circle())

                            Text(incident.assignedTo)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        }

                        Spacer()

                        // Failure prediction indicator
                        if incident.status == .open || incident.status == .inProgress {
                            HStack(spacing: SpendlySpacing.xs) {
                                Circle()
                                    .fill(viewModel.failurePredictionColor(for: incident.failureProbability))
                                    .frame(width: 8, height: 8)
                                Text("\(Int(incident.failureProbability * 100))% risk")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(viewModel.failurePredictionColor(for: incident.failureProbability))
                            }
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func severityBadgeStyle(for severity: IncidentSeverity) -> SPBadgeStyle {
        viewModel.severityBadgeStyle(for: severity)
    }
}

// MARK: - Preview

#Preview("Incident Analysis - Light") {
    IncidentAnalysisRootView()
        .preferredColorScheme(.light)
}

#Preview("Incident Analysis - Dark") {
    IncidentAnalysisRootView()
        .preferredColorScheme(.dark)
}
