import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Invoice Tab

enum InvoiceTab: String, CaseIterable, Identifiable {
    case draft = "Draft"
    case sent = "Sent"
    case paid = "Paid"
    case overdue = "Overdue"

    var id: String { rawValue }
}

// MARK: - Invoice Display Model

struct InvoiceDisplayModel: Identifiable {
    let id: UUID
    var invoiceNumber: String
    var customerName: String
    var customerAddress: String
    var jobTitle: String
    var jobNumber: String
    var status: InvoiceStatus
    var subtotal: Double
    var laborCost: Double
    var partsCost: Double
    var taxRate: Double
    var taxAmount: Double
    var total: Double
    var dueDate: Date?
    var paidAt: Date?
    var completedDate: Date
    var createdAt: Date
    var notes: String?
    var lineItems: [InvoiceLineItem]
    var paymentHistory: [PaymentRecord]

    var customerInitials: String {
        let parts = customerName.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(first)\(last)".uppercased()
    }

    var costBreakdown: String {
        if laborCost > 0 && partsCost > 0 {
            return "Labor: \(formatCurrency(laborCost)) \u{2022} Parts: \(formatCurrency(partsCost))"
        } else if laborCost > 0 {
            return "Labor: \(formatCurrency(laborCost))"
        } else {
            return "Fixed Rate Service"
        }
    }

    var statusBadgeStyle: SPBadgeStyle {
        switch status {
        case .draft:     return .neutral
        case .sent:      return .info
        case .paid:      return .success
        case .overdue:   return .error
        case .cancelled: return .warning
        }
    }

    var statusLabel: String {
        switch status {
        case .draft:     return "Draft"
        case .sent:      return "Sent"
        case .paid:      return "Paid"
        case .overdue:   return "Overdue"
        case .cancelled: return "Cancelled"
        }
    }

    var isOverdue: Bool {
        guard let due = dueDate, status != .paid && status != .cancelled else { return false }
        return due < Date()
    }

