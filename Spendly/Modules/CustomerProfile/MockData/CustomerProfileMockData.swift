import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Customer Display Model

struct CustomerDisplayModel: Identifiable {
    let id: UUID
    var name: String
    var companyName: String
    var contactTitle: String
    var email: String
    var phone: String
    var address: String
    var city: String
    var state: String
    var postalCode: String
    var avatarURL: String?
    var isPremium: Bool
    var accountBalance: Double
    var budgetAllocated: Double
    var region: String
    var contractType: String
    var paymentStatus: PaymentStatusType
    var lastActivityDate: Date
    var createdAt: Date
    var notes: [String]
    var machines: [CustomerMachineItem]
    var jobHistory: [CustomerJobItem]

    var initials: String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(first)\(last)".uppercased()
    }

    var fullAddress: String {
        "\(address), \(city), \(state) \(postalCode)"
    }

    var totalJobsCompleted: Int {
        jobHistory.filter { $0.status == .completed }.count
    }
}

// MARK: - Payment Status

enum PaymentStatusType: String, CaseIterable {
    case current = "Current"
    case overdue = "Overdue"
    case pending = "Pending"
    case paid = "Paid"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .current: return .success
        case .overdue: return .error
        case .pending: return .warning
        case .paid:    return .info
        }
    }
}

// MARK: - Customer Machine Item

struct CustomerMachineItem: Identifiable {
    let id: UUID
    var name: String
    var model: String
    var serialNumber: String
    var status: MachineStatus
}

// MARK: - Customer Job Item

struct CustomerJobItem: Identifiable {
    let id: UUID
    var title: String
    var jobID: String
    var status: CustomerJobStatus
    var scheduledDate: Date
    var amount: Double?
    var technicianName: String?
}

enum CustomerJobStatus: String {
    case inProgress = "In Progress"
    case completed = "Completed"
    case scheduled = "Scheduled"
    case cancelled = "Cancelled"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .inProgress: return .success
        case .completed:  return .neutral
        case .scheduled:  return .info
        case .cancelled:  return .error
        }
    }
}

// MARK: - Contract Type

enum ContractType: String, CaseIterable {
    case annual = "Annual"
    case perCall = "Per Call"
    case warranty = "Warranty"
    case enterprise = "Enterprise"
}

// MARK: - Mock Data

enum CustomerProfileMockData {

