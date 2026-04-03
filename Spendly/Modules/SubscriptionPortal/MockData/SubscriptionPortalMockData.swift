import Foundation
import SwiftUI

// MARK: - Subscription Plan

struct SubscriptionPlan: Identifiable {
    let id: UUID
    var name: String
    var monthlyPrice: Double
    var annualPrice: Double
    var features: [String]
    var isPopular: Bool
    var maxTechnicians: Int
    var storageGB: Int

    init(
        id: UUID = UUID(),
        name: String,
        monthlyPrice: Double,
        annualPrice: Double,
        features: [String] = [],
        isPopular: Bool = false,
        maxTechnicians: Int = 5,
        storageGB: Int = 10
    ) {
        self.id = id
        self.name = name
        self.monthlyPrice = monthlyPrice
        self.annualPrice = annualPrice
        self.features = features
        self.isPopular = isPopular
        self.maxTechnicians = maxTechnicians
        self.storageGB = storageGB
    }
}

// MARK: - Billing Module

struct BillingModule: Identifiable {
    let id: UUID
    var name: String
    var monthlyCost: Double
    var isActive: Bool
    var icon: String

    init(
        id: UUID = UUID(),
        name: String,
        monthlyCost: Double,
        isActive: Bool = true,
        icon: String = "checkmark"
    ) {
        self.id = id
        self.name = name
        self.monthlyCost = monthlyCost
        self.isActive = isActive
        self.icon = icon
    }
}

// MARK: - Invoice

struct Invoice: Identifiable {
    let id: UUID
    var title: String
    var date: Date
    var amount: Double
    var status: SubscriptionInvoiceStatus
    var invoiceNumber: String

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        amount: Double,
        status: SubscriptionInvoiceStatus = .paid,
        invoiceNumber: String = ""
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.amount = amount
        self.status = status
        self.invoiceNumber = invoiceNumber
    }
}

enum SubscriptionInvoiceStatus: String {
    case paid = "Paid"
    case pending = "Pending"
    case overdue = "Overdue"
    case refunded = "Refunded"
}

// MARK: - Transaction

struct Transaction: Identifiable {
    let id: UUID
    var description: String
    var date: Date
    var amount: Double
    var type: TransactionType

    init(
        id: UUID = UUID(),
        description: String,
        date: Date,
        amount: Double,
        type: TransactionType = .charge
    ) {
        self.id = id
        self.description = description
        self.date = date
        self.amount = amount
        self.type = type
    }
}

enum TransactionType: String {
    case charge = "Charge"
    case refund = "Refund"
    case credit = "Credit"
    case adjustment = "Adjustment"
}

// MARK: - Billing Contact

struct BillingContact: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var phone: String

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        phone: String
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
    }
}

// MARK: - Payment Method

struct SubscriptionPaymentMethod: Identifiable {
    let id: UUID
    var cardBrand: String
    var lastFourDigits: String
    var expiryMonth: Int
    var expiryYear: Int
    var isDefault: Bool

    init(
        id: UUID = UUID(),
        cardBrand: String,
        lastFourDigits: String,
        expiryMonth: Int,
        expiryYear: Int,
        isDefault: Bool = true
    ) {
        self.id = id
        self.cardBrand = cardBrand
        self.lastFourDigits = lastFourDigits
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
        self.isDefault = isDefault
    }

    var maskedDisplay: String {
        "\u{2022}\u{2022}\u{2022}\u{2022} \(lastFourDigits)"
    }

    var expiryDisplay: String {
        String(format: "%02d/%d", expiryMonth, expiryYear)
    }
}

// MARK: - Mock Data

enum SubscriptionPortalMockData {

    // MARK: - Current Plan

    static let currentPlanName = "Enterprise Custom Tier"
    static let currentMonthlyTotal: Double = 384.00
    static let paymentStatus = "Paid in Advance"
    static let billingCycle = "Monthly"

    static let nextBillingDate: Date = {
        var components = DateComponents()
        components.year = 2026
        components.month = 5
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }()

    // MARK: - Payment Method

    static let paymentMethod = SubscriptionPaymentMethod(
        cardBrand: "Visa",
        lastFourDigits: "8829",
        expiryMonth: 12,
        expiryYear: 2028
    )

    // MARK: - Billing Contact

    static let billingContact = BillingContact(
        name: "Alexander Vance",
        email: "finance@atelier-studios.com",
        phone: "+1 (555) 012-9934"
    )

    // MARK: - Billing Modules (Feature-Level Breakdown)

