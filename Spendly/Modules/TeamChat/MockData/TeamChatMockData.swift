import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Chat Participant

struct ChatParticipant: Identifiable {
    let id: UUID
    let name: String
    let initials: String
    let role: String
    let avatarURL: String?
    let presenceStatus: PresenceStatus
}

// MARK: - Presence Status

enum PresenceStatus: Equatable {
    case online
    case offline
    case typing

    var dotColor: Color {
        switch self {
        case .online: return SpendlyColors.success
        case .offline: return SpendlyColors.secondary
        case .typing: return SpendlyColors.accent
        }
    }

    var label: String {
        switch self {
        case .online: return "Online"
        case .offline: return "Offline"
        case .typing: return "Typing..."
        }
    }
}

// MARK: - Chat Message Type (View-Level)

enum TeamChatMessageKind {
    case text
    case image(imageName: String)
    case system
}

// MARK: - Chat Message (View-Level)

struct TeamChatMessage: Identifiable {
    let id: UUID
    let senderID: UUID?
    let senderName: String?
    let senderRole: String?
    let senderInitials: String?
    let senderAvatarURL: String?
    let content: String
    let kind: TeamChatMessageKind
    let timestamp: Date
    let isRead: Bool
    let isOutgoing: Bool
}

// MARK: - Chat Room Summary

struct ChatRoomSummary: Identifiable {
    let id: UUID
    let ticketNumber: String
    let ticketCategory: String
    let lastMessage: String
    let lastMessageTime: Date
    let participants: [ChatParticipant]
    let unreadCount: Int
    let isActive: Bool
}

// MARK: - Mock Data

enum TeamChatMockData {

    // MARK: - Stable IDs

    static let currentUserID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let alexID         = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    static let sarahID        = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!
    static let marcusID       = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
    static let jordanID       = UUID(uuidString: "00000000-0000-0000-0000-000000000005")!
    static let elenaID        = UUID(uuidString: "00000000-0000-0000-0000-000000000006")!

    static let roomTK98234    = UUID(uuidString: "10000000-0000-0000-0000-000000000001")!
    static let roomTK44092    = UUID(uuidString: "10000000-0000-0000-0000-000000000002")!
    static let roomTK44098    = UUID(uuidString: "10000000-0000-0000-0000-000000000003")!

    // MARK: - Date Helpers

    private static let calendar = Calendar.current

