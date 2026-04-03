import SwiftUI
import SpendlyCore

struct CompareTechniciansView: View {
    @Bindable var vm: ResourceManagementViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SPScreenWrapper {
            VStack(spacing: SpendlySpacing.lg) {
                // Technician Selection Bar
                selectionBar

                if vm.selectedTechnicians.count == 2 {
                    // Comparison Table
                    comparisonTable

                    // Skill Radar (simplified bar chart)
                    skillCompetencies

                    // Recent Praise
                    recentPraiseSection

                    // Action Buttons
                    actionButtons
                } else {
                    selectionPrompt
                }
            }
        }
    }

    // MARK: - Selection Bar

    private var selectionBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpendlySpacing.lg) {
                ForEach(vm.compareCandidates) { tech in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            vm.toggleTechForComparison(tech)
                        }
                    } label: {
                        techSelectionAvatar(tech)
                    }
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
        }
        .padding(.vertical, SpendlySpacing.sm)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    private func techSelectionAvatar(_ tech: TechnicianDisplayItem) -> some View {
        let isSelected = vm.isTechSelected(tech)
        let index = vm.selectedTechnicians.firstIndex(of: tech)
        let borderColor: Color = {
            guard isSelected, let idx = index else { return .clear }
            return idx == 0 ? SpendlyColors.info : SpendlyColors.success
        }()

        return VStack(spacing: SpendlySpacing.xs) {
            ZStack(alignment: .topTrailing) {
                Circle()
                    .strokeBorder(borderColor, lineWidth: isSelected ? 3 : 0)
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(SpendlyColors.primary.opacity(0.12))
                            .overlay(
                                Text(tech.initials)
                                    .font(SpendlyFont.headline())
                                    .fontWeight(.semibold)
                                    .foregroundStyle(SpendlyColors.primary)
                            )
                    )

                if isSelected {
                    Circle()
                        .fill(borderColor)
                        .frame(width: 18, height: 18)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .offset(x: 2, y: -2)
                }
            }

            Text(shortName(tech.name))
                .font(SpendlyFont.caption())
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(
                    isSelected
                        ? SpendlyColors.foreground(for: colorScheme)
                        : SpendlyColors.secondary
                )
        }
        .opacity(isSelected ? 1.0 : 0.55)
        .grayscale(isSelected ? 0 : 0.5)
    }

    private func shortName(_ name: String) -> String {
        let parts = name.split(separator: " ")
        guard let first = parts.first else { return name }
        let lastInitial = parts.count > 1 ? "\(parts.last!.prefix(1))." : ""
        return "\(first) \(lastInitial)"
    }

    // MARK: - Selection Prompt

    private var selectionPrompt: some View {
        SPEmptyState(
            icon: "person.2.circle",
            title: "Select Two Technicians",
            message: "Tap on technician avatars above to compare their performance metrics side by side."
        )
        .padding(.top, SpendlySpacing.xxxl)
    }

    // MARK: - Comparison Table

    private var comparisonTable: some View {
        let techA = vm.selectedTechnicians[0]
        let techB = vm.selectedTechnicians[1]

        return SPCard(elevation: .low, padding: 0) {
            VStack(spacing: 0) {
                // Header row
                comparisonHeader(techA: techA, techB: techB)

                // Metric rows
                comparisonRow(
                    label: "Jobs Comp.",
                    valueA: "\(techA.jobsCompleted)",
                    valueB: "\(techB.jobsCompleted)",
                    trendA: "+12%",
                    trendB: "+18%"
                )

                comparisonRow(
                    label: "Avg Rating",
                    valueA: String(format: "%.1f", techA.averageRating),
                    valueB: String(format: "%.1f", techB.averageRating),
                    isRating: true
                )

                comparisonRow(
                    label: "On-Time %",
                    valueA: "\(techA.onTimePercentage)%",
                    valueB: "\(techB.onTimePercentage)%"
                )

                comparisonRow(
                    label: "Resp. Time",
                    valueA: "\(techA.responseTimeMinutes)m",
                    valueB: "\(techB.responseTimeMinutes)m",
                    highlightLower: true
                )

                // Revenue row (highlighted)
                revenueRow(techA: techA, techB: techB)
            }
        }
    }

    private func comparisonHeader(techA: TechnicianDisplayItem, techB: TechnicianDisplayItem) -> some View {
        HStack {
            Text("Metric")
                .frame(width: 80, alignment: .leading)
            Text(shortName(techA.name))
                .frame(maxWidth: .infinity)
                .foregroundStyle(SpendlyColors.info)
            Text(shortName(techB.name))
                .frame(maxWidth: .infinity)
                .foregroundStyle(SpendlyColors.success)
        }
        .font(.system(size: 10, weight: .bold))
        .textCase(.uppercase)
        .foregroundStyle(SpendlyColors.secondary)
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.secondary.opacity(0.06))
    }

    private func comparisonRow(
        label: String,
        valueA: String,
        valueB: String,
        trendA: String? = nil,
        trendB: String? = nil,
        isRating: Bool = false,
        highlightLower: Bool = false
    ) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.bodyMedium())
                .frame(width: 80, alignment: .leading)

            VStack(spacing: 2) {
                Text(valueA)
                    .font(SpendlyFont.headline())
                    .fontWeight(.bold)
                if let trendA {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 8))
                        Text(trendA)
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(SpendlyColors.success)
                }
                if isRating {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(SpendlyColors.accent)
                }
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 2) {
                Text(valueB)
                    .font(SpendlyFont.headline())
                    .fontWeight(.bold)
                    .foregroundStyle(
                        highlightLower ? SpendlyColors.success : SpendlyColors.foreground(for: colorScheme)
                    )
                if let trendB {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 8))
                        Text(trendB)
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(SpendlyColors.success)
                }
                if isRating {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(SpendlyColors.accent)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.vertical, SpendlySpacing.md)
    }

    private func revenueRow(techA: TechnicianDisplayItem, techB: TechnicianDisplayItem) -> some View {
        HStack {
            Text("Revenue")
                .font(SpendlyFont.bodySemibold())
                .frame(width: 80, alignment: .leading)
            Text(vm.formatCurrency(techA.revenueGenerated))
                .font(SpendlyFont.headline())
                .fontWeight(.black)
                .frame(maxWidth: .infinity)
            Text(vm.formatCurrency(techB.revenueGenerated))
                .font(SpendlyFont.headline())
                .fontWeight(.black)
                .frame(maxWidth: .infinity)
        }
        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.primary.opacity(0.05))
    }

    // MARK: - Skill Competencies

    private var skillCompetencies: some View {
        let techA = vm.selectedTechnicians[0]
        let techB = vm.selectedTechnicians[1]

        return SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                Text("Skill Competencies")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundStyle(SpendlyColors.secondary)

                VStack(spacing: SpendlySpacing.md) {
                    ForEach(Array(RMSkillScores.labels.enumerated()), id: \.offset) { index, label in
                        skillBar(
                            label: label,
                            scoreA: techA.skillScores.values[index],
                            scoreB: techB.skillScores.values[index]
                        )
                    }
                }

                // Legend
                HStack(spacing: SpendlySpacing.lg) {
                    Spacer()
                    legendDot(color: SpendlyColors.info, name: shortName(techA.name))
                    legendDot(color: SpendlyColors.success, name: shortName(techB.name))
                    Spacer()
                }
            }
        }
    }

    private func skillBar(label: String, scoreA: Int, scoreB: Int) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text(label)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)

            GeometryReader { geo in
                VStack(spacing: 3) {
                    // Tech A bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(SpendlyColors.info.opacity(0.15))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(SpendlyColors.info)
                            .frame(width: geo.size.width * CGFloat(scoreA) / 100.0, height: 10)
                    }

                    // Tech B bar
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(SpendlyColors.success.opacity(0.15))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(SpendlyColors.success)
                            .frame(width: geo.size.width * CGFloat(scoreB) / 100.0, height: 10)
                    }
                }
            }
            .frame(height: 23)
        }
    }

    private func legendDot(color: Color, name: String) -> some View {
        HStack(spacing: SpendlySpacing.sm) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(name)
                .font(SpendlyFont.caption())
                .fontWeight(.medium)
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
    }

    // MARK: - Recent Praise

    private var recentPraiseSection: some View {
        let techs = vm.selectedTechnicians
        let hasPraise = techs.contains { $0.recentPraise != nil }
        guard hasPraise else { return AnyView(EmptyView()) }

        return AnyView(
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                Text("Recent Praise")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundStyle(SpendlyColors.secondary)

                HStack(alignment: .top, spacing: SpendlySpacing.md) {
                    if let praise = techs[0].recentPraise {
                        praiseCard(
                            text: praise,
                            client: techs[0].praiseClient ?? "Client",
                            color: SpendlyColors.info
                        )
                    }
                    if let praise = techs[1].recentPraise {
                        praiseCard(
                            text: praise,
                            client: techs[1].praiseClient ?? "Client",
                            color: SpendlyColors.success
                        )
                    }
                }
            }
        )
    }

    private func praiseCard(text: String, client: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("\"\(text)\"")
                .font(SpendlyFont.caption())
                .italic()
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .lineSpacing(2)

            Text("-- Client: \(client)")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(color)
        }
        .padding(SpendlySpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: SpendlySpacing.md) {
            SPButton("Export Comparison", icon: "square.and.arrow.up", style: .secondary) {
                // Export action
            }

            SPButton("Schedule 1-on-1", style: .accent) {
                // Schedule action
            }
        }
        .padding(.top, SpendlySpacing.sm)
    }
}

// MARK: - Preview

#Preview {
    let vm = ResourceManagementViewModel()
    vm.selectedTechIDs = [
        UUID(uuidString: "E1111111-1111-1111-1111-111111111111")!,
        UUID(uuidString: "E2222222-2222-2222-2222-222222222222")!,
    ]
    return CompareTechniciansView(vm: vm)
}
