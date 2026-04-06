import Foundation
import SpendlyCore

// MARK: - Machine Vault Display Model

/// Lightweight view-model struct used for UI display in the Machine Vault module.
/// Maps loosely to `Machine` from CoreModels but adds vault-specific fields
/// (health score, division, image, maintenance history).
struct VaultMachine: Identifiable, Hashable {
    let id: UUID
    let name: String
    let model: String
    let serialNumber: String
    let status: MachineStatus
    let division: String
    let location: String
    let healthScore: Double          // 0.0 ... 1.0
    let warrantyExpiry: Date?
    let installDate: Date?
    let imageName: String?           // SF Symbol fallback when nil
    let customerName: String?
    let notes: String?
    let category: MachineTypeFilter  // exact machine type for filtering
    let maintenanceHistory: [MaintenanceEvent]
    let scheduledMaintenance: [ScheduledMaintenance]

    // Computed
    var healthPercent: Int { Int(healthScore * 100) }

    var warrantyStatus: WarrantyDisplayStatus {
        guard let expiry = warrantyExpiry else { return .unknown }
        if expiry > Date() {
            let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: expiry).day ?? 0
            if daysLeft <= 30 { return .expiringSoon }
            return .active
        }
        return .expired
    }

    var statusBadgeStyle: SPBadgeStyle {
        switch status {
        case .operational:       return .success
        case .needsMaintenance:  return .warning
        case .underRepair:       return .info
        case .decommissioned:    return .error
        }
    }

    var statusLabel: String {
        switch status {
        case .operational:       return "In Service"
        case .needsMaintenance:  return "Needs Maintenance"
        case .underRepair:       return "Under Repair"
        case .decommissioned:    return "Decommissioned"
        }
    }
}

// MARK: - Supporting Types

enum WarrantyDisplayStatus {
    case active
    case expiringSoon
    case expired
    case unknown

    var label: String {
        switch self {
        case .active:       return "Warranty Active"
        case .expiringSoon: return "Expiring Soon"
        case .expired:      return "Warranty Expired"
        case .unknown:      return "No Warranty"
        }
    }

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .active:       return .success
        case .expiringSoon: return .warning
        case .expired:      return .error
        case .unknown:      return .neutral
        }
    }
}

struct MaintenanceEvent: Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let date: Date
    let ticketNumber: String?
    let technicianName: String?
    let type: MaintenanceType

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        date: Date,
        ticketNumber: String? = nil,
        technicianName: String? = nil,
        type: MaintenanceType = .corrective
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.ticketNumber = ticketNumber
        self.technicianName = technicianName
        self.type = type
    }
}

struct ScheduledMaintenance: Identifiable, Hashable {
    let id: UUID
    let title: String
    let scheduledDate: Date
    let assignedTechnician: String?
    let isOverdue: Bool

    init(
        id: UUID = UUID(),
        title: String,
        scheduledDate: Date,
        assignedTechnician: String? = nil,
        isOverdue: Bool = false
    ) {
        self.id = id
        self.title = title
        self.scheduledDate = scheduledDate
        self.assignedTechnician = assignedTechnician
        self.isOverdue = isOverdue
    }
}

enum MaintenanceType: String, CaseIterable, Hashable {
    case preventive  = "Preventive"
    case corrective  = "Corrective"
    case emergency   = "Emergency"
    case calibration = "Calibration"
    case inspection  = "Inspection"
}

enum MachineTypeFilter: String, CaseIterable {
    case all            = "All"
    case ffs            = "FFS"
    case pouchMaker     = "Pouch Maker"
    case converter      = "Converter"
    case blownFilm      = "Blown Film"
    case sachet         = "Sachet"
}

// MARK: - Mock Data

enum MachineVaultMockData {

