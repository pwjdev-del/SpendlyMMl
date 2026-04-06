import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Job Status

enum JobExecutionStatus: String {
    case completed = "Completed"
    case inProgress = "In Progress"
    case upcoming = "Upcoming"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .completed:  return .neutral
        case .inProgress: return .custom(SpendlyColors.primary)
        case .upcoming:   return .warning
        }
    }

    var timelineStatus: SPTimelineStatus {
        switch self {
        case .completed:  return .completed
        case .inProgress: return .active
        case .upcoming:   return .upcoming
        }
    }

    var dotColor: Color {
        switch self {
        case .completed:  return SpendlyColors.success
        case .inProgress: return SpendlyColors.primary
        case .upcoming:   return SpendlyColors.secondary.opacity(0.4)
        }
    }
}

// MARK: - Job Type

enum JobType: String {
    case hvacService = "HVAC Service"
    case fiberInstallation = "Fiber Installation"
    case maintenance = "Maintenance"
    case inspection = "Inspection"
    case repair = "Repair"
    case teamSync = "Team Sync"
}

// MARK: - Checklist Item

struct ChecklistItem: Identifiable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

// MARK: - Material Item

struct MaterialItem: Identifiable {
    let id: UUID
    var name: String
    var quantity: Int
    var unitCost: Double

    init(id: UUID = UUID(), name: String, quantity: Int = 1, unitCost: Double = 0.0) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unitCost = unitCost
    }

    var totalCost: Double { Double(quantity) * unitCost }
}

// MARK: - Photo Capture Item

struct PhotoCaptureItem: Identifiable {
    let id: UUID
    var caption: String
    var isBefore: Bool
    var timestamp: Date
    var imageData: Data?
    var placeholderIcon: String

    init(id: UUID = UUID(), caption: String = "", isBefore: Bool = true, timestamp: Date = Date(), imageData: Data? = nil, placeholderIcon: String = "photo.on.rectangle.angled") {
        self.id = id
        self.caption = caption
        self.isBefore = isBefore
        self.timestamp = timestamp
        self.imageData = imageData
        self.placeholderIcon = placeholderIcon
    }
}

// MARK: - Voice Note

struct VoiceNote: Identifiable {
    let id: UUID
    var duration: TimeInterval
    var fileURL: URL?
    var createdAt: Date

    init(id: UUID = UUID(), duration: TimeInterval = 0, fileURL: URL? = nil, createdAt: Date = Date()) {
        self.id = id
        self.duration = duration
        self.fileURL = fileURL
        self.createdAt = createdAt
    }

    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Client Info

struct ClientInfo {
    var name: String
    var address: String
    var phone: String
    var notes: String
}

// MARK: - Job Display Model

struct JobDisplayModel: Identifiable {
    let id: UUID
    var jobNumber: String
    var title: String
    var jobType: JobType
    var status: JobExecutionStatus
    var location: String
    var scheduledStart: Date
    var scheduledEnd: Date
    var client: ClientInfo
    var checklist: [ChecklistItem]
    var materials: [MaterialItem]
    var photos: [PhotoCaptureItem]
    var voiceNotes: [VoiceNote]
    var estimatedDurationSeconds: TimeInterval
    var elapsedSeconds: TimeInterval
    var isPaused: Bool
    var latitude: Double
    var longitude: Double

    var scheduledTimeRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: scheduledStart)) - \(formatter.string(from: scheduledEnd))"
    }

    var startTimeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: scheduledStart)
    }

    var completedTaskCount: Int {
        checklist.filter(\.isCompleted).count
    }

    var totalTaskCount: Int {
        checklist.count
    }

    /// Empty placeholder used as a fallback when no job is selected.
    static let placeholder = JobDisplayModel(
        id: UUID(),
        jobNumber: "--",
        title: "No Job",
        jobType: .maintenance,
        status: .upcoming,
        location: "--",
        scheduledStart: Date(),
        scheduledEnd: Date(),
        client: ClientInfo(name: "--", address: "--", phone: "", notes: ""),
        checklist: [],
        materials: [],
        photos: [],
        voiceNotes: [],
        estimatedDurationSeconds: 0,
        elapsedSeconds: 0,
        isPaused: false,
        latitude: 0,
        longitude: 0
    )
}

// MARK: - Week Day Model

struct WeekDay: Identifiable {
    let id = UUID()
    var dayAbbreviation: String
    var dayNumber: Int
    var date: Date
    var isSelected: Bool
}

// MARK: - Job Sync Display Status
// Renamed from `SyncStatus` to avoid shadowing `SpendlyCore.SyncStatus`.

enum JobSyncDisplayStatus {
    case synced
    case syncing
    case pendingSync(count: Int)
    case offline

    var label: String {
        switch self {
        case .synced:               return "Synced"
        case .syncing:              return "Syncing..."
        case .pendingSync(let c):   return "\(c) items pending sync"
        case .offline:              return "Offline Mode"
        }
    }
}

// MARK: - Mock Data

enum JobExecutionMockData {

