import SwiftUI
import SpendlyCore

// MARK: - AnalyticsDashboardsRootView

public struct AnalyticsDashboardsRootView: View {

    @State private var viewModel = AnalyticsDashboardsViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.xl) {

                    // MARK: Header
                    headerSection

                    // MARK: Page Title + Filters
                    titleAndFiltersSection

                    // MARK: 4 Metric Cards (2x2 grid)
                    metricsGridSection

                    // MARK: Jobs Completed per Week Bar Chart
                    jobsBarChartSection

                    // MARK: Team Skill Breakdown
                    teamSkillBreakdownSection

                    // MARK: Technician Performance Table
                    technicianPerformanceSection

                    // Bottom padding for tab bar
                    Spacer()
                        .frame(height: 60)
                }
            }

            // MARK: Bottom Navigation
            bottomNavigationBar
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(alignment: .center, spacing: SpendlySpacing.md) {
            // Logo block
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .fill(SpendlyColors.accent)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                )

            Text("Service Platform")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Spacer()

            // Notification bell
            Button {
                // Notification action
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: SpendlyIcon.notifications.systemName)
                        .font(.system(size: 20))
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                    Circle()
                        .fill(SpendlyColors.accent)
                        .frame(width: 8, height: 8)
                        .offset(x: 2, y: -2)
                }
                .frame(width: 36, height: 36)
            }

            // Admin avatar
            SPAvatar(
                initials: "AP",
                size: .sm,
                statusDot: SpendlyColors.success
            )
        }
    }

    // MARK: - Title and Filters

    private var titleAndFiltersSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text("Team Performance")
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text("Real-time overview of field operations and efficiency.")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }

            // Filter buttons row
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpendlySpacing.sm) {
                    filterButton(
                        icon: "calendar",
                        label: viewModel.selectedDateRange.rawValue
                    )
                    filterButton(
                        icon: "mappin.and.ellipse",
                        label: viewModel.selectedRegion
                    )
                    filterButton(
                        icon: "person",
                        label: "Technician"
                    )
                }
            }
        }
    }

    private func filterButton(icon: String, label: String) -> some View {
        Button {
            // Filter action
        } label: {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(SpendlyColors.accent)

                Text(label)
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(SpendlyColors.secondary)
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.sm + 2)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous)
                    .strokeBorder(
                        colorScheme == .dark
                            ? Color.white.opacity(0.1)
                            : Color.black.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
    }

    // MARK: - Metrics Grid (2x2)

    private var metricsGridSection: some View {
        let columns = [
            GridItem(.flexible(), spacing: SpendlySpacing.md),
            GridItem(.flexible(), spacing: SpendlySpacing.md),
        ]

        return LazyVGrid(columns: columns, spacing: SpendlySpacing.md) {
            metricCard(
                icon: "checkmark.circle",
                title: "Total Jobs Completed",
                value: viewModel.totalJobsCompleted,
                trend: viewModel.totalJobsTrend,
                trendPositive: true
            )
            metricCard(
                icon: "timer",
                title: "Avg. Response Time",
                value: viewModel.avgResponseTime,
                trend: viewModel.avgResponseTrend,
                trendPositive: false
            )
            metricCard(
                icon: "star.fill",
                title: "Avg. Rating",
                value: viewModel.avgRating,
                trend: viewModel.avgRatingTrend,
                trendPositive: true
            )
            metricCard(
                icon: "dollarsign.circle",
                title: "Revenue Generated",
                value: viewModel.totalRevenue,
                trend: viewModel.totalRevenueTrend,
                trendPositive: true
            )
        }
    }

    private func metricCard(
        icon: String,
        title: String,
        value: String,
        trend: String,
        trendPositive: Bool
    ) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                // Top row: icon + trend badge
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(SpendlyColors.accent)
                        .frame(width: 36, height: 36)
                        .background(SpendlyColors.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                    Spacer()

                    SPBadge(
                        trend,
                        style: trendPositive ? .success : .error
                    )
                }

                // Label
                Text(title)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                // Value
                Text(value)
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Jobs Completed per Week Bar Chart

    private var jobsBarChartSection: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                // Header row
                HStack {
                    Text("Jobs Completed per Week")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Spacer()

                    // Legend
                    HStack(spacing: SpendlySpacing.md) {
                        legendItem(color: SpendlyColors.accent, label: "This Month")
                        legendItem(color: SpendlyColors.secondary.opacity(0.2), label: "Previous")
                    }
                }

                // Bar chart
                GeometryReader { geo in
                    let maxValue: Double = 420 // slightly above max (398) for headroom
                    let barSpacing: CGFloat = SpendlySpacing.md
                    let barCount = CGFloat(viewModel.weeklyJobs.count)
                    let totalSpacing = barSpacing * (barCount - 1)
                    let barWidth = (geo.size.width - totalSpacing) / barCount

                    HStack(alignment: .bottom, spacing: barSpacing) {
                        ForEach(viewModel.weeklyJobs) { dataPoint in
                            VStack(spacing: SpendlySpacing.sm) {
                                // Value label on hover
                                Text("\(dataPoint.currentValue)")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                    .monospacedDigit()

                                // Bar
                                ZStack(alignment: .bottom) {
                                    // Background bar
                                    RoundedRectangle(cornerRadius: SpendlyRadius.small)
                                        .fill(SpendlyColors.secondary.opacity(0.1))
                                        .frame(
                                            width: barWidth,
                                            height: geo.size.height * 0.78
                                        )

                                    // Filled bar
                                    RoundedRectangle(cornerRadius: SpendlyRadius.small)
                                        .fill(SpendlyColors.accent)
                                        .frame(
                                            width: barWidth,
                                            height: geo.size.height * 0.78 * CGFloat(Double(dataPoint.currentValue) / maxValue)
                                        )
                                }

                                // Week label
                                Text(dataPoint.label)
                                    .font(.system(size: 11))
                                    .foregroundStyle(SpendlyColors.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .frame(height: 200)
            }
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(SpendlyColors.secondary)
        }
    }

    // MARK: - Team Skill Breakdown

    private var teamSkillBreakdownSection: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                Text("Team Skill Breakdown")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                VStack(spacing: SpendlySpacing.md) {
                    skillRow(label: "Speed", value: viewModel.teamSkills.speed)
                    skillRow(label: "Quality", value: viewModel.teamSkills.quality)
                    skillRow(label: "Compliance", value: viewModel.teamSkills.compliance)
                    skillRow(label: "Communication", value: viewModel.teamSkills.communication)
                }
            }
        }
    }

    private func skillRow(label: String, value: Double) -> some View {
        VStack(spacing: SpendlySpacing.xs) {
            HStack {
                Text(label)
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                Text("\(Int(value * 100))%")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.accent)
                    .monospacedDigit()
            }

            SPProgressBar(progress: value, height: 8)
        }
    }

    // MARK: - Technician Performance Table

    private var technicianPerformanceSection: some View {
        SPCard(elevation: .low, padding: 0) {
            VStack(spacing: 0) {
                // Section header
                HStack {
                    Text("Individual Technician Performance")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Spacer()

                    Button {
                        // View all action
                    } label: {
                        Text("View All")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.accent)
                    }
                }
                .padding(SpendlySpacing.lg)

                SPDivider()

                // Table header
                techTableHeader

                SPDivider()

                // Technician rows
                ForEach(Array(viewModel.filteredTechnicians.enumerated()), id: \.element.id) { index, tech in
                    technicianRow(tech)

                    if index < viewModel.filteredTechnicians.count - 1 {
                        Divider()
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.1))
                    }
                }
            }
        }
    }

    private var techTableHeader: some View {
        HStack(spacing: 0) {
            Text("TECHNICIAN")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("STATUS")
                .frame(width: 72, alignment: .leading)

            Text("JOBS")
                .frame(width: 44, alignment: .center)

            Text("RATING")
                .frame(width: 56, alignment: .center)

            Text("REVENUE")
                .frame(width: 72, alignment: .trailing)
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

    private func technicianRow(_ tech: TechnicianPerformance) -> some View {
        HStack(spacing: 0) {
            // Avatar + name + specialty
            HStack(spacing: SpendlySpacing.sm) {
                SPAvatar(
                    initials: tech.initials,
                    size: .sm,
                    statusDot: tech.statusDotColor
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

            // Status badge
            SPBadge(tech.statusLabel, style: tech.statusBadgeStyle)
                .frame(width: 72, alignment: .leading)

            // Jobs count
            Text("\(tech.jobsCompleted)")
                .font(SpendlyFont.bodyMedium())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .monospacedDigit()
                .frame(width: 44, alignment: .center)

            // Rating with star
            HStack(spacing: 2) {
                Text(String(format: "%.1f", tech.avgRating))
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .monospacedDigit()

                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(SpendlyColors.warning)
            }
            .frame(width: 56, alignment: .center)

            // Revenue
            Text(tech.formattedRevenue)
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .monospacedDigit()
                .frame(width: 72, alignment: .trailing)
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.selectTechnician(tech)
        }
    }

    // MARK: - Bottom Navigation Bar

    private var bottomNavigationBar: some View {
        HStack {
            ForEach(AnalyticsBottomTab.allCases, id: \.self) { tab in
                Button {
                    viewModel.selectedBottomTab = tab
                } label: {
                    VStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: viewModel.selectedBottomTab == tab ? tab.filledIcon : tab.icon)
                            .font(.system(size: 20))

                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(
                        viewModel.selectedBottomTab == tab
                            ? SpendlyColors.accent
                            : SpendlyColors.secondary
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, SpendlySpacing.sm)
        .padding(.bottom, SpendlySpacing.sm)
        .background(
            SpendlyColors.surface(for: colorScheme)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: -4)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Previews

#Preview("Analytics Dashboard") {
    AnalyticsDashboardsRootView()
}

#Preview("Analytics Dashboard - Dark") {
    AnalyticsDashboardsRootView()
        .preferredColorScheme(.dark)
}
