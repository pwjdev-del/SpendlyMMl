import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Estimate Display Model

struct EstimateDisplayModel: Identifiable, Codable {
    let id: UUID
    var estimateNumber: String
    var customerName: String
    var customerAddress: String
    var status: EstimateStatus
    var tasks: [EstimateTaskItem]
    var taxRate: Double       // e.g. 0.08 for 8%
    var discountPercent: Double // e.g. 0.10 for 10%
    var createdAt: Date
    var expiresAt: Date
    var region: String
    var projectType: String
    var technicianName: String
    var paymentStatus: String   // "Unpaid", "Partial", "Paid"
    var projectStatus: String   // "Not Started", "In Progress", "Completed"
    var materialCost: Double    // total material costs for the estimate

    var subtotal: Double {
        tasks.reduce(0) { $0 + $1.lineTotal }
    }

    var taxAmount: Double {
        subtotal * taxRate
    }

    var discountAmount: Double {
        subtotal * discountPercent
    }

    var grandTotal: Double {
        subtotal + taxAmount - discountAmount
    }

    var customerInitials: String {
        let parts = customerName.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? (parts.last?.prefix(1) ?? "") : ""
        return "\(first)\(last)".uppercased()
    }

    var taskCount: Int { tasks.count }

    var statusBadgeStyle: SPBadgeStyle {
        switch status {
        case .draft:    return .neutral
        case .sent:     return .info
        case .approved: return .success
        case .rejected: return .error
        case .expired:  return .warning
        }
    }

    var statusLabel: String {
        switch status {
        case .draft:    return "Draft"
        case .sent:     return "Sent"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .expired:  return "Expired"
        }
    }
}

// MARK: - Estimate Task Item

struct EstimateTaskItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var imageName: String   // SF Symbol for placeholder
    var estimatedHours: Double
    var hourlyRate: Double

    var lineTotal: Double {
        estimatedHours * hourlyRate
    }
}

// MARK: - Customer Option

struct CustomerOption: Identifiable, Hashable {
    let id: UUID
    var name: String
    var address: String

    var displayLabel: String {
        "\(name) - \(address)"
    }
}

// MARK: - Task Template

struct TaskTemplate: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var imageName: String
    var defaultHours: Double
    var defaultRate: Double
}

// MARK: - Mock Data

enum EstimateBuilderMockData {

    // MARK: Customers

    static let customers: [CustomerOption] = [
        CustomerOption(
            id: UUID(),
            name: "John Doe",
            address: "123 Maple St"
        ),
        CustomerOption(
            id: UUID(),
            name: "Jane Smith",
            address: "456 Oak Ave"
        ),
        CustomerOption(
            id: UUID(),
            name: "Robert Wilson",
            address: "789 Pine Rd"
        ),
        CustomerOption(
            id: UUID(),
            name: "Sarah Johnson",
            address: "321 Elm Blvd"
        )
    ]

    // MARK: Task Templates

    static let taskTemplates: [TaskTemplate] = [
        TaskTemplate(
            id: UUID(),
            name: "Electrical Rewiring",
            description: "Full house rewiring for safety compliance and modern appliance support.",
            imageName: "bolt.fill",
            defaultHours: 8,
            defaultRate: 75
        ),
        TaskTemplate(
            id: UUID(),
            name: "Smart Switch Installation",
            description: "Installation and configuration of 12 smart light switches with app syncing.",
            imageName: "light.switch.2",
            defaultHours: 3,
            defaultRate: 85
        ),
        TaskTemplate(
            id: UUID(),
            name: "HVAC Maintenance",
            description: "Filter replacement and cooling efficiency diagnostic for rooftop units.",
            imageName: "fan.fill",
            defaultHours: 4,
            defaultRate: 90
        ),
        TaskTemplate(
            id: UUID(),
            name: "Plumbing Inspection",
            description: "Full residential plumbing inspection with pressure testing and leak detection.",
            imageName: "wrench.and.screwdriver.fill",
            defaultHours: 2,
            defaultRate: 65
        ),
        TaskTemplate(
            id: UUID(),
            name: "Panel Upgrade",
            description: "Electrical panel upgrade from 100A to 200A for expanded capacity.",
            imageName: "powerplug.fill",
            defaultHours: 6,
            defaultRate: 95
        )
    ]

