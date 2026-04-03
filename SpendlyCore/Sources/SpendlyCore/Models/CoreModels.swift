import Foundation
import SwiftData

// MARK: - Organization

@Model
public class Organization {
    public var id: UUID
    public var name: String
    public var slug: String
    public var logoURL: String?
    public var primaryColor: String?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        name: String = "",
        slug: String = "",
        logoURL: String? = nil,
        primaryColor: String? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.logoURL = logoURL
        self.primaryColor = primaryColor
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - SPUser

@Model
public class SPUser {
    public var id: UUID
    public var orgID: UUID
    public var email: String
    public var fullName: String
    public var role: UserRole
    public var phone: String?
    public var avatarURL: String?
    public var isActive: Bool
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        email: String = "",
        fullName: String = "",
        role: UserRole = .technician,
        phone: String? = nil,
        avatarURL: String? = nil,
        isActive: Bool = true,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.email = email
        self.fullName = fullName
        self.role = role
        self.phone = phone
        self.avatarURL = avatarURL
        self.isActive = isActive
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Customer

@Model
public class Customer {
    public var id: UUID
    public var orgID: UUID
    public var name: String
    public var contactName: String?
    public var email: String?
    public var phone: String?
    public var address: String?
    public var city: String?
    public var state: String?
    public var postalCode: String?
    public var notes: String?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        name: String = "",
        contactName: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        address: String? = nil,
        city: String? = nil,
        state: String? = nil,
        postalCode: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.name = name
        self.contactName = contactName
        self.email = email
        self.phone = phone
        self.address = address
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.notes = notes
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Machine

@Model
public class Machine {
    public var id: UUID
    public var orgID: UUID
    public var customerID: UUID?
    public var name: String
    public var model: String?
    public var serialNumber: String?
    public var status: MachineStatus
    public var installDate: Date?
    public var warrantyExpiry: Date?
    public var location: String?
    public var notes: String?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        customerID: UUID? = nil,
        name: String = "",
        model: String? = nil,
        serialNumber: String? = nil,
        status: MachineStatus = .operational,
        installDate: Date? = nil,
        warrantyExpiry: Date? = nil,
        location: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.customerID = customerID
        self.name = name
        self.model = model
        self.serialNumber = serialNumber
        self.status = status
        self.installDate = installDate
        self.warrantyExpiry = warrantyExpiry
        self.location = location
        self.notes = notes
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}
