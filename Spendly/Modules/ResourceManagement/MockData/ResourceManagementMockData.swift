import Foundation
import SpendlyCore

// MARK: - Technician Status

enum RMTechnicianStatus: String, CaseIterable {
    case onSite
    case travel
    case available
    case offDuty

    var label: String {
        switch self {
        case .onSite:   return "On-site"
        case .travel:   return "Travel"
        case .available: return "Available"
        case .offDuty:  return "Off Duty"
        }
    }

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .onSite:   return .success
        case .travel:   return .info
        case .available: return .neutral
        case .offDuty:  return .warning
        }
    }
}

// MARK: - Request Priority

enum RequestPriority: String, CaseIterable {
    case high
    case maintenance
    case inspection

    var label: String {
        switch self {
        case .high:        return "High Priority"
        case .maintenance: return "Maintenance"
        case .inspection:  return "Inspection"
        }
    }

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .high:        return .error
        case .maintenance: return .info
        case .inspection:  return .neutral
        }
    }
}

// MARK: - Unassigned Request

struct UnassignedRequest: Identifiable {
    let id: UUID
    let requestNumber: String
    let title: String
    let customerName: String
    let location: String
    let estimatedHours: Double
    let priority: RequestPriority
}

// MARK: - Schedule Block

struct ScheduleBlock: Identifiable {
    let id: UUID
    let label: String
    let startFraction: Double   // 0.0–1.0 within the day
    let widthFraction: Double   // portion of day
    let isTravel: Bool
}

// MARK: - Technician Display Item

struct TechnicianDisplayItem: Identifiable, Equatable {
    let id: UUID
    let name: String
    let specialty: String
    let status: RMTechnicianStatus
    let workloadHours: Double
    let capacityHours: Double
    let region: String
    let scheduleBlocks: [ScheduleBlock]

    // Comparison metrics
    let jobsCompleted: Int
    let averageRating: Double
    let onTimePercentage: Int
    let responseTimeMinutes: Int
    let revenueGenerated: Double
    let skillScores: RMSkillScores
    let recentPraise: String?
    let praiseClient: String?

