import SwiftUI
import SpendlyCore

// MARK: - Incident Detail View

struct IncidentDetailView: View {

    let incident: AnalysisIncident
    let viewModel: IncidentAnalysisViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SpendlySpacing.xl) {
                        statusCard
                        machineDetailsSection
                        problemDescriptionSection
                        failurePredictionSection
                        rootCauseAnalysisSection
                        historyTimelineSection
                        resolutionSection
                        aiInsightsSection
                        exportSection
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.top, SpendlySpacing.sm)
                    .padding(.bottom, SpendlySpacing.xxxl * 2)
                }
            }
            .navigationTitle("Audit: \(incident.code)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: SpendlyIcon.arrowBack.systemName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            viewModel.exportReport(for: incident)
                        } label: {
                            Label("Export Report", systemImage: SpendlyIcon.download.systemName)
                        }
                        Button {
                            // share action
                        } label: {
                            Label("Share", systemImage: SpendlyIcon.share.systemName)
                        }
                    } label: {
                        Image(systemName: SpendlyIcon.moreVert.systemName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
            }
            .alert("Report Exported", isPresented: .constant(viewModel.showExportConfirmation)) {
                Button("OK") {
                    viewModel.showExportConfirmation = false
                }
            } message: {
                Text("Incident report for \(incident.code) has been exported successfully.")
            }
        }
    }

    // MARK: - Status Card

    private var statusCard: some View {
        SPCard(elevation: .medium) {
            HStack {
                HStack(spacing: SpendlySpacing.md) {
                    statusIcon
                        .font(.system(size: 28))
                        .foregroundStyle(statusColor)
                        .frame(width: 48, height: 48)
                        .background(statusColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("Current Status")
                            .font(SpendlyFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(SpendlyColors.secondary)
                            .textCase(.uppercase)

                        Text(incident.status.rawValue)
                            .font(SpendlyFont.title())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                    SPBadge(
                        incident.severity.rawValue.uppercased(),
                        style: viewModel.severityBadgeStyle(for: incident.severity)
                    )

                    if let resolvedDate = incident.resolvedDate {
                        Text(dateFormatter.string(from: resolvedDate))
                            .font(.system(size: 10))
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch incident.status {
        case .resolved, .closed:
            Image(systemName: "checkmark.circle.fill")
        case .inProgress:
            Image(systemName: "arrow.triangle.2.circlepath")
        case .open:
            Image(systemName: "exclamationmark.circle.fill")
        }
    }

    private var statusColor: Color {
        switch incident.status {
        case .resolved, .closed: return SpendlyColors.success
        case .inProgress:        return SpendlyColors.warning
        case .open:              return SpendlyColors.error
        }
    }

    // MARK: - Machine Details Section

    private var machineDetailsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            sectionHeader(icon: "gearshape.2", title: "Machine Details")

            SPCard(elevation: .low) {
                VStack(spacing: 0) {
                    detailRow(label: "Machine ID", value: incident.machineID, isMonospaced: true)
                    SPDivider()
                    detailRow(label: "Model", value: incident.machineModel)
                    SPDivider()
                    detailRow(label: "Company", value: incident.companyName)
                    SPDivider()
                    detailRow(label: "Assembly Area", value: incident.assemblyArea)
                    SPDivider()
                    detailRow(label: "Assigned To", value: incident.assignedTo)
                }
            }
        }
    }

    // MARK: - Problem Description

    private var problemDescriptionSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            sectionHeader(icon: "exclamationmark.triangle", title: "Problem Description")

            HStack(spacing: SpendlySpacing.lg) {
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text("Incident Date")
                        .font(SpendlyFont.caption())
                        .fontWeight(.semibold)
                        .foregroundStyle(SpendlyColors.secondary)
                        .textCase(.uppercase)
                    Text(dateFormatter.string(from: incident.reportedDate))
                        .font(SpendlyFont.bodyMedium())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text("Category")
                        .font(SpendlyFont.caption())
                        .fontWeight(.semibold)
                        .foregroundStyle(SpendlyColors.secondary)
                        .textCase(.uppercase)
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: incident.category.icon)
                            .font(.system(size: 12))
                        Text(incident.category.rawValue)
                            .font(SpendlyFont.bodyMedium())
                    }
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }

            // Observation card
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Observation")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .foregroundStyle(SpendlyColors.accent)
                    .textCase(.uppercase)

                Text(incident.observation)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text(incident.detailedDescription)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .lineSpacing(4)
            }
            .padding(SpendlySpacing.lg)
            .background(SpendlyColors.accent.opacity(colorScheme == .dark ? 0.08 : 0.06))
            .overlay(
                Rectangle()
                    .fill(SpendlyColors.accent)
                    .frame(width: 4),
                alignment: .leading
            )
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        }
    }

    // MARK: - Failure Prediction

    private var failurePredictionSection: some View {
        SPCard(elevation: .low) {
            VStack(spacing: SpendlySpacing.lg) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(viewModel.failurePredictionColor(for: incident.failureProbability))
                    Text("Failure Prediction")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Spacer()
                }

                // Gauge
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(SpendlyColors.secondary.opacity(0.15), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(135))

                    Circle()
                        .trim(from: 0, to: 0.75 * incident.failureProbability)
                        .stroke(
                            viewModel.failurePredictionColor(for: incident.failureProbability),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(135))

                    VStack(spacing: SpendlySpacing.xs) {
                        Text("\(Int(incident.failureProbability * 100))%")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(viewModel.failurePredictionColor(for: incident.failureProbability))
                            .monospacedDigit()

                        Text("risk level")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
                .frame(width: 140, height: 140)
                .frame(maxWidth: .infinity)

                // Legend
                HStack(spacing: SpendlySpacing.xl) {
                    predictionLegend(color: SpendlyColors.error, label: "High", range: "70-100%")
                    predictionLegend(color: SpendlyColors.warning, label: "Medium", range: "40-69%")
                    predictionLegend(color: SpendlyColors.success, label: "Low", range: "0-39%")
                }
            }
        }
    }

    private func predictionLegend(color: Color, label: String, range: String) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading) {
                Text(label)
                    .font(SpendlyFont.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Text(range)
                    .font(.system(size: 10))
                    .foregroundStyle(SpendlyColors.secondary)
            }
        }
    }

    // MARK: - Root Cause Analysis

    private var rootCauseAnalysisSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            sectionHeader(icon: "point.3.filled.connected.trianglepath.dotted", title: "Root Cause Analysis")

            // Root node
            HStack {
                Spacer()
                Text("Incident Report Analysis")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.primary)
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.vertical, SpendlySpacing.md)
                    .background(SpendlyColors.primary.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                            .strokeBorder(SpendlyColors.primary.opacity(0.3), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                Spacer()
            }

            // Branch cards
            ForEach(incident.rootCauses) { cause in
                rootCauseBranchCard(cause)
            }
        }
    }

    private func rootCauseBranchCard(_ cause: RootCause) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                // Branch label
                HStack {
                    SPBadge(cause.branch.uppercased(), style: .custom(SpendlyColors.primary))

                    Spacer()
                }

                // Title with icon
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: cause.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(SpendlyColors.primary)
                    Text(cause.branchTitle)
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }

                // Items
                VStack(spacing: SpendlySpacing.sm) {
                    ForEach(cause.items) { item in
                        HStack {
                            Text(item.name)
                                .font(SpendlyFont.bodyMedium())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Spacer()
                            Circle()
                                .fill(rootCauseDotColor(item.severityLevel))
                                .frame(width: 8, height: 8)
                        }
                        .padding(SpendlySpacing.md)
                        .background(SpendlyColors.background(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }
                }
            }
        }
    }

    private func rootCauseDotColor(_ level: RootCauseSeverityLevel) -> Color {
        switch level {
        case .critical: return SpendlyColors.error
        case .warning:  return SpendlyColors.warning
        case .normal:   return SpendlyColors.success
        }
    }

    // MARK: - History Timeline

    private var historyTimelineSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Image(systemName: "clock.arrow.counterclockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpendlyColors.primary)
                Text("Incident Timeline")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
                Text("\(incident.timelineEvents.count) events")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            SPCard(elevation: .low, padding: SpendlySpacing.md) {
                SPTimeline(
                    items: incident.timelineEvents.map { event in
                        SPTimelineItem(
                            title: event.title,
                            subtitle: event.subtitle,
                            status: event.status,
                            time: event.time
                        )
                    }
                )
            }
        }
    }

    // MARK: - Resolution Details

    @ViewBuilder
    private var resolutionSection: some View {
        if let resolution = incident.resolution {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                sectionHeader(icon: "wrench.and.screwdriver", title: "Resolution Details")

                SPCard(elevation: .low) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                        Text(resolution)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .italic()
                            .lineSpacing(4)
                            .padding(.leading, SpendlySpacing.md)
                            .overlay(
                                Rectangle()
                                    .fill(SpendlyColors.secondary.opacity(0.2))
                                    .frame(width: 2),
                                alignment: .leading
                            )

                        if let resolvedBy = incident.resolvedBy {
                            HStack(spacing: SpendlySpacing.sm) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(SpendlyColors.secondary)
                                Text("Resolved by \(resolvedBy)")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - AI Insights

    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(SpendlyColors.accent)
                    Text("AI Insights")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.accent)
                }

                Text("Knowledge Base Summary (Anonymized):")
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    ForEach(Array(incident.aiInsights.enumerated()), id: \.offset) { _, insight in
                        HStack(alignment: .top, spacing: SpendlySpacing.sm) {
                            Text("\u{2022}")
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.accent)
                                .fontWeight(.bold)
                            Text(insight)
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                                .lineSpacing(3)
                        }
                    }
                }
            }
            .padding(SpendlySpacing.xl)
            .background(
                LinearGradient(
                    colors: [
                        SpendlyColors.accent.opacity(colorScheme == .dark ? 0.12 : 0.08),
                        SpendlyColors.accent.opacity(0.02),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous)
                    .strokeBorder(SpendlyColors.accent.opacity(0.2), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous))
        }
    }

    // MARK: - Export Section

    private var exportSection: some View {
        SPButton("Export Incident Report", icon: SpendlyIcon.download.systemName, style: .secondary) {
            viewModel.exportReport(for: incident)
        }
    }

    // MARK: - Reusable Components

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: SpendlySpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(SpendlyColors.primary)
            Text(title)
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
    }

    private func detailRow(label: String, value: String, isMonospaced: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(SpendlyColors.secondary)
                .tracking(0.8)
                .textCase(.uppercase)
            Spacer()
            if isMonospaced {
                Text(value)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            } else {
                Text(value)
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
        }
        .padding(.vertical, SpendlySpacing.md)
    }
}

// MARK: - Preview

#Preview("Detail - In Progress") {
    IncidentDetailView(
        incident: IncidentAnalysisMockData.incidents[0],
        viewModel: IncidentAnalysisViewModel()
    )
    .preferredColorScheme(.light)
}

#Preview("Detail - Resolved") {
    IncidentDetailView(
        incident: IncidentAnalysisMockData.incidents[2],
        viewModel: IncidentAnalysisViewModel()
    )
    .preferredColorScheme(.dark)
}
