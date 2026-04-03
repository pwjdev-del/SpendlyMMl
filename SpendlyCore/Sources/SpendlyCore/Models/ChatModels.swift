import Foundation
import SwiftData

// MARK: - Chat Room

@Model
public class ChatRoom {
    public var id: UUID
    public var orgID: UUID
    public var name: String?
    public var isGroup: Bool
    public var participantIDs: [UUID]
    public var lastMessageAt: Date?
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        name: String? = nil,
        isGroup: Bool = false,
        participantIDs: [UUID] = [],
        lastMessageAt: Date? = nil,
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.name = name
        self.isGroup = isGroup
        self.participantIDs = participantIDs
        self.lastMessageAt = lastMessageAt
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Chat Message

@Model
public class ChatMessage {
    public var id: UUID
    public var orgID: UUID
    public var roomID: UUID
    public var senderID: UUID
    public var content: String
    public var messageType: ChatMessageType
    public var attachmentURL: String?
    public var isRead: Bool
    public var sentAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        roomID: UUID = UUID(),
        senderID: UUID = UUID(),
        content: String = "",
        messageType: ChatMessageType = .text,
        attachmentURL: String? = nil,
        isRead: Bool = false,
        sentAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.roomID = roomID
        self.senderID = senderID
        self.content = content
        self.messageType = messageType
        self.attachmentURL = attachmentURL
        self.isRead = isRead
        self.sentAt = sentAt
        self.syncStatus = syncStatus
    }
}
