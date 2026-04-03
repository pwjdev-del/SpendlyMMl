import SwiftUI
import SpendlyCore

struct TicketDetailView: View {

    let ticket: DisplayTicket

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    private let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm a"
        return f
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SpendlySpacing.xl) {
                        issueSummaryHeader
                        quickActionBar
                        statusTimelineSection
                        ticketInfoSection
                        machineInfoSection
                        schedulingSection
                        technicianUpdatesSection
                        contactActionSection
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.bottom, SpendlySpacing.xxxl * 2)
                }
            }
            .navigationTitle("Issue Status Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: SpendlyIcon.close.systemName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            // Edit action
                        } label: {
                            Label("Edit Ticket", systemImage: SpendlyIcon.edit.systemName)
                        }
                        Button {
                            // Share action
                        } label: {
                            Label("Share", systemImage: SpendlyIcon.share.systemName)
                        }
                        Button {
                            // Export action
                        } label: {
                            Label("Export PDF", systemImage: SpendlyIcon.download.systemName)
                        }
                        Divider()
                        Button(role: .destructive) {
                            // Close ticket
                        } label: {
                            Label("Close Ticket", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: SpendlyIcon.moreVert.systemName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
            }
        }
    }

    // MARK: - Issue Summary Header

    private var issueSummaryHeader: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            // Ticket number badge + priority
            HStack {
                Text(ticket.ticketNumber)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, SpendlySpacing.sm)
                    .padding(.vertical, SpendlySpacing.xs)
                    .background(SpendlyColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
                    .textCase(.uppercase)
                    .tracking(0.5)

                Spacer()

                HStack(spacing: SpendlySpacing.xs) {
                    Text("Priority:")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                    SPBadge(ticket.urgency.rawValue, style: ticket.urgency.badgeStyle)
                }
            }

            // Title
            Text(ticket.title)
                .font(SpendlyFont.title())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            // Location + Source
            HStack(spacing: SpendlySpacing.md) {
                if let location = ticket.location {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 11))
                        Text(location)
                            .font(SpendlyFont.caption())
                    }
                    .foregroundStyle(SpendlyColors.secondary)
                }

                // Source badge
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: sourceIcon)
                        .font(.system(size: 11))
                    Text(ticket.source.rawValue)
                        .font(SpendlyFont.caption())
                }
                .foregroundStyle(SpendlyColors.secondary)

                // Sync status
                if !ticket.isSyncedOffline {
                    HStack(spacing: 2) {
                        Image(systemName: "icloud.slash")
                            .font(.system(size: 11))
                        Text("Pending Sync")
                            .font(SpendlyFont.caption())
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(SpendlyColors.warning)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.primary.opacity(colorScheme == .dark ? 0.2 : 0.05))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    private var sourceIcon: String {
        switch ticket.source {
        case .manual:       return "pencil.and.list.clipboard"
        case .incomingCall: return "phone.arrow.down.left"
        case .diagnostic:   return "waveform.path.ecg"
        case .offline:      return "wifi.slash"
        }
    }

    // MARK: - Quick Action Bar

    private var quickActionBar: some View {
        HStack(spacing: SpendlySpacing.sm) {
            quickActionButton(icon: "phone.fill", label: "Call", color: SpendlyColors.success)
            quickActionButton(icon: "message.fill", label: "Message", color: SpendlyColors.info)
            quickActionButton(icon: "calendar.badge.plus", label: "Schedule", color: SpendlyColors.accent)
            quickActionButton(icon: "arrow.triangle.2.circlepath", label: "Escalate", color: SpendlyColors.error)
        }
    }

    private func quickActionButton(icon: String, label: String, color: Color) -> some View {
        Button {
            // Action placeholder
        } label: {
            VStack(spacing: SpendlySpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .textCase(.uppercase)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.md)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        }
    }

    // MARK: - Status Timeline

    private var statusTimelineSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpendlyColors.primary)
                Text("Status Timeline")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
                SPBadge(ticket.status.rawValue, style: ticket.status.badgeStyle)
            }

            SPCard(elevation: .low, padding: SpendlySpacing.md) {
                VStack(spacing: 0) {
                    ForEach(Array(ticket.timeline.enumerated()), id: \.element.id) { index, event in
                        HStack(alignment: .top, spacing: SpendlySpacing.md) {
                            // Timeline dot + line
                            VStack(spacing: 0) {
                                // Status-colored dot
                                ZStack {
                                    Circle()
                                        .fill(timelineDotColor(for: event, isLast: index == ticket.timeline.count - 1))
                                        .frame(width: 28, height: 28)

                                    Image(systemName: timelineIcon(for: event))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.white)
                                }

                                if index < ticket.timeline.count - 1 {
                                    Rectangle()
                                        .fill(SpendlyColors.primary.opacity(0.2))
                                        .frame(width: 2)
                                        .frame(minHeight: 36)
                                }
                            }
                            .frame(width: 28)

                            // Content
                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                HStack {
                                    Text(event.title)
                                        .font(SpendlyFont.bodySemibold())
                                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                    Spacer()
                                    Text(shortDateFormatter.string(from: event.date))
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondary)
                                }

                                if let description = event.description {
                                    Text(description)
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                                }

                                if let performer = event.performedBy {
                                    HStack(spacing: SpendlySpacing.xs) {
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 9))
                                        Text(performer)
                                            .font(.system(size: 11, weight: .medium))
                                    }
                                    .foregroundStyle(SpendlyColors.primary.opacity(0.7))
                                }
                            }
                            .padding(.bottom, SpendlySpacing.lg)
                        }
                    }

                    // Pending "Resolved" step if not yet resolved
                    if ticket.status != .resolved && ticket.status != .closed {
                        HStack(alignment: .top, spacing: SpendlySpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(SpendlyColors.secondary.opacity(0.15))
                                    .frame(width: 28, height: 28)

                                Image(systemName: "clock")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                            }
                            .frame(width: 28)

                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text("Resolved")
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.4))

                                if let scheduled = ticket.scheduledDate {
                                    Text("Estimated \(scheduledDateString(scheduled))")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                                } else {
                                    Text("Pending resolution")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func timelineDotColor(for event: TicketTimelineEvent, isLast: Bool) -> Color {
        if isLast {
            // Most recent step gets the status-aware color
            switch event.status {
            case .open:       return SpendlyColors.info
            case .inProgress: return SpendlyColors.primary
            case .onHold:     return SpendlyColors.warning
            case .resolved:   return SpendlyColors.success
            case .closed:     return SpendlyColors.secondary
            case .all:        return SpendlyColors.primary
            }
        }
        return SpendlyColors.primary
    }

    private func timelineIcon(for event: TicketTimelineEvent) -> String {
        let title = event.title.lowercased()
        if title.contains("submit") || title.contains("created") { return "plus" }
        if title.contains("assign") { return "person" }
        if title.contains("progress") { return "wrench.and.screwdriver" }
        if title.contains("part") { return "shippingbox" }
        if title.contains("hold") { return "pause" }
        if title.contains("resolv") { return "checkmark" }
        return "circle.fill"
    }

    private func scheduledDateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f.string(from: date)
    }

    // MARK: - Ticket Info Section

    private var ticketInfoSection: some View {
        SPCard(elevation: .low) {
            VStack(spacing: 0) {
                infoRow(label: "CATEGORY", value: ticket.category.rawValue, icon: ticket.category.icon, iconColor: ticket.category.color)
                SPDivider()
                infoRow(label: "STATUS", value: ticket.status.rawValue)
                SPDivider()
                infoRow(label: "URGENCY", value: ticket.urgency.rawValue)
                SPDivider()
                infoRow(label: "CUSTOMER", value: ticket.customerName)
                SPDivider()
                infoRow(label: "CREATED", value: dateFormatter.string(from: ticket.createdAt))
                SPDivider()
                infoRow(label: "LAST UPDATED", value: dateFormatter.string(from: ticket.updatedAt))
                if let tech = ticket.assignedTechnician {
                    SPDivider()
                    infoRow(label: "ASSIGNED TO", value: tech)
                }
                if ticket.photoCount > 0 {
                    SPDivider()
                    infoRow(label: "ATTACHMENTS", value: "\(ticket.photoCount) photo\(ticket.photoCount == 1 ? "" : "s")")
                }

                // Description
                SPDivider()
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text("DESCRIPTION")
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(SpendlyColors.secondary)
                        .tracking(0.8)
                    Text(ticket.description)
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, SpendlySpacing.md)
            }
        }
    }

    private func infoRow(label: String, value: String, icon: String? = nil, iconColor: Color? = nil) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(SpendlyColors.secondary)
                .tracking(0.8)
            Spacer()
            HStack(spacing: SpendlySpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                        .foregroundStyle(iconColor ?? SpendlyColors.primary)
                }
                Text(value)
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
        }
        .padding(.vertical, SpendlySpacing.md)
    }

    // MARK: - Machine Info Section

    @ViewBuilder
    private var machineInfoSection: some View {
        if let machineName = ticket.machineName {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                HStack {
                    Image(systemName: "gearshape.2")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(SpendlyColors.primary)
                    Text("Equipment Details")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }

                SPCard(elevation: .low) {
                    HStack(spacing: SpendlySpacing.md) {
                        // Machine icon
                        ZStack {
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .fill(SpendlyColors.primary.opacity(colorScheme == .dark ? 0.25 : 0.08))
                                .frame(width: 56, height: 56)
                            Image(systemName: "gearshape.2")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(SpendlyColors.primary)
                        }

                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text(machineName)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            if let serial = ticket.machineSerial {
                                Text(serial)
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundStyle(SpendlyColors.secondary)
                            }

                            if let location = ticket.location {
                                HStack(spacing: SpendlySpacing.xs) {
                                    Image(systemName: "mappin")
                                        .font(.system(size: 10))
                                    Text(location)
                                        .font(SpendlyFont.caption())
                                }
                                .foregroundStyle(SpendlyColors.secondary)
                            }
                        }

                        Spacer()

                        Image(systemName: SpendlyIcon.chevronRight.systemName)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                    }
                }
            }
        }
    }

    // MARK: - Scheduling Section

    @ViewBuilder
    private var schedulingSection: some View {
        if let scheduledDate = ticket.scheduledDate {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(SpendlyColors.accent)
                    Text("Scheduled Visit")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }

                SPCard(elevation: .low) {
                    HStack(spacing: SpendlySpacing.md) {
                        // Date pill
                        VStack(spacing: 2) {
                            Text(monthAbbrev(scheduledDate))
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                                .foregroundStyle(SpendlyColors.accent)
                                .textCase(.uppercase)
                            Text(dayString(scheduledDate))
                                .font(SpendlyFont.title())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                .monospacedDigit()
                        }
                        .frame(width: 48)
                        .padding(.vertical, SpendlySpacing.sm)
                        .background(SpendlyColors.accent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text("Service Visit")
                                .font(SpendlyFont.bodyMedium())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            if let tech = ticket.assignedTechnician {
                                HStack(spacing: SpendlySpacing.xs) {
                                    Image(systemName: "person")
                                        .font(.system(size: 10))
                                    Text(tech)
                                        .font(SpendlyFont.caption())
                                }
                                .foregroundStyle(SpendlyColors.secondary)
                            }

                            Text(dateFormatter.string(from: scheduledDate))
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.accent)
                        }

                        Spacer()
                    }
                }
            }
        }
    }

    // MARK: - Technician Updates

    private var technicianUpdatesSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Image(systemName: "bubble.left.and.text.bubble.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpendlyColors.primary)
                Text("Activity Log")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
                Text("\(ticket.timeline.count) events")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            VStack(spacing: SpendlySpacing.sm) {
                ForEach(ticket.timeline.reversed()) { event in
                    SPCard(elevation: .low, padding: SpendlySpacing.md) {
                        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                            HStack {
                                if let performer = event.performedBy {
                                    HStack(spacing: SpendlySpacing.sm) {
                                        // Avatar placeholder
                                        Circle()
                                            .fill(SpendlyColors.primary.opacity(0.15))
                                            .frame(width: 28, height: 28)
                                            .overlay(
                                                Text(String(performer.prefix(1)))
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundStyle(SpendlyColors.primary)
                                            )

                                        VStack(alignment: .leading) {
                                            Text(performer)
                                                .font(SpendlyFont.bodySemibold())
                                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                                .lineLimit(1)

                                            Text(shortDateFormatter.string(from: event.date))
                                                .font(.system(size: 10, weight: .medium))
                                                .foregroundStyle(SpendlyColors.secondary)
                                                .textCase(.uppercase)
                                        }
                                    }
                                }

                                Spacer()

                                SPBadge(event.title, style: event.status.badgeStyle)
                            }

                            if let description = event.description {
                                Text(description)
                                    .font(SpendlyFont.body())
                                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Contact Action Section

    private var contactActionSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            if ticket.assignedTechnician != nil {
                SPButton("Message Technician", icon: "message.fill", style: .primary) {
                    // Message action
                }
            }

            SPButton("Convert to Service Trip", icon: "arrow.triangle.turn.up.right.diamond", style: .secondary) {
                // Convert action
            }
        }
    }

    // MARK: - Helpers

    private func monthAbbrev(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MMM"
        return f.string(from: date)
    }

    private func dayString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f.string(from: date)
    }
}

// MARK: - Previews

#Preview("Ticket Detail - In Progress") {
    TicketDetailView(ticket: TicketManagementMockData.tickets[1])
        .preferredColorScheme(.light)
}

#Preview("Ticket Detail - Open Critical") {
    TicketDetailView(ticket: TicketManagementMockData.tickets[0])
        .preferredColorScheme(.light)
}

#Preview("Ticket Detail - Dark") {
    TicketDetailView(ticket: TicketManagementMockData.tickets[2])
        .preferredColorScheme(.dark)
}