    var daysUntilDue: Int? {
        guard let due = dueDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: due).day
    }

    var amountPaid: Double {
        paymentHistory.reduce(0) { $0 + $1.amount }
    }

    var balanceDue: Double {
        total - amountPaid
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Invoice Line Item

struct InvoiceLineItem: Identifiable {
    let id: UUID
    var itemDescription: String
    var quantity: Double
    var unitPrice: Double

    var lineTotal: Double {
        quantity * unitPrice
    }
}

// MARK: - Payment Record

struct PaymentRecord: Identifiable {
    let id: UUID
    var amount: Double
    var method: PaymentMethod
    var date: Date
    var reference: String?
}

// MARK: - Payment Method

enum PaymentMethod: String, CaseIterable {
    case cash = "Cash"
    case check = "Check"
    case creditCard = "Credit Card"
    case bankTransfer = "Bank Transfer"
    case online = "Online Payment"

    var icon: String {
        switch self {
        case .cash:         return "banknote"
        case .check:        return "doc.text"
        case .creditCard:   return "creditcard"
        case .bankTransfer: return "building.columns"
        case .online:       return "globe"
        }
    }
}

// MARK: - Ready To Invoice Job

struct ReadyToInvoiceJob: Identifiable {
    let id: UUID
    var jobTitle: String
    var jobNumber: String
    var customerName: String
    var completedDate: Date
    var amount: Double
    var laborCost: Double
    var partsCost: Double
    var iconName: String

    var costBreakdown: String {
        if laborCost > 0 && partsCost > 0 {
            return "Labor: \(formatCurrency(laborCost)) \u{2022} Parts: \(formatCurrency(partsCost))"
        } else if laborCost > 0 {
            return "Labor: \(formatCurrency(laborCost))"
        } else {
            return "Fixed Rate Service"
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Billing Summary

struct BillingSummary {
    var totalOutstanding: Double
    var outstandingCount: Int
    var outstandingTrend: String
    var totalOverdue: Double
    var overdueCount: Int
    var overdueTrend: String
    var totalPaidMTD: Double
    var paidCount: Int
    var paidTrend: String
}

// MARK: - White Label Config

struct InvoiceBrandingConfig {
    var companyName: String
    var companyLogo: String?
    var companyAddress: String
    var companyPhone: String
    var companyEmail: String
    var accentColor: Color
    var showPoweredBy: Bool
    var paymentTerms: String
    var footerNote: String
}

// MARK: - Mock Data

enum InvoicingBillingMockData {

    // MARK: Billing Summary

    static let summary = BillingSummary(
        totalOutstanding: 12450.00,
        outstandingCount: 14,
        outstandingTrend: "+5.2%",
        totalOverdue: 3200.00,
        overdueCount: 4,
        overdueTrend: "+1.5%",
        totalPaidMTD: 8900.00,
        paidCount: 28,
        paidTrend: "+12.8%"
    )

    // MARK: White Label Branding

    static let branding = InvoiceBrandingConfig(
        companyName: "ProServ Solutions",
        companyLogo: nil,
        companyAddress: "1200 Commerce Blvd, Suite 400\nAustin, TX 78701",
        companyPhone: "(512) 555-0199",
        companyEmail: "billing@proservsolutions.com",
        accentColor: SpendlyColors.primary,
        showPoweredBy: false,
        paymentTerms: "Net 30",
        footerNote: "Thank you for your business. Payment is due within 30 days of the invoice date."
    )

    // MARK: Ready to Invoice Jobs

    static let readyToInvoiceJobs: [ReadyToInvoiceJob] = [
        ReadyToInvoiceJob(
            id: UUID(),
            jobTitle: "AC Repair - Johnson Res.",
            jobNumber: "8821",
            customerName: "Mark Johnson",
            completedDate: makeDate(month: 6, day: 12),
            amount: 450.00,
            laborCost: 300.00,
            partsCost: 150.00,
            iconName: "fan.fill"
        ),
        ReadyToInvoiceJob(
            id: UUID(),
            jobTitle: "Kitchen Remodel Plumbing",
            jobNumber: "8824",
            customerName: "Linda Chen",
            completedDate: makeDate(month: 6, day: 14),
            amount: 1200.00,
            laborCost: 800.00,
            partsCost: 400.00,
            iconName: "wrench.and.screwdriver.fill"
        ),
        ReadyToInvoiceJob(
            id: UUID(),
            jobTitle: "Monthly Maintenance",
            jobNumber: "8829",
            customerName: "TechCorp LLC",
            completedDate: makeDate(month: 6, day: 15),
            amount: 175.00,
            laborCost: 175.00,
            partsCost: 0,
            iconName: "gearshape.fill"
        )
    ]

    // MARK: Invoices

    static let invoices: [InvoiceDisplayModel] = [
        // Draft invoices
        InvoiceDisplayModel(
            id: UUID(),
            invoiceNumber: "INV-2026-041",
            customerName: "Sarah Mitchell",
            customerAddress: "412 Cedar Ln",
            jobTitle: "Electrical Panel Upgrade",
            jobNumber: "8801",
            status: .draft,
            subtotal: 2100.00,
            laborCost: 1400.00,
            partsCost: 700.00,
            taxRate: 0.08,
            taxAmount: 168.00,
            total: 2268.00,
            dueDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
            paidAt: nil,
            completedDate: makeDate(month: 6, day: 8),
            createdAt: makeDate(month: 6, day: 10),
            notes: "Panel upgrade from 100A to 200A. Includes all permits and inspection.",
            lineItems: [
                InvoiceLineItem(id: UUID(), itemDescription: "200A Main Panel", quantity: 1, unitPrice: 450.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Copper Wiring (100ft)", quantity: 2, unitPrice: 125.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Labor - Licensed Electrician", quantity: 8, unitPrice: 175.00)
            ],
            paymentHistory: []
        ),
        InvoiceDisplayModel(
            id: UUID(),
            invoiceNumber: "INV-2026-042",
            customerName: "David Park",
            customerAddress: "88 Willow Dr",
            jobTitle: "HVAC Duct Cleaning",
            jobNumber: "8805",
            status: .draft,
            subtotal: 380.00,
            laborCost: 280.00,
            partsCost: 100.00,
            taxRate: 0.08,
            taxAmount: 30.40,
            total: 410.40,
            dueDate: Calendar.current.date(byAdding: .day, value: 21, to: Date()),
            paidAt: nil,
            completedDate: makeDate(month: 6, day: 9),
            createdAt: makeDate(month: 6, day: 11),
            notes: nil,
            lineItems: [
                InvoiceLineItem(id: UUID(), itemDescription: "Duct Cleaning Service", quantity: 1, unitPrice: 280.00),
                InvoiceLineItem(id: UUID(), itemDescription: "HEPA Filter Replacement", quantity: 2, unitPrice: 50.00)
            ],
            paymentHistory: []
        ),

        // Sent invoices
        InvoiceDisplayModel(
            id: UUID(),
            invoiceNumber: "INV-2026-035",
            customerName: "Metro Office Group",
            customerAddress: "900 Commerce Blvd",
            jobTitle: "Commercial HVAC Service",
            jobNumber: "8790",
            status: .sent,
            subtotal: 3400.00,
            laborCost: 2200.00,
            partsCost: 1200.00,
            taxRate: 0.08,
            taxAmount: 272.00,
            total: 3672.00,
            dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()),
            paidAt: nil,
            completedDate: makeDate(month: 6, day: 1),
            createdAt: makeDate(month: 6, day: 3),
            notes: "Quarterly HVAC service for floors 1-3. Includes refrigerant top-off.",
            lineItems: [
                InvoiceLineItem(id: UUID(), itemDescription: "Commercial HVAC Inspection", quantity: 3, unitPrice: 350.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Refrigerant R-410A (5lb)", quantity: 2, unitPrice: 175.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Filter Set (Commercial)", quantity: 6, unitPrice: 85.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Labor - HVAC Technician", quantity: 10, unitPrice: 115.00)
            ],
            paymentHistory: []
        ),
        InvoiceDisplayModel(
            id: UUID(),
            invoiceNumber: "INV-2026-036",
            customerName: "Rachel Torres",
            customerAddress: "215 Birch Ave",
            jobTitle: "Bathroom Remodel Plumbing",
            jobNumber: "8795",
            status: .sent,
            subtotal: 1850.00,
            laborCost: 1200.00,
            partsCost: 650.00,
            taxRate: 0.07,
            taxAmount: 129.50,
            total: 1979.50,
            dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()),
            paidAt: nil,
            completedDate: makeDate(month: 6, day: 3),
            createdAt: makeDate(month: 6, day: 5),
            notes: nil,
            lineItems: [
                InvoiceLineItem(id: UUID(), itemDescription: "Fixture Installation (Toilet, Sink, Shower)", quantity: 1, unitPrice: 650.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Plumbing Materials", quantity: 1, unitPrice: 650.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Labor - Licensed Plumber", quantity: 8, unitPrice: 150.00)
            ],
            paymentHistory: []
        ),

        // Paid invoices
        InvoiceDisplayModel(
            id: UUID(),
            invoiceNumber: "INV-2026-028",
            customerName: "James Rodriguez",
            customerAddress: "334 Sunset Blvd",
            jobTitle: "Water Heater Installation",
            jobNumber: "8770",
            status: .paid,
            subtotal: 1600.00,
            laborCost: 800.00,
            partsCost: 800.00,
            taxRate: 0.08,
            taxAmount: 128.00,
            total: 1728.00,
            dueDate: makeDate(month: 5, day: 25),
            paidAt: makeDate(month: 5, day: 22),
            completedDate: makeDate(month: 5, day: 10),
            createdAt: makeDate(month: 5, day: 12),
            notes: "50-gallon tankless water heater. 10-year warranty included.",
            lineItems: [
                InvoiceLineItem(id: UUID(), itemDescription: "Tankless Water Heater Unit", quantity: 1, unitPrice: 800.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Installation Labor", quantity: 5, unitPrice: 160.00)
            ],
            paymentHistory: [
                PaymentRecord(id: UUID(), amount: 1728.00, method: .creditCard, date: makeDate(month: 5, day: 22), reference: "CC-4821")
            ]
        ),
        InvoiceDisplayModel(
            id: UUID(),
            invoiceNumber: "INV-2026-029",
            customerName: "Emily Watson",
            customerAddress: "567 Maple Creek",
            jobTitle: "Smart Home Wiring",
            jobNumber: "8775",
            status: .paid,
            subtotal: 2400.00,
            laborCost: 1800.00,
            partsCost: 600.00,
            taxRate: 0.08,
            taxAmount: 192.00,
            total: 2592.00,
            dueDate: makeDate(month: 5, day: 30),
            paidAt: makeDate(month: 5, day: 28),
            completedDate: makeDate(month: 5, day: 15),
            createdAt: makeDate(month: 5, day: 16),
            notes: nil,
            lineItems: [
                InvoiceLineItem(id: UUID(), itemDescription: "CAT6 Network Cabling", quantity: 500, unitPrice: 1.20),
                InvoiceLineItem(id: UUID(), itemDescription: "Smart Switch Units", quantity: 12, unitPrice: 45.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Labor - Electrician", quantity: 12, unitPrice: 105.00)
            ],
            paymentHistory: [
                PaymentRecord(id: UUID(), amount: 2592.00, method: .bankTransfer, date: makeDate(month: 5, day: 28), reference: "ACH-99201")
            ]
        ),

        // Overdue invoices
        InvoiceDisplayModel(
            id: UUID(),
            invoiceNumber: "INV-2026-019",
            customerName: "Tom Bradley",
            customerAddress: "78 Oak Ridge",
            jobTitle: "Emergency Pipe Repair",
            jobNumber: "8740",
            status: .overdue,
            subtotal: 950.00,
            laborCost: 650.00,
            partsCost: 300.00,
            taxRate: 0.08,
            taxAmount: 76.00,
            total: 1026.00,
            dueDate: Calendar.current.date(byAdding: .day, value: -15, to: Date()),
            paidAt: nil,
            completedDate: makeDate(month: 4, day: 20),
            createdAt: makeDate(month: 4, day: 22),
            notes: "Emergency after-hours call. Burst pipe in basement.",
            lineItems: [
                InvoiceLineItem(id: UUID(), itemDescription: "Emergency Service Call", quantity: 1, unitPrice: 200.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Copper Pipe + Fittings", quantity: 1, unitPrice: 300.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Labor - Emergency Rate", quantity: 3, unitPrice: 150.00)
            ],
            paymentHistory: []
        ),
        InvoiceDisplayModel(
            id: UUID(),
            invoiceNumber: "INV-2026-022",
            customerName: "Greenfield HOA",
            customerAddress: "1 Greenfield Plaza",
            jobTitle: "Pool Equipment Repair",
            jobNumber: "8755",
            status: .overdue,
            subtotal: 2200.00,
            laborCost: 1400.00,
            partsCost: 800.00,
            taxRate: 0.08,
            taxAmount: 176.00,
            total: 2376.00,
            dueDate: Calendar.current.date(byAdding: .day, value: -8, to: Date()),
            paidAt: nil,
            completedDate: makeDate(month: 5, day: 1),
            createdAt: makeDate(month: 5, day: 3),
            notes: "Pump motor replacement and filtration system service.",
            lineItems: [
                InvoiceLineItem(id: UUID(), itemDescription: "Pool Pump Motor", quantity: 1, unitPrice: 600.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Filter Cartridge Set", quantity: 4, unitPrice: 50.00),
                InvoiceLineItem(id: UUID(), itemDescription: "Labor - Pool Technician", quantity: 10, unitPrice: 140.00)
            ],
            paymentHistory: []
        )
    ]

    // MARK: - Date Helper

    private static func makeDate(month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }
}
