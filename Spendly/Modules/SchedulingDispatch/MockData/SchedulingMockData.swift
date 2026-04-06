import Foundation
import SwiftUI
import UniformTypeIdentifiers
import SpendlyCore

// MARK: - Schedule Event

struct ScheduleEvent: Identifiable, Codable, Transferable {
    let id: UUID
    var title: String
    var category: EventCategory
    var date: Date
    var startTime: Date
    var endTime: Date
    var technicianID: UUID
    var technicianName: String
    var customerName: String?
    var address: String?
    var latitude: Double = 39.7817
    var longitude: Double = -89.6501
    var priority: TicketPriority
    var status: TripStatus
    var estimatedHours: Double
    var ticketID: String?
    var notes: String?

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .plainText)
    }

    var durationText: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: startTime, to: endTime) ?? "\(estimatedHours)h"
    }

    var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}

// MARK: - Event Category

enum EventCategory: String, CaseIterable, Codable {
    case hvac = "HVAC"
    case electrical = "Electrical"
    case plumbing = "Plumbing"
    case general = "General"
    case training = "Training"

    var color: Color {
        switch self {
        case .hvac:       return SpendlyColors.info
        case .electrical: return SpendlyColors.accent
        case .plumbing:   return SpendlyColors.success
        case .general:    return SpendlyColors.secondary
        case .training:   return SpendlyColors.primary
        }
    }

    var lightBackground: Color {
        color.opacity(0.12)
    }

    var icon: String {
        switch self {
        case .hvac:       return "fan"
        case .electrical: return "bolt.fill"
        case .plumbing:   return "wrench.and.screwdriver.fill"
        case .general:    return "gearshape.fill"
        case .training:   return "book.fill"
        }
    }
}

// MARK: - Technician

struct Technician: Identifiable {
    let id: UUID
    let name: String
    let initials: String
    let specialty: String
    let skills: [String]
    let rating: Double
    let reviewCount: Int
    let distance: Double
    let availability: TechAvailability
    let hoursUsed: Double
    let hoursTotal: Double
    let avatarURL: String?

    var utilizationPercent: Double {
        guard hoursTotal > 0 else { return 0 }
        return hoursUsed / hoursTotal
    }

    var utilizationText: String {
        "\(Int(hoursUsed))/\(Int(hoursTotal))h"
    }
}

// MARK: - Technician Availability

enum TechAvailability {
    case available
    case busy(until: String)
    case offDuty

    var label: String {
        switch self {
        case .available:        return "Available Now"
        case .busy(let until):  return "Busy until \(until)"
        case .offDuty:          return "Off Duty"
        }
    }

    var color: Color {
        switch self {
        case .available: return SpendlyColors.success
        case .busy:      return SpendlyColors.warning
        case .offDuty:   return SpendlyColors.secondary
        }
    }

    var dotColor: Color { color }
}

// MARK: - Time Slot

struct TimeSlot: Identifiable {
    let id: UUID
    let startTime: String
    let endTime: String
    let label: String?
    let isRecommended: Bool

    var displayText: String {
        "\(startTime) - \(endTime)"
    }
}

// MARK: - Unscheduled Job

struct UnscheduledJob: Identifiable {
    let id: UUID
    let name: String
    let category: EventCategory
    let type: String
    let estimatedHours: Double
    let priority: TicketPriority
}

// MARK: - Mock Data

enum SchedulingMockData {

    // MARK: Calendar helpers

    private static let calendar = Calendar.current

    private static func date(daysFromNow offset: Int, hour: Int, minute: Int = 0) -> Date {
        let today = calendar.startOfDay(for: Date())
        let day = calendar.date(byAdding: .day, value: offset, to: today) ?? today
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }

