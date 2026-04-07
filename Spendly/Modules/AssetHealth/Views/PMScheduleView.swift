import SwiftUI
import SpendlyCore

// MARK: - PM Frequency

enum PMFrequency: String, CaseIterable {
    case weekly     = "Weekly"
    case biWeekly   = "Bi-Weekly"
    case monthly    = "Monthly"
    case quarterly  = "Quarterly"
    case semiAnnual = "Semi-Annual"
    case annual     = "Annual"

    var days: Int {
        switch self {
        case .weekly:     return 7
        case .biWeekly:   return 14
        case .monthly:    return 30
        case .quarterly:  return 90
        case .semiAnnual: return 180
        case .annual:     return 365
        }
    }
}

// MARK: - PM Schedule Display

struct PMScheduleDisplay: Identifiable {
    let id: UUID
    let title: String
    let machineName: String
    let machineID: String
    let frequency: PMFrequency
    let assignedTechnician: String?
    let lastCompletedAt: Date?
    let nextDueAt: Date
    let checklistItems: [String]
    let isActive: Bool
    let isOverdue: Bool

    init(
        id: UUID = UUID(),
        title: String,
        machineName: String,
        machineID: String,
        frequency: PMFrequency,
        assignedTechnician: String? = nil,
        lastCompletedAt: Date? = nil,
        nextDueAt: Date,
        checklistItems: [String] = [],
        isActive: Bool = true
    ) {
        self.id = id
        self.title = title
        self.machineName = machineName
        self.machineID = machineID
        self.frequency = frequency
        self.assignedTechnician = assignedTechnician
        self.lastCompletedAt = lastCompletedAt
        self.nextDueAt = nextDueAt
        self.checklistItems = checklistItems
        self.isActive = isActive
        self.isOverdue = nextDueAt < Date()
    }
}

// MARK: - PM Mock Data

enum PMScheduleMockData {

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    private static func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }

    static let schedules: [PMScheduleDisplay] = [
        PMScheduleDisplay(
            title: "Quarterly Vibration Analysis",
            machineName: "Compressor Unit C-7",
            machineID: "MCH-C7-0041",
            frequency: .quarterly,
            assignedTechnician: "Emily Rodriguez",
            lastCompletedAt: daysAgo(85),
            nextDueAt: daysFromNow(5),
            checklistItems: ["Check vibration levels", "Record frequency spectrum", "Oil sampling", "Inspect belt tension", "Update sensor firmware"]
        ),
        PMScheduleDisplay(
            title: "Monthly Bearing Inspection",
            machineName: "Conveyor XR-904",
            machineID: "MCH-XR904-0012",
            frequency: .monthly,
            assignedTechnician: "Marcus Chen",
            lastCompletedAt: daysAgo(25),
            nextDueAt: daysFromNow(5),
            checklistItems: ["Inspect bearing temperature", "Check lubrication levels", "Measure vibration amplitude", "Inspect seals and shields"]
        ),
        PMScheduleDisplay(
            title: "Bi-Weekly Filter Inspection",
            machineName: "Cooling Tower Alpha",
            machineID: "MCH-CTA-0003",
            frequency: .biWeekly,
            assignedTechnician: "David Park",
            lastCompletedAt: daysAgo(18),
            nextDueAt: daysAgo(4),
            checklistItems: ["Inspect filter cartridge", "Check water flow rate", "Measure inlet/outlet pressure", "Clean debris from intake"]
        ),
        PMScheduleDisplay(
            title: "Semi-Annual Transformer Calibration",
            machineName: "Main Transformer B-2",
            machineID: "MCH-TRB2-0001",
            frequency: .semiAnnual,
            assignedTechnician: "Sarah Mitchel",
            lastCompletedAt: daysAgo(170),
            nextDueAt: daysFromNow(10),
            checklistItems: ["Voltage output calibration", "Insulation resistance test", "Thermal imaging scan", "Check bushing condition", "Oil sample analysis", "Update maintenance log"]
        ),
        PMScheduleDisplay(
            title: "Annual Generator Overhaul",
            machineName: "Generator Set D-1",
            machineID: "MCH-GD1-0007",
            frequency: .annual,
            assignedTechnician: nil,
            lastCompletedAt: daysAgo(350),
            nextDueAt: daysFromNow(15),
            checklistItems: ["Full oil change", "Replace all filters", "Inspect cooling system", "Test load bank", "Check fuel injectors", "Inspect exhaust system", "Update operating hours log"]
        ),
        PMScheduleDisplay(
            title: "Weekly Hydraulic Pressure Check",
            machineName: "Press Unit H-9",
            machineID: "MCH-PH9-0019",
            frequency: .weekly,
            assignedTechnician: "James Wilson",
            lastCompletedAt: daysAgo(5),
            nextDueAt: daysFromNow(2),
            checklistItems: ["Record system pressure", "Check for leaks", "Inspect hose connections", "Verify gauge accuracy"]
        ),
    ]
}

