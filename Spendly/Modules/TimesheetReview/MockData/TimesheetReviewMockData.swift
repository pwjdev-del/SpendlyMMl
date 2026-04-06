import Foundation
import SpendlyCore

// MARK: - Display Models (Module-Local)

enum TimesheetEntryStatus: String, CaseIterable {
    case draft
    case submitted
    case approved
    case rejected
}

struct TimesheetDayEntry: Identifiable {
    let id: UUID
    var date: Date
    var projectName: String
    var clientName: String
    var regularHours: Double
    var overtimeHours: Double
    var breakMinutes: Int
    var notes: String?
    var status: TimesheetEntryStatus
    var isSelected: Bool
    var rejectionReason: String?
}

struct TimesheetComment: Identifiable {
    let id: UUID
    let author: String
    let text: String
    let date: Date
    let isManager: Bool
}

struct TeamTimesheetSummary: Identifiable {
    let id: UUID
    let technicianName: String
    let role: String
    let totalHours: Double
    let overtimeHours: Double
    var status: TimesheetEntryStatus
    let weekLabel: String
    var isSelected: Bool
}

// MARK: - Mock Data

enum TimesheetReviewMockData {

    // MARK: Week Range

    static let weekStartDate: Date = dateFrom(year: 2026, month: 3, day: 23)
    static let weekEndDate: Date = dateFrom(year: 2026, month: 3, day: 29)

    static var weekLabel: String { "Mar 23 - Mar 29, 2026" }

    // MARK: Daily Entries (Mon-Sun)

    static let weekEntries: [TimesheetDayEntry] = [
        TimesheetDayEntry(
            id: UUID(uuidString: "A1111111-1111-1111-1111-111111111111") ?? UUID(),
            date: dateFrom(year: 2026, month: 3, day: 23),
            projectName: "Line Maintenance - A102",
            clientName: "Industrial Systems Inc.",
            regularHours: 8.0,
            overtimeHours: 0.0,
            breakMinutes: 30,
            notes: "Completed preventive maintenance on conveyor belt system.",
            status: .submitted,
            isSelected: false,
            rejectionReason: nil
        ),
        TimesheetDayEntry(
            id: UUID(uuidString: "A2222222-2222-2222-2222-222222222222") ?? UUID(),
            date: dateFrom(year: 2026, month: 3, day: 24),
            projectName: "Solar Array Calibration",
            clientName: "Green Energy Corp",
            regularHours: 8.0,
            overtimeHours: 1.5,
            breakMinutes: 45,
            notes: "Calibrated panels in east wing. Extended for urgent inverter issue.",
            status: .submitted,
            isSelected: false,
            rejectionReason: nil
        ),
        TimesheetDayEntry(
            id: UUID(uuidString: "A3333333-3333-3333-3333-333333333333") ?? UUID(),
            date: dateFrom(year: 2026, month: 3, day: 25),
            projectName: "Line Maintenance - A102",
            clientName: "Industrial Systems Inc.",
            regularHours: 8.0,
            overtimeHours: 0.0,
            breakMinutes: 30,
            notes: nil,
            status: .approved,
            isSelected: false,
            rejectionReason: nil
        ),
        TimesheetDayEntry(
            id: UUID(uuidString: "A4444444-4444-4444-4444-444444444444") ?? UUID(),
            date: dateFrom(year: 2026, month: 3, day: 26),
            projectName: "Quarterly Inspection",
            clientName: "Logistics Hub 4",
            regularHours: 7.5,
            overtimeHours: 0.0,
            breakMinutes: 60,
            notes: "Full facility walk-through and documentation.",
            status: .submitted,
            isSelected: false,
            rejectionReason: nil
        ),
        TimesheetDayEntry(
            id: UUID(uuidString: "A5555555-5555-5555-5555-555555555555") ?? UUID(),
            date: dateFrom(year: 2026, month: 3, day: 27),
            projectName: "Solar Array Calibration",
            clientName: "Green Energy Corp",
            regularHours: 8.0,
            overtimeHours: 1.0,
            breakMinutes: 30,
            notes: "Final calibration adjustments and quality checks.",
            status: .rejected,
            isSelected: false,
            rejectionReason: "Overtime not pre-approved. Please provide justification."
        ),
        TimesheetDayEntry(
            id: UUID(uuidString: "A6666666-6666-6666-6666-666666666666") ?? UUID(),
            date: dateFrom(year: 2026, month: 3, day: 28),
            projectName: "Line Maintenance - A102",
            clientName: "Industrial Systems Inc.",
            regularHours: 4.0,
            overtimeHours: 0.0,
            breakMinutes: 0,
            notes: "Saturday half-day for emergency repair.",
            status: .draft,
            isSelected: false,
            rejectionReason: nil
        ),
        TimesheetDayEntry(
            id: UUID(uuidString: "A7777777-7777-7777-7777-777777777777") ?? UUID(),
            date: dateFrom(year: 2026, month: 3, day: 29),
            projectName: "—",
            clientName: "—",
            regularHours: 0.0,
            overtimeHours: 0.0,
            breakMinutes: 0,
            notes: nil,
            status: .draft,
            isSelected: false,
            rejectionReason: nil
        ),
    ]

    // MARK: Comments

    static let sampleComments: [TimesheetComment] = [
        TimesheetComment(
            id: UUID(uuidString: "C1111111-1111-1111-1111-111111111111") ?? UUID(),
            author: "Janet Rodriguez",
            text: "Please add more detail for Friday's overtime hours.",
            date: dateFrom(year: 2026, month: 3, day: 28),
            isManager: true
        ),
        TimesheetComment(
            id: UUID(uuidString: "C2222222-2222-2222-2222-222222222222") ?? UUID(),
            author: "David Miller",
            text: "Updated Friday entry with inverter emergency details.",
            date: dateFrom(year: 2026, month: 3, day: 28),
            isManager: false
        ),
    ]

    // MARK: Team Summaries (Manager View)

    static let teamTimesheets: [TeamTimesheetSummary] = [
        TeamTimesheetSummary(
            id: UUID(uuidString: "T1111111-1111-1111-1111-111111111111") ?? UUID(),
            technicianName: "David Miller",
            role: "Lead Field Tech",
            totalHours: 40.5,
            overtimeHours: 0.5,
            status: .submitted,
            weekLabel: "Mar 23 - Mar 29",
            isSelected: false
        ),
        TeamTimesheetSummary(
            id: UUID(uuidString: "T2222222-2222-2222-2222-222222222222") ?? UUID(),
            technicianName: "Sarah Chen",
            role: "Automation Specialist",
            totalHours: 44.0,
            overtimeHours: 4.0,
            status: .submitted,
            weekLabel: "Mar 23 - Mar 29",
            isSelected: false
        ),
        TeamTimesheetSummary(
            id: UUID(uuidString: "T3333333-3333-3333-3333-333333333333") ?? UUID(),
            technicianName: "Marcus Johnson",
            role: "HVAC Technician",
            totalHours: 38.0,
            overtimeHours: 0.0,
            status: .submitted,
            weekLabel: "Mar 23 - Mar 29",
            isSelected: false
        ),
    ]

    // MARK: Projects

    static let projects: [String] = [
        "Line Maintenance - A102",
        "Solar Array Calibration",
        "Quarterly Inspection",
        "Emergency Repair Pool",
    ]

    // MARK: Helpers

    static func dateFrom(year: Int, month: Int, day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }

    static func dayOfWeekShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    static func dayOfMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    static func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