    var workloadFraction: Double {
        guard capacityHours > 0 else { return 0 }
        return workloadHours / capacityHours
    }

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(first)\(last)".uppercased()
    }

    static func == (lhs: TechnicianDisplayItem, rhs: TechnicianDisplayItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Skill Scores

struct RMSkillScores {
    let quality: Int
    let speed: Int
    let communication: Int
    let safety: Int
    let punctuality: Int

    var values: [Int] { [quality, speed, communication, safety, punctuality] }
    static let labels = ["Quality", "Speed", "Communication", "Safety", "Punctuality"]
}

// MARK: - Prior Commitment

struct PriorCommitment: Identifiable {
    let id: UUID
    let jobTitle: String
    let customerName: String
    let technicianName: String
    let timeSlot: String
}

// MARK: - Saved Group

struct SavedTechGroup: Identifiable {
    let id: UUID
    let name: String
    let technicianCount: Int
    let memberIDs: [UUID]
    let updatedAt: Date
}

// MARK: - Regional Summary

struct RegionalSummary: Identifiable {
    let id: UUID
    let regionName: String
    let technicianCount: Int
    let activeJobs: Int
    let utilizationPercent: Int
}

// MARK: - Mock Data Provider

enum ResourceManagementMockData {

    // MARK: Technicians

    static let technicians: [TechnicianDisplayItem] = [
        TechnicianDisplayItem(
            id: UUID(uuidString: "E1111111-1111-1111-1111-111111111111")!,
            name: "Marcus Chen",
            specialty: "Expert HVAC Specialist",
            status: .onSite,
            workloadHours: 6.5,
            capacityHours: 8,
            region: "Downtown",
            scheduleBlocks: [
                ScheduleBlock(id: UUID(), label: "Job #301", startFraction: 0.0, widthFraction: 0.25, isTravel: false),
                ScheduleBlock(id: UUID(), label: "Job #305", startFraction: 0.25, widthFraction: 0.33, isTravel: false),
                ScheduleBlock(id: UUID(), label: "Travel", startFraction: 0.58, widthFraction: 0.15, isTravel: true),
                ScheduleBlock(id: UUID(), label: "Job #312", startFraction: 0.73, widthFraction: 0.20, isTravel: false),
            ],
            jobsCompleted: 142,
            averageRating: 4.8,
            onTimePercentage: 92,
            responseTimeMinutes: 24,
            revenueGenerated: 12400,
            skillScores: RMSkillScores(quality: 85, speed: 70, communication: 95, safety: 80, punctuality: 88),
            recentPraise: "Very professional and explained the repair process clearly.",
            praiseClient: "Acme Corp"
        ),
        TechnicianDisplayItem(
            id: UUID(uuidString: "E2222222-2222-2222-2222-222222222222")!,
            name: "Sarah Jenkins",
            specialty: "Electrical Maintenance",
            status: .travel,
            workloadHours: 4.0,
            capacityHours: 8,
            region: "East District",
            scheduleBlocks: [
                ScheduleBlock(id: UUID(), label: "Job #298", startFraction: 0.0, widthFraction: 0.50, isTravel: false),
                ScheduleBlock(id: UUID(), label: "Travel", startFraction: 0.50, widthFraction: 0.15, isTravel: true),
            ],
            jobsCompleted: 158,
            averageRating: 4.9,
            onTimePercentage: 96,
            responseTimeMinutes: 18,
            revenueGenerated: 14100,
            skillScores: RMSkillScores(quality: 92, speed: 95, communication: 85, safety: 90, punctuality: 98),
            recentPraise: "Incredibly fast and left the workspace cleaner than found!",
            praiseClient: "Zen Homes"
        ),
        TechnicianDisplayItem(
            id: UUID(uuidString: "E3333333-3333-3333-3333-333333333333")!,
            name: "David Miller",
            specialty: "Security Systems",
            status: .available,
            workloadHours: 0,
            capacityHours: 8,
            region: "West Port",
            scheduleBlocks: [],
            jobsCompleted: 98,
            averageRating: 4.6,
            onTimePercentage: 89,
            responseTimeMinutes: 30,
            revenueGenerated: 8750,
            skillScores: RMSkillScores(quality: 78, speed: 82, communication: 75, safety: 92, punctuality: 80),
            recentPraise: "Great attention to detail with the CCTV installation.",
            praiseClient: "Stellar Logistics"
        ),
        TechnicianDisplayItem(
            id: UUID(uuidString: "E4444444-4444-4444-4444-444444444444")!,
            name: "Alex Lopez",
            specialty: "Plumbing Systems",
            status: .onSite,
            workloadHours: 7.0,
            capacityHours: 8,
            region: "North Wing",
            scheduleBlocks: [
                ScheduleBlock(id: UUID(), label: "Job #310", startFraction: 0.0, widthFraction: 0.40, isTravel: false),
                ScheduleBlock(id: UUID(), label: "Travel", startFraction: 0.40, widthFraction: 0.10, isTravel: true),
                ScheduleBlock(id: UUID(), label: "Job #315", startFraction: 0.50, widthFraction: 0.375, isTravel: false),
            ],
            jobsCompleted: 175,
            averageRating: 4.7,
            onTimePercentage: 94,
            responseTimeMinutes: 22,
            revenueGenerated: 15200,
            skillScores: RMSkillScores(quality: 88, speed: 90, communication: 80, safety: 85, punctuality: 92),
            recentPraise: "Fixed the pipe leak in record time!",
            praiseClient: "Global Industries"
        ),
        TechnicianDisplayItem(
            id: UUID(uuidString: "E5555555-5555-5555-5555-555555555555")!,
            name: "Kate Barrett",
            specialty: "Fire Safety",
            status: .offDuty,
            workloadHours: 0,
            capacityHours: 8,
            region: "East District",
            scheduleBlocks: [],
            jobsCompleted: 112,
            averageRating: 4.5,
            onTimePercentage: 91,
            responseTimeMinutes: 26,
            revenueGenerated: 9800,
            skillScores: RMSkillScores(quality: 82, speed: 76, communication: 88, safety: 95, punctuality: 86),
            recentPraise: nil,
            praiseClient: nil
        ),
    ]

    // MARK: Unassigned Requests

    static let unassignedRequests: [UnassignedRequest] = [
        UnassignedRequest(
            id: UUID(uuidString: "F1111111-1111-1111-1111-111111111111")!,
            requestNumber: "#REQ-402",
            title: "HVAC Emergency Repair",
            customerName: "Global Industries - North Wing",
            location: "Downtown",
            estimatedHours: 4,
            priority: .high
        ),
        UnassignedRequest(
            id: UUID(uuidString: "F2222222-2222-2222-2222-222222222222")!,
            requestNumber: "#REQ-405",
            title: "Annual System Audit",
            customerName: "TechCorp Solutions",
            location: "East District",
            estimatedHours: 2,
            priority: .maintenance
        ),
        UnassignedRequest(
            id: UUID(uuidString: "F3333333-3333-3333-3333-333333333333")!,
            requestNumber: "#REQ-409",
            title: "Fire Safety Check",
            customerName: "Stellar Logistics",
            location: "West Port",
            estimatedHours: 1,
            priority: .inspection
        ),
    ]

    // MARK: Prior Commitments

    static let priorCommitments: [PriorCommitment] = [
        PriorCommitment(
            id: UUID(uuidString: "G1111111-1111-1111-1111-111111111111")!,
            jobTitle: "Network Rack Install",
            customerName: "Stellar Logistics",
            technicianName: "Marcus Chen",
            timeSlot: "08:00 - 10:30"
        ),
        PriorCommitment(
            id: UUID(uuidString: "G2222222-2222-2222-2222-222222222222")!,
            jobTitle: "CCTV Calibration",
            customerName: "Private Client #82",
            technicianName: "Sarah Jenkins",
            timeSlot: "13:00 - 15:00"
        ),
    ]

    // MARK: Saved Groups

    static let savedGroups: [SavedTechGroup] = [
        SavedTechGroup(
            id: UUID(uuidString: "H1111111-1111-1111-1111-111111111111")!,
            name: "Plumbing Leads",
            technicianCount: 12,
            memberIDs: [
                UUID(uuidString: "E3333333-3333-3333-3333-333333333333")!,
                UUID(uuidString: "E2222222-2222-2222-2222-222222222222")!,
            ],
            updatedAt: dateFrom(year: 2026, month: 3, day: 24)
        ),
        SavedTechGroup(
            id: UUID(uuidString: "H2222222-2222-2222-2222-222222222222")!,
            name: "Top Tier North",
            technicianCount: 8,
            memberIDs: [
                UUID(uuidString: "E1111111-1111-1111-1111-111111111111")!,
                UUID(uuidString: "E4444444-4444-4444-4444-444444444444")!,
            ],
            updatedAt: dateFrom(year: 2026, month: 3, day: 20)
        ),
        SavedTechGroup(
            id: UUID(uuidString: "H3333333-3333-3333-3333-333333333333")!,
            name: "HVAC Specialists",
            technicianCount: 15,
            memberIDs: [
                UUID(uuidString: "E1111111-1111-1111-1111-111111111111")!,
            ],
            updatedAt: dateFrom(year: 2026, month: 3, day: 18)
        ),
        SavedTechGroup(
            id: UUID(uuidString: "H4444444-4444-4444-4444-444444444444")!,
            name: "Weekend Emergency",
            technicianCount: 5,
            memberIDs: [
                UUID(uuidString: "E2222222-2222-2222-2222-222222222222")!,
                UUID(uuidString: "E3333333-3333-3333-3333-333333333333")!,
            ],
            updatedAt: dateFrom(year: 2026, month: 3, day: 15)
        ),
    ]

    // MARK: Regional Summaries

    static let regionalSummaries: [RegionalSummary] = [
        RegionalSummary(id: UUID(), regionName: "Downtown", technicianCount: 8, activeJobs: 14, utilizationPercent: 88),
        RegionalSummary(id: UUID(), regionName: "East District", technicianCount: 6, activeJobs: 9, utilizationPercent: 75),
        RegionalSummary(id: UUID(), regionName: "West Port", technicianCount: 4, activeJobs: 5, utilizationPercent: 63),
        RegionalSummary(id: UUID(), regionName: "North Wing", technicianCount: 5, activeJobs: 11, utilizationPercent: 92),
    ]

    // MARK: Helpers

    private static func dateFrom(year: Int, month: Int, day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }
}