    static let billingModules: [BillingModule] = [
        BillingModule(name: "Base License", monthlyCost: 199.00, icon: "shield.checkered"),
        BillingModule(name: "AI Diagnostic Engine", monthlyCost: 45.00, icon: "brain.head.profile"),
        BillingModule(name: "10 Technician Seats", monthlyCost: 80.00, icon: "person.3"),
        BillingModule(name: "Offline Data Sync", monthlyCost: 25.00, icon: "arrow.triangle.2.circlepath"),
        BillingModule(name: "White-label Export", monthlyCost: 35.00, icon: "paintbrush"),
    ]

    // MARK: - Invoices

    static let invoices: [Invoice] = {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return [
            Invoice(
                title: "March 2026 Invoice",
                date: formatter.date(from: "2026-03-01") ?? Date(),
                amount: 384.00,
                status: .paid,
                invoiceNumber: "INV-2026-0003"
            ),
            Invoice(
                title: "February 2026 Invoice",
                date: formatter.date(from: "2026-02-01") ?? Date(),
                amount: 384.00,
                status: .paid,
                invoiceNumber: "INV-2026-0002"
            ),
            Invoice(
                title: "January 2026 Invoice",
                date: formatter.date(from: "2026-01-01") ?? Date(),
                amount: 384.00,
                status: .paid,
                invoiceNumber: "INV-2026-0001"
            ),
            Invoice(
                title: "December 2025 Invoice",
                date: formatter.date(from: "2025-12-01") ?? Date(),
                amount: 384.00,
                status: .paid,
                invoiceNumber: "INV-2025-0012"
            ),
            Invoice(
                title: "November 2025 Invoice",
                date: formatter.date(from: "2025-11-01") ?? Date(),
                amount: 359.00,
                status: .paid,
                invoiceNumber: "INV-2025-0011"
            ),
            Invoice(
                title: "October 2025 Invoice",
                date: formatter.date(from: "2025-10-01") ?? Date(),
                amount: 359.00,
                status: .paid,
                invoiceNumber: "INV-2025-0010"
            ),
        ]
    }()

    // MARK: - Transactions

    static let transactions: [Transaction] = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        return [
            Transaction(
                description: "Monthly subscription payment",
                date: formatter.date(from: "2026-03-01") ?? Date(),
                amount: 384.00,
                type: .charge
            ),
            Transaction(
                description: "Monthly subscription payment",
                date: formatter.date(from: "2026-02-01") ?? Date(),
                amount: 384.00,
                type: .charge
            ),
            Transaction(
                description: "Module upgrade credit applied",
                date: formatter.date(from: "2026-01-15") ?? Date(),
                amount: -25.00,
                type: .credit
            ),
            Transaction(
                description: "Monthly subscription payment",
                date: formatter.date(from: "2026-01-01") ?? Date(),
                amount: 384.00,
                type: .charge
            ),
            Transaction(
                description: "Monthly subscription payment",
                date: formatter.date(from: "2025-12-01") ?? Date(),
                amount: 384.00,
                type: .charge
            ),
            Transaction(
                description: "Plan adjustment refund",
                date: formatter.date(from: "2025-11-20") ?? Date(),
                amount: -50.00,
                type: .refund
            ),
            Transaction(
                description: "Monthly subscription payment",
                date: formatter.date(from: "2025-11-01") ?? Date(),
                amount: 359.00,
                type: .charge
            ),
        ]
    }()

    // MARK: - Subscription Plans (Plan Comparison)

    static let availablePlans: [SubscriptionPlan] = [
        SubscriptionPlan(
            name: "Starter",
            monthlyPrice: 49.00,
            annualPrice: 470.00,
            features: [
                "Up to 3 Technicians",
                "Basic Scheduling",
                "Invoice Generation",
                "5 GB Storage",
                "Email Support",
            ],
            maxTechnicians: 3,
            storageGB: 5
        ),
        SubscriptionPlan(
            name: "Professional",
            monthlyPrice: 149.00,
            annualPrice: 1430.00,
            features: [
                "Up to 10 Technicians",
                "Advanced Scheduling & Dispatch",
                "Invoice & Estimate Builder",
                "Offline Data Sync",
                "25 GB Storage",
                "Priority Support",
                "Basic Analytics",
            ],
            isPopular: true,
            maxTechnicians: 10,
            storageGB: 25
        ),
        SubscriptionPlan(
            name: "Enterprise",
            monthlyPrice: 299.00,
            annualPrice: 2870.00,
            features: [
                "Unlimited Technicians",
                "AI Diagnostic Engine",
                "White-label Branding",
                "Advanced Analytics & Reporting",
                "Custom Integrations",
                "100 GB Storage",
                "Dedicated Account Manager",
                "SLA Guarantee",
            ],
            maxTechnicians: 999,
            storageGB: 100
        ),
    ]

    // MARK: - Annual Savings

    static let annualSavingsAmount: Double = 1200.00
    static let annualSavingsMessage = "You saved $1,200 annually by switching to the Enterprise Tier."
}
