import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Trip Report Display Model

struct TripReportDisplayModel: Identifiable {
    let id: UUID
    var reportNumber: String
    var customerName: String
    var customerAddress: String
    var customerCity: String
    var customerState: String
    var customerPostalCode: String
    var serviceDate: Date
    var technicianName: String
    var technicianEmail: String
    var completedTasks: [CompletedTaskItem]
    var additionalWorkItems: [AdditionalWorkItem]
    var partsUsed: [PartItem]
    var laborHours: Double
    var laborRate: Double
    var travelCharge: Double
    var tripNotes: String
    var manualTimeEntry: TimeEntry?
    var companyName: String
    var companyTagline: String

    var laborTotal: Double {
        laborHours * laborRate
    }

    var materialsTotal: Double {
        partsUsed.reduce(0) { $0 + $1.lineTotal }
    }

    var additionalWorkTotal: Double {
        additionalWorkItems.reduce(0) { $0 + $1.cost }
    }

    var grandTotal: Double {
        laborTotal + materialsTotal + additionalWorkTotal + travelCharge
    }

    var formattedServiceDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: serviceDate)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: serviceDate)
    }
}

// MARK: - Completed Task Item

struct CompletedTaskItem: Identifiable {
    let id: UUID
    var name: String
    var isCompleted: Bool
}

// MARK: - Additional Work Item

struct AdditionalWorkItem: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var cost: Double
}

// MARK: - Part Item

struct PartItem: Identifiable {
    let id: UUID
    var name: String
    var quantity: Int
    var unitPrice: Double

    var lineTotal: Double {
        Double(quantity) * unitPrice
    }
}

// MARK: - Time Entry

struct TimeEntry: Identifiable {
    let id: UUID
    var startTime: Date
    var endTime: Date
    var breakMinutes: Int

    var totalHours: Double {
        let interval = endTime.timeIntervalSince(startTime)
        let breakInterval = Double(breakMinutes) * 60
        return max(0, (interval - breakInterval) / 3600)
    }
}

// MARK: - Email Recipient

struct EmailRecipient: Identifiable {
    let id: UUID
    var name: String
    var email: String
    var role: String
    var isSelected: Bool
}

// MARK: - Charge Line Item (for itemized display)

struct ChargeLineItem: Identifiable {
    let id: UUID
    var description: String
    var amount: Double
}

// MARK: - Mock Data

enum TripReportMockData {

    // MARK: Completed Trips