    // MARK: Sample Estimates

    static let estimates: [EstimateDisplayModel] = [
        EstimateDisplayModel(
            id: UUID(),
            estimateNumber: "EST-2026-001",
            customerName: "John Doe",
            customerAddress: "123 Maple St",
            status: .draft,
            tasks: [
                EstimateTaskItem(
                    id: UUID(),
                    name: "Electrical Rewiring",
                    description: "Full house rewiring for safety compliance and modern appliance support.",
                    imageName: "bolt.fill",
                    estimatedHours: 8,
                    hourlyRate: 75
                ),
                EstimateTaskItem(
                    id: UUID(),
                    name: "Smart Switch Installation",
                    description: "Installation and configuration of 12 smart light switches with app syncing.",
                    imageName: "light.switch.2",
                    estimatedHours: 3,
                    hourlyRate: 85
                )
            ],
            taxRate: 0.08,
            discountPercent: 0.0,
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 29, to: Date()) ?? Date(),
            region: "North",
            projectType: "Installation",
            technicianName: "Amit Shah",
            paymentStatus: "Unpaid",
            projectStatus: "Not Started",
            materialCost: 150
        ),

        EstimateDisplayModel(
            id: UUID(),
            estimateNumber: "EST-2026-002",
            customerName: "Jane Smith",
            customerAddress: "456 Oak Ave",
            status: .sent,
            tasks: [
                EstimateTaskItem(
                    id: UUID(),
                    name: "HVAC Maintenance",
                    description: "Filter replacement and cooling efficiency diagnostic for rooftop units.",
                    imageName: "fan.fill",
                    estimatedHours: 4,
                    hourlyRate: 90
                ),
                EstimateTaskItem(
                    id: UUID(),
                    name: "Plumbing Inspection",
                    description: "Full residential plumbing inspection with pressure testing and leak detection.",
                    imageName: "wrench.and.screwdriver.fill",
                    estimatedHours: 2,
                    hourlyRate: 65
                ),
                EstimateTaskItem(
                    id: UUID(),
                    name: "Panel Upgrade",
                    description: "Electrical panel upgrade from 100A to 200A for expanded capacity.",
                    imageName: "powerplug.fill",
                    estimatedHours: 6,
                    hourlyRate: 95
                )
            ],
            taxRate: 0.07,
            discountPercent: 0.05,
            createdAt: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 23, to: Date()) ?? Date(),
            region: "South",
            projectType: "Maintenance",
            technicianName: "Priya Nair",
            paymentStatus: "Partial",
            projectStatus: "In Progress",
            materialCost: 450
        ),

        EstimateDisplayModel(
            id: UUID(),
            estimateNumber: "EST-2026-003",
            customerName: "Robert Wilson",
            customerAddress: "789 Pine Rd",
            status: .approved,
            tasks: [
                EstimateTaskItem(
                    id: UUID(),
                    name: "Panel Upgrade",
                    description: "Electrical panel upgrade from 100A to 200A for expanded capacity.",
                    imageName: "powerplug.fill",
                    estimatedHours: 6,
                    hourlyRate: 95
                )
            ],
            taxRate: 0.06,
            discountPercent: 0.10,
            createdAt: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
            expiresAt: Calendar.current.date(byAdding: .day, value: 16, to: Date()) ?? Date(),
            region: "West",
            projectType: "Emergency Repair",
            technicianName: "Vikram Desai",
            paymentStatus: "Paid",
            projectStatus: "Completed",
            materialCost: 1200
        )
    ]
}
