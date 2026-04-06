import SwiftUI
import SpendlyCore

struct TicketDetailView: View {

    let ticket: DisplayTicket
    var viewModel: TicketManagementViewModel? = nil

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    // BUG 4 FIX: Quick action sheet states
    @State private var showMessageCompose: Bool = false
    @State private var messageText: String = ""
    @State private var showScheduleSheet: Bool = false
    @State private var selectedScheduleDate: Date = Date()
    @State private var showEscalateConfirmation: Bool = false

    // BUG 5 FIX: Menu action sheet states
    @State private var showEditSheet: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var showPDFPreview: Bool = false
    @State private var showCloseConfirmation: Bool = false
    @State private var pdfURL: URL?

    // BUG 6 FIX: Contact action sheet states
    @State private var showTechnicianMessage: Bool = false
    @State private var technicianMessageText: String = ""
    @State private var showConvertConfirmation: Bool = false
    @State private var showConvertSuccess: Bool = false

    // General feedback
    @State private var showActionConfirmation: Bool = false
    @State private var actionConfirmationMessage: String = ""

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

                // Action confirmation toast
                if showActionConfirmation {
                    VStack {
                        Spacer()
                        HStack(spacing: SpendlySpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(SpendlyColors.success)
                            Text(actionConfirmationMessage)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        }
                        .padding(SpendlySpacing.lg)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous))
                        .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
                        .padding(.bottom, SpendlySpacing.xxxl)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(10)
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
                        // BUG 5 FIX: Edit action
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("Edit Ticket", systemImage: SpendlyIcon.edit.systemName)
                        }
                        // BUG 5 FIX: Share action
                        Button {
                            showShareSheet = true
                        } label: {
                            Label("Share", systemImage: SpendlyIcon.share.systemName)
                        }
                        // BUG 5 FIX: Export PDF action
                        Button {
                            exportPDF()
                        } label: {
                            Label("Export PDF", systemImage: SpendlyIcon.download.systemName)
                        }
                        Divider()
                        // BUG 5 FIX: Close ticket action
                        Button(role: .destructive) {
                            showCloseConfirmation = true
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
            // BUG 4: Message compose sheet
            .sheet(isPresented: $showMessageCompose) {
                messageComposeSheet(
                    title: "Message Customer",
                    recipient: ticket.customerName,
                    text: $messageText,
                    isPresented: $showMessageCompose
                ) {
                    showConfirmation("Message sent to \(ticket.customerName)")
                }
            }
            // BUG 4: Schedule sheet
            .sheet(isPresented: $showScheduleSheet) {
                scheduleSheet
            }
            // BUG 5: Edit sheet (pre-filled form)
            .sheet(isPresented: $showEditSheet) {
                editTicketSheet
            }
            // BUG 5: Share sheet
            .sheet(isPresented: $showShareSheet) {
                let shareText = "Ticket \(ticket.ticketNumber): \(ticket.title)\nStatus: \(ticket.status.rawValue)\nCustomer: \(ticket.customerName)\nPriority: \(ticket.urgency.rawValue)\n\n\(ticket.description)"
                ShareSheetView(items: [shareText])
            }
            // BUG 5: PDF preview sheet
            .sheet(isPresented: $showPDFPreview) {
                if let url = pdfURL {
                    PDFPreviewSheet(url: url, isPresented: $showPDFPreview)
                } else {
                    // Fallback: dismiss immediately if URL became nil
                    Color.clear.onAppear { showPDFPreview = false }
                }
            }
            // BUG 6: Technician message sheet
            .sheet(isPresented: $showTechnicianMessage) {
                messageComposeSheet(
                    title: "Message Technician",
                    recipient: ticket.assignedTechnician ?? "Technician",
                    text: $technicianMessageText,
                    isPresented: $showTechnicianMessage
                ) {
                    showConfirmation("Message sent to \(ticket.assignedTechnician ?? "technician")")
                }
            }
            // BUG 4: Escalate confirmation
            .alert("Escalate Ticket", isPresented: $showEscalateConfirmation) {
                Button("Escalate", role: .destructive) {
                    viewModel?.updateTicket(ticket, urgency: .critical)
                    showConfirmation("Ticket escalated to Critical priority")
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will set the ticket priority to Critical and notify the on-call team. Continue?")
            }
            // BUG 5: Close ticket confirmation
            .alert("Close Ticket", isPresented: $showCloseConfirmation) {
                Button("Close Ticket", role: .destructive) {
                    viewModel?.updateTicket(ticket, status: .closed)
                    showConfirmation("Ticket closed successfully")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will mark the ticket as closed. This action can be reversed by reopening the ticket later.")
            }
            // BUG 6: Convert to service trip confirmation
            .alert("Convert to Service Trip", isPresented: $showConvertConfirmation) {
                Button("Convert") {
                    viewModel?.updateTicket(ticket, status: .inProgress)
                    showConfirmation("Ticket converted to Service Trip")
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will create a new service trip from this ticket and update its status to In Progress.")
            }
        }
    }

    // MARK: - Helpers

    private func showConfirmation(_ message: String) {
        actionConfirmationMessage = message
        withAnimation(.spring(response: 0.4)) {
            showActionConfirmation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut) {
                showActionConfirmation = false
            }
        }
    }

    private func exportPDF() {
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792))
        let data = renderer.pdfData { context in
            context.beginPage()
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20)
            ]
            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12)
            ]
            let labelAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]

            var y: CGFloat = 40
            let leftMargin: CGFloat = 40

            // Title
            (ticket.ticketNumber as NSString).draw(at: CGPoint(x: leftMargin, y: y), withAttributes: labelAttrs)
            y += 24
            (ticket.title as NSString).draw(at: CGPoint(x: leftMargin, y: y), withAttributes: attrs)
            y += 32

            // Details
            let fields: [(String, String)] = [
                ("Status", ticket.status.rawValue),
                ("Priority", ticket.urgency.rawValue),
                ("Category", ticket.category.rawValue),
                ("Customer", ticket.customerName),
                ("Machine", ticket.machineName ?? "N/A"),
                ("Serial", ticket.machineSerial ?? "N/A"),
                ("Location", ticket.location ?? "N/A"),
                ("Assigned To", ticket.assignedTechnician ?? "Unassigned"),
                ("Created", dateFormatter.string(from: ticket.createdAt)),
                ("Updated", dateFormatter.string(from: ticket.updatedAt)),
            ]

            for (label, value) in fields {
                ("\(label):" as NSString).draw(at: CGPoint(x: leftMargin, y: y), withAttributes: labelAttrs)
                (value as NSString).draw(at: CGPoint(x: leftMargin + 120, y: y), withAttributes: bodyAttrs)
                y += 20
            }

            y += 16
            ("Description:" as NSString).draw(at: CGPoint(x: leftMargin, y: y), withAttributes: labelAttrs)
            y += 20
            let descRect = CGRect(x: leftMargin, y: y, width: 532, height: 200)
            (ticket.description as NSString).draw(in: descRect, withAttributes: bodyAttrs)
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(ticket.ticketNumber)-export.pdf")
        try? data.write(to: tempURL)
        pdfURL = tempURL
        showPDFPreview = true
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

    // MARK: - Quick Action Bar (BUG 4 FIX)

    private var quickActionBar: some View {
        HStack(spacing: SpendlySpacing.sm) {
            // Call: open tel:// URL
            quickActionButtonView(icon: "phone.fill", label: "Call", color: SpendlyColors.success) {
                let phone = "1-800-555-0199" // placeholder customer phone
                if let url = URL(string: "tel://\(phone)") {
                    UIApplication.shared.open(url)
                }
            }
            // Message: present compose sheet
            quickActionButtonView(icon: "message.fill", label: "Message", color: SpendlyColors.info) {
                messageText = ""
                showMessageCompose = true
            }
            // Schedule: present scheduling view
            quickActionButtonView(icon: "calendar.badge.plus", label: "Schedule", color: SpendlyColors.accent) {
                selectedScheduleDate = Date()
                showScheduleSheet = true
            }
            // Escalate: set priority to critical
            quickActionButtonView(icon: "arrow.triangle.2.circlepath", label: "Escalate", color: SpendlyColors.error) {
                showEscalateConfirmation = true
            }
        }
    }

    private func quickActionButtonView(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
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
            case .draft:      return SpendlyColors.secondary
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

    // MARK: - Contact Action Section (BUG 6 FIX)

    private var contactActionSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            if ticket.assignedTechnician != nil {
                SPButton("Message Technician", icon: "message.fill", style: .primary) {
                    technicianMessageText = ""
                    showTechnicianMessage = true
                }
            }

            SPButton("Convert to Service Trip", icon: "arrow.triangle.turn.up.right.diamond", style: .secondary) {
                showConvertConfirmation = true
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

    // MARK: - Message Compose Sheet

    private func messageComposeSheet(
        title: String,
        recipient: String,
        text: Binding<String>,
        isPresented: Binding<Bool>,
        onSend: @escaping () -> Void
    ) -> some View {
        NavigationStack {
            VStack(spacing: SpendlySpacing.lg) {
                // Recipient header
                HStack(spacing: SpendlySpacing.md) {
                    Circle()
                        .fill(SpendlyColors.primary.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(recipient.prefix(1)))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(SpendlyColors.primary)
                        )
                    VStack(alignment: .leading, spacing: 2) {
                        Text("To: \(recipient)")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("Re: \(ticket.ticketNumber) - \(ticket.title)")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                }
                .padding(.horizontal, SpendlySpacing.lg)

                // Message text editor
                TextEditor(text: text)
                    .font(SpendlyFont.body())
                    .frame(minHeight: 200)
                    .padding(SpendlySpacing.sm)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                            .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, SpendlySpacing.lg)

                Spacer()
            }
            .padding(.top, SpendlySpacing.lg)
            .background(SpendlyTheme.blueprint.backgroundColor(for: colorScheme))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented.wrappedValue = false
                    }
                    .foregroundStyle(SpendlyColors.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresented.wrappedValue = false
                        onSend()
                    } label: {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 12))
                            Text("Send")
                                .font(SpendlyFont.bodySemibold())
                        }
                        .foregroundStyle(text.wrappedValue.isEmpty ? SpendlyColors.secondary : SpendlyColors.primary)
                    }
                    .disabled(text.wrappedValue.isEmpty)
                }
            }
        }
    }

    // MARK: - Schedule Sheet

    private var scheduleSheet: some View {
        NavigationStack {
            VStack(spacing: SpendlySpacing.xl) {
                VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                    Text("Schedule a service visit for this ticket.")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                    SPCard(elevation: .low) {
                        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                            HStack(spacing: SpendlySpacing.sm) {
                                Image(systemName: "calendar")
                                    .foregroundStyle(SpendlyColors.accent)
                                Text(ticket.ticketNumber)
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            }
                            Text(ticket.title)
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                                .lineLimit(2)
                        }
                    }

                    DatePicker(
                        "Visit Date & Time",
                        selection: $selectedScheduleDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .tint(SpendlyColors.primary)
                }
                .padding(.horizontal, SpendlySpacing.lg)

                Spacer()

                SPButton("Confirm Schedule", icon: "calendar.badge.checkmark", style: .primary) {
                    showScheduleSheet = false
                    showConfirmation("Visit scheduled for \(dateFormatter.string(from: selectedScheduleDate))")
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.bottom, SpendlySpacing.xl)
            }
            .padding(.top, SpendlySpacing.lg)
            .background(SpendlyTheme.blueprint.backgroundColor(for: colorScheme))
            .navigationTitle("Schedule Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showScheduleSheet = false
                    }
                    .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
    }

    // MARK: - Edit Ticket Sheet (BUG 5 FIX)

    private var editTicketSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpendlySpacing.lg) {
                    // Pre-filled with current ticket data (read-only summary for now)
                    SPCard(elevation: .low) {
                        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                            HStack {
                                Text(ticket.ticketNumber)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, SpendlySpacing.sm)
                                    .padding(.vertical, SpendlySpacing.xs)
                                    .background(SpendlyColors.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
                                Spacer()
                                SPBadge(ticket.status.rawValue, style: ticket.status.badgeStyle)
                            }

                            Text("Title")
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                                .foregroundStyle(SpendlyColors.secondary)
                            Text(ticket.title)
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            Text("Description")
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                                .foregroundStyle(SpendlyColors.secondary)
                            Text(ticket.description)
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            SPDivider()

                            HStack {
                                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                    Text("Category")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondary)
                                    HStack(spacing: SpendlySpacing.xs) {
                                        Image(systemName: ticket.category.icon)
                                            .foregroundStyle(ticket.category.color)
                                        Text(ticket.category.rawValue)
                                            .font(SpendlyFont.bodyMedium())
                                    }
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                                    Text("Priority")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondary)
                                    SPBadge(ticket.urgency.rawValue, style: ticket.urgency.badgeStyle)
                                }
                            }

                            HStack {
                                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                    Text("Customer")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondary)
                                    Text(ticket.customerName)
                                        .font(SpendlyFont.bodyMedium())
                                }
                                Spacer()
                                if let tech = ticket.assignedTechnician {
                                    VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                                        Text("Assigned")
                                            .font(SpendlyFont.caption())
                                            .foregroundStyle(SpendlyColors.secondary)
                                        Text(tech)
                                            .font(SpendlyFont.bodyMedium())
                                    }
                                }
                            }
                        }
                    }

                    Text("Full editing will be available in a future update. Use the quick actions to change status or priority.")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, SpendlySpacing.xl)
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.top, SpendlySpacing.lg)
            }
            .background(SpendlyTheme.blueprint.backgroundColor(for: colorScheme))
            .navigationTitle("Edit Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showEditSheet = false
                    }
                    .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
    }
}

// MARK: - Share Sheet (UIKit wrapper)

private struct ShareSheetView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - PDF Preview Sheet

private struct PDFPreviewSheet: View {
    let url: URL
    @Binding var isPresented: Bool
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: SpendlySpacing.lg) {
                // PDF icon + info
                VStack(spacing: SpendlySpacing.md) {
                    Image(systemName: "doc.richtext")
                        .font(.system(size: 48))
                        .foregroundStyle(SpendlyColors.primary)

                    Text("PDF Generated")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Text(url.lastPathComponent)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .padding(.top, SpendlySpacing.xxxl)

                Spacer()

                // Share the PDF
                ShareLink(item: url) {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Share PDF")
                            .font(SpendlyFont.bodySemibold())
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous)
                            .fill(SpendlyColors.primary)
                    )
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.bottom, SpendlySpacing.xl)
            }
            .background(SpendlyTheme.blueprint.backgroundColor(for: colorScheme))
            .navigationTitle("Export PDF")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
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
