import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Navigation Destination

enum TeamChatDestination: Hashable {
    case chatRoom(roomID: UUID)
}

// MARK: - ViewModel

@Observable
final class TeamChatViewModel {

    // MARK: - Data

    var chatRooms: [ChatRoomSummary] = TeamChatMockData.chatRooms
    var messages: [TeamChatMessage] = TeamChatMockData.tk98234Messages
    var participants: [ChatParticipant] = TeamChatMockData.participants
    var currentUserID: UUID = TeamChatMockData.currentUserID

    // MARK: - Input State

    var messageText: String = ""
    var isShowingAttachmentPicker: Bool = false
    var isShowingImagePicker: Bool = false

    // MARK: - Navigation

    var navigationPath: [TeamChatDestination] = []
    var selectedRoom: ChatRoomSummary? = nil

    // MARK: - Presence / Typing

    var typingParticipantIDs: Set<UUID> = []

    // MARK: - Search

    var searchText: String = ""

    // MARK: - Computed Properties

    var filteredRooms: [ChatRoomSummary] {
        if searchText.isEmpty { return chatRooms }
        let query = searchText.lowercased()
        return chatRooms.filter { room in
            room.ticketNumber.lowercased().contains(query) ||
            room.ticketCategory.lowercased().contains(query) ||
            room.lastMessage.lowercased().contains(query)
        }
    }

    var totalUnreadCount: Int {
        chatRooms.reduce(0) { $0 + $1.unreadCount }
    }

    var activeParticipantCount: Int {
        participants.filter { $0.presenceStatus == .online || $0.presenceStatus == .typing }.count
    }

    var typingIndicatorText: String? {
        let typingNames = participants
            .filter { typingParticipantIDs.contains($0.id) && $0.id != currentUserID }
            .map { $0.name.components(separatedBy: " ").first ?? $0.name }

        switch typingNames.count {
        case 0: return nil
        case 1: return "\(typingNames[0]) is typing..."
        case 2: return "\(typingNames[0]) and \(typingNames[1]) are typing..."
        default: return "\(typingNames[0]) and \(typingNames.count - 1) others are typing..."
        }
    }

    var overflowParticipantCount: Int {
        let maxVisible = 3
        return max(0, participants.count - maxVisible)
    }

    var visibleParticipants: [ChatParticipant] {
        Array(participants.prefix(3))
    }

    // MARK: - Actions

    func sendMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let newMessage = TeamChatMessage(
            id: UUID(),
            senderID: currentUserID,
            senderName: "You",
            senderRole: "Service Manager",
            senderInitials: "ME",
            senderAvatarURL: nil,
            content: trimmed,
            kind: .text,
            timestamp: Date(),
            isRead: false,
            isOutgoing: true
        )

        withAnimation(.easeInOut(duration: 0.25)) {
            messages.append(newMessage)
        }

        messageText = ""

        // Simulate typing indicator from Alex after a short delay
        simulateTypingResponse()
    }

    func selectRoom(_ room: ChatRoomSummary) {
        selectedRoom = room
        // Load messages for the selected room (for now, always show TK-98234 conversation)
        messages = TeamChatMockData.tk98234Messages
        navigationPath.append(.chatRoom(roomID: room.id))
    }

    func markRoomAsRead(_ room: ChatRoomSummary) {
        if let index = chatRooms.firstIndex(where: { $0.id == room.id }) {
            let updated = ChatRoomSummary(
                id: room.id,
                ticketNumber: room.ticketNumber,
                ticketCategory: room.ticketCategory,
                lastMessage: room.lastMessage,
                lastMessageTime: room.lastMessageTime,
                participants: room.participants,
                unreadCount: 0,
                isActive: room.isActive
            )
            chatRooms[index] = updated
        }
    }

    func participant(for id: UUID?) -> ChatParticipant? {
        guard let id else { return nil }
        return participants.first(where: { $0.id == id })
    }

    // MARK: - Formatting

    func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    func relativeTimeString(from date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return timeString(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }

    // MARK: - Simulated Interactions

    private func simulateTypingResponse() {
        let alexID = TeamChatMockData.alexID

        // Show typing indicator after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            withAnimation(.easeInOut(duration: 0.2)) {
                _ = self?.typingParticipantIDs.insert(alexID)
            }
        }

        // Remove typing and add response after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            withAnimation(.easeInOut(duration: 0.25)) {
                self?.typingParticipantIDs.remove(alexID)
                let response = TeamChatMessage(
                    id: UUID(),
                    senderID: alexID,
                    senderName: "Alex Rivera",
                    senderRole: "On-Site Lead",
                    senderInitials: "AR",
                    senderAvatarURL: nil,
                    content: "Got it. I'll check the parts inventory and update you shortly.",
                    kind: .text,
                    timestamp: Date(),
                    isRead: false,
                    isOutgoing: false
                )
                self?.messages.append(response)
            }
        }
    }
}