    static let customers: [CustomerDisplayModel] = [
        CustomerDisplayModel(
            id: UUID(),
            name: "Rajesh Patel",
            companyName: "Patel Packaging Industries",
            contactTitle: "Managing Director",
            email: "rajesh@patelpackaging.com",
            phone: "+91 98765 43210",
            address: "Plot 42, GIDC Industrial Estate",
            city: "Ahmedabad",
            state: "Gujarat",
            postalCode: "382445",
            avatarURL: nil,
            isPremium: true,
            accountBalance: 12500.00,
            budgetAllocated: 50000.00,
            region: "West",
            contractType: "Annual",
            paymentStatus: .current,
            lastActivityDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            createdAt: Calendar.current.date(byAdding: .month, value: -18, to: Date())!,
            notes: [
                "Gate code: 7742. Security clearance needed for Zone B.",
                "Prefers morning service appointments before 10 AM."
            ],
            machines: [
                CustomerMachineItem(
                    id: UUID(),
                    name: "FlexPack 3000",
                    model: "FP-3000X",
                    serialNumber: "SN-FP-2023-0142",
                    status: .operational
                ),
                CustomerMachineItem(
                    id: UUID(),
                    name: "SealMaster Pro",
                    model: "SM-800",
                    serialNumber: "SN-SM-2022-0891",
                    status: .needsMaintenance
                )
            ],
            jobHistory: [
                CustomerJobItem(
                    id: UUID(),
                    title: "FlexPack Calibration",
                    jobID: "#9201",
                    status: .inProgress,
                    scheduledDate: Date(),
                    amount: nil,
                    technicianName: "Amit Shah"
                ),
                CustomerJobItem(
                    id: UUID(),
                    title: "SealMaster Belt Replacement",
                    jobID: "#8744",
                    status: .completed,
                    scheduledDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                    amount: 2450.00,
                    technicianName: "Vikram Desai"
                )
            ]
        ),

        CustomerDisplayModel(
            id: UUID(),
            name: "Ananya Sharma",
            companyName: "SharpEdge Corrugators",
            contactTitle: "Plant Manager",
            email: "ananya.s@sharpedge.in",
            phone: "+91 87654 32109",
            address: "Unit 15, Sector 63",
            city: "Noida",
            state: "Uttar Pradesh",
            postalCode: "201301",
            avatarURL: nil,
            isPremium: true,
            accountBalance: 8200.00,
            budgetAllocated: 35000.00,
            region: "North",
            contractType: "Enterprise",
            paymentStatus: .current,
            lastActivityDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            createdAt: Calendar.current.date(byAdding: .month, value: -24, to: Date())!,
            notes: [
                "Requires 48-hour advance notice for all service calls.",
                "Contact security desk first at ext 201."
            ],
            machines: [
                CustomerMachineItem(
                    id: UUID(),
                    name: "CorrugaMaster 500",
                    model: "CM-500E",
                    serialNumber: "SN-CM-2021-0337",
                    status: .operational
                )
            ],
            jobHistory: [
                CustomerJobItem(
                    id: UUID(),
                    title: "CorrugaMaster Annual Service",
                    jobID: "#8992",
                    status: .scheduled,
                    scheduledDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
                    amount: nil,
                    technicianName: "Priya Nair"
                ),
                CustomerJobItem(
                    id: UUID(),
                    title: "Die Cutter Blade Sharpening",
                    jobID: "#8510",
                    status: .completed,
                    scheduledDate: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
                    amount: 1800.00,
                    technicianName: "Suresh Kumar"
                )
            ]
        ),

        CustomerDisplayModel(
            id: UUID(),
            name: "Mohammed Al-Rashidi",
            companyName: "Gulf Carton Factory",
            contactTitle: "Operations Head",
            email: "m.rashidi@gulfcarton.ae",
            phone: "+971 55 987 6543",
            address: "Industrial Area 3, Block C",
            city: "Sharjah",
            state: "Sharjah",
            postalCode: "00000",
            avatarURL: nil,
            isPremium: false,
            accountBalance: -3400.00,
            budgetAllocated: 20000.00,
            region: "East",
            contractType: "Per Call",
            paymentStatus: .overdue,
            lastActivityDate: Calendar.current.date(byAdding: .day, value: -45, to: Date())!,
            createdAt: Calendar.current.date(byAdding: .month, value: -8, to: Date())!,
            notes: [
                "Outstanding balance from Q3 invoice. Follow up required."
            ],
            machines: [
                CustomerMachineItem(
                    id: UUID(),
                    name: "BoxFold 200",
                    model: "BF-200L",
                    serialNumber: "SN-BF-2023-0056",
                    status: .underRepair
                )
            ],
            jobHistory: [
                CustomerJobItem(
                    id: UUID(),
                    title: "BoxFold Emergency Repair",
                    jobID: "#8399",
                    status: .completed,
                    scheduledDate: Calendar.current.date(byAdding: .day, value: -45, to: Date())!,
                    amount: 3400.00,
                    technicianName: "Farhan Khan"
                )
            ]
        ),

        CustomerDisplayModel(
            id: UUID(),
            name: "Priya Venkatesh",
            companyName: "Southern Laminations Pvt Ltd",
            contactTitle: "CEO",
            email: "priya.v@southlam.co.in",
            phone: "+91 94432 10987",
            address: "Plot 88, Ambattur Industrial Estate",
            city: "Chennai",
            state: "Tamil Nadu",
            postalCode: "600058",
            avatarURL: nil,
            isPremium: true,
            accountBalance: 0.00,
            budgetAllocated: 75000.00,
            region: "South",
            contractType: "Annual",
            paymentStatus: .paid,
            lastActivityDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            createdAt: Calendar.current.date(byAdding: .month, value: -36, to: Date())!,
            notes: [
                "VIP client. Dedicated account manager: Kiran.",
                "Eco-friendly materials only for all service work."
            ],
            machines: [
                CustomerMachineItem(
                    id: UUID(),
                    name: "LaminaPro 700",
                    model: "LP-700HD",
                    serialNumber: "SN-LP-2020-0214",
                    status: .operational
                ),
                CustomerMachineItem(
                    id: UUID(),
                    name: "LaminaPro 700",
                    model: "LP-700HD",
                    serialNumber: "SN-LP-2021-0533",
                    status: .operational
                ),
                CustomerMachineItem(
                    id: UUID(),
                    name: "CoatMax 350",
                    model: "CX-350UV",
                    serialNumber: "SN-CX-2022-0102",
                    status: .operational
                )
            ],
            jobHistory: [
                CustomerJobItem(
                    id: UUID(),
                    title: "Quarterly Preventive Maintenance",
                    jobID: "#9188",
                    status: .inProgress,
                    scheduledDate: Date(),
                    amount: nil,
                    technicianName: "Deepak Rajan"
                ),
                CustomerJobItem(
                    id: UUID(),
                    title: "CoatMax UV Lamp Replacement",
                    jobID: "#8901",
                    status: .completed,
                    scheduledDate: Calendar.current.date(byAdding: .day, value: -20, to: Date())!,
                    amount: 4200.00,
                    technicianName: "Deepak Rajan"
                ),
                CustomerJobItem(
                    id: UUID(),
                    title: "LaminaPro Roller Alignment",
                    jobID: "#8650",
                    status: .completed,
                    scheduledDate: Calendar.current.date(byAdding: .day, value: -60, to: Date())!,
                    amount: 1500.00,
                    technicianName: "Suresh Kumar"
                )
            ]
        ),

        CustomerDisplayModel(
            id: UUID(),
            name: "Vikram Mehta",
            companyName: "Mehta Flexibles & Co",
            contactTitle: "Technical Director",
            email: "vikram.m@mehtaflex.com",
            phone: "+91 99887 76655",
            address: "Survey No. 120, Chakan MIDC",
            city: "Pune",
            state: "Maharashtra",
            postalCode: "410501",
            avatarURL: nil,
            isPremium: false,
            accountBalance: 1200.00,
            budgetAllocated: 15000.00,
            region: "West",
            contractType: "Warranty",
            paymentStatus: .pending,
            lastActivityDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            createdAt: Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
            notes: [
                "New customer. Still under initial warranty period.",
                "Parking available at Gate 3 only."
            ],
            machines: [
                CustomerMachineItem(
                    id: UUID(),
                    name: "FlexiPrint 450",
                    model: "FXP-450CI",
                    serialNumber: "SN-FXP-2024-0018",
                    status: .operational
                )
            ],
            jobHistory: [
                CustomerJobItem(
                    id: UUID(),
                    title: "Installation Commissioning",
                    jobID: "#9050",
                    status: .completed,
                    scheduledDate: Calendar.current.date(byAdding: .month, value: -4, to: Date())!,
                    amount: 0.00,
                    technicianName: "Amit Shah"
                ),
                CustomerJobItem(
                    id: UUID(),
                    title: "Warranty Inspection",
                    jobID: "#9155",
                    status: .scheduled,
                    scheduledDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
                    amount: nil,
                    technicianName: "Amit Shah"
                )
            ]
        )
    ]
}