    static let completedTrips: [TripReportDisplayModel] = [
        TripReportDisplayModel(
            id: UUID(),
            reportNumber: "TR-88294-2023",
            customerName: "Acme Corp - John Doe",
            customerAddress: "123 Industrial Parkway, Suite 500",
            customerCity: "Chicago",
            customerState: "IL",
            customerPostalCode: "60601",
            serviceDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            technicianName: "Robert Wilson",
            technicianEmail: "r.wilson@fieldservicepro.com",
            completedTasks: [
                CompletedTaskItem(id: UUID(), name: "HVAC Unit Inspection", isCompleted: true),
                CompletedTaskItem(id: UUID(), name: "Filter Replacement", isCompleted: true),
                CompletedTaskItem(id: UUID(), name: "Thermostat Calibration", isCompleted: true)
            ],
            additionalWorkItems: [
                AdditionalWorkItem(
                    id: UUID(),
                    title: "Emergency Drain Unclogging",
                    description: "Found secondary blockage during inspection",
                    cost: 85.00
                ),
                AdditionalWorkItem(
                    id: UUID(),
                    title: "Copper Fitting (1/2 inch)",
                    description: "Part used for drain repair",
                    cost: 12.50
                )
            ],
            partsUsed: [
                PartItem(id: UUID(), name: "HEPA Filter (Model XL-500)", quantity: 2, unitPrice: 18.75),
                PartItem(id: UUID(), name: "Copper Fitting 1/2\"", quantity: 1, unitPrice: 5.00)
            ],
            laborHours: 2.5,
            laborRate: 75.00,
            travelCharge: 0.00,
            tripNotes: "Customer requested follow-up visit in 3 months for seasonal maintenance. Building access code: 4521.",
            manualTimeEntry: TimeEntry(
                id: UUID(),
                startTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!,
                endTime: Calendar.current.date(bySettingHour: 11, minute: 30, second: 0, of: Date())!,
                breakMinutes: 0
            ),
            companyName: "Field Service Pro",
            companyTagline: "Certified Maintenance Solutions"
        ),

        TripReportDisplayModel(
            id: UUID(),
            reportNumber: "TR-88295-2023",
            customerName: "Metro Health Systems",
            customerAddress: "456 Medical Center Dr",
            customerCity: "Dallas",
            customerState: "TX",
            customerPostalCode: "75201",
            serviceDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            technicianName: "Sarah Chen",
            technicianEmail: "s.chen@fieldservicepro.com",
            completedTasks: [
                CompletedTaskItem(id: UUID(), name: "Generator Load Test", isCompleted: true),
                CompletedTaskItem(id: UUID(), name: "Transfer Switch Inspection", isCompleted: true),
                CompletedTaskItem(id: UUID(), name: "Fuel System Check", isCompleted: true),
                CompletedTaskItem(id: UUID(), name: "Battery Replacement", isCompleted: true)
            ],
            additionalWorkItems: [
                AdditionalWorkItem(
                    id: UUID(),
                    title: "Coolant Flush",
                    description: "Coolant levels were low; performed full system flush",
                    cost: 120.00
                )
            ],
            partsUsed: [
                PartItem(id: UUID(), name: "Generator Battery 12V", quantity: 2, unitPrice: 89.99),
                PartItem(id: UUID(), name: "Coolant (1 gallon)", quantity: 2, unitPrice: 24.50),
                PartItem(id: UUID(), name: "Air Filter Element", quantity: 1, unitPrice: 32.00)
            ],
            laborHours: 4.0,
            laborRate: 85.00,
            travelCharge: 45.00,
            tripNotes: "Annual generator maintenance complete. Recommend replacing fuel lines within 6 months.",
            manualTimeEntry: nil,
            companyName: "Field Service Pro",
            companyTagline: "Certified Maintenance Solutions"
        ),

        TripReportDisplayModel(
            id: UUID(),
            reportNumber: "TR-88296-2023",
            customerName: "Sunrise Manufacturing",
            customerAddress: "789 Factory Row",
            customerCity: "Phoenix",
            customerState: "AZ",
            customerPostalCode: "85001",
            serviceDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            technicianName: "James Martinez",
            technicianEmail: "j.martinez@fieldservicepro.com",
            completedTasks: [
                CompletedTaskItem(id: UUID(), name: "Conveyor Belt Alignment", isCompleted: true),
                CompletedTaskItem(id: UUID(), name: "Motor Bearing Lubrication", isCompleted: true)
            ],
            additionalWorkItems: [],
            partsUsed: [
                PartItem(id: UUID(), name: "Industrial Lubricant (16oz)", quantity: 3, unitPrice: 14.25)
            ],
            laborHours: 1.5,
            laborRate: 90.00,
            travelCharge: 25.00,
            tripNotes: "Quick maintenance call. All systems operating within normal parameters.",
            manualTimeEntry: nil,
            companyName: "Field Service Pro",
            companyTagline: "Certified Maintenance Solutions"
        )
    ]

    // MARK: Default Recipients

    static let defaultRecipients: [EmailRecipient] = [
        EmailRecipient(
            id: UUID(),
            name: "Sarah Jenkins",
            email: "s.jenkins@acmecorp.com",
            role: "Requestor",
            isSelected: true
        ),
        EmailRecipient(
            id: UUID(),
            name: "Michael Acme",
            email: "m.acme@acmecorp.com",
            role: "Signatory",
            isSelected: true
        ),
        EmailRecipient(
            id: UUID(),
            name: "AP Department",
            email: "billing@acmecorp.com",
            role: "Accounts Payable",
            isSelected: false
        ),
        EmailRecipient(
            id: UUID(),
            name: "Kevin Wright",
            email: "k.wright@acmecorp.com",
            role: "Purchasing (Parts)",
            isSelected: false
        )
    ]
}
