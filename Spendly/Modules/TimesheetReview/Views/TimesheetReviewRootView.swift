import SwiftUI
import SpendlyCore

public struct TimesheetReviewRootView: View {
    @State private var vm = TimesheetReviewViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            SPHeader(title: "Timesheet Review") {
                Button {
                    vm.showingCommentSheet = true
                } label: {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }

            // Tab Picker
            tabPicker

            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.lg) {
                    switch vm.selectedTab {
                    case .mySummary:
                        mySummaryContent
                    case .teamApprovals:
                        teamApprovalsContent
                    }
                }
            }
        }
        .sheet(isPresented: $vm.showingRejectSheet) {
            rejectSheet
        }
        .sheet(isPresented: $vm.showingCommentSheet) {
            commentSheet
        }
        .sheet(isPresented: $vm.showingEntryDetail) {
            if let entry = vm.selectedEntryDetail {
                entryDetailSheet(entry)
            }
        }
        .alert("Submitted", isPresented: $vm.showingSubmitConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your timesheet has been submitted for approval.")
        }
        .alert("Approved", isPresented: $vm.showingApprovalConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Entry has been approved.")
        }
        .alert("Bulk Approved", isPresented: $vm.showingBulkApprovalConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("All selected entries have been approved.")
        }
        .alert("Team Approved", isPresented: $vm.showingBulkTeamApprovalConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("All selected team timesheets have been approved.")
        }
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(TimesheetReviewViewModel.Tab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.selectedTab = tab
                    }
                } label: {
                    VStack(spacing: SpendlySpacing.sm) {
                        Text(tab.rawValue)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(
                                vm.selectedTab == tab
                                    ? SpendlyColors.primary
                                    : SpendlyColors.secondary
                            )

                        Rectangle()
                            .fill(vm.selectedTab == tab ? SpendlyColors.primary : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - My Summary Content

    @ViewBuilder
    private var mySummaryContent: some View {
        // Week Selector
        weekSelectorCard

        // Technician Card
        technicianCard

        // Weekly Summary
        weeklySummaryCard

        // Select All Header
        selectAllHeader

        // Daily Entries
        ForEach(vm.entries) { entry in
            dailyEntryCard(entry)
        }

        // Action Buttons
        actionButtons

        // Comments Section
        if !vm.comments.isEmpty {
            commentsSection
        }
    }

    // MARK: - Team Approvals Content

    @ViewBuilder
    private var teamApprovalsContent: some View {
        // Week Label
        SPCard(elevation: .low) {
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundStyle(SpendlyColors.primary)
                Text(TimesheetReviewMockData.weekLabel)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
            }
        }

        // Select All Team
        if vm.teamTimesheets.contains(where: { $0.status == .submitted }) {
            teamSelectAllHeader
        }

        // Team Cards
        ForEach(vm.teamTimesheets) { summary in
            teamMemberCard(summary)
        }

        // Bulk Approve Team
        if vm.hasTeamSelection {
            SPButton(
                "Bulk Approve (\(vm.selectedTeamTimesheets.count))",
                icon: "checkmark.circle.fill",
                style: .primary
            ) {
                vm.bulkApproveTeam()
            }
        }
    }

    // MARK: - Week Selector Card

    private var weekSelectorCard: some View {
        SPCard(elevation: .low) {
            HStack {
                Button {
                    vm.goToPreviousWeek()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(SpendlyColors.primary)
                        .frame(width: 32, height: 32)
                        .background(SpendlyColors.primary.opacity(0.1))
                        .clipShape(Circle())
                }

                Spacer()

                VStack(spacing: SpendlySpacing.xs) {
                    Text(vm.currentWeekLabel)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    SPBadge(
                        vm.statusLabel(for: vm.weeklyStatus),
                        style: vm.badgeStyle(for: vm.weeklyStatus)
                    )
                }

                Spacer()

                Button {
                    vm.goToNextWeek()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(SpendlyColors.primary)
                        .frame(width: 32, height: 32)
                        .background(SpendlyColors.primary.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
    }

    // MARK: - Technician Card

    private var technicianCard: some View {
        SPCard(elevation: .low) {
            HStack(spacing: SpendlySpacing.md) {
                SPAvatar(
                    initials: "DM",
                    size: .lg,
                    statusDot: SpendlyColors.success
                )

                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text("David Miller")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text("Lead Field Technician")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "building.2")
                            .font(.system(size: 10))
                            .foregroundStyle(SpendlyColors.secondary)
                        Text("Industrial Systems Inc.")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }

                Spacer()
            }
        }
    }

    // MARK: - Weekly Summary Card

    private var weeklySummaryCard: some View {
        SPCard(elevation: .medium) {
            VStack(spacing: SpendlySpacing.md) {
                HStack {
                    Text("WEEKLY SUMMARY")
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .tracking(1.2)
                        .foregroundStyle(SpendlyColors.secondary)
                    Spacer()
                }

                HStack(spacing: 0) {
                    summaryMetric(
                        value: vm.formatHours(vm.totalRegularHours),
                        label: "Regular",
                        icon: "clock",
                        color: SpendlyColors.primary
                    )
                    summaryDivider
                    summaryMetric(
                        value: vm.formatHours(vm.totalOvertimeHours),
                        label: "Overtime",
                        icon: "exclamationmark.clock",
                        color: vm.hasOvertime ? SpendlyColors.warning : SpendlyColors.secondary
                    )
                    summaryDivider
                    summaryMetric(
                        value: vm.formattedBreakHours,
                        label: "Break",
                        icon: "cup.and.saucer",
                        color: SpendlyColors.info
                    )
                    summaryDivider
                    summaryMetric(
                        value: vm.formatHours(vm.totalHours),
                        label: "Total",
                        icon: "sum",
                        color: SpendlyColors.accent
                    )
                }

                // Overtime indicator
                if vm.hasOvertime {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(SpendlyColors.warning)
                        Text("\(vm.formatHours(vm.totalOvertimeHours)) overtime this week")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.warning)
                        Spacer()
                    }
                    .padding(SpendlySpacing.sm)
                    .background(SpendlyColors.warning.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }

                // Additional stats
                HStack(spacing: SpendlySpacing.lg) {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 12))
                            .foregroundStyle(SpendlyColors.success)
                        Text("Billable: \(vm.formatHours(vm.billableHours))")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "folder")
                            .font(.system(size: 12))
                            .foregroundStyle(SpendlyColors.info)
                        Text("\(vm.activeProjects) Projects")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                    Spacer()
                }
            }
        }
    }

    private func summaryMetric(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: SpendlySpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
            Text(value)
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .monospacedDigit()
            Text(label)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var summaryDivider: some View {
        Rectangle()
            .fill(SpendlyColors.secondary.opacity(0.15))
            .frame(width: 1, height: 44)
    }

    // MARK: - Select All Header

    private var selectAllHeader: some View {
        HStack {
            Text("DAILY ENTRIES")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .tracking(1.2)
                .foregroundStyle(SpendlyColors.secondary)

            Spacer()

            if vm.entries.contains(where: { $0.status == .submitted }) {
                Button {
                    vm.toggleSelectAllSubmitted()
                } label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: vm.allSubmittedSelected
                              ? "checkmark.square.fill"
                              : "square"
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(SpendlyColors.primary)
                        Text("Select All")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.primary)
                    }
                }
            }
        }
    }

    // MARK: - Daily Entry Card

    private func dailyEntryCard(_ entry: TimesheetDayEntry) -> some View {
        Button {
            vm.selectedEntryDetail = entry
            vm.showingEntryDetail = true
        } label: {
            SPCard(elevation: entry.isSelected ? .medium : .low) {
                VStack(spacing: SpendlySpacing.md) {
                    // Top row: Day + Date, Status Badge, Checkbox
                    HStack(alignment: .top) {
                        // Day indicator
                        VStack(spacing: 2) {
                            Text(TimesheetReviewMockData.dayOfWeekShort(entry.date))
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                                .foregroundStyle(SpendlyColors.secondary)
                            Text(TimesheetReviewMockData.dayOfMonth(entry.date))
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        }
                        .frame(width: 40)

                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text(entry.projectName)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                .lineLimit(1)
                            Text(entry.clientName)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        SPBadge(
                            vm.statusLabel(for: entry.status),
                            style: vm.badgeStyle(for: entry.status)
                        )

                        // Selection checkbox for submitted entries
                        if entry.status == .submitted {
                            Button {
                                vm.toggleEntrySelection(entry)
                            } label: {
                                Image(systemName: entry.isSelected
                                      ? "checkmark.square.fill"
                                      : "square"
                                )
                                .font(.system(size: 20))
                                .foregroundStyle(
                                    entry.isSelected
                                        ? SpendlyColors.primary
                                        : SpendlyColors.secondary.opacity(0.5)
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, SpendlySpacing.sm)
                        }
                    }

                    // Hours breakdown
                    HStack(spacing: SpendlySpacing.lg) {
                        hoursChip(
                            icon: "clock",
                            label: "Hours",
                            value: vm.formatHours(entry.regularHours),
                            color: SpendlyColors.primary
                        )
                        hoursChip(
                            icon: "cup.and.saucer",
                            label: "Break",
                            value: vm.formatBreak(entry.breakMinutes),
                            color: SpendlyColors.info
                        )
                        if entry.overtimeHours > 0 {
                            hoursChip(
                                icon: "exclamationmark.clock.fill",
                                label: "OT",
                                value: vm.formatHours(entry.overtimeHours),
                                color: SpendlyColors.warning
                            )
                        }
                        Spacer()
                    }

                    // Rejection reason
                    if let reason = entry.rejectionReason, entry.status == .rejected {
                        HStack(spacing: SpendlySpacing.sm) {
                            Image(systemName: "exclamationmark.bubble.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(SpendlyColors.error)
                            Text(reason)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.error)
                                .lineLimit(2)
                            Spacer()
                        }
                        .padding(SpendlySpacing.sm)
                        .background(SpendlyColors.error.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }

                    // Approve / Reject inline buttons for submitted entries
                    if entry.status == .submitted {
                        HStack(spacing: SpendlySpacing.md) {
                            Button {
                                vm.approveEntry(entry)
                            } label: {
                                HStack(spacing: SpendlySpacing.xs) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                    Text("Approve")
                                        .font(SpendlyFont.bodySemibold())
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, SpendlySpacing.sm)
                                .background(SpendlyColors.success)
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                            }
                            .buttonStyle(.plain)

                            Button {
                                vm.beginRejectEntry(entry)
                            } label: {
                                HStack(spacing: SpendlySpacing.xs) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 14))
                                    Text("Reject")
                                        .font(SpendlyFont.bodySemibold())
                                }
                                .foregroundStyle(SpendlyColors.error)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, SpendlySpacing.sm)
                                .background(SpendlyColors.error.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(
                        entry.isSelected
                            ? SpendlyColors.primary.opacity(0.4)
                            : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func hoursChip(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)
            Text(value)
                .font(SpendlyFont.tabularNumbers())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
        .padding(.horizontal, SpendlySpacing.sm)
        .padding(.vertical, SpendlySpacing.xs)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Bulk Approve Selected
            if vm.hasSelection {
                SPButton(
                    "Bulk Approve (\(vm.selectedEntries.count))",
                    icon: "checkmark.circle.fill",
                    style: .primary
                ) {
                    vm.bulkApproveSelected()
                }
            }

            // Submit for Approval (drafts)
            if vm.entries.contains(where: { $0.status == .draft }) {
                SPButton(
                    "Submit for Approval",
                    icon: "paperplane.fill",
                    style: .secondary
                ) {
                    vm.submitForApproval()
                }
            }
        }
    }

    // MARK: - Comments Section

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Text("COMMENTS")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .tracking(1.2)
                    .foregroundStyle(SpendlyColors.secondary)
                Spacer()
                Button {
                    vm.showingCommentSheet = true
                } label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "plus")
                            .font(.system(size: 10, weight: .bold))
                        Text("Add")
                            .font(SpendlyFont.caption())
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(SpendlyColors.primary)
                }
            }

            ForEach(vm.comments) { comment in
                commentBubble(comment)
            }
        }
    }

    private func commentBubble(_ comment: TimesheetComment) -> some View {
        HStack(alignment: .top, spacing: SpendlySpacing.md) {
            SPAvatar(
                initials: String(comment.author.prefix(1)),
                size: .sm,
                statusDot: comment.isManager ? SpendlyColors.accent : nil
            )

            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                HStack {
                    Text(comment.author)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    if comment.isManager {
                        SPBadge("Manager", style: .info)
                    }
                    Spacer()
                    Text(vm.formatShortDate(comment.date))
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                Text(comment.text)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
        }
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(SpendlyColors.secondary.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Team Member Card

    private func teamMemberCard(_ summary: TeamTimesheetSummary) -> some View {
        SPCard(elevation: summary.isSelected ? .medium : .low) {
            VStack(spacing: SpendlySpacing.md) {
                // Top: Avatar, Name, Role, Status
                HStack(spacing: SpendlySpacing.md) {
                    SPAvatar(
                        initials: teamInitials(summary.technicianName),
                        size: .md,
                        statusDot: summary.status == .submitted
                            ? SpendlyColors.warning
                            : summary.status == .approved
                                ? SpendlyColors.success
                                : nil
                    )

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(summary.technicianName)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text(summary.role)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    Spacer()

                    SPBadge(
                        vm.statusLabel(for: summary.status),
                        style: vm.badgeStyle(for: summary.status)
                    )

                    if summary.status == .submitted {
                        Button {
                            vm.toggleTeamSelection(summary)
                        } label: {
                            Image(systemName: summary.isSelected
                                  ? "checkmark.square.fill"
                                  : "square"
                            )
                            .font(.system(size: 20))
                            .foregroundStyle(
                                summary.isSelected
                                    ? SpendlyColors.primary
                                    : SpendlyColors.secondary.opacity(0.5)
                            )
                        }
                    }
                }

                // Hours summary
                HStack(spacing: SpendlySpacing.lg) {
                    hoursChip(
                        icon: "clock",
                        label: "Total",
                        value: vm.formatHours(summary.totalHours),
                        color: SpendlyColors.primary
                    )
                    if summary.overtimeHours > 0 {
                        hoursChip(
                            icon: "exclamationmark.clock.fill",
                            label: "OT",
                            value: vm.formatHours(summary.overtimeHours),
                            color: SpendlyColors.warning
                        )
                    }
                    Spacer()
                    Text(summary.weekLabel)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                // Approve / Reject buttons for submitted
                if summary.status == .submitted {
                    HStack(spacing: SpendlySpacing.md) {
                        Button {
                            vm.approveTeamMember(summary)
                        } label: {
                            HStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                Text("Approve")
                                    .font(SpendlyFont.bodySemibold())
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpendlySpacing.sm)
                            .background(SpendlyColors.success)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        }

                        Button {
                            vm.beginRejectTeamMember(summary)
                        } label: {
                            HStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                Text("Reject")
                                    .font(SpendlyFont.bodySemibold())
                            }
                            .foregroundStyle(SpendlyColors.error)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpendlySpacing.sm)
                            .background(SpendlyColors.error.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        }
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(
                    summary.isSelected
                        ? SpendlyColors.primary.opacity(0.4)
                        : Color.clear,
                    lineWidth: 1.5
                )
        )
    }

    // MARK: - Team Select All Header

    private var teamSelectAllHeader: some View {
        HStack {
            Text("TEAM TIMESHEETS")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .tracking(1.2)
                .foregroundStyle(SpendlyColors.secondary)

            Spacer()

            Button {
                vm.toggleSelectAllTeam()
            } label: {
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: vm.allTeamSelected
                          ? "checkmark.square.fill"
                          : "square"
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(SpendlyColors.primary)
                    Text("Select All")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.primary)
                }
            }
        }
    }

    // MARK: - Reject Sheet

    private var rejectSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
                // Context: which entry or team member
                if let entry = vm.entryToReject {
                    HStack(spacing: SpendlySpacing.md) {
                        VStack(spacing: 2) {
                            Text(TimesheetReviewMockData.dayOfWeekShort(entry.date))
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                                .foregroundStyle(SpendlyColors.secondary)
                            Text(TimesheetReviewMockData.dayOfMonth(entry.date))
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        }
                        .frame(width: 40)

                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text(entry.projectName)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text("\(vm.formatHours(entry.regularHours + entry.overtimeHours)) total")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                    }
                } else if let member = vm.teamMemberToReject {
                    HStack(spacing: SpendlySpacing.md) {
                        SPAvatar(initials: teamInitials(member.technicianName), size: .md)
                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text(member.technicianName)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text("\(vm.formatHours(member.totalHours)) total")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Reason for Rejection")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    TextEditor(text: $vm.rejectionReason)
                        .font(SpendlyFont.body())
                        .frame(minHeight: 120)
                        .padding(SpendlySpacing.sm)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                        )
                }

                SPButton("Reject", icon: "xmark.circle", style: .destructive) {
                    if vm.entryToReject != nil {
                        vm.executeRejectEntry()
                    } else if vm.teamMemberToReject != nil {
                        vm.executeRejectTeamMember()
                    }
                }

                Spacer()
            }
            .padding(SpendlySpacing.lg)
            .navigationTitle("Reject Timesheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.showingRejectSheet = false
                        vm.entryToReject = nil
                        vm.teamMemberToReject = nil
                        vm.rejectionReason = ""
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Comment Sheet

    private var commentSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Add a Comment")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    TextEditor(text: $vm.newCommentText)
                        .font(SpendlyFont.body())
                        .frame(minHeight: 120)
                        .padding(SpendlySpacing.sm)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                        )
                }

                SPButton("Post Comment", icon: "paperplane.fill", style: .primary) {
                    vm.addComment()
                }
                .opacity(vm.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
                .disabled(vm.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Spacer()
            }
            .padding(SpendlySpacing.lg)
            .navigationTitle("Comment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.showingCommentSheet = false
                        vm.newCommentText = ""
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Entry Detail Sheet

    private func entryDetailSheet(_ entry: TimesheetDayEntry) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                    // Date header
                    HStack {
                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text(vm.formatFullDate(entry.date))
                                .font(SpendlyFont.title())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text(TimesheetReviewMockData.dayOfWeekShort(entry.date))
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                        Spacer()
                        SPBadge(
                            vm.statusLabel(for: entry.status),
                            style: vm.badgeStyle(for: entry.status)
                        )
                    }

                    SPCard(elevation: .low) {
                        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                            detailRow(label: "Project", value: entry.projectName)
                            detailRow(label: "Client", value: entry.clientName)
                            detailRow(label: "Regular Hours", value: vm.formatHours(entry.regularHours))
                            detailRow(label: "Overtime", value: vm.formatHours(entry.overtimeHours))
                            detailRow(label: "Break", value: vm.formatBreak(entry.breakMinutes))
                            detailRow(
                                label: "Total",
                                value: vm.formatHours(entry.regularHours + entry.overtimeHours)
                            )
                        }
                    }

                    if let notes = entry.notes {
                        SPCard(elevation: .low) {
                            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                                Text("NOTES")
                                    .font(SpendlyFont.caption())
                                    .fontWeight(.bold)
                                    .tracking(1.2)
                                    .foregroundStyle(SpendlyColors.secondary)
                                Text(notes)
                                    .font(SpendlyFont.body())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            }
                        }
                    }

                    if let reason = entry.rejectionReason, entry.status == .rejected {
                        SPCard(elevation: .low) {
                            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                                HStack(spacing: SpendlySpacing.sm) {
                                    Image(systemName: "exclamationmark.bubble.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(SpendlyColors.error)
                                    Text("REJECTION REASON")
                                        .font(SpendlyFont.caption())
                                        .fontWeight(.bold)
                                        .tracking(1.2)
                                        .foregroundStyle(SpendlyColors.error)
                                }
                                Text(reason)
                                    .font(SpendlyFont.body())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            }
                        }
                    }
                }
                .padding(SpendlySpacing.lg)
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationTitle("Entry Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        vm.showingEntryDetail = false
                        vm.selectedEntryDetail = nil
                    }
                }
            }
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
            Spacer()
            Text(value)
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .monospacedDigit()
        }
    }

    // MARK: - Helpers

    private func teamInitials(_ name: String) -> String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1)) + String(parts[1].prefix(1))
        }
        return String(name.prefix(2))
    }
}

#Preview {
    TimesheetReviewRootView()
}