// MARK: - PM Schedule View

struct PMScheduleView: View {
    @Environment(\.colorScheme) private var colorScheme

    @State private var schedules: [PMScheduleDisplay] = PMScheduleMockData.schedules
    @State private var searchText: String = ""
    @State private var selectedFrequencyFilter: PMFrequency? = nil
    @State private var showOverdueOnly: Bool = false
    @State private var showCreateSheet: Bool = false

    // Create form state
    @State private var newTitle: String = ""
    @State private var newFrequency: PMFrequency = .monthly
    @State private var newMachine: String = ""
    @State private var newTechnician: String = ""

    var filteredSchedules: [PMScheduleDisplay] {
        var result = schedules

        if showOverdueOnly {
            result = result.filter { $0.isOverdue }
        }

        if let freq = selectedFrequencyFilter {
            result = result.filter { $0.frequency == freq }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.machineName.lowercased().contains(query) ||
                ($0.assignedTechnician?.lowercased().contains(query) ?? false)
            }
        }

        return result.sorted { lhs, rhs in
            if lhs.isOverdue != rhs.isOverdue { return lhs.isOverdue }
            return lhs.nextDueAt < rhs.nextDueAt
        }
    }

    var overdueCount: Int {
        schedules.filter { $0.isOverdue }.count
    }

    var dueSoonCount: Int {
        let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        return schedules.filter { !$0.isOverdue && $0.nextDueAt <= weekFromNow }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            // KPIs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpendlySpacing.sm) {
                    SPMetricCard(title: "Active Schedules", value: "\(schedules.filter(\.isActive).count)", trend: nil, trendDirection: .flat)
                    SPMetricCard(title: "Overdue", value: "\(overdueCount)", trend: overdueCount > 0 ? "Action Needed" : "On Track", trendDirection: overdueCount > 0 ? .down : .up)
                    SPMetricCard(title: "Due This Week", value: "\(dueSoonCount)", trend: nil, trendDirection: .flat)
                }
                .padding(.horizontal, SpendlySpacing.md)
            }
            .padding(.vertical, SpendlySpacing.sm)

            // Filters
            HStack(spacing: SpendlySpacing.sm) {
                Button {
                    showOverdueOnly.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 10))
                        Text("Overdue")
                            .font(SpendlyFont.caption(weight: .medium))
                    }
                    .padding(.horizontal, SpendlySpacing.sm)
                    .padding(.vertical, 6)
                    .background(
                        showOverdueOnly ? SpendlyColors.error.opacity(0.15) : SpendlyColors.secondaryBackground(for: colorScheme),
                        in: Capsule()
                    )
                    .foregroundStyle(showOverdueOnly ? SpendlyColors.error : SpendlyColors.secondaryForeground(for: colorScheme))
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SpendlySpacing.xs) {
                        ForEach(PMFrequency.allCases, id: \.self) { freq in
                            Button {
                                selectedFrequencyFilter = selectedFrequencyFilter == freq ? nil : freq
                            } label: {
                                Text(freq.rawValue)
                                    .font(SpendlyFont.caption(weight: .medium))
                                    .padding(.horizontal, SpendlySpacing.sm)
                                    .padding(.vertical, 6)
                                    .background(
                                        selectedFrequencyFilter == freq ? SpendlyColors.primary.opacity(0.15) : SpendlyColors.secondaryBackground(for: colorScheme),
                                        in: Capsule()
                                    )
                                    .foregroundStyle(selectedFrequencyFilter == freq ? SpendlyColors.primary : SpendlyColors.secondaryForeground(for: colorScheme))
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding(.horizontal, SpendlySpacing.md)
            .padding(.bottom, SpendlySpacing.sm)

            SPSearchBar(text: $searchText, placeholder: "Search PM schedules...")
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.bottom, SpendlySpacing.sm)

            // List
            ScrollView {
                LazyVStack(spacing: SpendlySpacing.sm) {
                    if filteredSchedules.isEmpty {
                        SPEmptyState(title: "No PM Schedules", subtitle: "Create a preventive maintenance schedule to get started.", icon: "calendar.badge.clock")
                    } else {
                        ForEach(filteredSchedules) { schedule in
                            pmScheduleCard(schedule)
                        }
                    }
                }
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.bottom, SpendlySpacing.xxl)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            createPMSheet
        }
    }

    private func pmScheduleCard(_ schedule: PMScheduleDisplay) -> some View {
        SPCard {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(schedule.title)
                            .font(SpendlyFont.bodySmall(weight: .semibold))
                            .foregroundStyle(SpendlyColors.primaryForeground(for: colorScheme))
                        Text("\(schedule.machineName) (\(schedule.machineID))")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }
                    Spacer()
                    if schedule.isOverdue {
                        SPBadge(text: "Overdue", style: .error)
                    } else {
                        SPBadge(text: schedule.frequency.rawValue, style: .info)
                    }
                }

                SPDivider()

                HStack {
                    Label {
                        Text("Next: \(formattedDate(schedule.nextDueAt))")
                    } icon: {
                        Image(systemName: "calendar")
                    }
                    Spacer()
                    if let tech = schedule.assignedTechnician {
                        Label(tech, systemImage: "person")
                    } else {
                        Label("Unassigned", systemImage: "person.badge.clock")
                            .foregroundStyle(SpendlyColors.warning)
                    }
                }
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                if !schedule.checklistItems.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "checklist")
                            .font(.system(size: 10))
                        Text("\(schedule.checklistItems.count) checklist items")
                            .font(SpendlyFont.caption())
                    }
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                }

                if let last = schedule.lastCompletedAt {
                    Text("Last completed: \(formattedDate(last))")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme).opacity(0.7))
                }
            }
        }
    }

    private var createPMSheet: some View {
        NavigationStack {
            Form {
                Section("Schedule Details") {
                    TextField("Title (e.g. Quarterly Oil Change)", text: $newTitle)
                    TextField("Machine Name", text: $newMachine)
                    Picker("Frequency", selection: $newFrequency) {
                        ForEach(PMFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    TextField("Assigned Technician (optional)", text: $newTechnician)
                }
            }
            .navigationTitle("New PM Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCreateSheet = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let schedule = PMScheduleDisplay(
                            title: newTitle.isEmpty ? "New PM Schedule" : newTitle,
                            machineName: newMachine.isEmpty ? "Unspecified Machine" : newMachine,
                            machineID: "MCH-NEW-\(schedules.count + 1)",
                            frequency: newFrequency,
                            assignedTechnician: newTechnician.isEmpty ? nil : newTechnician,
                            nextDueAt: Calendar.current.date(byAdding: .day, value: newFrequency.days, to: Date()) ?? Date(),
                            isActive: true
                        )
                        schedules.append(schedule)
                        showCreateSheet = false
                        newTitle = ""
                        newMachine = ""
                        newTechnician = ""
                    }
                    .disabled(newTitle.isEmpty)
                }
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        PMScheduleView()
    }
}
