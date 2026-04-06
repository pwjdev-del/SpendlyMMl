import SwiftUI
import SpendlyCore

// MARK: - Team Chat Root View (Chat Room List)

public struct TeamChatRootView: View {
    @State private var viewModel = TeamChatViewModel()

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        VStack(spacing: 0) {
            headerSection
            searchBar
            chatRoomList
        }
        .background(SpendlyColors.background(for: colorScheme))
        .navigationTitle("Team Chat")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: TeamChatDestination.self) { destination in
            switch destination {
            case .chatRoom(let roomID):
                if let room = viewModel.chatRooms.first(where: { $0.id == roomID }) {
                    ChatRoomView(viewModel: viewModel, room: room)
                        .onAppear { viewModel.selectRoom(room) }
                } else {
                    ContentUnavailableView("Chat Not Found", systemImage: "bubble.left.and.bubble.right", description: Text("This chat room is no longer available."))
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(viewModel.chatRooms.count) active conversations")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)

                Spacer()

                // Unread badge
                if viewModel.totalUnreadCount > 0 {
                    SPBadge("\(viewModel.totalUnreadCount) unread", style: .error)
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.sm)
        }
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Search

    private var searchBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(SpendlyColors.secondary)

                TextField("Search conversations...", text: $viewModel.searchText)
                    .font(SpendlyFont.body())

                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }
            .padding(.horizontal, SpendlySpacing.md)
            .padding(.vertical, SpendlySpacing.sm + 2)
            .background(SpendlyColors.backgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.md)

            Rectangle()
                .fill(SpendlyColors.secondary.opacity(0.12))
                .frame(height: 1)
        }
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Chat Room List

    private var chatRoomList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredRooms) { room in
                    chatRoomRow(room)

                    // Divider between rows
                    if room.id != viewModel.filteredRooms.last?.id {
                        Rectangle()
                            .fill(SpendlyColors.secondary.opacity(0.1))
                            .frame(height: 1)
                            .padding(.leading, 72)
                    }
                }
            }
            .padding(.bottom, SpendlySpacing.xxxl)
        }
    }

    // MARK: - Chat Room Row

    private func chatRoomRow(_ room: ChatRoomSummary) -> some View {
        NavigationLink(value: TeamChatDestination.chatRoom(roomID: room.id)) {
            HStack(spacing: SpendlySpacing.md) {
                // Ticket icon avatar
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(SpendlyColors.primary.opacity(0.1))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "message.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(SpendlyColors.primary)
                        )

                    // Active status dot
                    if room.isActive {
                        Circle()
                            .fill(SpendlyColors.success)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .strokeBorder(.white, lineWidth: 2)
                            )
                            .offset(x: 2, y: 2)
                    }
                }

                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    // Top row: ticket number + time
                    HStack {
                        Text(room.ticketNumber)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        SPBadge(room.ticketCategory, style: .info)

                        Spacer()

                        Text(viewModel.relativeTimeString(from: room.lastMessageTime))
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    // Last message
                    HStack {
                        Text(room.lastMessage)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                            .lineLimit(2)

                        Spacer(minLength: SpendlySpacing.sm)

                        // Unread badge
                        if room.unreadCount > 0 {
                            Text("\(room.unreadCount)")
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(minWidth: 20, minHeight: 20)
                                .background(SpendlyColors.accent)
                                .clipShape(Circle())
                        }
                    }

                    // Participant mini-avatars
                    HStack(spacing: -6) {
                        ForEach(room.participants.prefix(4)) { participant in
                            SPAvatar(
                                imageURL: participant.avatarURL,
                                initials: participant.initials,
                                size: .sm,
                                statusDot: participant.presenceStatus == .online ? SpendlyColors.success : nil
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(SpendlyColors.surface(for: colorScheme), lineWidth: 1.5)
                            )
                            .frame(width: 24, height: 24)
                        }

                        if room.participants.count > 4 {
                            Text("+\(room.participants.count - 4)")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(SpendlyColors.secondary)
                                .padding(.leading, SpendlySpacing.xs)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.md)
            .background(
                room.unreadCount > 0
                    ? SpendlyColors.accent.opacity(0.03)
                    : Color.clear
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    TeamChatRootView()
}
