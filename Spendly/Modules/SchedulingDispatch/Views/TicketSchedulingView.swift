import SwiftUI
import SpendlyCore

struct TicketSchedulingView: View {

    @Bindable var viewModel: SchedulingDispatchViewModel
    let ticketID: String?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: SpendlySpacing.lg) {
                    serviceSummaryCard
                    prioritySection
                    selectedTeamSection
                    recommendedTechnicians
                    timeSlotSection
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.top, SpendlySpacing.sm)
                .padding(.bottom, 130)
            }

            // Sticky footer
            footerAction
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            VStack(spacing: 0) {
                Text("Schedule Service Visit")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Text(ticketToolbarSubtitle)
                    .font(SpendlyFont.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(SpendlyColors.accent)
            }
        }
    }

    // MARK: - Service Summary Card

    /// Finds a matching event or unscheduled job from the ticketID, if provided.
    private var matchedEvent: ScheduleEvent? {
        guard let ticketID else { return nil }
        return viewModel.events.first(where: { $0.ticketID == ticketID })
    }

    private var matchedJob: UnscheduledJob? {
        // If no event matched, try to use the first unscheduled job as context
        guard matchedEvent == nil else { return nil }
        return viewModel.unscheduledJobs.first
    }

    // Bug 10: Display actual ticket/job data instead of hardcoded summary
    private var serviceSummaryCard: some View {
        HStack(alignment: .top, spacing: SpendlySpacing.md) {
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text("DIAGNOSTIC RECAP")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(SpendlyColors.primary.opacity(0.6))

                Text(serviceSummaryTitle)
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: serviceSummaryCategory.icon)
                        .font(.system(size: 12))
                    Text(serviceSummaryDescription)
                        .font(SpendlyFont.body())
                }
                .foregroundStyle(SpendlyColors.secondary)
            }

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(serviceSummaryCategory.color.opacity(0.08))
                    .frame(width: 56, height: 56)
                Image(systemName: serviceSummaryCategory.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(serviceSummaryCategory.color.opacity(0.5))
            }
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(SpendlyColors.primary.opacity(0.05), lineWidth: 1)
        )
    }

    private var serviceSummaryTitle: String {
        if let event = matchedEvent { return event.title }
        if let job = matchedJob { return job.name }
        return "New Service Visit"
    }

    private var serviceSummaryCategory: EventCategory {
        if let event = matchedEvent { return event.category }
        if let job = matchedJob { return job.category }
        return .general
    }

    private var ticketToolbarSubtitle: String {
        if let ticketID { return ticketID }
        if let event = matchedEvent, let tid = event.ticketID {
            return "\(tid) | \(event.customerName ?? event.category.rawValue)"
        }
        if let job = matchedJob {
            return "\(job.name) | \(job.type)"
        }
        return "New Service Visit"
    }

    private var serviceSummaryDescription: String {
        if let event = matchedEvent {
            return [event.category.rawValue, event.notes].compactMap { $0 }.joined(separator: " - ")
        }
        if let job = matchedJob {
            return "\(job.type) \u{2022} Est. \(String(format: "%.1f", job.estimatedHours))h"
        }
        return "Schedule a new service visit"
    }

    // MARK: - Priority Section

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            Text("Service Priority")
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            HStack(spacing: SpendlySpacing.sm) {
                ForEach(ServicePriority.allCases, id: \.self) { priority in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedPriority = priority
                        }
                    } label: {
                        Text(priority.rawValue)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(
                                viewModel.selectedPriority == priority
                                    ? SpendlyColors.primary
                                    : SpendlyColors.secondary
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpendlySpacing.sm)
                            .background(
                                viewModel.selectedPriority == priority
                                    ? SpendlyColors.surface(for: colorScheme)
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                            .overlay(
                                viewModel.selectedPriority == priority
                                    ? RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                        .strokeBorder(SpendlyColors.primary.opacity(0.2), lineWidth: 1)
                                    : nil
                            )
                            .shadow(
                                color: viewModel.selectedPriority == priority
                                    ? SpendlyColors.primary.opacity(0.08) : .clear,
                                radius: 4, y: 2
                            )
                    }
                }
            }
            .padding(SpendlySpacing.xs)
            .background(SpendlyColors.secondary.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium + 2, style: .continuous))
        }
    }

    // MARK: - Selected Team Section

    @ViewBuilder
    private var selectedTeamSection: some View {
        if !viewModel.preferredTechnicianIDs.isEmpty {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                Text("SELECTED TEAM (\(viewModel.preferredTechnicianIDs.count))")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.8)
                    .foregroundStyle(SpendlyColors.primary)

                ForEach(selectedTechnicians) { tech in
                    HStack(spacing: SpendlySpacing.md) {
                        SPAvatar(initials: tech.initials, size: .sm)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(tech.name)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            Text(tech.id == selectedTechnicians.first?.id ? "ON-SITE LEAD" : "SUPPORT")
                                .font(.system(size: 9, weight: .bold))
                                .tracking(0.5)
                                .foregroundStyle(tech.id == selectedTechnicians.first?.id ? SpendlyColors.info : Color.purple)
                                .padding(.horizontal, SpendlySpacing.sm)
                                .padding(.vertical, 2)
                                .background(
                                    (tech.id == selectedTechnicians.first?.id ? SpendlyColors.info : Color.purple)
                                        .opacity(0.1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                        }

                        Spacer()

                        Button {
                            viewModel.togglePreferredTechnician(tech.id)
                        } label: {
                            Image(systemName: SpendlyIcon.close.systemName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                    }
                }
            }
            .padding(SpendlySpacing.lg)
            .background(SpendlyColors.primary.opacity(colorScheme == .dark ? 0.08 : 0.04))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(SpendlyColors.primary.opacity(0.15), lineWidth: 1)
            )
        }
    }

    private var selectedTechnicians: [Technician] {
        viewModel.technicians.filter { viewModel.preferredTechnicianIDs.contains($0.id) }
    }

    // MARK: - Recommended Technicians

    private var recommendedTechnicians: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Text("Recommended Technicians")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                Button {
                    viewModel.navigationPath.append(.assignTechnician(eventID: nil))
                } label: {
                    Text("See All")
                        .font(SpendlyFont.caption())
                        .fontWeight(.medium)
                        .foregroundStyle(SpendlyColors.primary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpendlySpacing.md) {
                    ForEach(viewModel.technicians.prefix(3)) { tech in
                        techRecommendationCard(tech: tech)
                    }
                }
            }
        }
    }

    private func techRecommendationCard(tech: Technician) -> some View {
        let isSelected = viewModel.preferredTechnicianIDs.contains(tech.id)

        return Button {
            viewModel.togglePreferredTechnician(tech.id)
        } label: {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                // Header
                HStack(spacing: SpendlySpacing.md) {
                    SPAvatar(initials: tech.initials, size: .md)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(tech.name)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        HStack(spacing: 3) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(SpendlyColors.warning)
                            Text(String(format: "%.1f", tech.rating))
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text("(\(tech.reviewCount))")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                    }
                }

                // Stats
                VStack(spacing: SpendlySpacing.sm) {
                    HStack {
                        Text("Distance")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                        Spacer()
                        Text(String(format: "%.1f miles", tech.distance))
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                    HStack {
                        Text("Next Available")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                        Spacer()
                        Text(tech.availability.label)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(
                                tech.availability.color
                            )
                    }
                }
            }
            .padding(SpendlySpacing.lg)
            .frame(width: 240)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(
                        isSelected ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.15),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? SpendlyColors.primary.opacity(0.1) : .clear,
                radius: 6, y: 3
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    ZStack {
                        RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                            .fill(SpendlyColors.primary)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(SpendlySpacing.sm)
                }
            }
            .opacity(isSelected ? 1 : 0.85)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Time Slot Section

    private var timeSlotSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            Text("Select Time Slot")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            // Bug 4: Stateful day tabs - tapping changes which day's slots are shown
            HStack(spacing: SpendlySpacing.lg) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.schedulingDayIsToday = true
                    }
                } label: {
                    dayTab(label: "Today", isSelected: viewModel.schedulingDayIsToday)
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.schedulingDayIsToday = false
                    }
                } label: {
                    dayTab(label: "Tomorrow", isSelected: !viewModel.schedulingDayIsToday)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, SpendlySpacing.xs)

            // Bug 4: Show day label
            Text(schedulingDayLabel)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)

            // Slots
            ForEach(viewModel.timeSlots) { slot in
                timeSlotRow(slot: slot)
            }
        }
    }

    /// Label for the currently selected scheduling day.
    private var schedulingDayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        let cal = Calendar.current
        let day = cal.date(byAdding: .day, value: viewModel.schedulingDayIsToday ? 0 : 1, to: Date()) ?? Date()
        return formatter.string(from: day)
    }

    private func dayTab(label: String, isSelected: Bool) -> some View {
        VStack(spacing: SpendlySpacing.sm) {
            Text(label)
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(
                    isSelected
                        ? SpendlyColors.primary
                        : SpendlyColors.secondary
                )
            Rectangle()
                .fill(isSelected ? SpendlyColors.primary : Color.clear)
                .frame(height: 2)
        }
    }

    private func timeSlotRow(slot: TimeSlot) -> some View {
        let isSelected = viewModel.selectedTimeSlotID == slot.id

        return Button {
            viewModel.selectTimeSlot(slot.id)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text(slot.displayText)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    if let label = slot.label {
                        Text(label)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(
                                slot.isRecommended
                                    ? SpendlyColors.primary
                                    : SpendlyColors.secondary
                            )
                            .fontWeight(slot.isRecommended ? .medium : .regular)
                    }
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(
                        isSelected
                            ? SpendlyColors.primary
                            : SpendlyColors.secondary.opacity(0.3)
                    )
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
                            ? SpendlyColors.primary.opacity(0.2)
                            : SpendlyColors.secondary.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Footer Action

    private var footerAction: some View {
        VStack(spacing: SpendlySpacing.sm) {
            let teamCount = viewModel.preferredTechnicianIDs.count

            SPButton(
                teamCount > 1
                    ? "Confirm Team Schedule & Dispatch (\(teamCount))"
                    : "Confirm Schedule & Dispatch",
                style: .primary
            ) {
                // Bug 5: Create event from selected time slot, priority, and team before dismissing
                viewModel.createEventFromScheduling()
                dismiss()
            }

            Button {
                dismiss()
            } label: {
                Text("Save for Later")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.sm)
            }
        }
        .padding(SpendlySpacing.lg)
        .background(
            (SpendlyColors.surface(for: colorScheme)).opacity(0.85)
        )
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Divider().foregroundStyle(SpendlyColors.primary.opacity(0.1))
        }
    }
}

// MARK: - Preview

#Preview("Ticket Scheduling") {
    NavigationStack {
        TicketSchedulingView(
            viewModel: SchedulingDispatchViewModel(),
            ticketID: "#TK-98234"
        )
    }
}

#Preview("Ticket Scheduling - Multi Tech") {
    NavigationStack {
        TicketSchedulingView(
            viewModel: {
                let vm = SchedulingDispatchViewModel()
                vm.preferredTechnicianIDs = Set(vm.technicians.prefix(2).map(\.id))
                vm.selectedTimeSlotID = vm.timeSlots.first(where: \.isRecommended)?.id
                return vm
            }(),
            ticketID: "#TK-98234"
        )
    }
}
