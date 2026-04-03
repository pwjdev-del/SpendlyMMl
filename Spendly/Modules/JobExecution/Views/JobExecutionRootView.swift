import SwiftUI
import SpendlyCore

// MARK: - JobExecutionRootView (Technician Schedule)

public struct JobExecutionRootView: View {

    @State private var viewModel = JobExecutionViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Header + Weekly Strip
                scheduleHeader

                // MARK: - Timeline Content
                ScrollView {
                    VStack(spacing: 0) {
                        timelineView
                    }
                    .padding(.top, SpendlySpacing.lg)
                    .padding(.bottom, 80)
                }
                .background(SpendlyColors.background(for: colorScheme))
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showTimerView) {
                if let job = viewModel.selectedJob {
                    JobExecutionTimerView(viewModel: viewModel, job: job)
                }
            }
        }
    }

    // MARK: - Schedule Header

    private var scheduleHeader: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button {} label: {
                    Image(systemName: SpendlyIcon.menu.systemName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .frame(width: 40, height: 40)

                Spacer()

                Text("My Schedule")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.primary)

                Spacer()

                HStack(spacing: SpendlySpacing.sm) {
                    Button {} label: {
                        Image(systemName: SpendlyIcon.notifications.systemName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                    .frame(width: 40, height: 40)

                    Circle()
                        .fill(SpendlyColors.primary.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: SpendlyIcon.person.systemName)
                                .font(.system(size: 14))
                                .foregroundStyle(SpendlyColors.primary)
                        )
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.sm)

            // Month label + Full Month button
            HStack {
                Text(viewModel.monthYearLabel)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme).opacity(0.7))

                Spacer()

                Button {} label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Text("Full Month")
                            .font(SpendlyFont.caption())
                            .fontWeight(.medium)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundStyle(SpendlyColors.primary)
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.bottom, SpendlySpacing.lg)

            // Weekly day strip
            weeklyDayStrip
                .padding(.bottom, SpendlySpacing.lg)

            // Offline indicator
            if viewModel.isOffline {
                offlineBanner
            }
        }
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Weekly Day Strip

    private var weeklyDayStrip: some View {
        HStack(spacing: 0) {
            ForEach(Array(viewModel.weekDays.enumerated()), id: \.element.id) { index, day in
                dayCell(day: day, index: index)
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
    }

    private func dayCell(day: WeekDay, index: Int) -> some View {
        VStack(spacing: SpendlySpacing.sm) {
            Text(day.dayAbbreviation)
                .font(.system(size: 11, weight: day.isSelected ? .bold : .medium))
                .foregroundStyle(day.isSelected ? SpendlyColors.primary : SpendlyColors.secondary)

            Button {
                viewModel.selectDay(at: index)
            } label: {
                ZStack {
                    if day.isSelected {
                        RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                            .fill(SpendlyColors.primary)
                            .frame(width: 40, height: 40)
                    }

                    Text("\(day.dayNumber)")
                        .font(.system(size: 15, weight: day.isSelected ? .bold : .semibold))
                        .foregroundStyle(day.isSelected ? .white : SpendlyColors.foreground(for: colorScheme).opacity(0.6))
                }
                .frame(width: 40, height: 40)
            }

            // Today indicator dot
            Circle()
                .fill(day.isSelected ? SpendlyColors.primary : .clear)
                .frame(width: 4, height: 4)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Offline Banner

    private var offlineBanner: some View {
        HStack(spacing: SpendlySpacing.sm) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 12, weight: .bold))
            Text("OFFLINE MODE: ACTIVE")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.8)
            Spacer()
            if case .pendingSync(let count) = viewModel.syncStatus {
                Text("\(count) items pending sync")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, SpendlySpacing.sm)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small))
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.sm)
        .background(SpendlyColors.warning)
    }

    // MARK: - Vertical Timeline

    private var timelineView: some View {
        VStack(spacing: 0) {
            ForEach(Array(viewModel.jobsForSelectedDay.enumerated()), id: \.element.id) { index, job in
                timelineJobRow(job: job, isLast: index == viewModel.jobsForSelectedDay.count - 1)
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
    }

    private func timelineJobRow(job: JobDisplayModel, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline column: dot + line
            VStack(spacing: 0) {
                timelineDot(for: job)
                    .padding(.top, 6)

                if !isLast {
                    Rectangle()
                        .fill(SpendlyColors.secondary.opacity(0.2))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 32)

            // Job card area
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                // Time label
                HStack(spacing: SpendlySpacing.xs) {
                    Text(job.startTimeLabel.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(
                            job.status == .inProgress
                                ? SpendlyColors.primary
                                : SpendlyColors.secondary
                        )

                    if job.status == .inProgress {
                        Text("-- IN PROGRESS")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.8)
                            .foregroundStyle(SpendlyColors.primary)
                    }
                }

                // Job card
                jobCard(for: job)
            }
            .padding(.leading, SpendlySpacing.md)
            .padding(.bottom, isLast ? SpendlySpacing.lg : SpendlySpacing.xxl)
        }
    }

    // MARK: - Timeline Dot

    private func timelineDot(for job: JobDisplayModel) -> some View {
        ZStack {
            Circle()
                .fill(dotBackgroundColor(for: job.status))
                .frame(width: 32, height: 32)

            switch job.status {
            case .completed:
                Image(systemName: SpendlyIcon.checkCircle.systemName)
                    .font(.system(size: 14))
                    .foregroundStyle(SpendlyColors.success)
            case .inProgress:
                Circle()
                    .fill(SpendlyColors.primary)
                    .frame(width: 12, height: 12)
            case .upcoming:
                Image(systemName: SpendlyIcon.schedule.systemName)
                    .font(.system(size: 14))
                    .foregroundStyle(SpendlyColors.secondary)
            }
        }
    }

    private func dotBackgroundColor(for status: JobExecutionStatus) -> Color {
        switch status {
        case .completed:  return SpendlyColors.success.opacity(0.1)
        case .inProgress: return SpendlyColors.primary.opacity(0.1)
        case .upcoming:   return SpendlyColors.secondary.opacity(0.1)
        }
    }

    // MARK: - Job Card

    private func jobCard(for job: JobDisplayModel) -> some View {
        Button {
            viewModel.openJob(job)
        } label: {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                // Status badge + title row
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        SPBadge(job.status.rawValue, style: job.status.badgeStyle)

                        Text(job.title)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    if job.status == .inProgress {
                        Button {} label: {
                            Image(systemName: "location.north.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(SpendlyColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                        }
                    }
                }

                // Location
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: SpendlyIcon.location.systemName)
                        .font(.system(size: 13))
                        .foregroundStyle(
                            job.status == .inProgress
                                ? SpendlyColors.primary.opacity(0.6)
                                : SpendlyColors.secondary
                        )
                    Text(job.location)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                }

                // Time range (for in-progress and upcoming)
                if job.status != .completed {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: SpendlyIcon.schedule.systemName)
                            .font(.system(size: 13))
                            .foregroundStyle(
                                job.status == .inProgress
                                    ? SpendlyColors.primary.opacity(0.6)
                                    : SpendlyColors.secondary
                            )
                        Text("Scheduled: \(job.scheduledTimeRange)")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }
                }

                // Team note for completed
                if job.status == .completed {
                    HStack(spacing: SpendlySpacing.sm) {
                        HStack(spacing: -6) {
                            Circle()
                                .fill(SpendlyColors.secondary.opacity(0.3))
                                .frame(width: 24, height: 24)
                            Circle()
                                .fill(SpendlyColors.secondary.opacity(0.4))
                                .frame(width: 24, height: 24)
                        }
                        Text("Team meeting completed")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }

                // Action buttons
                if job.status == .inProgress {
                    inProgressButtons(for: job)
                } else if job.status == .upcoming {
                    upcomingButtons(for: job)
                }
            }
            .padding(SpendlySpacing.lg)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(
                        job.status == .inProgress
                            ? SpendlyColors.primary.opacity(0.2)
                            : SpendlyColors.secondary.opacity(0.15),
                        lineWidth: 1
                    )
            )
            .overlay(
                // Left accent border for in-progress jobs
                job.status == .inProgress
                    ? HStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(SpendlyColors.primary)
                            .frame(width: 4)
                            .padding(.vertical, 8)
                        Spacer()
                    }
                    : nil
            )
            .opacity(job.status == .upcoming ? 0.8 : 1.0)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Action Buttons

    private func inProgressButtons(for job: JobDisplayModel) -> some View {
        HStack(spacing: SpendlySpacing.sm) {
            Button {
                viewModel.openJob(job)
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: SpendlyIcon.directions.systemName)
                        .font(.system(size: 13, weight: .semibold))
                    Text("Get Directions")
                        .font(SpendlyFont.bodySemibold())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpendlySpacing.md)
                .foregroundStyle(.white)
                .background(SpendlyColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            }

            Button {
                viewModel.openJob(job)
            } label: {
                Text("Details")
                    .font(SpendlyFont.bodySemibold())
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.vertical, SpendlySpacing.md)
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme).opacity(0.6))
                    .background(SpendlyColors.background(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            }
        }
    }

    private func upcomingButtons(for job: JobDisplayModel) -> some View {
        Button {
            viewModel.openJob(job)
        } label: {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: SpendlyIcon.directions.systemName)
                    .font(.system(size: 13, weight: .semibold))
                Text("Get Directions")
                    .font(SpendlyFont.bodySemibold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.md)
            .foregroundStyle(SpendlyColors.foreground(for: colorScheme).opacity(0.6))
            .background(SpendlyColors.background(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview

#Preview {
    JobExecutionRootView()
}