    private static func dayStart(daysFromNow offset: Int) -> Date {
        let today = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .day, value: offset, to: today) ?? today
    }

    // MARK: Technicians

    static let technicians: [Technician] = [
        Technician(
            id: UUID(),
            name: "Alex Rivera",
            initials: "AR",
            specialty: "Electrical Specialist",
            skills: ["Electrical Specialist", "HVAC Expert"],
            rating: 4.8,
            reviewCount: 124,
            distance: 2.4,
            availability: .available,
            hoursUsed: 28,
            hoursTotal: 40,
            avatarURL: nil
        ),
        Technician(
            id: UUID(),
            name: "Jordan Smith",
            initials: "JS",
            specialty: "HVAC Specialist",
            skills: ["HVAC Specialist", "Smart Home"],
            rating: 5.0,
            reviewCount: 87,
            distance: 5.1,
            availability: .busy(until: "2:00 PM"),
            hoursUsed: 40,
            hoursTotal: 40,
            avatarURL: nil
        ),
        Technician(
            id: UUID(),
            name: "Marcus Chen",
            initials: "MC",
            specialty: "Plumbing",
            skills: ["Plumbing", "Emergency Repair"],
            rating: 4.2,
            reviewCount: 63,
            distance: 7.8,
            availability: .available,
            hoursUsed: 12,
            hoursTotal: 40,
            avatarURL: nil
        ),
        Technician(
            id: UUID(),
            name: "Sarah Chen",
            initials: "SC",
            specialty: "Electrical",
            skills: ["Electrical", "Industrial"],
            rating: 4.8,
            reviewCount: 98,
            distance: 3.5,
            availability: .busy(until: "4:30 PM"),
            hoursUsed: 32,
            hoursTotal: 40,
            avatarURL: nil
        ),
        Technician(
            id: UUID(),
            name: "Elena Park",
            initials: "EP",
            specialty: "Plumbing",
            skills: ["Plumbing", "HVAC"],
            rating: 4.6,
            reviewCount: 45,
            distance: 4.2,
            availability: .available,
            hoursUsed: 18,
            hoursTotal: 40,
            avatarURL: nil
        ),
    ]

    // MARK: Scheduled Events (spread across this week)

    static let events: [ScheduleEvent] = [
        // Today
        ScheduleEvent(
            id: UUID(),
            title: "Acme Office HVAC Maintenance",
            category: .hvac,
            date: dayStart(daysFromNow: 0),
            startTime: date(daysFromNow: 0, hour: 8, minute: 30),
            endTime: date(daysFromNow: 0, hour: 11, minute: 0),
            technicianID: technicians[0].id,
            technicianName: "Alex Rivera",
            customerName: "Acme Corp",
            address: "123 Maple Avenue, Springfield, IL",
            latitude: 39.7817,
            longitude: -89.6501,
            priority: .high,
            status: .scheduled,
            estimatedHours: 2.5,
            ticketID: "#44092",
            notes: "Annual HVAC maintenance check"
        ),
        ScheduleEvent(
            id: UUID(),
            title: "Residential Rewiring",
            category: .electrical,
            date: dayStart(daysFromNow: 0),
            startTime: date(daysFromNow: 0, hour: 13, minute: 0),
            endTime: date(daysFromNow: 0, hour: 17, minute: 0),
            technicianID: technicians[0].id,
            technicianName: "Alex Rivera",
            customerName: "Henderson Residence",
            address: "456 Oak Street, Springfield, IL",
            latitude: 39.7730,
            longitude: -89.6440,
            priority: .medium,
            status: .scheduled,
            estimatedHours: 4.0,
            ticketID: "#44095",
            notes: nil
        ),
        ScheduleEvent(
            id: UUID(),
            title: "Pipe Leak Emergency",
            category: .plumbing,
            date: dayStart(daysFromNow: 0),
            startTime: date(daysFromNow: 0, hour: 9, minute: 0),
            endTime: date(daysFromNow: 0, hour: 11, minute: 0),
            technicianID: technicians[2].id,
            technicianName: "Marcus Chen",
            customerName: "City Hall",
            address: "1 Main St, Springfield, IL",
            latitude: 39.7990,
            longitude: -89.6440,
            priority: .critical,
            status: .enRoute,
            estimatedHours: 2.0,
            ticketID: "#44098",
            notes: "Urgent - water damage risk"
        ),
        // Tomorrow
        ScheduleEvent(
            id: UUID(),
            title: "Smart Home Installation",
            category: .electrical,
            date: dayStart(daysFromNow: 1),
            startTime: date(daysFromNow: 1, hour: 10, minute: 0),
            endTime: date(daysFromNow: 1, hour: 14, minute: 0),
            technicianID: technicians[1].id,
            technicianName: "Jordan Smith",
            customerName: "Wilson Residence",
            address: "789 Pine Ave, Springfield, IL",
            latitude: 39.7650,
            longitude: -89.6580,
            priority: .medium,
            status: .scheduled,
            estimatedHours: 4.0,
            ticketID: "#44100",
            notes: nil
        ),
        ScheduleEvent(
            id: UUID(),
            title: "HVAC Filter Replacement",
            category: .hvac,
            date: dayStart(daysFromNow: 1),
            startTime: date(daysFromNow: 1, hour: 15, minute: 0),
            endTime: date(daysFromNow: 1, hour: 16, minute: 30),
            technicianID: technicians[3].id,
            technicianName: "Sarah Chen",
            customerName: "TechStart Inc",
            address: "200 Business Pkwy, Springfield, IL",
            latitude: 39.7870,
            longitude: -89.6370,
            priority: .low,
            status: .scheduled,
            estimatedHours: 1.5,
            ticketID: "#44102",
            notes: nil
        ),
        // Day after tomorrow
        ScheduleEvent(
            id: UUID(),
            title: "Plumbing Inspection",
            category: .plumbing,
            date: dayStart(daysFromNow: 2),
            startTime: date(daysFromNow: 2, hour: 8, minute: 0),
            endTime: date(daysFromNow: 2, hour: 10, minute: 0),
            technicianID: technicians[4].id,
            technicianName: "Elena Park",
            customerName: "Riverside Apartments",
            address: "300 River Rd, Springfield, IL",
            latitude: 39.7560,
            longitude: -89.6690,
            priority: .medium,
            status: .scheduled,
            estimatedHours: 2.0,
            ticketID: "#44105",
            notes: nil
        ),
        // +3 days
        ScheduleEvent(
            id: UUID(),
            title: "Electrical Panel Upgrade",
            category: .electrical,
            date: dayStart(daysFromNow: 3),
            startTime: date(daysFromNow: 3, hour: 9, minute: 0),
            endTime: date(daysFromNow: 3, hour: 15, minute: 0),
            technicianID: technicians[0].id,
            technicianName: "Alex Rivera",
            customerName: "Metro Mall",
            address: "500 Commerce Dr, Springfield, IL",
            latitude: 39.8010,
            longitude: -89.6260,
            priority: .high,
            status: .scheduled,
            estimatedHours: 6.0,
            ticketID: "#44108",
            notes: "Requires 2-person team"
        ),
        // +4 days
        ScheduleEvent(
            id: UUID(),
            title: "Service Team Training",
            category: .training,
            date: dayStart(daysFromNow: 4),
            startTime: date(daysFromNow: 4, hour: 9, minute: 0),
            endTime: date(daysFromNow: 4, hour: 12, minute: 0),
            technicianID: technicians[1].id,
            technicianName: "Jordan Smith",
            customerName: nil,
            address: "HQ Training Room",
            latitude: 39.7900,
            longitude: -89.6500,
            priority: .low,
            status: .scheduled,
            estimatedHours: 3.0,
            ticketID: nil,
            notes: "Quarterly safety training"
        ),
        // +5 days
        ScheduleEvent(
            id: UUID(),
            title: "HVAC System Overhaul",
            category: .hvac,
            date: dayStart(daysFromNow: 5),
            startTime: date(daysFromNow: 5, hour: 7, minute: 30),
            endTime: date(daysFromNow: 5, hour: 16, minute: 0),
            technicianID: technicians[1].id,
            technicianName: "Jordan Smith",
            customerName: "Grand Hotel",
            address: "1000 Grand Blvd, Springfield, IL",
            latitude: 39.8100,
            longitude: -89.6350,
            priority: .high,
            status: .scheduled,
            estimatedHours: 8.5,
            ticketID: "#44112",
            notes: "Full system replacement"
        ),
        ScheduleEvent(
            id: UUID(),
            title: "Water Heater Install",
            category: .plumbing,
            date: dayStart(daysFromNow: 5),
            startTime: date(daysFromNow: 5, hour: 13, minute: 0),
            endTime: date(daysFromNow: 5, hour: 16, minute: 0),
            technicianID: technicians[2].id,
            technicianName: "Marcus Chen",
            customerName: "Park Residence",
            address: "88 Lake View Dr, Springfield, IL",
            latitude: 39.7710,
            longitude: -89.6610,
            priority: .medium,
            status: .scheduled,
            estimatedHours: 3.0,
            ticketID: "#44115",
            notes: nil
        ),
    ]

    // MARK: Unscheduled Jobs

    static let unscheduledJobs: [UnscheduledJob] = [
        UnscheduledJob(id: UUID(), name: "Acme Office HVAC", category: .hvac, type: "Repair", estimatedHours: 4.5, priority: .high),
        UnscheduledJob(id: UUID(), name: "Residential Rewiring", category: .electrical, type: "Electrical", estimatedHours: 8, priority: .medium),
        UnscheduledJob(id: UUID(), name: "Pipe Leak Repair", category: .plumbing, type: "Plumbing", estimatedHours: 2, priority: .critical),
        UnscheduledJob(id: UUID(), name: "City Hall Inspection", category: .general, type: "Compliance", estimatedHours: 3, priority: .low),
    ]

    // MARK: Time Slots

    static let timeSlots: [TimeSlot] = [
        TimeSlot(id: UUID(), startTime: "09:00 AM", endTime: "11:00 AM", label: "Morning Window", isRecommended: false),
        TimeSlot(id: UUID(), startTime: "02:00 PM", endTime: "04:00 PM", label: "Recommended: Matches Alex's window", isRecommended: true),
        TimeSlot(id: UUID(), startTime: "04:30 PM", endTime: "06:30 PM", label: "Standard Window", isRecommended: false),
    ]
}
