import SwiftUI
import SpendlyCore

struct MachineDetailView: View {

    let machine: VaultMachine
    var viewModel: MachineVaultViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false
    @State private var exportText = ""

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
                        heroSection
                        machineInfoSection
                        warrantySection
                        healthGaugeSection
                        maintenanceHistorySection
                        scheduledMaintenanceSection
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.bottom, SpendlySpacing.xxxl * 2)
                }
            }
            .navigationTitle(machine.name)
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
                            showEditSheet = true
                        } label: {
                            Label("Edit Machine", systemImage: SpendlyIcon.edit.systemName)
                        }
                        Button {
                            exportText = generateReport()
                            showShareSheet = true
                        } label: {
                            Label("Export Report", systemImage: SpendlyIcon.download.systemName)
                        }
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("Delete Machine", systemImage: SpendlyIcon.delete.systemName)
                        }
                    } label: {
                        Image(systemName: SpendlyIcon.moreVert.systemName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
            }
            .alert("Delete Machine", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    viewModel.deleteMachine(id: machine.id)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete \"\(machine.name)\"? This action cannot be undone.")
            }
            .sheet(isPresented: $showEditSheet) {
                EditMachineView(machine: machine) { updated in
                    viewModel.updateMachine(updated)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheetView(text: exportText)
            }
        }
    }

    // MARK: - Report Generation

    private func generateReport() -> String {
        var report = """
        MACHINE REPORT
        ==============
        Name: \(machine.name)
        Model: \(machine.model)
        Serial Number: \(machine.serialNumber)
        Status: \(machine.statusLabel)
        Division: \(machine.division)
        Location: \(machine.location)
        Health Score: \(machine.healthPercent)%
        Category: \(machine.category.rawValue)
        """

        if let customer = machine.customerName {
            report += "\nCustomer: \(customer)"
        }
        if let installDate = machine.installDate {
            report += "\nInstall Date: \(dateFormatter.string(from: installDate))"
        }
        if let expiry = machine.warrantyExpiry {
            report += "\nWarranty Expiry: \(dateFormatter.string(from: expiry))"
        }
        report += "\nWarranty Status: \(machine.warrantyStatus.label)"

        if let notes = machine.notes, !notes.isEmpty {
            report += "\n\nNotes: \(notes)"
        }

        if !machine.maintenanceHistory.isEmpty {
            report += "\n\nMAINTENANCE HISTORY"
            report += "\n-------------------"
            for event in machine.maintenanceHistory {
                report += "\n[\(dateFormatter.string(from: event.date))] \(event.title)"
                if let ticket = event.ticketNumber { report += " (\(ticket))" }
                report += "\n  \(event.description)"
                if let tech = event.technicianName { report += "\n  Technician: \(tech)" }
            }
        }

        if !machine.scheduledMaintenance.isEmpty {
            report += "\n\nSCHEDULED MAINTENANCE"
            report += "\n---------------------"
            for event in machine.scheduledMaintenance {
                report += "\n[\(dateFormatter.string(from: event.scheduledDate))] \(event.title)"
                if let tech = event.assignedTechnician { report += " - Assigned: \(tech)" }
                if event.isOverdue { report += " (OVERDUE)" }
            }
        }

        report += "\n\nGenerated: \(dateFormatter.string(from: Date()))"
        return report
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            SpendlyColors.primary.opacity(colorScheme == .dark ? 0.4 : 0.12),
                            SpendlyColors.primary.opacity(colorScheme == .dark ? 0.15 : 0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 180)

            VStack(spacing: SpendlySpacing.md) {
                Image(systemName: sfSymbolForMachine)
                    .font(.system(size: 52, weight: .thin))
                    .foregroundStyle(SpendlyColors.primary.opacity(0.6))

                SPBadge(machine.statusLabel, style: machine.statusBadgeStyle)
            }
        }
    }

    // MARK: - Machine Info

    private var machineInfoSection: some View {
        SPCard(elevation: .low) {
            VStack(spacing: 0) {
                infoRow(label: "MODEL", value: machine.model)
                SPDivider()
                infoRow(label: "SERIAL NUMBER", value: machine.serialNumber, isMonospaced: true)
                SPDivider()
                infoRow(label: "DIVISION", value: machine.division)
                SPDivider()
                infoRow(label: "LOCATION", value: machine.location)
                if let customer = machine.customerName {
                    SPDivider()
                    infoRow(label: "CUSTOMER", value: customer)
                }
                if let installDate = machine.installDate {
                    SPDivider()
                    infoRow(label: "INSTALL DATE", value: dateFormatter.string(from: installDate))
                }
                if let notes = machine.notes, !notes.isEmpty {
                    SPDivider()
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("NOTES")
                            .font(SpendlyFont.caption())
                            .fontWeight(.bold)
                            .foregroundStyle(SpendlyColors.secondary)
                            .tracking(0.8)
                        Text(notes)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, SpendlySpacing.md)
                }
            }
        }
    }

    private func infoRow(label: String, value: String, isMonospaced: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(SpendlyColors.secondary)
                .tracking(0.8)
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

    // MARK: - Warranty

    private var warrantySection: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                HStack {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(warrantyColor)
                    Text("Warranty Status")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Spacer()
                    SPBadge(machine.warrantyStatus.label, style: machine.warrantyStatus.badgeStyle)
                }

                if let expiry = machine.warrantyExpiry {
                    HStack {
                        Text("Expiry Date")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                        Spacer()
                        Text(dateFormatter.string(from: expiry))
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(warrantyColor)
                    }
                }

                if machine.warrantyStatus == .expiringSoon {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(SpendlyColors.warning)
                        Text("Warranty expires within 30 days. Consider renewal.")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.warning)
                    }
                    .padding(SpendlySpacing.sm)
                    .background(SpendlyColors.warning.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }
            }
        }
    }

    private var warrantyColor: Color {
        switch machine.warrantyStatus {
        case .active:       return SpendlyColors.success
        case .expiringSoon: return SpendlyColors.warning
        case .expired:      return SpendlyColors.error
        case .unknown:      return SpendlyColors.secondary
        }
    }

    // MARK: - Health Gauge

    private var healthGaugeSection: some View {
        SPCard(elevation: .low) {
            VStack(spacing: SpendlySpacing.lg) {
                HStack {
                    Image(systemName: "heart.text.square")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(healthColor)
                    Text("Health Score")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Spacer()
                }

                // Gauge
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(SpendlyColors.secondary.opacity(0.15), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(135))

                    Circle()
                        .trim(from: 0, to: 0.75 * machine.healthScore)
                        .stroke(healthColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(135))
                        .animation(.easeInOut(duration: 0.8), value: machine.healthScore)

                    VStack(spacing: SpendlySpacing.xs) {
                        Text("\(machine.healthPercent)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(healthColor)
                            .monospacedDigit()
                        Text("out of 100")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
                .frame(width: 160, height: 160)
                .frame(maxWidth: .infinity)

                // Health breakdown labels
                HStack(spacing: SpendlySpacing.xl) {
                    healthLegendItem(color: SpendlyColors.success, label: "Good", range: "80-100")
                    healthLegendItem(color: SpendlyColors.warning, label: "Fair", range: "50-79")
                    healthLegendItem(color: SpendlyColors.error, label: "Poor", range: "0-49")
                }
            }
        }
    }

    private func healthLegendItem(color: Color, label: String, range: String) -> some View {
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

    private var healthColor: Color {
        if machine.healthScore >= 0.8 { return SpendlyColors.success }
        if machine.healthScore >= 0.5 { return SpendlyColors.warning }
        return SpendlyColors.error
    }

    // MARK: - Maintenance History

    private var maintenanceHistorySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Image(systemName: "clock.arrow.counterclockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpendlyColors.primary)
                Text("Maintenance History")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
                Text("\(machine.maintenanceHistory.count) events")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            if machine.maintenanceHistory.isEmpty {
                SPCard(elevation: .low) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                        Text("No maintenance records yet.")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                SPCard(elevation: .low, padding: SpendlySpacing.md) {
                    SPTimeline(
                        items: machine.maintenanceHistory.map { event in
                            SPTimelineItem(
                                title: event.title,
                                subtitle: buildSubtitle(for: event),
                                status: timelineStatus(for: event),
                                time: dateFormatter.string(from: event.date)
                            )
                        }
                    )
                }
            }
        }
    }

    private func buildSubtitle(for event: MaintenanceEvent) -> String {
        var parts: [String] = []
        if let ticket = event.ticketNumber {
            parts.append(ticket)
        }
        if let tech = event.technicianName {
            parts.append("Tech: \(tech)")
        }
        parts.append(event.description)
        return parts.joined(separator: " | ")
    }

    private func timelineStatus(for event: MaintenanceEvent) -> SPTimelineStatus {
        switch event.type {
        case .emergency:    return .active
        case .corrective:   return .default
        case .preventive:   return .completed
        case .calibration:  return .completed
        case .inspection:   return .default
        }
    }

    // MARK: - Scheduled Maintenance

    private var scheduledMaintenanceSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpendlyColors.accent)
                Text("Upcoming Maintenance")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            if machine.scheduledMaintenance.isEmpty {
                SPCard(elevation: .low) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                        Text("No upcoming maintenance scheduled.")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(spacing: SpendlySpacing.sm) {
                    ForEach(machine.scheduledMaintenance) { event in
                        scheduledEventCard(event)
                    }
                }
            }
        }
    }

    private func scheduledEventCard(_ event: ScheduledMaintenance) -> some View {
        SPCard(elevation: .low) {
            HStack(spacing: SpendlySpacing.md) {
                // Date pill
                VStack(spacing: 2) {
                    Text(monthAbbrev(event.scheduledDate))
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(event.isOverdue ? SpendlyColors.error : SpendlyColors.accent)
                        .textCase(.uppercase)
                    Text(dayString(event.scheduledDate))
                        .font(SpendlyFont.title())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .monospacedDigit()
                }
                .frame(width: 48)
                .padding(.vertical, SpendlySpacing.sm)
                .background(
                    (event.isOverdue ? SpendlyColors.error : SpendlyColors.accent)
                        .opacity(0.1)
                )
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    HStack {
                        Text(event.title)
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Spacer()
                        if event.isOverdue {
                            SPBadge("Overdue", style: .error)
                        }
                    }
                    if let tech = event.assignedTechnician {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "person")
                                .font(.system(size: 10))
                            Text(tech)
                                .font(SpendlyFont.caption())
                        }
                        .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var sfSymbolForMachine: String {
        let name = machine.name.lowercased()
        if name.contains("film") { return "film.stack" }
        if name.contains("sachet") { return "shippingbox" }
        if name.contains("convert") { return "scissors" }
        if name.contains("vega") || name.contains("pouch") { return "bag" }
        return "gearshape.2"
    }

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

// MARK: - Edit Machine View

private struct EditMachineView: View {

    let machine: VaultMachine
    var onSave: (VaultMachine) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var name: String
    @State private var model: String
    @State private var serialNumber: String
    @State private var location: String
    @State private var customer: String
    @State private var division: String
    @State private var notes: String
    @State private var healthScore: Double
    @State private var status: MachineStatus
    @State private var category: MachineTypeFilter

    init(machine: VaultMachine, onSave: @escaping (VaultMachine) -> Void) {
        self.machine = machine
        self.onSave = onSave
        _name = State(initialValue: machine.name)
        _model = State(initialValue: machine.model)
        _serialNumber = State(initialValue: machine.serialNumber)
        _location = State(initialValue: machine.location)
        _customer = State(initialValue: machine.customerName ?? "")
        _division = State(initialValue: machine.division)
        _notes = State(initialValue: machine.notes ?? "")
        _healthScore = State(initialValue: machine.healthScore)
        _status = State(initialValue: machine.status)
        _category = State(initialValue: machine.category)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !serialNumber.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SpendlySpacing.lg) {
                        formSection(title: "Basic Information") {
                            formField(label: "Machine Name *", text: $name, placeholder: "e.g. M-200 FFS")
                            formField(label: "Model", text: $model, placeholder: "e.g. M-200-FFS-XL")
                            formField(label: "Serial Number *", text: $serialNumber, placeholder: "e.g. SN-M200-4821")
                        }

                        formSection(title: "Location & Customer") {
                            formField(label: "Location", text: $location, placeholder: "e.g. Plant A - Line 3")
                            formField(label: "Division", text: $division, placeholder: "e.g. Packaging Division")
                            formField(label: "Customer", text: $customer, placeholder: "e.g. Industrial Logistics Corp.")
                        }

                        formSection(title: "Machine Details") {
                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text("Category")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                                Picker("Category", selection: $category) {
                                    ForEach(MachineTypeFilter.allCases.filter { $0 != .all }, id: \.self) { type in
                                        Text(type.rawValue).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }

                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text("Status")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                                Picker("Status", selection: $status) {
                                    Text("Operational").tag(MachineStatus.operational)
                                    Text("Needs Maintenance").tag(MachineStatus.needsMaintenance)
                                    Text("Under Repair").tag(MachineStatus.underRepair)
                                    Text("Decommissioned").tag(MachineStatus.decommissioned)
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                HStack {
                                    Text("Health Score")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondary)
                                    Spacer()
                                    Text("\(Int(healthScore * 100))%")
                                        .font(SpendlyFont.bodySemibold())
                                        .foregroundStyle(SpendlyColors.primary)
                                        .monospacedDigit()
                                }
                                Slider(value: $healthScore, in: 0...1, step: 0.01)
                                    .tint(SpendlyColors.primary)
                            }
                        }

                        formSection(title: "Notes") {
                            TextField("Additional notes...", text: $notes, axis: .vertical)
                                .font(SpendlyFont.body())
                                .lineLimit(3...6)
                                .padding(SpendlySpacing.md)
                                .background(SpendlyColors.background(for: colorScheme))
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        }
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.top, SpendlySpacing.sm)
                    .padding(.bottom, SpendlySpacing.xxxl)
                }
            }
            .navigationTitle("Edit Machine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(SpendlyColors.secondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveChanges() }
                        .fontWeight(.semibold)
                        .foregroundStyle(isValid ? SpendlyColors.primary : SpendlyColors.secondary)
                        .disabled(!isValid)
                }
            }
        }
    }

    private func formSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            Text(title)
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            VStack(spacing: SpendlySpacing.md) {
                content()
            }
            .padding(SpendlySpacing.md)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        }
    }

    private func formField(label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text(label)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
            TextField(placeholder, text: text)
                .font(SpendlyFont.body())
                .padding(SpendlySpacing.md)
                .background(SpendlyColors.background(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
        }
    }

    private func saveChanges() {
        let updated = VaultMachine(
            id: machine.id,
            name: name.trimmingCharacters(in: .whitespaces),
            model: model.trimmingCharacters(in: .whitespaces),
            serialNumber: serialNumber.trimmingCharacters(in: .whitespaces),
            status: status,
            division: division.trimmingCharacters(in: .whitespaces),
            location: location.trimmingCharacters(in: .whitespaces),
            healthScore: healthScore,
            warrantyExpiry: machine.warrantyExpiry,
            installDate: machine.installDate,
            imageName: machine.imageName,
            customerName: customer.isEmpty ? nil : customer.trimmingCharacters(in: .whitespaces),
            notes: notes.isEmpty ? nil : notes.trimmingCharacters(in: .whitespaces),
            category: category,
            maintenanceHistory: machine.maintenanceHistory,
            scheduledMaintenance: machine.scheduledMaintenance
        )
        onSave(updated)
        dismiss()
    }
}

// MARK: - Share Sheet (UIKit wrapper)

private struct ShareSheetView: UIViewControllerRepresentable {
    let text: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [text], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview("Machine Detail - Light") {
    MachineDetailView(machine: MachineVaultMockData.machines[0], viewModel: MachineVaultViewModel())
        .preferredColorScheme(.light)
}

#Preview("Machine Detail - Dark") {
    MachineDetailView(machine: MachineVaultMockData.machines[3], viewModel: MachineVaultViewModel())
        .preferredColorScheme(.dark)
}
