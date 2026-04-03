import Foundation
import SwiftData

// MARK: - Estimate

@Model
public class Estimate {
    public var id: UUID
    public var orgID: UUID
    public var customerID: UUID
    public var createdByID: UUID
    public var estimateNumber: String
    public var status: EstimateStatus
    public var subtotal: Double
    public var taxRate: Double
    public var taxAmount: Double
    public var total: Double
    public var notes: String?
    public var validUntil: Date?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        customerID: UUID = UUID(),
        createdByID: UUID = UUID(),
        estimateNumber: String = "",
        status: EstimateStatus = .draft,
        subtotal: Double = 0,
        taxRate: Double = 0,
        taxAmount: Double = 0,
        total: Double = 0,
        notes: String? = nil,
        validUntil: Date? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.customerID = customerID
        self.createdByID = createdByID
        self.estimateNumber = estimateNumber
        self.status = status
        self.subtotal = subtotal
        self.taxRate = taxRate
        self.taxAmount = taxAmount
        self.total = total
        self.notes = notes
        self.validUntil = validUntil
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Estimate Item

@Model
public class EstimateItem {
    public var id: UUID
    public var orgID: UUID
    public var estimateID: UUID
    public var itemDescription: String
    public var quantity: Double
    public var unitPrice: Double
    public var total: Double
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        estimateID: UUID = UUID(),
        itemDescription: String = "",
        quantity: Double = 1,
        unitPrice: Double = 0,
        total: Double = 0,
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.estimateID = estimateID
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.total = total
        self.syncStatus = syncStatus
    }
}

// MARK: - Invoice

@Model
public class Invoice {
    public var id: UUID
    public var orgID: UUID
    public var customerID: UUID
    public var estimateID: UUID?
    public var serviceTripID: UUID?
    public var invoiceNumber: String
    public var status: InvoiceStatus
    public var subtotal: Double
    public var taxRate: Double
    public var taxAmount: Double
    public var total: Double
    public var dueDate: Date?
    public var paidAt: Date?
    public var notes: String?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        customerID: UUID = UUID(),
        estimateID: UUID? = nil,
        serviceTripID: UUID? = nil,
        invoiceNumber: String = "",
        status: InvoiceStatus = .draft,
        subtotal: Double = 0,
        taxRate: Double = 0,
        taxAmount: Double = 0,
        total: Double = 0,
        dueDate: Date? = nil,
        paidAt: Date? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.customerID = customerID
        self.estimateID = estimateID
        self.serviceTripID = serviceTripID
        self.invoiceNumber = invoiceNumber
        self.status = status
        self.subtotal = subtotal
        self.taxRate = taxRate
        self.taxAmount = taxAmount
        self.total = total
        self.dueDate = dueDate
        self.paidAt = paidAt
        self.notes = notes
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Invoice Item

@Model
public class InvoiceItem {
    public var id: UUID
    public var orgID: UUID
    public var invoiceID: UUID
    public var itemDescription: String
    public var quantity: Double
    public var unitPrice: Double
    public var total: Double
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        invoiceID: UUID = UUID(),
        itemDescription: String = "",
        quantity: Double = 1,
        unitPrice: Double = 0,
        total: Double = 0,
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.invoiceID = invoiceID
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.total = total
        self.syncStatus = syncStatus
    }
}

// MARK: - Expense

@Model
public class Expense {
    public var id: UUID
    public var orgID: UUID
    public var userID: UUID
    public var serviceTripID: UUID?
    public var category: String
    public var amount: Double
    public var currency: String
    public var expenseDescription: String?
    public var receiptURL: String?
    public var status: ExpenseStatus
    public var date: Date
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        userID: UUID = UUID(),
        serviceTripID: UUID? = nil,
        category: String = "",
        amount: Double = 0,
        currency: String = "USD",
        expenseDescription: String? = nil,
        receiptURL: String? = nil,
        status: ExpenseStatus = .pending,
        date: Date = Date(),
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.userID = userID
        self.serviceTripID = serviceTripID
        self.category = category
        self.amount = amount
        self.currency = currency
        self.expenseDescription = expenseDescription
        self.receiptURL = receiptURL
        self.status = status
        self.date = date
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}
