import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Part Category

enum PartCategory: String, CaseIterable, Hashable {
    case electrical   = "Electrical"
    case mechanical   = "Mechanical"
    case hydraulic    = "Hydraulic"
    case pneumatic    = "Pneumatic"
    case consumable   = "Consumable"
    case sensor       = "Sensor"

    var icon: String {
        switch self {
        case .electrical:  return "bolt.fill"
        case .mechanical:  return "gearshape.2.fill"
        case .hydraulic:   return "drop.fill"
        case .pneumatic:   return "wind"
        case .consumable:  return "shippingbox.fill"
        case .sensor:      return "antenna.radiowaves.left.and.right"
        }
    }

    var color: Color {
        switch self {
        case .electrical:  return SpendlyColors.info
        case .mechanical:  return SpendlyColors.success
        case .hydraulic:   return SpendlyColors.primary
        case .pneumatic:   return SpendlyColors.warning
        case .consumable:  return SpendlyColors.secondary
        case .sensor:      return SpendlyColors.accent
        }
    }
}

// MARK: - Stock Status

enum StockStatus: String, CaseIterable {
    case inStock    = "In Stock"
    case lowStock   = "Low Stock"
    case outOfStock = "Out of Stock"
    case onOrder    = "On Order"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .inStock:    return .success
        case .lowStock:   return .warning
        case .outOfStock: return .error
        case .onOrder:    return .info
        }
    }
}

// MARK: - Order Status

enum PartsOrderStatus: String, CaseIterable {
    case pending     = "Pending"
    case confirmed   = "Confirmed"
    case shipped     = "Shipped"
    case delivered   = "Delivered"
    case cancelled   = "Cancelled"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .pending:   return .warning
        case .confirmed: return .info
        case .shipped:   return .custom(SpendlyColors.accent)
        case .delivered: return .success
        case .cancelled: return .error
        }
    }
}

// MARK: - Display Part

struct DisplayPart: Identifiable, Hashable {
    let id: UUID
    let partNumber: String
    let name: String
    let description: String?
    let category: PartCategory
    let unitCost: Double
    let stockQuantity: Int
    let minimumStock: Int
    let warehouseLocation: String?
    let supplierName: String
    let leadTimeDays: Int
    let lastRestockedAt: Date?

    var stockStatus: StockStatus {
        if stockQuantity == 0 { return .outOfStock }
        if stockQuantity <= minimumStock { return .lowStock }
        return .inStock
    }

    var formattedUnitCost: String {
        String(format: "$%.2f", unitCost)
    }

    var totalStockValue: Double {
        unitCost * Double(stockQuantity)
    }

    init(
        id: UUID = UUID(),
        partNumber: String,
        name: String,
        description: String? = nil,
        category: PartCategory,
        unitCost: Double,
        stockQuantity: Int,
        minimumStock: Int = 5,
        warehouseLocation: String? = nil,
        supplierName: String,
        leadTimeDays: Int = 7,
        lastRestockedAt: Date? = nil
    ) {
        self.id = id
        self.partNumber = partNumber
        self.name = name
        self.description = description
        self.category = category
        self.unitCost = unitCost
        self.stockQuantity = stockQuantity
        self.minimumStock = minimumStock
        self.warehouseLocation = warehouseLocation
        self.supplierName = supplierName
        self.leadTimeDays = leadTimeDays
        self.lastRestockedAt = lastRestockedAt
    }
}

// MARK: - Display Order

struct DisplayPartsOrder: Identifiable, Hashable {
    let id: UUID
    let orderNumber: String
    let partName: String
    let partNumber: String
    let quantity: Int
    let unitCost: Double
    let totalCost: Double
    let supplierName: String
    let status: PartsOrderStatus
    let orderedAt: Date
    let expectedDeliveryAt: Date?
    let orderedBy: String

    init(
        id: UUID = UUID(),
        orderNumber: String,
        partName: String,
        partNumber: String,
        quantity: Int,
        unitCost: Double,
        supplierName: String,
        status: PartsOrderStatus,
        orderedAt: Date,
        expectedDeliveryAt: Date?,
        orderedBy: String
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.partName = partName
        self.partNumber = partNumber
        self.quantity = quantity
        self.unitCost = unitCost
        self.totalCost = unitCost * Double(quantity)
        self.supplierName = supplierName
        self.status = status
        self.orderedAt = orderedAt
        self.expectedDeliveryAt = expectedDeliveryAt
        self.orderedBy = orderedBy
    }
}

// MARK: - Mock Data

