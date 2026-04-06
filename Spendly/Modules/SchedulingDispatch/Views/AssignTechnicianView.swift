import SwiftUI
import MapKit
import SpendlyCore

struct AssignTechnicianView: View {

    @Bindable var viewModel: SchedulingDispatchViewModel
    let eventID: UUID?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var showMapSheet: Bool = false

    /// Resolves the event associated with this assignment screen.
    private var event: ScheduleEvent? {
        guard let eventID else { return nil }
        return viewModel.events.first(where: { $0.id == eventID })
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    searchAndFilters
                    technicianList
                    mapToggle
                }
                .padding(.bottom, 140)
            }

            // Sticky footer
            footerAction
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
        .onAppear {
            // Pre-select first available technician
            if viewModel.selectedTechnicianID == nil {
                viewModel.selectedTechnicianID = viewModel.filteredTechnicians.first?.id
            }
        }
        .sheet(isPresented: $showMapSheet) {
            if let event {
                JobLocationMapView(
                    jobTitle: event.title,
                    address: event.address ?? "Unknown Address",
                    latitude: event.latitude,
                    longitude: event.longitude
                )
            } else {
                // Fallback: dismiss if event is not available
                Color.clear.onAppear { showMapSheet = false }
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(spacing: 0) {
                Text("Assign Technician")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.primary)
                if let eventID, let event = viewModel.events.first(where: { $0.id == eventID }) {
                    Text("Ticket \(event.ticketID ?? "") \u{2022} Service Visit")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                } else {
                    Text("Select a technician to assign")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
    }

    // MARK: - Search & Filters

    private var searchAndFilters: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Search bar
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: SpendlyIcon.search.systemName)
                    .foregroundStyle(SpendlyColors.secondary)
                    .padding(.leading, SpendlySpacing.md)

                TextField("Search by name or skill...", text: $viewModel.searchText)
                    .font(SpendlyFont.body())
                    .padding(.vertical, SpendlySpacing.md)
                    .padding(.trailing, SpendlySpacing.md)
            }
            .background(SpendlyColors.background(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
            )

            // Skill filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpendlySpacing.sm) {
                    ForEach(TechSkillFilter.allCases, id: \.self) { filter in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectedSkillFilter = filter
                            }
                        } label: {
                            Text(filter.rawValue)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(
                                    viewModel.selectedSkillFilter == filter
                                        ? .white
                                        : SpendlyColors.foreground(for: colorScheme)
                                )
                                .padding(.horizontal, SpendlySpacing.lg)
                                .padding(.vertical, SpendlySpacing.sm)
                                .background(
                                    viewModel.selectedSkillFilter == filter
                                        ? SpendlyColors.primary
                                        : SpendlyColors.surface(for: colorScheme)
                                )
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(
                                            viewModel.selectedSkillFilter == filter
                                                ? Color.clear
                                                : SpendlyColors.secondary.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Technician List

    private var technicianList: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("RECOMMENDED TECHNICIANS")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(SpendlyColors.secondary)
                .tracking(0.5)
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.top, SpendlySpacing.md)

            ForEach(viewModel.filteredTechnicians) { tech in
                technicianCard(tech: tech)
            }
        }
    }

    private func technicianCard(tech: Technician) -> some View {
        let isSelected = viewModel.selectedTechnicianID == tech.id

        return Button {
            viewModel.selectTechnician(tech)
        } label: {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                HStack(alignment: .top) {
                    // Avatar + status
                    SPAvatar(
                        initials: tech.initials,
                        size: .lg,
                        statusDot: tech.availability.dotColor
                    )

                    // Name + availability
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(tech.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: availabilityIcon(tech.availability))
                                .font(.system(size: 12))
                            Text(tech.availability.label)
                                .font(SpendlyFont.bodySemibold())
                        }
                        .foregroundStyle(tech.availability.color)
                    }

                    Spacer()

                    // Distance + rating
                    VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                        Text(String(format: "%.1f miles", tech.distance))
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(
                                isSelected
                                    ? SpendlyColors.primary
                                    : SpendlyColors.secondary
                            )

                        HStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { index in
                                Image(systemName: starIcon(for: index, rating: tech.rating))
                                    .font(.system(size: 11))
                                    .foregroundStyle(SpendlyColors.warning)
                            }
                            Text(String(format: "%.1f", tech.rating))
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                    }
                }

                // Skills
                HStack(spacing: SpendlySpacing.sm) {
                    ForEach(tech.skills, id: \.self) { skill in
                        Text(skill.uppercased())
                            .font(.system(size: 9, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(
                                isSelected
                                    ? SpendlyColors.primary
                                    : SpendlyColors.secondary
                            )
                            .padding(.horizontal, SpendlySpacing.sm)
                            .padding(.vertical, SpendlySpacing.xs)
                            .background(
                                isSelected
                                    ? SpendlyColors.surface(for: colorScheme)
                                    : SpendlyColors.background(for: colorScheme)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                                    .strokeBorder(
                                        isSelected
                                            ? SpendlyColors.primary.opacity(0.2)
                                            : SpendlyColors.secondary.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                    }
                }

                // Selected checkmark
                if isSelected {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(SpendlyColors.primary)
                                .frame(width: 28, height: 28)
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.top, -SpendlySpacing.sm)
                }
            }
            .padding(SpendlySpacing.lg)
            .background(
                isSelected
                    ? SpendlyColors.primary.opacity(0.05)
                    : SpendlyColors.surface(for: colorScheme)
            )
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(
                        isSelected
                            ? SpendlyColors.primary
                            : SpendlyColors.secondary.opacity(0.15),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, SpendlySpacing.lg)
    }

    // MARK: - Map Toggle

    private var mapToggle: some View {
        HStack {
            Spacer()
            Button {
                showMapSheet = true
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: SpendlyIcon.map.systemName)
                        .font(.system(size: 14, weight: .medium))
                    Text("View on Map")
                        .font(SpendlyFont.bodySemibold())
                }
                .foregroundStyle(SpendlyColors.primary)
                .padding(.horizontal, SpendlySpacing.xl)
                .padding(.vertical, SpendlySpacing.sm)
                .background(SpendlyColors.primary.opacity(0.08))
                .clipShape(Capsule())
            }
            Spacer()
        }
        .padding(.vertical, SpendlySpacing.xl)
    }

    // MARK: - Footer Action

    private var footerAction: some View {
        VStack(spacing: SpendlySpacing.md) {
            if let tech = viewModel.selectedTechnician {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Selected Technician")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                        Text(tech.name)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Estimated Arrival")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                        // Bug 8: Dynamic ETA based on technician distance
                        Text(viewModel.estimatedETAText(for: tech))
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.primary)
                    }
                }
                .padding(.horizontal, SpendlySpacing.sm)
            }

            SPButton("Assign and Dispatch", icon: SpendlyIcon.send.systemName, style: .primary) {
                guard let techID = viewModel.selectedTechnicianID else { return }
                viewModel.navigationPath.append(.dispatchConfirmation(technicianID: techID, eventID: eventID))
            }
        }
        .padding(SpendlySpacing.lg)
        .background(
            (colorScheme == .dark ? SpendlyColors.surfaceDark : .white)
                .opacity(0.9)
        )
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Divider().foregroundStyle(SpendlyColors.secondary.opacity(0.2))
        }
    }

    // MARK: - Helpers

    private func availabilityIcon(_ availability: TechAvailability) -> String {
        switch availability {
        case .available: return "checkmark.circle.fill"
        case .busy:      return "clock"
        case .offDuty:   return "moon.fill"
        }
    }

    private func starIcon(for index: Int, rating: Double) -> String {
        let threshold = Double(index) + 1.0
        if rating >= threshold {
            return "star.fill"
        } else if rating >= threshold - 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}

// MARK: - Preview

#Preview("Assign Technician") {
    NavigationStack {
        AssignTechnicianView(
            viewModel: SchedulingDispatchViewModel(),
            eventID: nil
        )
    }
}
