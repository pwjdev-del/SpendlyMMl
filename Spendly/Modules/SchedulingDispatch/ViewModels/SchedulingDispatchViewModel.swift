import Foundation
import SwiftUI
import MapKit
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

    // MARK: - Ticket Scheduling Day Tab
    var schedulingDayIsToday: Bool = true

    // MARK: - Create / Edit Event State
    var showCreateEventSheet: Bool = false
    var showEditEventSheet: Bool = false
    var showDeleteConfirmation: Bool = false
    var editingEvent: ScheduleEvent? = nil
    var conflictWarningMessage: String? = nil
    var showConflictWarning: Bool = false

    // Create-event form fields
    var newEventTitle: String = ""
    var newEventCategory: EventCategory = .general
    var newEventStartHour: Int = 9
    var newEventStartMinute: Int = 0
    var newEventDuration: Double = 2.0
    var newEventTechnicianID: UUID? = nil
    var newEventPriority: TicketPriority = .medium
    var newEventCustomerName: String = ""
    var newEventAddress: String = ""
    var newEventNotes: String = ""

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
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) ?? currentDate
        guard let range = calendar.range(of: .day, in: .month, for: startOfMonth) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)

        var days: [CalendarDay] = []

        // Leading filler days from previous month
        let prevMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth) ?? startOfMonth
        let prevMonthRange = calendar.range(of: .day, in: .month, for: prevMonth) ?? (1..<31)
        let fillerCount = firstWeekday - 1
        for i in 0..<fillerCount {
            let day = prevMonthRange.upperBound - fillerCount + i
            let date = calendar.date(byAdding: .day, value: -(fillerCount - i), to: startOfMonth) ?? startOfMonth
            days.append(CalendarDay(dayNumber: day, date: date, isCurrentMonth: false))
        }

        // Current month days
        for day in range {
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) ?? startOfMonth
            days.append(CalendarDay(dayNumber: day, date: date, isCurrentMonth: true))
        }

        // Trailing filler days (fill to 35 or 42)
        let totalCells = days.count <= 35 ? 35 : 42
        let trailingCount = totalCells - days.count
        if trailingCount > 0 {
            for i in 1...trailingCount {
                let date = calendar.date(byAdding: .day, value: range.count + i - 1, to: startOfMonth) ?? startOfMonth
                days.append(CalendarDay(dayNumber: i, date: date, isCurrentMonth: false))
            }
        }

        return days
    }

    /// Returns the 7 days of the currently selected week.
    var weekDays: [CalendarDay] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)) ?? selectedDate
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) ?? startOfWeek
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
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        }
    }

    func navigateToPreviousMonth() {
        withAnimation(.easeInOut(duration: 0.25)) {
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        }
    }

    func navigateToNextWeek() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
        }
    }

    func navigateToPreviousWeek() {
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
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

    // MARK: - Bug 1 Fix: confirmDispatch updates event status + assigns technician
    func confirmDispatch() {
        guard let techID = selectedTechnicianID,
              let tech = selectedTechnician else {
            isDispatching = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.isDispatching = false
                self?.showDispatchSuccess = true
            }
            return
        }

        isDispatching = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            // Find the event being dispatched and update its status + technician
            if let eventID = self.navigationPath.compactMap({ dest -> UUID? in
                if case .dispatchConfirmation(_, let eID) = dest { return eID }
                return nil
            }).last, let idx = self.events.firstIndex(where: { $0.id == eventID }) {
                self.events[idx].status = .enRoute
                self.events[idx].technicianID = techID
                self.events[idx].technicianName = tech.name
            }
            self.isDispatching = false
            self.showDispatchSuccess = true
        }
    }

    // MARK: - Bug 6 Fix: Conflict detection called on create/edit
    /// Checks whether a proposed time range (in total minutes from midnight) overlaps with
    /// any existing event for the given technician on the given date.
    func detectConflict(for date: Date, startMinutes: Int, endMinutes: Int, techID: UUID, excludingEventID: UUID? = nil) -> Bool {
        let dayEvents = events.filter {
            calendar.isDate($0.date, inSameDayAs: date) &&
            $0.technicianID == techID &&
            $0.id != excludingEventID
        }
        for event in dayEvents {
            let eventStartMins = calendar.component(.hour, from: event.startTime) * 60 + calendar.component(.minute, from: event.startTime)
            let eventEndMins = calendar.component(.hour, from: event.endTime) * 60 + calendar.component(.minute, from: event.endTime)
            if startMinutes < eventEndMins && endMinutes > eventStartMins {
                return true
            }
        }
        return false
    }

    /// Returns a human-readable conflict message, or nil if no conflict.
    func checkConflictAndWarn(date: Date, startMinutes: Int, endMinutes: Int, techID: UUID, excludingEventID: UUID? = nil) -> String? {
        guard detectConflict(for: date, startMinutes: startMinutes, endMinutes: endMinutes, techID: techID, excludingEventID: excludingEventID) else {
            return nil
        }
        let techName = technicians.first(where: { $0.id == techID })?.name ?? "Selected technician"
        return "\(techName) already has an overlapping event during this time slot. Scheduling may cause a conflict."
    }

    // MARK: - Bug 2 Fix: Create Event
    func resetCreateEventForm() {
        newEventTitle = ""
        newEventCategory = .general
        newEventStartHour = 9
        newEventStartMinute = 0
        newEventDuration = 2.0
        newEventTechnicianID = nil
        newEventPriority = .medium
        newEventCustomerName = ""
        newEventAddress = ""
        newEventNotes = ""
        conflictWarningMessage = nil
    }

    func createEvent() {
        let dayStart = calendar.startOfDay(for: selectedDate)
        let start = calendar.date(bySettingHour: newEventStartHour, minute: newEventStartMinute, second: 0, of: dayStart) ?? dayStart
        let durationMinutes = Int(newEventDuration * 60)
        let end = calendar.date(byAdding: .minute, value: durationMinutes, to: start) ?? start
        let endHourMinutes = newEventStartHour * 60 + newEventStartMinute + durationMinutes

        let techID = newEventTechnicianID ?? technicians.first?.id ?? UUID()
        let techName = technicians.first(where: { $0.id == techID })?.name ?? "Unassigned"

        // Bug 6: Check for conflicts
        if let warning = checkConflictAndWarn(
            date: dayStart,
            startMinutes: newEventStartHour * 60 + newEventStartMinute,
            endMinutes: endHourMinutes,
            techID: techID
        ) {
            conflictWarningMessage = warning
            showConflictWarning = true
            // Still allow creation, just warn
        }

        let event = ScheduleEvent(
            id: UUID(),
            title: newEventTitle.isEmpty ? "New Event" : newEventTitle,
            category: newEventCategory,
            date: dayStart,
            startTime: start,
            endTime: end,
            technicianID: techID,
            technicianName: techName,
            customerName: newEventCustomerName.isEmpty ? nil : newEventCustomerName,
            address: newEventAddress.isEmpty ? nil : newEventAddress,
            priority: newEventPriority,
            status: .scheduled,
            estimatedHours: newEventDuration,
            ticketID: nil,
            notes: newEventNotes.isEmpty ? nil : newEventNotes
        )

        withAnimation(.easeInOut(duration: 0.25)) {
            events.append(event)
        }
        showCreateEventSheet = false
        resetCreateEventForm()
    }

    // MARK: - Bug 3 Fix: Edit Event
    func prepareEditEvent(_ event: ScheduleEvent) {
        editingEvent = event
        newEventTitle = event.title
        newEventCategory = event.category
        newEventStartHour = calendar.component(.hour, from: event.startTime)
        newEventStartMinute = calendar.component(.minute, from: event.startTime)
        newEventDuration = event.estimatedHours
        newEventTechnicianID = event.technicianID
        newEventPriority = event.priority
        newEventCustomerName = event.customerName ?? ""
        newEventAddress = event.address ?? ""
        newEventNotes = event.notes ?? ""
        showEditEventSheet = true
    }

    func saveEditedEvent() {
        guard let editing = editingEvent,
              let idx = events.firstIndex(where: { $0.id == editing.id }) else { return }

        let dayStart = calendar.startOfDay(for: events[idx].date)
        let start = calendar.date(bySettingHour: newEventStartHour, minute: newEventStartMinute, second: 0, of: dayStart) ?? dayStart
        let durationMinutes = Int(newEventDuration * 60)
        let end = calendar.date(byAdding: .minute, value: durationMinutes, to: start) ?? start
        let endHourMinutes = newEventStartHour * 60 + newEventStartMinute + durationMinutes

        let techID = newEventTechnicianID ?? events[idx].technicianID
        let techName = technicians.first(where: { $0.id == techID })?.name ?? events[idx].technicianName

        // Bug 6: Check for conflicts on edit
        if let warning = checkConflictAndWarn(
            date: dayStart,
            startMinutes: newEventStartHour * 60 + newEventStartMinute,
            endMinutes: endHourMinutes,
            techID: techID,
            excludingEventID: editing.id
        ) {
            conflictWarningMessage = warning
            showConflictWarning = true
        }

        withAnimation(.easeInOut(duration: 0.25)) {
            events[idx].title = newEventTitle.isEmpty ? "Untitled Event" : newEventTitle
            events[idx].category = newEventCategory
            events[idx].startTime = start
            events[idx].endTime = end
            events[idx].technicianID = techID
            events[idx].technicianName = techName
            events[idx].customerName = newEventCustomerName.isEmpty ? nil : newEventCustomerName
            events[idx].address = newEventAddress.isEmpty ? nil : newEventAddress
            events[idx].priority = newEventPriority
            events[idx].estimatedHours = newEventDuration
            events[idx].notes = newEventNotes.isEmpty ? nil : newEventNotes
        }

        showEditEventSheet = false
        selectedEvent = nil
        showEventDetail = false
        editingEvent = nil
        resetCreateEventForm()
    }

    // MARK: - Bug 3 Fix: Delete Event
    func deleteEvent(_ event: ScheduleEvent) {
        withAnimation(.easeInOut(duration: 0.25)) {
            events.removeAll { $0.id == event.id }
        }
        showEventDetail = false
        selectedEvent = nil
    }

    // MARK: - Bug 5 Fix: Create event from ticket scheduling
    func createEventFromScheduling() {
        guard let slotID = selectedTimeSlotID,
              let slot = timeSlots.first(where: { $0.id == slotID }) else { return }

        let isToday = schedulingDayIsToday
        let dayOffset = isToday ? 0 : 1
        let dayStart = calendar.startOfDay(for: calendar.date(byAdding: .day, value: dayOffset, to: Date()) ?? Date())

        // Parse slot start time (e.g. "09:00 AM")
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let slotStart = formatter.date(from: slot.startTime) ?? Date()
        let slotEnd = formatter.date(from: slot.endTime) ?? Date()
        let startHour = calendar.component(.hour, from: slotStart)
        let startMin = calendar.component(.minute, from: slotStart)
        let endHour = calendar.component(.hour, from: slotEnd)
        let endMin = calendar.component(.minute, from: slotEnd)

        let start = calendar.date(bySettingHour: startHour, minute: startMin, second: 0, of: dayStart) ?? dayStart
        let end = calendar.date(bySettingHour: endHour, minute: endMin, second: 0, of: dayStart) ?? dayStart
        let duration = end.timeIntervalSince(start) / 3600.0

        // Map ServicePriority to TicketPriority
        let ticketPriority: TicketPriority = {
            switch selectedPriority {
            case .low: return .low
            case .medium: return .medium
            case .high: return .high
            }
        }()

        // Use preferred technicians or first available
        let techID = preferredTechnicianIDs.first ?? technicians.first?.id ?? UUID()
        let techName = technicians.first(where: { $0.id == techID })?.name ?? "Unassigned"

        // Bug 6: Check for conflicts
        let startMins = startHour * 60 + startMin
        let endMins = endHour * 60 + endMin
        if let warning = checkConflictAndWarn(date: dayStart, startMinutes: startMins, endMinutes: endMins, techID: techID) {
            conflictWarningMessage = warning
            showConflictWarning = true
        }

        let event = ScheduleEvent(
            id: UUID(),
            title: "Scheduled Service Visit",
            category: .general,
            date: dayStart,
            startTime: start,
            endTime: end,
            technicianID: techID,
            technicianName: techName,
            customerName: nil,
            address: nil,
            priority: ticketPriority,
            status: .scheduled,
            estimatedHours: duration,
            ticketID: nil,
            notes: nil
        )

        withAnimation(.easeInOut(duration: 0.25)) {
            events.append(event)
        }
    }

    // MARK: - Bug 8 Fix: Dynamic ETA based on technician distance
    func estimatedETAText(for technician: Technician) -> String {
        // Base: ~6 min per mile, plus availability delay
        let baseTravelMinutes = Int(technician.distance * 6)
        let availabilityDelay: Int
        switch technician.availability {
        case .available:
            availabilityDelay = 0
        case .busy:
            availabilityDelay = 15
        case .offDuty:
            availabilityDelay = 45
        }
        let minETA = max(5, baseTravelMinutes + availabilityDelay)
        let maxETA = minETA + max(5, Int(Double(baseTravelMinutes) * 0.4))
        return "\(minETA) - \(maxETA) mins"
    }

    // MARK: - Bug 9 Fix: Open Apple Maps
    func openInMaps(address: String?) {
        guard let address, !address.isEmpty else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, _ in
            guard let placemark = placemarks?.first,
                  let location = placemark.location else { return }
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location.coordinate))
            mapItem.name = address
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        }
    }

    // MARK: - Bug 11 Fix: Drag-and-drop rescheduling
    func moveEvent(eventID: UUID, toDate newDate: Date) {
        guard let idx = events.firstIndex(where: { $0.id == eventID }) else { return }

        let oldDate = events[idx].date
        let newDayStart = calendar.startOfDay(for: newDate)

        // Compute offset in days
        let oldDayStart = calendar.startOfDay(for: oldDate)
        let dayDifference = calendar.dateComponents([.day], from: oldDayStart, to: newDayStart).day ?? 0

        guard dayDifference != 0 else { return }

        withAnimation(.easeInOut(duration: 0.25)) {
            events[idx].date = newDayStart
            events[idx].startTime = calendar.date(byAdding: .day, value: dayDifference, to: events[idx].startTime) ?? events[idx].startTime
            events[idx].endTime = calendar.date(byAdding: .day, value: dayDifference, to: events[idx].endTime) ?? events[idx].endTime
        }
    }
}

// MARK: - Calendar Day Model

struct CalendarDay: Identifiable, Hashable {
    let id = UUID()
    let dayNumber: Int
    let date: Date
    let isCurrentMonth: Bool
}
