import Foundation
import SwiftData

// MARK: - Notification

@Model
public class SPNotification {
    public var id: UUID
    public var orgID: UUID
    public var userID: UUID
    public var title: String
    public var body: String
    public var notificationType: NotificationType
    public var isRead: Bool
    public var relatedID: UUID?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        userID: UUID = UUID(),
        title: String = "",
        body: String = "",
        notificationType: NotificationType = .systemAlert,
        isRead: Bool = false,
        relatedID: UUID? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.userID = userID
        self.title = title
        self.body = body
        self.notificationType = notificationType
        self.isRead = isRead
        self.relatedID = relatedID
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Subscription

@Model
public class Subscription {
    public var id: UUID
    public var orgID: UUID
    public var planName: String
    public var status: SubscriptionStatus
    public var stripeCustomerID: String?
    public var stripeSubscriptionID: String?
    public var currentPeriodStart: Date
    public var currentPeriodEnd: Date
    public var maxUsers: Int
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        planName: String = "",
        status: SubscriptionStatus = .active,
        stripeCustomerID: String? = nil,
        stripeSubscriptionID: String? = nil,
        currentPeriodStart: Date = Date(),
        currentPeriodEnd: Date = Date(),
        maxUsers: Int = 5,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.planName = planName
        self.status = status
        self.stripeCustomerID = stripeCustomerID
        self.stripeSubscriptionID = stripeSubscriptionID
        self.currentPeriodStart = currentPeriodStart
        self.currentPeriodEnd = currentPeriodEnd
        self.maxUsers = maxUsers
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Subscription Module

@Model
public class SubscriptionModule {
    public var id: UUID
    public var orgID: UUID
    public var subscriptionID: UUID
    public var moduleName: String
    public var isEnabled: Bool
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        subscriptionID: UUID = UUID(),
        moduleName: String = "",
        isEnabled: Bool = true,
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.subscriptionID = subscriptionID
        self.moduleName = moduleName
        self.isEnabled = isEnabled
        self.syncStatus = syncStatus
    }
}

// MARK: - User Settings

@Model
public class UserSettings {
    public var id: UUID
    public var orgID: UUID
    public var userID: UUID
    public var useBiometrics: Bool
    public var notificationsEnabled: Bool
    public var preferredLanguage: String
    public var darkModePreference: String
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        userID: UUID = UUID(),
        useBiometrics: Bool = false,
        notificationsEnabled: Bool = true,
        preferredLanguage: String = "en",
        darkModePreference: String = "system",
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.userID = userID
        self.useBiometrics = useBiometrics
        self.notificationsEnabled = notificationsEnabled
        self.preferredLanguage = preferredLanguage
        self.darkModePreference = darkModePreference
        self.syncStatus = syncStatus
    }
}

// MARK: - Org Branding

@Model
public class OrgBranding {
    public var id: UUID
    public var orgID: UUID
    public var logoURL: String?
    public var primaryColor: String
    public var secondaryColor: String
    public var accentColor: String
    public var fontName: String?
    public var tagline: String?
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        logoURL: String? = nil,
        primaryColor: String = "#007AFF",
        secondaryColor: String = "#5856D6",
        accentColor: String = "#FF9500",
        fontName: String? = nil,
        tagline: String? = nil,
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.logoURL = logoURL
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.accentColor = accentColor
        self.fontName = fontName
        self.tagline = tagline
        self.syncStatus = syncStatus
    }
}