    // Date helpers
    private static func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: y, month: m, day: d)) ?? Date()
    }

    static let machines: [VaultMachine] = [
        VaultMachine(
            id: UUID(),
            name: "M-200 FFS",
            model: "M-200-FFS-XL",
            serialNumber: "SN-M200-4821-FFS",
            status: .operational,
            division: "Packaging Division",
            location: "Plant A - Line 3",
            healthScore: 0.92,
            warrantyExpiry: date(2027, 3, 15),
            installDate: date(2023, 6, 10),
            imageName: nil,
            customerName: "Industrial Logistics Corp.",
            notes: "High-speed vertical form-fill-seal machine. 120 bags/min capacity.",
            category: .ffs,
            maintenanceHistory: [
                MaintenanceEvent(
                    title: "Scheduled Preventive Maintenance",
                    description: "Replaced jaw heater elements and re-calibrated bag length sensor. Firmware updated to v3.8.1.",
                    date: date(2026, 2, 14),
                    ticketNumber: "WO-30112",
                    technicianName: "Raj Mehta",
                    type: .preventive
                ),
                MaintenanceEvent(
                    title: "Emergency Seal Bar Repair",
                    description: "Horizontal seal bar misalignment caused intermittent weak seals. Realigned and torqued to spec.",
                    date: date(2025, 11, 5),
                    ticketNumber: "WO-29887",
                    technicianName: "Mike Chen",
                    type: .emergency
                ),
                MaintenanceEvent(
                    title: "Annual Calibration",
                    description: "Full calibration of temperature controllers, load cells, and photocell registration.",
                    date: date(2025, 6, 20),
                    ticketNumber: "WO-28501",
                    technicianName: "Raj Mehta",
                    type: .calibration
                ),
            ],
            scheduledMaintenance: [
                ScheduledMaintenance(
                    title: "6-Month Preventive Service",
                    scheduledDate: date(2026, 8, 14),
                    assignedTechnician: "Raj Mehta"
                ),
            ]
        ),
        VaultMachine(
            id: UUID(),
            name: "Vega 285 PM",
            model: "VEGA-285-PM",
            serialNumber: "SN-V285-1190-PM",
            status: .needsMaintenance,
            division: "Flexible Packaging",
            location: "Plant B - Bay 7",
            healthScore: 0.68,
            warrantyExpiry: date(2025, 12, 1),
            installDate: date(2022, 12, 1),
            imageName: nil,
            customerName: "Pacific Foods Inc.",
            notes: "Premade pouch filler with zipper applicator. Needs roller replacement.",
            category: .pouchMaker,
            maintenanceHistory: [
                MaintenanceEvent(
                    title: "Roller Wear Inspection",
                    description: "Feed rollers showing 40% wear. Recommended replacement within 30 days.",
                    date: date(2026, 3, 1),
                    ticketNumber: "WO-30445",
                    technicianName: "Sarah Lopez",
                    type: .inspection
                ),
                MaintenanceEvent(
                    title: "Zipper Applicator Adjustment",
                    description: "Re-tensioned zipper tape guide and replaced worn guide rail bushings.",
                    date: date(2025, 9, 18),
                    ticketNumber: "WO-29200",
                    technicianName: "Sarah Lopez",
                    type: .corrective
                ),
            ],
            scheduledMaintenance: [
                ScheduledMaintenance(
                    title: "Feed Roller Replacement",
                    scheduledDate: date(2026, 4, 10),
                    assignedTechnician: "Sarah Lopez",
                    isOverdue: false
                ),
                ScheduledMaintenance(
                    title: "Full PM Cycle",
                    scheduledDate: date(2026, 6, 1),
                    assignedTechnician: "Raj Mehta"
                ),
            ]
        ),
        VaultMachine(
            id: UUID(),
            name: "ConvertPro 750P",
            model: "CP-750P-TURBO",
            serialNumber: "SN-CP750-3305-TRB",
            status: .operational,
            division: "Converting Division",
            location: "Plant A - Line 1",
            healthScore: 0.97,
            warrantyExpiry: date(2028, 1, 20),
            installDate: date(2024, 1, 20),
            imageName: nil,
            customerName: "Industrial Logistics Corp.",
            notes: "High-speed slitter-rewinder with automatic knife positioning. Top performer.",
            category: .converter,
            maintenanceHistory: [
                MaintenanceEvent(
                    title: "Blade Replacement & Calibration",
                    description: "Replaced all 8 shear blades and recalibrated edge-guide sensors.",
                    date: date(2026, 1, 10),
                    ticketNumber: "WO-30001",
                    technicianName: "Mike Chen",
                    type: .preventive
                ),
            ],
            scheduledMaintenance: [
                ScheduledMaintenance(
                    title: "Quarterly Inspection",
                    scheduledDate: date(2026, 4, 20),
                    assignedTechnician: "Mike Chen"
                ),
            ]
        ),
        VaultMachine(
            id: UUID(),
            name: "BF-3200 Blown Film Line",
            model: "BF-3200-COEX",
            serialNumber: "SN-BF32-0078-CX",
            status: .underRepair,
            division: "Film Extrusion",
            location: "Plant C - Hall 2",
            healthScore: 0.41,
            warrantyExpiry: date(2024, 8, 30),
            installDate: date(2021, 8, 30),
            imageName: nil,
            customerName: "Global Wrap Solutions",
            notes: "3-layer co-extrusion blown film line. Currently down for die repair.",
            category: .blownFilm,
            maintenanceHistory: [
                MaintenanceEvent(
                    title: "Die Head Disassembly & Cleaning",
                    description: "Carbonized resin buildup found in distribution channels. Full disassembly and ultrasonic cleaning in progress.",
                    date: date(2026, 3, 25),
                    ticketNumber: "WO-30620",
                    technicianName: "Tom Brewer",
                    type: .corrective
                ),
                MaintenanceEvent(
                    title: "Extruder Gearbox Overhaul",
                    description: "Gearbox oil analysis showed metal particulates. Bearings replaced, oil flushed.",
                    date: date(2025, 7, 12),
                    ticketNumber: "WO-28900",
                    technicianName: "Tom Brewer",
                    type: .emergency
                ),
                MaintenanceEvent(
                    title: "IBC System Recalibration",
                    description: "Internal bubble cooling system recalibrated after film gauge inconsistency detected.",
                    date: date(2025, 3, 5),
                    ticketNumber: "WO-27650",
                    technicianName: "Mike Chen",
                    type: .calibration
                ),
            ],
            scheduledMaintenance: [
                ScheduledMaintenance(
                    title: "Die Reassembly & Startup",
                    scheduledDate: date(2026, 4, 5),
                    assignedTechnician: "Tom Brewer"
                ),
            ]
        ),
        VaultMachine(
            id: UUID(),
            name: "SP-60 Sachet Machine",
            model: "SP-60-MULTI",
            serialNumber: "SN-SP60-5512-ML",
            status: .operational,
            division: "Sachet & Stick Pack",
            location: "Plant B - Line 5",
            healthScore: 0.85,
            warrantyExpiry: date(2026, 5, 15),
            installDate: date(2023, 5, 15),
            imageName: nil,
            customerName: "Pacific Foods Inc.",
            notes: "Multi-lane sachet filler. 8-lane configuration for powder & granule products.",
            category: .sachet,
            maintenanceHistory: [
                MaintenanceEvent(
                    title: "Lane Balancing & Auger Service",
                    description: "All 8 auger fillers serviced. Replaced worn auger screws on lanes 3 and 7.",
                    date: date(2026, 2, 28),
                    ticketNumber: "WO-30380",
                    technicianName: "Sarah Lopez",
                    type: .preventive
                ),
                MaintenanceEvent(
                    title: "Cutter Blade Replacement",
                    description: "Cross-cut blades replaced on all lanes. Adjusted cut timing to reduce tail length.",
                    date: date(2025, 10, 15),
                    ticketNumber: "WO-29500",
                    technicianName: "Raj Mehta",
                    type: .corrective
                ),
            ],
            scheduledMaintenance: [
                ScheduledMaintenance(
                    title: "Annual Warranty Inspection",
                    scheduledDate: date(2026, 5, 1),
                    assignedTechnician: "Sarah Lopez"
                ),
            ]
        ),
    ]
}
