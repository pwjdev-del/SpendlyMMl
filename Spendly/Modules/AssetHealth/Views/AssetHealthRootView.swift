import SwiftUI
import SpendlyCore

// MARK: - AssetHealthRootView

public struct AssetHealthRootView: View {

    @State private var viewModel = AssetHealthViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Top Bar
                topBar

                // MARK: - Tab Selector
                tabSelector

                // MARK: - Content
                TabView(selection: $viewModel.selectedTab) {
                    overviewTab
                        .tag(AssetHealthTab.overview)

                    MaintenancePredictorView(viewModel: viewModel)
                        .tag(AssetHealthTab.predictor)

                    ServiceHistoryView(viewModel: viewModel)
                        .tag(AssetHealthTab.history)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationBarHidden(true)
            .alert("Initiate Recall", isPresented: $viewModel.showRecallConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Confirm Recall", role: .destructive) {
                    viewModel.confirmRecall()
                }
            } message: {
                Text("This will initiate a recall for all \(viewModel.modelName) units. This action cannot be undone.")
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button {} label: {
                Image(systemName: SpendlyIcon.menu.systemName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(SpendlyColors.secondary)
            }
            .frame(width: 40, height: 40)

            Spacer()

            Text("Asset Health")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Spacer()

            Button {} label: {
                Image(systemName: SpendlyIcon.notifications.systemName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(SpendlyColors.secondary)
            }
            .frame(width: 40, height: 40)
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.sm)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(AssetHealthTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: SpendlySpacing.sm) {
                        Text(tab.rawValue)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(
                                viewModel.selectedTab == tab
                                    ? SpendlyColors.primary
                                    : SpendlyColors.secondary
                            )

                        Rectangle()
                            .fill(
                                viewModel.selectedTab == tab
                                    ? SpendlyColors.primary
                                    : Color.clear
                            )
                            .frame(height: 2)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Overview Tab

    private var overviewTab: some View {
        ScrollView {
            VStack(spacing: SpendlySpacing.xl) {
                // Fleet Intelligence header
                fleetIntelligenceHeader

                // Metric cards grid
                metricsGrid

                // Lifecycle distribution
                lifecycleCard

                // Failure analysis
                failureAnalysisCard

                // Regional breakdown
                regionalBreakdownCard
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.top, SpendlySpacing.lg)
            .padding(.bottom, SpendlySpacing.xxxl)
        }
        .background(SpendlyColors.background(for: colorScheme))
    }

    // MARK: - Fleet Intelligence Header

    private var fleetIntelligenceHeader: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("FLEET INTELLIGENCE")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .tracking(1.5)
                .foregroundStyle(SpendlyColors.accent)

            Text(viewModel.modelName)
                .font(SpendlyFont.largeTitle())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            // Action buttons
            HStack(spacing: SpendlySpacing.md) {
                SPButton("Export Report", icon: "square.and.arrow.up", style: .secondary) {
                    viewModel.showExportSheet = true
                    viewModel.exportReport()
                }

                SPButton("Initiate Recall", icon: "bolt.fill", style: .accent) {
                    viewModel.initiateRecall()
                }
            }
            .padding(.top, SpendlySpacing.sm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Metrics Grid

    private var metricsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: SpendlySpacing.md),
            GridItem(.flexible(), spacing: SpendlySpacing.md),
        ], spacing: SpendlySpacing.md) {
            ForEach(viewModel.fleetMetrics) { metric in
                SPMetricCard(
                    title: metric.title,
                    value: metric.value,
                    trend: metric.trend,
                    trendDirection: metric.trendDirection
                )
            }
        }
    }

    // MARK: - Lifecycle Distribution Card

    private var lifecycleCard: some View {
        SPCard(elevation: .medium) {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                HStack {
                    Text("Service Lifecycle Distribution")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Spacer()
                    Text("Data across \(viewModel.totalUnitsForLifecycle) units")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                // Lifecycle progress bar
                lifecycleProgressBar

                // Phase labels
                HStack(spacing: 0) {
                    ForEach(viewModel.lifecyclePhases, id: \.self) { phase in
                        VStack(spacing: SpendlySpacing.xs) {
                            Text(phase.rangeLabel)
                                .font(.system(size: 10, weight: .bold))
                                .tracking(0.5)
                                .foregroundStyle(SpendlyColors.secondary)

                            Text(phase.rawValue)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(phase.color)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, SpendlySpacing.sm)

                // Chart view
                SPChartCard(
                    title: "Units by Age Group",
                    chartType: .bar,
                    data: viewModel.lifecycleChartData
                )
            }
        }
    }

    private var lifecycleProgressBar: some View {
        GeometryReader { geo in
            HStack(spacing: 1) {
                ForEach(viewModel.lifecyclePhases, id: \.self) { phase in
                    RoundedRectangle(cornerRadius: SpendlyRadius.small)
                        .fill(phase.color)
                        .frame(width: geo.size.width * phase.proportion)
                }
            }
        }
        .frame(height: 32)
        .clipShape(Capsule())
        .background(
            Capsule()
                .fill(SpendlyColors.secondary.opacity(0.1))
        )
    }

    // MARK: - Failure Analysis Card

    private var failureAnalysisCard: some View {
        SPCard(elevation: .medium) {
            VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
                Text("Root Cause Failure Analysis")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                VStack(spacing: SpendlySpacing.lg) {
                    ForEach(viewModel.failureCauses) { cause in
                        failureCauseRow(cause)
                    }
                }
            }
        }
    }

    private func failureCauseRow(_ cause: FailureCause) -> some View {
        VStack(spacing: SpendlySpacing.sm) {
            HStack {
                HStack(spacing: SpendlySpacing.sm) {
                    Circle()
                        .fill(cause.color)
                        .frame(width: 10, height: 10)

                    Text(cause.name)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }

                Spacer()

                Text("\(Int(cause.percentage * 100))%")
                    .font(SpendlyFont.tabularNumbers())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(SpendlyColors.secondary.opacity(0.1))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(cause.color)
                        .frame(width: geo.size.width * cause.percentage, height: 4)
                }
            }
            .frame(height: 4)
        }
    }

    // MARK: - Regional Breakdown Card

    private var regionalBreakdownCard: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                Text("REGIONAL BREAKDOWN")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .tracking(1.5)
                    .foregroundStyle(SpendlyColors.secondary)

                VStack(spacing: SpendlySpacing.lg) {
                    ForEach(viewModel.regionalSummaries) { region in
                        regionalRow(region)
                    }
                }
            }
        }
    }

    private func regionalRow(_ region: RegionalAssetSummary) -> some View {
        HStack(spacing: SpendlySpacing.md) {
            // Abbreviation badge
            Text(region.abbreviation)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(SpendlyColors.primary)
                .frame(width: 40, height: 40)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))

            // Info
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text(region.name)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text("\(region.assetCount) Assets  --  \(Int(region.healthPercentage))% Health")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            Spacer()

            // Status icon
            Image(systemName: region.isHealthy ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 18))
                .foregroundStyle(region.isHealthy ? SpendlyColors.success : SpendlyColors.warning)
        }
    }
}

// MARK: - Preview

#Preview {
    AssetHealthRootView()
}
