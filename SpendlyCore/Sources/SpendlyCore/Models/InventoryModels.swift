import Foundation
import SwiftData

// MARK: - Inventory Item (Part)

@Model
public class InventoryItem {
    public var id: UUID
    public var orgID: UUID
    public var partNumber: String
    public var name: String
    public var itemDescription: String?
    public var category: String
    public var unitCost: Double
    public var stockQuantity: Int
    public var minimumStock: Int
    public var warehouseLocation: String?
    public var supplierName: String?
    public var leadTimeDays: Int?
    public var isActive: Bool
    public var lastRestockedAt: Date?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        partNumber: String = "",
        name: String = "",
        itemDescription: String? = nil,
        category: String = "",
        unitCost: Double = 0,
        stockQuantity: Int = 0,
        minimumStock: Int = 5,
        warehouseLocation: String? = nil,
        supplierName: String? = nil,
        leadTimeDays: Int? = nil,
        isActive: Bool = true,
        lastRestockedAt: Date? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.partNumber = partNumber
        self.name = name
        self.itemDescription = itemDescription
        self.category = category
        self.unitCost = unitCost
        self.stockQuantity = stockQuantity
        self.minimumStock = minimumStock
        self.warehouseLocation = warehouseLocation
        self.supplierName = supplierName
        self.leadTimeDays = leadTimeDays
        self.isActive = isActive
        self.lastRestockedAt = lastRestockedAt
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Parts Order

@Model
public class PartsOrder {
    public var id: UUID
    public var orgID: UUID
    public var orderNumber: String
    public var inventoryItemID: UUID
    public var quantity: Int
    public var unitCost: Double
    public var totalCost: Double
    public var supplierName: String
    public var status: String
    public var orderedAt: Date
    public var expectedDeliveryAt: Date?
    public var deliveredAt: Date?
    public var notes: String?
    public var orderedByID: UUID
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        orderNumber: String = "",
        inventoryItemID: UUID = UUID(),
        quantity: Int = 1,
        unitCost: Double = 0,
        totalCost: Double = 0,
        supplierName: String = "",
        status: String = "pending",
        orderedAt: Date = Date(),
        expectedDeliveryAt: Date? = nil,
        deliveredAt: Date? = nil,
        notes: String? = nil,
        orderedByID: UUID = UUID(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.orderNumber = orderNumber
        self.inventoryItemID = inventoryItemID
        self.quantity = quantity
        self.unitCost = unitCost
        self.totalCost = totalCost
        self.supplierName = supplierName
        self.status = status
        self.orderedAt = orderedAt
        self.expectedDeliveryAt = expectedDeliveryAt
        self.deliveredAt = deliveredAt
        self.notes = notes
        self.orderedByID = orderedByID
        self.syncStatus = syncStatus
    }
}
