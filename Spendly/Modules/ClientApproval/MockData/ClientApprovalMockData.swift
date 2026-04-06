import Foundation
import SpendlyCore

// MARK: - Display Models (Module-Local)

struct EstimateLineItem: Identifiable {
    let id: UUID
    let icon: String          // SF Symbol name
    let task: String
    let description: String
    let quantity: Int
    let unitPrice: Double

    var total: Double { Double(quantity) * unitPrice }
}

struct EstimateApprovalItem: Identifiable {
    let id: UUID
    let estimateNumber: String
    let issuedDate: Date
    let validUntilDate: Date
    let customerName: String
    let customerEmail: String
    let projectTitle: String
    let status: ApprovalStatus
    let laborItems: [EstimateLineItem]
    let materialItems: [EstimateLineItem]
    let taxRate: Double   // e.g. 0.085 for 8.5%
    var comments: String = ""  // client comments entered during approval/rejection

    var subtotal: Double {
        (laborItems + materialItems).reduce(0) { $0 + $1.total }
    }

    var taxAmount: Double {
        subtotal * taxRate
    }

    var grandTotal: Double {
        subtotal + taxAmount
    }

    var taxPercentageLabel: String {
        let pct = taxRate * 100
        if pct == pct.rounded() {
            return "\(Int(pct))%"
        }
        return String(format: "%.1f%%", pct)
    }
}

struct AssignedTeam {
    let name: String
    let responseTime: String
}

// MARK: - Mock Data

enum ClientApprovalMockData {

    // MARK: Assigned Teams

    static let eliteTeam = AssignedTeam(
        name: "Elite Services",
        responseTime: "Usually under 2 hours"
    )

    // MARK: Sample Estimates

    static let sampleEstimates: [EstimateApprovalItem] = [
        EstimateApprovalItem(
            id: UUID(),
            estimateNumber: "EST-2024-082",
            issuedDate: dateFrom(year: 2024, month: 10, day: 24),
            validUntilDate: dateFrom(year: 2024, month: 11, day: 24),
            customerName: "Alex Johnson",
            customerEmail: "alex.johnson@acmecorp.com",
            projectTitle: "Kitchen Renovation",
            status: .pending,
            laborItems: [
                EstimateLineItem(
                    id: UUID(),
                    icon: "rectangle.split.3x3",
                    task: "Kitchen Cabinet Installation",
                    description: "Installation of 12 custom soft-close units",
                    quantity: 1,
                    unitPrice: 1200.00
                ),
                EstimateLineItem(
                    id: UUID(),
                    icon: "wrench.and.screwdriver",
                    task: "Fixture Plumbing",
                    description: "Sink, faucet, and dishwasher hookups",
                    quantity: 1,
                    unitPrice: 450.00
                ),
            ],
            materialItems: [
                EstimateLineItem(
                    id: UUID(),
                    icon: "square.stack.3d.up",
                    task: "Premium Oak Cabinets",
                    description: "Shaker style, White finish (Set of 12)",
                    quantity: 1,
                    unitPrice: 4850.00
                ),
                EstimateLineItem(
                    id: UUID(),
                    icon: "screwdriver",
                    task: "Hardware & Fasteners",
                    description: "Brushed nickel handles and structural screws",
                    quantity: 1,
                    unitPrice: 320.00
                ),
            ],
            taxRate: 0.085
        ),
        EstimateApprovalItem(
            id: UUID(),
            estimateNumber: "EST-2024-091",
            issuedDate: dateFrom(year: 2024, month: 11, day: 5),
            validUntilDate: dateFrom(year: 2024, month: 12, day: 5),
            customerName: "Sarah Mitchell",
            customerEmail: "s.mitchell@globexinc.com",
            projectTitle: "Electrical Rewiring",
            status: .pending,
            laborItems: [
                EstimateLineItem(
                    id: UUID(),
                    icon: "bolt",
                    task: "Main Panel Upgrade",
                    description: "200A panel replacement with breaker mapping",
                    quantity: 1,
                    unitPrice: 2800.00
                ),
                EstimateLineItem(
                    id: UUID(),
                    icon: "lightbulb",
                    task: "Outlet & Switch Installation",
                    description: "Install 18 GFCI outlets and 12 smart switches",
                    quantity: 1,
                    unitPrice: 1500.00
                ),
            ],
            materialItems: [
                EstimateLineItem(
                    id: UUID(),
                    icon: "cable.coaxial",
                    task: "Romex Wiring (14/2 & 12/2)",
                    description: "1500 ft residential-grade copper wire",
                    quantity: 1,
                    unitPrice: 680.00
                ),
                EstimateLineItem(
                    id: UUID(),
                    icon: "powerplug.portrait",
                    task: "Outlets & Switches",
                    description: "18x Leviton GFCI + 12x Lutron Caseta",
                    quantity: 1,
                    unitPrice: 540.00
                ),
            ],
            taxRate: 0.07
        ),
        EstimateApprovalItem(
            id: UUID(),
            estimateNumber: "EST-2024-075",
            issuedDate: dateFrom(year: 2024, month: 9, day: 15),
            validUntilDate: dateFrom(year: 2024, month: 10, day: 15),
            customerName: "David Chen",
            customerEmail: "dchen@wayneent.com",
            projectTitle: "HVAC System Replacement",
            status: .approved,
            laborItems: [
                EstimateLineItem(
                    id: UUID(),
                    icon: "fan",
                    task: "HVAC Unit Installation",
                    description: "Remove old unit, install new 3-ton system",
                    quantity: 1,
                    unitPrice: 3200.00
                ),
            ],
            materialItems: [
                EstimateLineItem(
                    id: UUID(),
                    icon: "fan",
                    task: "Carrier 3-Ton Heat Pump",
                    description: "Model 25HCE636A003, 16 SEER2",
                    quantity: 1,
                    unitPrice: 4100.00
                ),
            ],
            taxRate: 0.085
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
