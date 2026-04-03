import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Calendar View Mode

enum CalendarViewMode: String, CaseIterable {
    case month = "Monthly"
    case week = "Weekly"

    var icon: String {
        switch self {
        case .month: return "calendar"
        case .week:  return "calendar.day.timeline.left"
        }
    }
}

// MARK: - Scheduling Navigation Destination

enum SchedulingDestination: Hashable {
    case assignTechnician(eventID: UUID?)
    case dispatchConfirmation(technicianID: UUID, eventID: UUID?)
    case ticketScheduling(ticketID: String?)
}

// MARK: - Skill Filter

enum TechSkillFilter: String, CaseIterable {
    case all = "All"
    case electrical = "Electrical"
    case hvac = "HVAC"
    case plumbing = "Plumbing"
}

// MARK: - Service Priority

enum ServicePriority: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

// MARK: - ViewModel

@Observable
final class SchedulingDispatchViewModel {

    // MARK: - Data
    var events: [ScheduleEvent] = SchedulingMockData.events
    var technicians: [Technician] = SchedulingMockData.technicians
    var unscheduledJobs: [UnscheduledJob] = SchedulingMockData.unscheduledJobs
    var timeSlots: [TimeSlot] = SchedulingMockData.timeSlots

    // MARK: - Calendar State
    var viewMode: CalendarViewMode = .month
    var currentDate: Date = Date()
    var selectedDate: Date = Date()

    // MARK: - Assign Technician State
    var searchText: String = ""
    var selectedSkillFilter: TechSkillFilter = .all
    var selectedTechnicianID: UUID? = nil

    // MARK: - Dispatch Confirmation State
    var dispatchNote: String = ""
    var isDispatching: Bool = false
    var showDispatchSuccess: Bool = false

    // MARK: - Ticket Scheduling State
    var selectedTimeSlotID: UUID? = nil
    var selectedPriority: ServicePriority = .low
    var selectedScheduleDate: Date = Date()
    var preferredTechnicianIDs: Set<UUID> = []

    // MARK: - Navigation
    var navigationPath: [SchedulingDestination] = []
    var showEventDetail: Bool = false
    var selectedEvent: ScheduleEvent? = nil

    // MARK: - Calendar Computed Properties

    private var calendar: Calendar { Calendar.current }

    var currentMonthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }

    var weekDayHeaders: [String] {
        ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    }

    /// Returns all days to display in the monthly calendar grid (including filler days from prev/next month).
    var monthDays: [CalendarDay] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)

        var days: [CalendarDay] = []

        // Leading filler days from previous month
        let prevMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
        let prevMonthRange = calendar.range(of: .day, in: .month, for: prevMonth)!
        let fillerCount = firstWeekday - 1
        for i in 0..<fillerCount {
            let day = prevMonthRange.upperBound - fillerCount + i
            let date = calendar.date(byAdding: .day, value: -(fillerCount - i), to: startOfMonth)!
            days.append(CalendarDay(dayNumber: day, date: date, isCurrentMonth: false))
        }

        // Current month days
        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            days.append(CalendarDay(dayNumber: day, date: date, isCurrentMonth: true))
        }

        // Trailing filler days (fill to 35 or 42)
        let totalCells = days.count <= 35 ? 35 : 42
        let trailingCount = totalCells - days.count
        for i in 1...max(trailingCount, 1) {
            if days.count >= totalCells { break }
            let date = calendar.date(byAdding: .day, value: range.count + i - 1, to: startOfMonth)!
            days.append(CalendarDay(dayNumber: i, date: date, isCurrentMonth: false))
        }

        return days
    }

    /// Returns the 7 days of the currently selected week.
    var weekDays: [CalendarDay] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek)!
            let day = calendar.component(.day, from: date)
            return CalendarDay(dayNumber: day, date: date, isCurrentMonth: true)
        }
    }

    /// Events for a specific date.
    func events(for date: Date) -> [ScheduleEvent] {
        events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    /// Events for the selected date.
    var selectedDateEvents: [ScheduleEvent] {
        events(for: selectedDate)
    }

    var isToday: Bool {
        calendar.isDateInToday(selectedDate)
    }

    func isDateToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    func isDateSelected(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: selectedDate)
    }

    // MARK: - Metrics

    var estimatedHoursTotal: Double {
        events.reduce(0) { $0 + $1.estimatedHours }
    }

    var availableHoursTotal: Double {
        technicians.reduce(0) { $0 + $1.hoursTotal }
    }

    var efficiencyPercent: Int {
        guard availableHoursTotal > 0 else { return 0 }
        let used = technicians.reduce(0.0) { $0 + $1.hoursUsed }
        return Int(used / availableHoursTotal * 100)
    }

    var unscheduledCount: Int {
        unscheduledJobs.count
    }

    // MARK: - Assign Technician Computed

    var filteredTechnicians: [Technician] {
        var result = technicians

        // Skill filter
        if selectedSkillFilter != .all {
            let filterValue = selectedSkillFilter.rawValue
            result = result.filter { tech in
                tech.skills.contains(where: { $0.localizedCaseInsensitiveContains(filterValue) }) ||
                tech.specialty.localizedCaseInsensitiveContains(filterValue)
            }
        }

        // Search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { tech in
                tech.name.lowercased().contains(query) ||
                tech.specialty.lowercased().contains(query) ||
                tech.skills.contains(where: { $0.lowercased().contains(query) })
            }
        }

        // Sort: available first, then by distance
        result.sort { lhs, rhs in
            let lhsAvail = if case .available = lhs.availability { true } else { false }
            let rhsAvail = if case .available = rhs.availability { true } else { false }
            if lhsAvail != rhsAvail { return lhsAvail }
            return lhs.distance < rhs.distance
        }

        return result
    }

    var selectedTechnician: Technician? {
        technicians.first(where: { $0.id == selectedTechnicianID })
    }

    // MARK: - Actions

    func navigateToNextMonth() {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        }
    }

    func navigateToPreviousMonth() {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        }
    }

    func navigateToNextWeek() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate)!
        }
    }

    func navigateToPreviousWeek() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate)!
        }
    }

    func selectDate(_ date: Date) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedDate = date
        }
    }

    func selectEvent(_ event: ScheduleEvent) {
        selectedEvent = event
        showEventDetail = true
    }

    func selectTechnician(_ tech: Technician) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedTechnicianID == tech.id {
                selectedTechnicianID = nil
            } else {
                selectedTechnicianID = tech.id
            }
        }
    }

    func togglePreferredTechnician(_ techID: UUID) {
        if preferredTechnicianIDs.contains(techID) {
            preferredTechnicianIDs.remove(techID)
        } else {
            preferredTechnicianIDs.insert(techID)
        }
    }

    func selectTimeSlot(_ slotID: UUID) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedTimeSlotID = slotID
        }
    }

    func confirmDispatch() {
        isDispatching = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isDispatching = false
            self?.showDispatchSuccess = true
        }
    }

    func detectConflict(for date: Date, startHour: Int, endHour: Int, techID: UUID) -> Bool {
        let dayEvents = events.filter { calendar.isDate($0.date, inSameDayAs: date) && $0.technicianID == techID }
        for event in dayEvents {
            let eventStart = calendar.component(.hour, from: event.startTime)
            let eventEnd = calendar.component(.hour, from: event.endTime)
            if startHour < eventEnd && endHour > eventStart {
                return true
            }
        }
        return false
    }
}

// MARK: - Calendar Day Model

struct CalendarDay: Identifiable, Hashable {
    let id = UUID()
    let dayNumber: Int
    let date: Date
    let isCurrentMonth: Bool
}