enum PartsInventoryMockData {

    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    private static func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }

    static let parts: [DisplayPart] = [
        DisplayPart(
            partNumber: "PN-900-SEAL",
            name: "Hydraulic Seal Kit",
            description: "Complete seal kit for primary hydraulic pump interface. Includes O-rings, gaskets, and retainer clips.",
            category: .hydraulic,
            unitCost: 245.00,
            stockQuantity: 12,
            minimumStock: 5,
            warehouseLocation: "Aisle 3, Shelf B-12",
            supplierName: "Parker Hannifin",
            leadTimeDays: 5,
            lastRestockedAt: daysAgo(14)
        ),
        DisplayPart(
            partNumber: "PN-SKF-6208",
            name: "SKF 6208-2RS Bearing",
            description: "Deep groove ball bearing for conveyor drive assemblies. Sealed, maintenance-free.",
            category: .mechanical,
            unitCost: 38.50,
            stockQuantity: 24,
            minimumStock: 10,
            warehouseLocation: "Aisle 1, Shelf A-04",
            supplierName: "SKF Industrial",
            leadTimeDays: 3,
            lastRestockedAt: daysAgo(7)
        ),
        DisplayPart(
            partNumber: "PN-VRM-22",
            name: "Voltage Regulator Module VRM-22",
            description: "Industrial voltage regulator module for transformer calibration. Input: 240V, Output: 24V DC.",
            category: .electrical,
            unitCost: 890.00,
            stockQuantity: 3,
            minimumStock: 2,
            warehouseLocation: "Aisle 5, Shelf E-01",
            supplierName: "Siemens Industrial",
            leadTimeDays: 10,
            lastRestockedAt: daysAgo(30)
        ),
        DisplayPart(
            partNumber: "PN-FILTER-HC",
            name: "HVAC Filter Cartridge",
            description: "High-efficiency particulate filter for industrial HVAC systems. MERV-13 rated.",
            category: .consumable,
            unitCost: 45.00,
            stockQuantity: 48,
            minimumStock: 20,
            warehouseLocation: "Aisle 2, Shelf C-08",
            supplierName: "Donaldson Filtration",
            leadTimeDays: 2,
            lastRestockedAt: daysAgo(3)
        ),
        DisplayPart(
            partNumber: "PN-PNF-QC4",
            name: "Pneumatic Quick-Connect Fitting",
            description: "1/4\" push-to-connect pneumatic fitting. Brass construction, rated to 150 PSI.",
            category: .pneumatic,
            unitCost: 12.75,
            stockQuantity: 2,
            minimumStock: 15,
            warehouseLocation: "Aisle 4, Shelf D-06",
            supplierName: "SMC Pneumatics",
            leadTimeDays: 4,
            lastRestockedAt: daysAgo(45)
        ),
        DisplayPart(
            partNumber: "PN-SENS-VIB3",
            name: "Vibration Sensor Module v3",
            description: "Industrial vibration monitoring sensor. Firmware v3.0.1 compatible. MEMS accelerometer.",
            category: .sensor,
            unitCost: 320.00,
            stockQuantity: 8,
            minimumStock: 4,
            warehouseLocation: "Aisle 5, Shelf E-09",
            supplierName: "Honeywell Industrial",
            leadTimeDays: 7,
            lastRestockedAt: daysAgo(21)
        ),
        DisplayPart(
            partNumber: "PN-HYD-HOSE",
            name: "High-Pressure Hydraulic Hose",
            description: "3/8\" high-pressure braided steel hose assembly. Rated 5000 PSI. 2m length with JIC fittings.",
            category: .hydraulic,
            unitCost: 185.00,
            stockQuantity: 6,
            minimumStock: 3,
            warehouseLocation: "Aisle 3, Shelf B-20",
            supplierName: "Gates Industrial",
            leadTimeDays: 6,
            lastRestockedAt: daysAgo(10)
        ),
        DisplayPart(
            partNumber: "PN-OIL-15W40",
            name: "15W-40 Synthetic Oil (20L)",
            description: "Full synthetic heavy-duty engine oil. 20-liter drum. Meets API CK-4/SN Plus specification.",
            category: .consumable,
            unitCost: 89.00,
            stockQuantity: 0,
            minimumStock: 4,
            warehouseLocation: "Aisle 6, Floor F-01",
            supplierName: "Shell Lubricants",
            leadTimeDays: 3,
            lastRestockedAt: daysAgo(60)
        ),
    ]

    static let orders: [DisplayPartsOrder] = [
        DisplayPartsOrder(
            orderNumber: "PO-2026-041",
            partName: "15W-40 Synthetic Oil (20L)",
            partNumber: "PN-OIL-15W40",
            quantity: 8,
            unitCost: 89.00,
            supplierName: "Shell Lubricants",
            status: .shipped,
            orderedAt: daysAgo(3),
            expectedDeliveryAt: daysFromNow(1),
            orderedBy: "David Park"
        ),
        DisplayPartsOrder(
            orderNumber: "PO-2026-040",
            partName: "Pneumatic Quick-Connect Fitting",
            partNumber: "PN-PNF-QC4",
            quantity: 30,
            unitCost: 12.75,
            supplierName: "SMC Pneumatics",
            status: .confirmed,
            orderedAt: daysAgo(2),
            expectedDeliveryAt: daysFromNow(3),
            orderedBy: "Sarah Mitchel"
        ),
        DisplayPartsOrder(
            orderNumber: "PO-2026-039",
            partName: "SKF 6208-2RS Bearing",
            partNumber: "PN-SKF-6208",
            quantity: 12,
            unitCost: 38.50,
            supplierName: "SKF Industrial",
            status: .delivered,
            orderedAt: daysAgo(10),
            expectedDeliveryAt: daysAgo(7),
            orderedBy: "Marcus Chen"
        ),
        DisplayPartsOrder(
            orderNumber: "PO-2026-038",
            partName: "Voltage Regulator Module VRM-22",
            partNumber: "PN-VRM-22",
            quantity: 2,
            unitCost: 890.00,
            supplierName: "Siemens Industrial",
            status: .pending,
            orderedAt: daysAgo(1),
            expectedDeliveryAt: daysFromNow(9),
            orderedBy: "Emily Rodriguez"
        ),
    ]
}
