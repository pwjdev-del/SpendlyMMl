import Foundation
import SpendlyCore

// MARK: - Display Models (Module-Local)

struct ExpenseDisplayItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var projectName: String
    var date: Date
    var status: ExpenseStatus
    var receiptURL: String?
    var rejectionReason: String?
    var reimbursedDate: Date?
}

// MARK: - Project Option

struct ProjectOption: Identifiable, Equatable {
    let id: UUID
    let name: String

    static func == (lhs: ProjectOption, rhs: ProjectOption) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data

enum ExpenseLoggingMockData {

    // MARK: Categories

    static let categories: [ExpenseCategory] = [
        .mileage,
        .partsAndMaterials,
        .mealsAndEntertainment,
        .travel
    ]

    static func categoryDisplayName(_ category: ExpenseCategory) -> String {
        switch category {
        case .mileage:               return "Mileage"
        case .partsAndMaterials:     return "Parts & Materials"
        case .mealsAndEntertainment: return "Meals & Entertainment"
        case .travel:                return "Travel"
        case .other:                 return "Other"
        }
    }

    static func categoryIcon(_ category: ExpenseCategory) -> String {
        switch category {
        case .mileage:               return "car.fill"
        case .partsAndMaterials:     return "wrench.and.screwdriver.fill"
        case .mealsAndEntertainment: return "fork.knife"
        case .travel:                return "airplane"
        case .other:                 return "ellipsis.circle.fill"
        }
    }

    // MARK: Projects

    static let projects: [ProjectOption] = [
        ProjectOption(
            id: UUID(uuidString: "E1111111-1111-1111-1111-111111111111") ?? UUID(),
            name: "Downtown Office Renovation"
        ),
        ProjectOption(
            id: UUID(uuidString: "E2222222-2222-2222-2222-222222222222") ?? UUID(),
            name: "Westside Highway Phase 2"
        ),
        ProjectOption(
            id: UUID(uuidString: "E3333333-3333-3333-3333-333333333333") ?? UUID(),
            name: "Corporate HQ Maintenance"
        ),
    ]

    // MARK: Sample Expenses (4 items)

    static let sampleExpenses: [ExpenseDisplayItem] = [
        ExpenseDisplayItem(
            id: UUID(uuidString: "F1111111-1111-1111-1111-111111111111") ?? UUID(),
            title: "Mileage Claim",
            amount: 45.50,
            category: .mileage,
            projectName: "Downtown Office Renovation",
            date: dateFrom(year: 2026, month: 3, day: 24),
            status: .pending,
            receiptURL: nil,
            rejectionReason: nil,
            reimbursedDate: nil
        ),
        ExpenseDisplayItem(
            id: UUID(uuidString: "F2222222-2222-2222-2222-222222222222") ?? UUID(),
            title: "HVAC Parts",
            amount: 312.00,
            category: .partsAndMaterials,
            projectName: "Westside Highway Phase 2",
            date: dateFrom(year: 2026, month: 3, day: 22),
            status: .approved,
            receiptURL: "receipt_hvac.jpg",
            rejectionReason: nil,
            reimbursedDate: nil
        ),
        ExpenseDisplayItem(
            id: UUID(uuidString: "F3333333-3333-3333-3333-333333333333") ?? UUID(),
            title: "Client Lunch",
            amount: 84.20,
            category: .mealsAndEntertainment,
            projectName: "Corporate HQ Maintenance",
            date: dateFrom(year: 2026, month: 3, day: 20),
            status: .approved,
            receiptURL: "receipt_lunch.jpg",
            rejectionReason: nil,
            reimbursedDate: nil
        ),
        ExpenseDisplayItem(
            id: UUID(uuidString: "F4444444-4444-4444-4444-444444444444") ?? UUID(),
            title: "Airport Shuttle",
            amount: 67.00,
            category: .travel,
            projectName: "Downtown Office Renovation",
            date: dateFrom(year: 2026, month: 3, day: 18),
            status: .rejected,
            receiptURL: nil,
            rejectionReason: "Missing receipt. Please resubmit with documentation.",
            reimbursedDate: nil
        ),
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
