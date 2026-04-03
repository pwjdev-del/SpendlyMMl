import Foundation
import SpendlyCore

// MARK: - Display Models (Module-Local)

struct FinancialMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let trend: String
    let trendDirection: SPTrendDirection
}

struct BankConnection: Identifiable {
    let id = UUID()
    let bankName: String
    let lastFour: String
    let isConnected: Bool
}

enum FinancialExpenseStatus: String {
    case pendingReview
    case approved
    case rejected
    case processing

    var label: String {
        switch self {
        case .pendingReview: return "PENDING REVIEW"
        case .approved:      return "APPROVED"
        case .rejected:      return "REJECTED"
        case .processing:    return "PROCESSING"
        }
    }

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .pendingReview: return .warning
        case .approved:      return .success
        case .rejected:      return .error
        case .processing:    return .info
        }
    }

    var dotColor: String {
        switch self {
        case .pendingReview: return "amber"
        case .approved:      return "emerald"
        case .rejected:      return "red"
        case .processing:    return "blue"
        }
    }
}

struct ExpenseStatusItem: Identifiable {
    let id = UUID()
    let title: String
    let requestedDate: String
    let amount: Double
    let status: FinancialExpenseStatus
}

struct PayoutItem: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let amount: Double
    let icon: String
}

// MARK: - Mock Data

enum FinancialHubMockData {

    // MARK: Metrics

    static let metrics: [FinancialMetric] = [
        FinancialMetric(
            title: "Pending Reimbursements",
            value: "$450.00",
            trend: "+12% vs last month",
            trendDirection: .up
        ),
        FinancialMetric(
            title: "Approved Amount",
            value: "$1,200.00",
            trend: "-5% vs last month",
            trendDirection: .down
        ),
    ]

    // MARK: Bank Connection

    static let bankConnection = BankConnection(
        bankName: "Bank of America",
        lastFour: "4567",
        isConnected: true
    )

    // MARK: Expense Status Items

    static let expenseStatusItems: [ExpenseStatusItem] = [
        ExpenseStatusItem(
            title: "Office Supplies",
            requestedDate: "Requested 2 days ago",
            amount: 124.50,
            status: .pendingReview
        ),
        ExpenseStatusItem(
            title: "Client Dinner",
            requestedDate: "Approved today",
            amount: 85.20,
            status: .approved
        ),
    ]

    // MARK: Recent Payouts

    static let recentPayouts: [PayoutItem] = [
        PayoutItem(
            title: "Travel Reimbursement",
            date: dateFrom(year: 2023, month: 10, day: 24),
            amount: 850.00,
            icon: "wallet.pass"
        ),
        PayoutItem(
            title: "Software Subscription",
            date: dateFrom(year: 2023, month: 10, day: 20),
            amount: 45.99,
            icon: "bag"
        ),
        PayoutItem(
            title: "Hardware Refresh",
            date: dateFrom(year: 2023, month: 10, day: 15),
            amount: 2100.00,
            icon: "doc.plaintext"
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

    static let payoutDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f
    }()
}