    static func todayAt(hour: Int, minute: Int = 0) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    static let jobs: [JobDisplayModel] = [
        JobDisplayModel(
            id: UUID(),
            jobNumber: "#4427",
            title: "Morning Sync & Inventory",
            jobType: .teamSync,
            status: .completed,
            location: "Main Warehouse, Downtown",
            scheduledStart: todayAt(hour: 8, minute: 0),
            scheduledEnd: todayAt(hour: 9, minute: 0),
            client: ClientInfo(
                name: "Internal",
                address: "Main Warehouse, Downtown",
                phone: "",
                notes: "Daily team meeting and inventory check."
            ),
            checklist: [
                ChecklistItem(title: "Review daily assignments", isCompleted: true),
                ChecklistItem(title: "Check inventory levels", isCompleted: true),
                ChecklistItem(title: "Load truck with parts", isCompleted: true)
            ],
            materials: [],
            photos: [],
            voiceNotes: [],
            estimatedDurationSeconds: 3600,
            elapsedSeconds: 3120,
            isPaused: false,
            latitude: 40.7128,
            longitude: -74.0060
        ),

        JobDisplayModel(
            id: UUID(),
            jobNumber: "#4429",
            title: "HVAC System Repair - Smith Residence",
            jobType: .hvacService,
            status: .inProgress,
            location: "124 Oakwood Circle, River Heights",
            scheduledStart: todayAt(hour: 9, minute: 30),
            scheduledEnd: todayAt(hour: 11, minute: 30),
            client: ClientInfo(
                name: "Alex Thompson",
                address: "452 Oakwood Ave, Springfield",
                phone: "+1 (555) 234-5678",
                notes: "Unit is in the basement. Access through the side garage door."
            ),
            checklist: [
                ChecklistItem(title: "Initial diagnostic check", isCompleted: true),
                ChecklistItem(title: "Replace filter cartridge", isCompleted: false),
                ChecklistItem(title: "Test thermostat connection", isCompleted: false),
                ChecklistItem(title: "Customer sign-off on inspection", isCompleted: false)
            ],
            materials: [
                MaterialItem(name: "HVAC Filter Cartridge", quantity: 1, unitCost: 45.00),
                MaterialItem(name: "Copper Tubing 1/4\"", quantity: 2, unitCost: 12.50)
            ],
            photos: [],
            voiceNotes: [],
            estimatedDurationSeconds: 7200,
            elapsedSeconds: 8096,
            isPaused: false,
            latitude: 40.7282,
            longitude: -73.7949
        ),

        JobDisplayModel(
            id: UUID(),
            jobNumber: "#4431",
            title: "Fiber Installation - Metro Office",
            jobType: .fiberInstallation,
            status: .upcoming,
            location: "800 Business Ave, Suite 402",
            scheduledStart: todayAt(hour: 13, minute: 0),
            scheduledEnd: todayAt(hour: 15, minute: 0),
            client: ClientInfo(
                name: "Sarah Mitchell",
                address: "800 Business Ave, Suite 402",
                phone: "+1 (555) 876-5432",
                notes: "Building security requires visitor badge. Check in at lobby."
            ),
            checklist: [
                ChecklistItem(title: "Survey cable routing path", isCompleted: false),
                ChecklistItem(title: "Install fiber conduit", isCompleted: false),
                ChecklistItem(title: "Terminate fiber ends", isCompleted: false),
                ChecklistItem(title: "Test connection speed", isCompleted: false),
                ChecklistItem(title: "Client walkthrough and sign-off", isCompleted: false)
            ],
            materials: [
                MaterialItem(name: "Fiber Optic Cable (50m)", quantity: 1, unitCost: 120.00),
                MaterialItem(name: "SC Connectors", quantity: 4, unitCost: 8.00),
                MaterialItem(name: "Cable Clips", quantity: 20, unitCost: 0.50)
            ],
            photos: [],
            voiceNotes: [],
            estimatedDurationSeconds: 7200,
            elapsedSeconds: 0,
            isPaused: false,
            latitude: 40.7580,
            longitude: -73.9855
        ),

        JobDisplayModel(
            id: UUID(),
            jobNumber: "#4433",
            title: "Maintenance Check - North Warehouse",
            jobType: .maintenance,
            status: .upcoming,
            location: "Terminal 2, Cargo Road",
            scheduledStart: todayAt(hour: 16, minute: 0),
            scheduledEnd: todayAt(hour: 17, minute: 30),
            client: ClientInfo(
                name: "David Chen",
                address: "Terminal 2, Cargo Road",
                phone: "+1 (555) 345-6789",
                notes: "Safety gear required. Hard hat and steel-toe boots mandatory."
            ),
            checklist: [
                ChecklistItem(title: "Inspect HVAC units", isCompleted: false),
                ChecklistItem(title: "Check fire suppression system", isCompleted: false),
                ChecklistItem(title: "Test emergency lighting", isCompleted: false),
                ChecklistItem(title: "Document findings", isCompleted: false)
            ],
            materials: [],
            photos: [],
            voiceNotes: [],
            estimatedDurationSeconds: 5400,
            elapsedSeconds: 0,
            isPaused: false,
            latitude: 40.6895,
            longitude: -74.1745
        )
    ]

    static func generateWeekDays() -> [WeekDay] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        // Sunday = 1, so offset to get start of the week (Sunday)
        let startOfWeek = calendar.date(byAdding: .day, value: -(weekday - 1), to: today) ?? today

        let dayAbbreviations = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) ?? startOfWeek
            let dayNumber = calendar.component(.day, from: date)
            let isToday = calendar.isDateInToday(date)
            return WeekDay(
                dayAbbreviation: dayAbbreviations[offset],
                dayNumber: dayNumber,
                date: date,
                isSelected: isToday
            )
        }
    }
}
