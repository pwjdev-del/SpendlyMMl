import SwiftUI
import SpendlyCore

// MARK: - MaintenancePredictorView

struct MaintenancePredictorView: View {

    @Bindable var viewModel: AssetHealthViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(spacing: SpendlySpacing.xl) {
                // Header section
                predictorHeader

                // Summary metric cards
                predictorMetricsRow

                // Upcoming predicted failures
                predictedFailuresSection

                // Maintenance trend chart
                maintenanceTrendChart

                // Predictive health insight card
                healthInsightCard

                // Recommendations
                recommendationsSection
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.top, SpendlySpacing.lg)
            .padding(.bottom, SpendlySpacing.xxxl)
        }
        .background(SpendlyColors.background(for: colorScheme))
    }

    // MARK: - Header

    private var predictorHeader: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("PREDICTIVE INTELLIGENCE")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .tracking(1.5)
                .foregroundStyle(SpendlyColors.secondary)

            Text("Maintenance Ledger")
                .font(SpendlyFont.largeTitle())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Text("Harnessing machine-level data to anticipate infrastructure volatility before it impacts your bottom line.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
                .padding(.top, SpendlySpacing.xs)

            // Action buttons
            HStack(spacing: SpendlySpacing.md) {
                SPButton("Export Forecast", icon: "arrow.down.circle", style: .secondary) {
                    viewModel.exportHistory()
                }

                SPButton("Optimize All", icon: "bolt.fill", style: .primary) {
                    // In production: batch-optimize all recommendations
                }
            }
            .padding(.top, SpendlySpacing.sm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Predictor Metrics

    private var predictorMetricsRow: some View {
        VStack(spacing: SpendlySpacing.md) {
            SPMetricCard(
                title: "Active Fleet Health",
                value: String(format: "%.1f%%", viewModel.fleetHealthScore),
                trend: viewModel.fleetHealthTrend,
                trendDirection: .up
            )

            HStack(spacing: SpendlySpacing.md) {
                SPMetricCard(
                    title: "Projected ROI Saved",
                    value: viewModel.projectedROISaved,
                    trend: "This Quarter",
                    trendDirection: .flat
                )

                criticalFailuresCard
            }
        }
    }

    private var criticalFailuresCard: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Critical Failures Predicted")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                HStack(spacing: SpendlySpacing.sm) {
                    Text(String(format: "%02d", viewModel.criticalFailuresPredicted))
                        .font(SpendlyFont.largeTitle())
                        .foregroundStyle(SpendlyColors.error)
                        .monospacedDigit()

                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(SpendlyColors.error)
                }

                Text("Requires immediate resource allocation")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Predicted Failures Section

    private var predictedFailuresSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Text("Upcoming Predicted Failures")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                HStack(spacing: SpendlySpacing.sm) {
                    Circle()
                        .fill(SpendlyColors.success)
                        .frame(width: 6, height: 6)

                    Text("LIVE FEED")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.xs)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(Capsule())
            }

            VStack(spacing: SpendlySpacing.md) {
                ForEach(viewModel.predictedFailures) { failure in
                    predictedFailureCard(failure)
                }
            }
        }
    }

    private func predictedFailureCard(_ failure: PredictedFailure) -> some View {
        SPCard(elevation: .low) {
            VStack(spacing: SpendlySpacing.md) {
                // Asset identity row
                HStack(spacing: SpendlySpacing.md) {
                    // Icon
                    Image(systemName: failure.icon)
                        .font(.system(size: 22))
                        .foregroundStyle(SpendlyColors.primary)
                        .frame(width: 44, height: 44)
                        .background(SpendlyColors.background(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(failure.assetName)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        Text(failure.issueType)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    Spacer()
                }

                // Probability + Window + Action
                HStack {
                    // Probability
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("Probability")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(SpendlyColors.secondary)

                        HStack(spacing: SpendlySpacing.sm) {
                            Text("\(Int(failure.probability * 100))%")
                                .font(SpendlyFont.headline())
                                .foregroundStyle(failure.riskLevel.color)
                                .monospacedDigit()

                            riskProgressBar(
                                progress: failure.probability,
                                color: failure.riskLevel.color
                            )
                        }
                    }

                    Spacer()

                    // Estimated window badge
                    SPBadge(failure.estimatedWindow, style: failure.riskLevel.badgeStyle)

                    Spacer()

                    // Schedule button
                    Button {
                        viewModel.scheduleMaintenance(for: failure)
                    } label: {
                        Text("Schedule")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, SpendlySpacing.lg)
                            .padding(.vertical, SpendlySpacing.sm)
                            .background(SpendlyColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                    }
                }
            }
        }
    }

    private func riskProgressBar(progress: Double, color: Color) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(SpendlyColors.secondary.opacity(0.1))
                    .frame(height: 4)

                RoundedRectangle(cornerRadius: 2)
                    .fill(color)
                    .frame(width: geo.size.width * progress, height: 4)
            }
        }
        .frame(width: 60, height: 4)
    }

    // MARK: - Maintenance Trend Chart

    private var maintenanceTrendChart: some View {
        SPChartCard(
            title: "Maintenance Events (6 Month Trend)",
            chartType: .line,
            data: viewModel.maintenanceTrendData
        )
    }

    // MARK: - Health Insight Card

    private var healthInsightCard: some View {
        SPCard(elevation: .high, padding: 0) {
            ZStack(alignment: .topTrailing) {
                // Background
                RoundedRectangle(cornerRadius: SpendlyRadius.large)
                    .fill(SpendlyColors.primary)

                // Decorative icon
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 64))
                    .foregroundStyle(.white.opacity(0.08))
                    .padding(SpendlySpacing.lg)

                // Content
                VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                    Text("MACHINE LEARNING INSIGHT")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.6))

                    Text(viewModel.healthInsight.title)
                        .font(SpendlyFont.title())
                        .foregroundStyle(.white)

                    Text(viewModel.healthInsight.body)
                        .font(SpendlyFont.body())
                        .foregroundStyle(.white.opacity(0.75))
                        .lineSpacing(4)

                    Button {} label: {
                        HStack(spacing: SpendlySpacing.sm) {
                            Text("Review Deep Analysis")
                                .font(SpendlyFont.bodySemibold())
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SpendlySpacing.md)
                        .foregroundStyle(SpendlyColors.primary)
                        .background(SpendlyColors.success)
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))
                    }
                }
                .padding(SpendlySpacing.xl)
            }
        }
    }

    // MARK: - Recommendations Section

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Text("AI Recommendations")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                Text("\(viewModel.activeRecommendations.count) active")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            VStack(spacing: SpendlySpacing.md) {
                ForEach(viewModel.activeRecommendations) { recommendation in
                    recommendationCard(recommendation)
                }
            }
        }
    }

    private func recommendationCard(_ recommendation: MaintenanceRecommendation) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        SPBadge(recommendation.riskLevel.rawValue, style: recommendation.riskLevel.badgeStyle)

                        Text(recommendation.title)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }

                    Spacer()

                    // Estimated savings
                    VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                        Text("Est. Savings")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(SpendlyColors.secondary)

                        Text(recommendation.estimatedSavings)
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.success)
                            .monospacedDigit()
                    }
                }

                // Detail
                Text(recommendation.detail)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
                    .lineSpacing(3)

                // Action buttons
                if recommendation.isAccepted {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(SpendlyColors.success)
                        Text("Accepted -- Scheduling in progress")
                            .font(SpendlyFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(SpendlyColors.success)
                    }
                    .padding(.vertical, SpendlySpacing.sm)
                } else {
                    HStack(spacing: SpendlySpacing.md) {
                        Button {
                            viewModel.acceptRecommendation(recommendation)
                        } label: {
                            HStack(spacing: SpendlySpacing.sm) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Accept")
                                    .font(SpendlyFont.bodySemibold())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpendlySpacing.md)
                            .foregroundStyle(.white)
                            .background(SpendlyColors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                        }

                        Button {
                            viewModel.dismissRecommendation(recommendation)
                        } label: {
                            HStack(spacing: SpendlySpacing.sm) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Dismiss")
                                    .font(SpendlyFont.bodySemibold())
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpendlySpacing.md)
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme).opacity(0.6))
                            .background(SpendlyColors.background(for: colorScheme))
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                                    .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                            )
                        }
                    }
                }
            }
        }
        .overlay(
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(recommendation.riskLevel.color)
                    .frame(width: 4)
                    .padding(.vertical, SpendlySpacing.sm)
                Spacer()
            }
        )
    }
}

// MARK: - Preview

#Preview {
    MaintenancePredictorView(viewModel: AssetHealthViewModel())
}