    private static func today(hour: Int, minute: Int) -> Date {
        let now = Date()
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now) ?? now
    }

    private static func daysAgo(_ days: Int, hour: Int, minute: Int) -> Date {
        let base = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: base) ?? base
    }

    // MARK: - Participants

    static let participants: [ChatParticipant] = [
        ChatParticipant(
            id: currentUserID,
            name: "You",
            initials: "ME",
            role: "Service Manager",
            avatarURL: nil,
            presenceStatus: .online
        ),
        ChatParticipant(
            id: alexID,
            name: "Alex Rivera",
            initials: "AR",
            role: "On-Site Lead",
            avatarURL: nil,
            presenceStatus: .online
        ),
        ChatParticipant(
            id: sarahID,
            name: "Sarah Chen",
            initials: "SC",
            role: "Support Tech",
            avatarURL: nil,
            presenceStatus: .online
        ),
        ChatParticipant(
            id: marcusID,
            name: "Marcus Chen",
            initials: "MC",
            role: "Electrician",
            avatarURL: nil,
            presenceStatus: .offline
        ),
        ChatParticipant(
            id: jordanID,
            name: "Jordan Smith",
            initials: "JS",
            role: "HVAC Specialist",
            avatarURL: nil,
            presenceStatus: .offline
        ),
    ]

    // MARK: - Ticket #TK-98234 Conversation (matches Stitch)

    static let tk98234Messages: [TeamChatMessage] = [
        // System: Technician Arrived
        TeamChatMessage(
            id: UUID(),
            senderID: nil,
            senderName: nil,
            senderRole: nil,
            senderInitials: nil,
            senderAvatarURL: nil,
            content: "System: Technician Arrived On-Site",
            kind: .system,
            timestamp: today(hour: 9, minute: 15),
            isRead: true,
            isOutgoing: false
        ),
        // Incoming: Alex Rivera
        TeamChatMessage(
            id: UUID(),
            senderID: alexID,
            senderName: "Alex Rivera",
            senderRole: "On-Site Lead",
            senderInitials: "AR",
            senderAvatarURL: nil,
            content: "Found the issue in the main circuit breaker. Looks like some water ingress.",
            kind: .text,
            timestamp: today(hour: 9, minute: 22),
            isRead: true,
            isOutgoing: false
        ),
        // Outgoing: Current user
        TeamChatMessage(
            id: UUID(),
            senderID: currentUserID,
            senderName: "You",
            senderRole: "Service Manager",
            senderInitials: "ME",
            senderAvatarURL: nil,
            content: "Copy that. Have you checked the seal on the external enclosure?",
            kind: .text,
            timestamp: today(hour: 10, minute: 24),
            isRead: true,
            isOutgoing: true
        ),
        // Incoming photo: Alex Rivera
        TeamChatMessage(
            id: UUID(),
            senderID: alexID,
            senderName: "Alex Rivera",
            senderRole: "On-Site Lead",
            senderInitials: "AR",
            senderAvatarURL: nil,
            content: "Enclosure seal is degraded. Need a replacement gasket before I can reseal this.",
            kind: .image(imageName: "photo"),
            timestamp: today(hour: 10, minute: 31),
            isRead: true,
            isOutgoing: false
        ),
        // System: Sarah joined
        TeamChatMessage(
            id: UUID(),
            senderID: nil,
            senderName: nil,
            senderRole: nil,
            senderInitials: nil,
            senderAvatarURL: nil,
            content: "Sarah Chen (Virtual) joined the chat",
            kind: .system,
            timestamp: today(hour: 10, minute: 35),
            isRead: true,
            isOutgoing: false
        ),
        // Incoming: Sarah Chen
        TeamChatMessage(
            id: UUID(),
            senderID: sarahID,
            senderName: "Sarah Chen",
            senderRole: "Support Tech",
            senderInitials: "SC",
            senderAvatarURL: nil,
            content: "Checking inventory now. We should have a type-C gasket in the van 4 inventory.",
            kind: .text,
            timestamp: today(hour: 10, minute: 38),
            isRead: true,
            isOutgoing: false
        ),
    ]

    // MARK: - Chat Room Summaries

    static let chatRooms: [ChatRoomSummary] = [
        ChatRoomSummary(
            id: roomTK98234,
            ticketNumber: "#TK-98234",
            ticketCategory: "Electrical & Programming",
            lastMessage: "Checking inventory now. We should have a type-C gasket in the van 4 inventory.",
            lastMessageTime: today(hour: 10, minute: 38),
            participants: participants,
            unreadCount: 3,
            isActive: true
        ),
        ChatRoomSummary(
            id: roomTK44092,
            ticketNumber: "#TK-44092",
            ticketCategory: "HVAC Maintenance",
            lastMessage: "Filter replacement is done. Running diagnostics now.",
            lastMessageTime: daysAgo(1, hour: 14, minute: 22),
            participants: Array(participants.prefix(3)),
            unreadCount: 0,
            isActive: true
        ),
        ChatRoomSummary(
            id: roomTK44098,
            ticketNumber: "#TK-44098",
            ticketCategory: "Plumbing Emergency",
            lastMessage: "Water main shutoff complete. Awaiting parts delivery.",
            lastMessageTime: daysAgo(2, hour: 11, minute: 5),
            participants: Array(participants.prefix(2)),
            unreadCount: 1,
            isActive: false
        ),
    ]
}
