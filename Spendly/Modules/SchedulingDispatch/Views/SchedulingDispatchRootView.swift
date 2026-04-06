import SwiftUI
import MapKit
import SpendlyCore

public struct SchedulingDispatchRootView: View {

    @State private var viewModel = SchedulingDispatchViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        metricsSection
                        viewModeToggle
                        calendarContent
                        dayEventsSection
                    }
                    .padding(.bottom, SpendlySpacing.xxxl)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .navigationDestination(for: SchedulingDestination.self) { destination in
                switch destination {
                case .assignTechnician(let eventID):
                    AssignTechnicianView(viewModel: viewModel, eventID: eventID)
                case .dispatchConfirmation(let techID, let eventID):
                    DispatchConfirmationView(viewModel: viewModel, technicianID: techID, eventID: eventID)
                case .ticketScheduling(let ticketID):
                    TicketSchedulingView(viewModel: viewModel, ticketID: ticketID)
                }
            }
            .sheet(item: $viewModel.selectedEvent) { event in
                eventDetailSheet(event: event)
            }
            // Bug 2: Create event sheet
            .sheet(isPresented: $viewModel.showCreateEventSheet) {
                createEventSheet
            }
            // Bug 3: Edit event sheet
            .sheet(isPresented: $viewModel.showEditEventSheet) {
                editEventSheet
            }
            // Bug 6: Conflict warning alert
            .alert("Scheduling Conflict", isPresented: $viewModel.showConflictWarning) {
                Button("OK", role: .cancel) {
                    viewModel.conflictWarningMessage = nil
                }
            } message: {
                Text(viewModel.conflictWarningMessage ?? "A scheduling conflict was detected.")
            }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: SpendlyIcon.calendar.systemName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(SpendlyColors.primary)
                Text("Service Planner")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.navigationPath.append(.ticketScheduling(ticketID: nil))
            } label: {
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: SpendlyIcon.add.systemName)
                        .font(.system(size: 12, weight: .bold))
                    Text("New Job")
                        .font(SpendlyFont.bodySemibold())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.sm)
                .background(SpendlyColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            }
        }
    }

    // MARK: - Metrics Section

    private var metricsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpendlySpacing.sm) {
                metricTile(
                    title: "ESTIMATED HOURS",
                    value: String(format: "%.0fh", viewModel.estimatedHoursTotal),
                    trend: "+5%",
                    trendColor: SpendlyColors.success
                )
                metricTile(
                    title: "AVAILABLE HOURS",
                    value: String(format: "%.0fh", viewModel.availableHoursTotal),
                    trend: "-2%",
                    trendColor: SpendlyColors.accent
                )
                metricTile(
                    title: "EFFICIENCY",
                    value: "\(viewModel.efficiencyPercent)%",
                    trend: nil,
                    trendColor: .clear,
                    showBar: true,
                    barProgress: Double(viewModel.efficiencyPercent) / 100.0
                )
                metricTile(
                    title: "UNSCHEDULED",
                    value: "\(viewModel.unscheduledCount)",
                    trend: "Requests",
                    trendColor: SpendlyColors.secondary,
                    valueColor: SpendlyColors.accent
                )
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.md)
        }
    }

    private func metricTile(
        title: String,
        value: String,
        trend: String?,
        trendColor: Color,
        showBar: Bool = false,
        barProgress: Double = 0,
        valueColor: Color? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text(title)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                .tracking(0.5)
                .lineLimit(1)

            HStack(alignment: .bottom, spacing: SpendlySpacing.sm) {
                Text(value)
                    .font(SpendlyFont.title())
                    .foregroundStyle(valueColor ?? SpendlyColors.foreground(for: colorScheme))
                    .monospacedDigit()

                if let trend {
                    Text(trend)
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(trendColor)
                }
            }

            if showBar {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(SpendlyColors.secondary.opacity(0.15))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 2)
                            .fill(SpendlyColors.primary)
                            .frame(width: geo.size.width * barProgress, height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .frame(width: 140)
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: - View Mode Toggle

    private var viewModeToggle: some View {
        HStack {
            // Toggle buttons
            HStack(spacing: 0) {
                ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.viewMode = mode
                        }
                    } label: {
                        Text(mode.rawValue)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(viewModel.viewMode == mode ? .white : SpendlyColors.secondary)
                            .padding(.horizontal, SpendlySpacing.lg)
                            .padding(.vertical, SpendlySpacing.sm)
                            .background(
                                viewModel.viewMode == mode
                                    ? SpendlyColors.primary
                                    : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }
                }
            }
            .padding(SpendlySpacing.xs)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium + 2, style: .continuous))

            Spacer()

            // Month/week navigation
            HStack(spacing: SpendlySpacing.md) {
                Button {
                    if viewModel.viewMode == .month {
                        viewModel.navigateToPreviousMonth()
                    } else {
                        viewModel.navigateToPreviousWeek()
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(SpendlyColors.primary)
                        .frame(width: 36, height: 36)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }

                Text(viewModel.currentMonthTitle)
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .frame(minWidth: 130)

                Button {
                    if viewModel.viewMode == .month {
                        viewModel.navigateToNextMonth()
                    } else {
                        viewModel.navigateToNextWeek()
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(SpendlyColors.primary)
                        .frame(width: 36, height: 36)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.bottom, SpendlySpacing.sm)
    }

    // MARK: - Calendar Content

    @ViewBuilder
    private var calendarContent: some View {
        if viewModel.viewMode == .month {
            monthlyCalendar
        } else {
            weeklyCalendar
        }
    }

    // MARK: - Monthly Calendar

    private var monthlyCalendar: some View {
        VStack(spacing: 0) {
            // Day headers
            HStack(spacing: 0) {
                ForEach(viewModel.weekDayHeaders, id: \.self) { header in
                    Text(header)
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(SpendlyColors.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SpendlySpacing.sm)
                }
            }
            .background(SpendlyColors.background(for: colorScheme))

            // Calendar grid
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(viewModel.monthDays) { day in
                    monthDayCell(day: day)
                }
            }
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .padding(.horizontal, SpendlySpacing.lg)
    }

    private func monthDayCell(day: CalendarDay) -> some View {
        let dayEvents = viewModel.events(for: day.date)
        let isSelected = viewModel.isDateSelected(day.date)
        let isToday = viewModel.isDateToday(day.date)

        return Button {
            viewModel.selectDate(day.date)
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                // Day number
                Text("\(day.dayNumber)")
                    .font(.system(size: 13, weight: isToday || isSelected ? .bold : .regular))
                    .foregroundStyle(
                        !day.isCurrentMonth
                            ? SpendlyColors.secondary.opacity(0.4)
                            : isToday
                                ? SpendlyColors.primary
                                : SpendlyColors.foreground(for: colorScheme)
                    )

                // Event dots / pills
                VStack(spacing: 2) {
                    ForEach(dayEvents.prefix(2)) { event in
                        HStack(spacing: 2) {
                            Circle()
                                .fill(event.category.color)
                                .frame(width: 4, height: 4)
                            Text(event.title.prefix(10))
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(event.category.color)
                                .lineLimit(1)
                        }
                    }
                    if dayEvents.count > 2 {
                        Text("+\(dayEvents.count - 2)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(SpendlySpacing.xs)
            .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
            .background(
                isSelected
                    ? SpendlyColors.primary.opacity(0.06)
                    : isToday
                        ? SpendlyColors.accent.opacity(0.04)
                        : Color.clear
            )
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.small)
                    .strokeBorder(
                        isSelected ? SpendlyColors.primary : Color.clear,
                        lineWidth: isSelected ? 2 : 0
                    )
            )
        }
        .buttonStyle(.plain)
        // Bug 11: Drop destination for drag-and-drop rescheduling
        .dropDestination(for: ScheduleEvent.self) { droppedEvents, _ in
            guard let event = droppedEvents.first else { return false }
            viewModel.moveEvent(eventID: event.id, toDate: day.date)
            return true
        }
    }

    // MARK: - Weekly Calendar

    private var weeklyCalendar: some View {
        VStack(spacing: 0) {
            // Week strip
            weekStrip

            Divider()
                .foregroundStyle(SpendlyColors.primary.opacity(0.1))

            // Day timeline view
            dayTimelineView
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .padding(.horizontal, SpendlySpacing.lg)
    }

    private var weekStrip: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.weekDays) { day in
                let isSelected = viewModel.isDateSelected(day.date)
                let isToday = viewModel.isDateToday(day.date)
                let dayEvents = viewModel.events(for: day.date)

                Button {
                    viewModel.selectDate(day.date)
                } label: {
                    VStack(spacing: SpendlySpacing.xs) {
                        Text(dayOfWeekAbbrev(day.date))
                            .font(SpendlyFont.caption())
                            .fontWeight(.bold)
                            .foregroundStyle(
                                isSelected
                                    ? SpendlyColors.primary
                                    : SpendlyColors.secondary
                            )

                        ZStack {
                            Circle()
                                .fill(
                                    isSelected
                                        ? SpendlyColors.primary
                                        : isToday
                                            ? SpendlyColors.primary.opacity(0.1)
                                            : Color.clear
                                )
                                .frame(width: 36, height: 36)

                            Text("\(day.dayNumber)")
                                .font(.system(size: 15, weight: isSelected || isToday ? .bold : .medium))
                                .foregroundStyle(
                                    isSelected
                                        ? .white
                                        : isToday
                                            ? SpendlyColors.primary
                                            : SpendlyColors.foreground(for: colorScheme)
                                )
                        }

                        // Event count dots
                        HStack(spacing: 3) {
                            ForEach(0..<min(dayEvents.count, 3), id: \.self) { idx in
                                Circle()
                                    .fill(dayEvents[idx].category.color)
                                    .frame(width: 5, height: 5)
                            }
                        }
                        .frame(height: 6)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.sm)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var dayTimelineView: some View {
        VStack(alignment: .leading, spacing: 0) {
            let dayEvents = viewModel.selectedDateEvents

            if dayEvents.isEmpty {
                VStack(spacing: SpendlySpacing.md) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 36))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                    Text("No events scheduled")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpendlySpacing.xxxl)
            } else {
                // Time blocks
                ForEach(dayEvents) { event in
                    timeBlockRow(event: event)
                }
            }
        }
        .padding(.vertical, SpendlySpacing.sm)
    }

    private func timeBlockRow(event: ScheduleEvent) -> some View {
        Button {
            viewModel.selectEvent(event)
        } label: {
            HStack(spacing: SpendlySpacing.md) {
                // Time column
                VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                    Text(timeString(event.startTime))
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text(timeString(event.endTime))
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .frame(width: 60)

                // Color bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(event.category.color)
                    .frame(width: 3)

                // Event info
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text(event.title)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .lineLimit(1)

                    HStack(spacing: SpendlySpacing.sm) {
                        if let customer = event.customerName {
                            HStack(spacing: 3) {
                                Image(systemName: "building.2")
                                    .font(.system(size: 10))
                                Text(customer)
                                    .font(SpendlyFont.caption())
                            }
                            .foregroundStyle(SpendlyColors.secondary)
                        }

                        SPBadge(event.category.rawValue, style: .custom(event.category.color))
                    }
                }

                Spacer()

                Image(systemName: SpendlyIcon.chevronRight.systemName)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
            }
            .padding(.horizontal, SpendlySpacing.md)
            .padding(.vertical, SpendlySpacing.md)
        }
        .buttonStyle(.plain)
        // Bug 11: Drag-and-drop support on timeline blocks
        .draggable(event)
    }

    // MARK: - Day Events Section (below calendar in Month mode)

    private var dayEventsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text(selectedDateLabel)
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text("\(viewModel.selectedDateEvents.count) event\(viewModel.selectedDateEvents.count == 1 ? "" : "s")")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                Spacer()

                // Bug 2: Add "+" button to create a new event on this date
                Button {
                    viewModel.resetCreateEventForm()
                    viewModel.showCreateEventSheet = true
                } label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: SpendlyIcon.add.systemName)
                            .font(.system(size: 13, weight: .bold))
                        Text("New Event")
                            .font(SpendlyFont.bodySemibold())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, SpendlySpacing.md)
                    .padding(.vertical, SpendlySpacing.sm)
                    .background(SpendlyColors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }

                Button {
                    viewModel.navigationPath.append(.assignTechnician(eventID: nil))
                } label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Assign")
                            .font(SpendlyFont.bodySemibold())
                    }
                    .foregroundStyle(SpendlyColors.primary)
                    .padding(.horizontal, SpendlySpacing.md)
                    .padding(.vertical, SpendlySpacing.sm)
                    .background(SpendlyColors.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.top, SpendlySpacing.lg)

            // Event cards
            if viewModel.selectedDateEvents.isEmpty {
                SPCard {
                    VStack(spacing: SpendlySpacing.md) {
                        Image(systemName: "calendar.badge.checkmark")
                            .font(.system(size: 32))
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                        Text("No events for this day")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                        Text("Tap 'New Job' to schedule one")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.lg)
                }
                .padding(.horizontal, SpendlySpacing.lg)
            } else {
                LazyVStack(spacing: SpendlySpacing.sm) {
                    ForEach(viewModel.selectedDateEvents) { event in
                        eventCard(event: event)
                    }
                }
                .padding(.horizontal, SpendlySpacing.lg)
            }

            // Unscheduled jobs
            if !viewModel.unscheduledJobs.isEmpty {
                unscheduledSection
            }
        }
    }

    private func eventCard(event: ScheduleEvent) -> some View {
        Button {
            viewModel.selectEvent(event)
        } label: {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                HStack {
                    // Category indicator
                    RoundedRectangle(cornerRadius: 2)
                        .fill(event.category.color)
                        .frame(width: 4, height: 40)

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(event.title)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .lineLimit(1)

                        Text(event.timeRangeText)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                        SPBadge(event.status.rawValue.capitalized, style: statusBadgeStyle(event.status))
                        Text(event.technicianName)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }

                if let address = event.address {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: SpendlyIcon.location.systemName)
                            .font(.system(size: 10))
                        Text(address)
                            .font(SpendlyFont.caption())
                            .lineLimit(1)
                    }
                    .foregroundStyle(SpendlyColors.secondary)
                }
            }
            .padding(SpendlySpacing.md)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        }
        .buttonStyle(.plain)
        // Bug 11: Drag-and-drop support on event cards
        .draggable(event)
    }

    // MARK: - Unscheduled Section

    private var unscheduledSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "clock.badge.questionmark")
                        .foregroundStyle(SpendlyColors.accent)
                    Text("Unscheduled")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }

                Spacer()

                Text("\(viewModel.unscheduledJobs.count)")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .foregroundStyle(SpendlyColors.accent)
                    .padding(.horizontal, SpendlySpacing.sm)
                    .padding(.vertical, SpendlySpacing.xs)
                    .background(SpendlyColors.accent.opacity(0.12))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, SpendlySpacing.lg)

            LazyVStack(spacing: SpendlySpacing.sm) {
                ForEach(viewModel.unscheduledJobs) { job in
                    unscheduledJobRow(job: job)
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
        }
        .padding(.top, SpendlySpacing.lg)
    }

    private func unscheduledJobRow(job: UnscheduledJob) -> some View {
        HStack(spacing: SpendlySpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(job.category.lightBackground)
                    .frame(width: 40, height: 40)
                Image(systemName: job.category.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(job.category.color)
            }

            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text(job.name)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .lineLimit(1)
                Text("\(job.type) \u{2022} \(String(format: "%.1f", job.estimatedHours)) hrs \u{2022} \(job.priority.rawValue.capitalized) Priority")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            Spacer()

            Button {
                viewModel.navigationPath.append(.ticketScheduling(ticketID: nil))
            } label: {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpendlyColors.accent)
            }
        }
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: - Event Detail Sheet

    private func eventDetailSheet(event: ScheduleEvent) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                    // Category & Status
                    HStack {
                        SPBadge(event.category.rawValue, style: .custom(event.category.color))
                        SPBadge(event.status.rawValue.capitalized, style: statusBadgeStyle(event.status))
                        if event.priority == .critical || event.priority == .high {
                            SPBadge(event.priority.rawValue.capitalized, style: event.priority == .critical ? .error : .warning)
                        }
                        Spacer()
                    }

                    // Title
                    Text(event.title)
                        .font(SpendlyFont.title())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    // Time
                    detailRow(icon: "clock", title: "Scheduled Time", value: event.timeRangeText)
                    detailRow(icon: "hourglass", title: "Duration", value: event.durationText)

                    if let customer = event.customerName {
                        detailRow(icon: "building.2", title: "Customer", value: customer)
                    }
                    if let address = event.address {
                        detailRow(icon: SpendlyIcon.location.systemName, title: "Location", value: address)
                    }

                    detailRow(icon: "person", title: "Technician", value: event.technicianName)

                    if let ticketID = event.ticketID {
                        detailRow(icon: "number", title: "Ticket", value: ticketID)
                    }
                    if let notes = event.notes {
                        detailRow(icon: "note.text", title: "Notes", value: notes)
                    }

                    Divider()

                    SPButton("Assign Technician", icon: "person.badge.plus", style: .primary) {
                        viewModel.showEventDetail = false
                        viewModel.navigationPath.append(.assignTechnician(eventID: event.id))
                    }

                    // Bug 3: Edit and Delete buttons
                    HStack(spacing: SpendlySpacing.md) {
                        Button {
                            viewModel.showEventDetail = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                viewModel.prepareEditEvent(event)
                            }
                        } label: {
                            HStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Edit")
                                    .font(SpendlyFont.bodySemibold())
                            }
                            .foregroundStyle(SpendlyColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpendlySpacing.md)
                            .background(SpendlyColors.primary.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        }

                        Button {
                            viewModel.showDeleteConfirmation = true
                        } label: {
                            HStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: "trash")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("Delete")
                                    .font(SpendlyFont.bodySemibold())
                            }
                            .foregroundStyle(SpendlyColors.error)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpendlySpacing.md)
                            .background(SpendlyColors.error.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        }
                    }
                }
                .padding(SpendlySpacing.lg)
            }
            .background(SpendlyTheme.blueprint.backgroundColor(for: colorScheme))
            .navigationTitle("Event Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.showEventDetail = false
                    }
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.primary)
                }
            }
            // Bug 3: Delete confirmation
            .alert("Delete Event", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteEvent(event)
                }
            } message: {
                Text("Are you sure you want to delete \"\(event.title)\"? This action cannot be undone.")
            }
        }
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: SpendlySpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(SpendlyColors.primary.opacity(0.08))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpendlyColors.primary)
            }

            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text(title)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
                Text(value)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            Spacer()
        }
    }

    // MARK: - Bug 2: Create Event Sheet

    private var createEventSheet: some View {
        NavigationStack {
            eventFormContent(isEdit: false)
                .navigationTitle("New Event")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            viewModel.showCreateEventSheet = false
                            viewModel.resetCreateEventForm()
                        }
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.secondary)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Create") {
                            viewModel.createEvent()
                        }
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.primary)
                        .disabled(viewModel.newEventTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
        }
    }

    // MARK: - Bug 3: Edit Event Sheet

    private var editEventSheet: some View {
        NavigationStack {
            eventFormContent(isEdit: true)
                .navigationTitle("Edit Event")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            viewModel.showEditEventSheet = false
                            viewModel.editingEvent = nil
                            viewModel.resetCreateEventForm()
                        }
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.secondary)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            viewModel.saveEditedEvent()
                        }
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.primary)
                    }
                }
        }
    }

    /// Shared form layout used by both create and edit sheets.
    private func eventFormContent(isEdit: Bool) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                // Title
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Title")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    TextField("Event title", text: $viewModel.newEventTitle)
                        .font(SpendlyFont.body())
                        .padding(SpendlySpacing.md)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                        )
                }

                // Category
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Category")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: SpendlySpacing.sm) {
                            ForEach(EventCategory.allCases, id: \.self) { cat in
                                Button {
                                    viewModel.newEventCategory = cat
                                } label: {
                                    Text(cat.rawValue)
                                        .font(SpendlyFont.bodySemibold())
                                        .foregroundStyle(
                                            viewModel.newEventCategory == cat ? .white : SpendlyColors.foreground(for: colorScheme)
                                        )
                                        .padding(.horizontal, SpendlySpacing.lg)
                                        .padding(.vertical, SpendlySpacing.sm)
                                        .background(viewModel.newEventCategory == cat ? cat.color : SpendlyColors.surface(for: colorScheme))
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(
                                                    viewModel.newEventCategory == cat ? Color.clear : SpendlyColors.secondary.opacity(0.2),
                                                    lineWidth: 1
                                                )
                                        )
                                }
                            }
                        }
                    }
                }

                // Time
                HStack(spacing: SpendlySpacing.md) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Text("Start Hour")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Picker("Hour", selection: $viewModel.newEventStartHour) {
                            ForEach(6..<21) { hour in
                                Text(String(format: "%d:00", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                        .clipped()
                    }

                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Text("Duration (hrs)")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Picker("Duration", selection: $viewModel.newEventDuration) {
                            ForEach([0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 6.0, 8.0], id: \.self) { d in
                                Text(String(format: "%.1fh", d)).tag(d)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                        .clipped()
                    }
                }

                // Priority
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Priority")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    HStack(spacing: SpendlySpacing.sm) {
                        ForEach(TicketPriority.allCases, id: \.self) { p in
                            Button {
                                viewModel.newEventPriority = p
                            } label: {
                                Text(p.rawValue.capitalized)
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(
                                        viewModel.newEventPriority == p ? .white : SpendlyColors.foreground(for: colorScheme)
                                    )
                                    .padding(.horizontal, SpendlySpacing.md)
                                    .padding(.vertical, SpendlySpacing.sm)
                                    .background(viewModel.newEventPriority == p ? SpendlyColors.primary : SpendlyColors.surface(for: colorScheme))
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().strokeBorder(
                                            viewModel.newEventPriority == p ? Color.clear : SpendlyColors.secondary.opacity(0.2),
                                            lineWidth: 1
                                        )
                                    )
                            }
                        }
                    }
                }

                // Technician assignment
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Assign Technician")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    ForEach(viewModel.technicians) { tech in
                        Button {
                            viewModel.newEventTechnicianID = tech.id
                        } label: {
                            HStack(spacing: SpendlySpacing.md) {
                                SPAvatar(initials: tech.initials, size: .sm, statusDot: tech.availability.dotColor)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(tech.name)
                                        .font(SpendlyFont.bodySemibold())
                                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                    Text(tech.specialty)
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondary)
                                }
                                Spacer()
                                if viewModel.newEventTechnicianID == tech.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(SpendlyColors.primary)
                                }
                            }
                            .padding(SpendlySpacing.md)
                            .background(
                                viewModel.newEventTechnicianID == tech.id
                                    ? SpendlyColors.primary.opacity(0.06)
                                    : SpendlyColors.surface(for: colorScheme)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                    .strokeBorder(
                                        viewModel.newEventTechnicianID == tech.id
                                            ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Customer & Address
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Customer Name (optional)")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    TextField("Customer name", text: $viewModel.newEventCustomerName)
                        .font(SpendlyFont.body())
                        .padding(SpendlySpacing.md)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Address (optional)")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    TextField("Service address", text: $viewModel.newEventAddress)
                        .font(SpendlyFont.body())
                        .padding(SpendlySpacing.md)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                        )
                }

                // Notes
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Notes (optional)")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    TextField("Additional notes", text: $viewModel.newEventNotes)
                        .font(SpendlyFont.body())
                        .padding(SpendlySpacing.md)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                        )
                }
            }
            .padding(SpendlySpacing.lg)
        }
        .background(SpendlyTheme.blueprint.backgroundColor(for: colorScheme))
    }

    // MARK: - Helpers

    private func statusBadgeStyle(_ status: TripStatus) -> SPBadgeStyle {
        switch status {
        case .scheduled:  return .info
        case .enRoute:    return .warning
        case .onSite:     return .custom(SpendlyColors.accent)
        case .completed:  return .success
        case .cancelled:  return .error
        }
    }

    // MARK: - Static Formatters

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    private static let selectedDateLabelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()

    private func timeString(_ date: Date) -> String {
        Self.timeFormatter.string(from: date)
    }

    private func dayOfWeekAbbrev(_ date: Date) -> String {
        Self.dayOfWeekFormatter.string(from: date).uppercased()
    }

    private var selectedDateLabel: String {
        Self.selectedDateLabelFormatter.string(from: viewModel.selectedDate)
    }
}

// MARK: - Preview

#Preview("Scheduling - Light") {
    SchedulingDispatchRootView()
        .preferredColorScheme(.light)
}

#Preview("Scheduling - Dark") {
    SchedulingDispatchRootView()
        .preferredColorScheme(.dark)
}
