import SwiftUI
import SpendlyCore

// MARK: - Chat Room View

struct ChatRoomView: View {
    @Bindable var viewModel: TeamChatViewModel
    let room: ChatRoomSummary

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            chatHeader
            chatMessageList
            typingIndicatorBar
            chatInputBar
        }
        .background(SpendlyColors.background(for: colorScheme))
        .navigationBarHidden(true)
        .onAppear {
            viewModel.markRoomAsRead(room)
        }
    }

    // MARK: - Header

    private var chatHeader: some View {
        VStack(spacing: 0) {
            VStack(spacing: SpendlySpacing.md) {
                // Top row: back button, ticket info, info button
                HStack(spacing: SpendlySpacing.md) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(SpendlyColors.secondary)
                            .frame(width: 32, height: 32)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(room.ticketNumber)
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text(room.ticketCategory)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    Spacer()

                    Button {
                        // Info action
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.system(size: 20))
                            .foregroundStyle(SpendlyColors.accent)
                            .frame(width: 36, height: 36)
                    }
                }

                // Participant avatars row
                HStack(spacing: SpendlySpacing.sm) {
                    // Overlapping avatars
                    HStack(spacing: -8) {
                        ForEach(viewModel.visibleParticipants) { participant in
                            SPAvatar(
                                imageURL: participant.avatarURL,
                                initials: participant.initials,
                                size: .md,
                                statusDot: participant.presenceStatus.dotColor
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(SpendlyColors.surface(for: colorScheme), lineWidth: 2)
                            )
                        }

                        if viewModel.overflowParticipantCount > 0 {
                            Circle()
                                .fill(SpendlyColors.backgroundLight)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("+\(viewModel.overflowParticipantCount)")
                                        .font(SpendlyFont.caption())
                                        .fontWeight(.medium)
                                        .foregroundStyle(SpendlyColors.secondary)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(SpendlyColors.surface(for: colorScheme), lineWidth: 2)
                                )
                        }
                    }

                    // Divider
                    Rectangle()
                        .fill(SpendlyColors.secondary.opacity(0.2))
                        .frame(width: 1, height: 24)
                        .padding(.horizontal, SpendlySpacing.xs)

                    // Active count badge
                    Text("\(viewModel.activeParticipantCount) Members Active")
                        .font(SpendlyFont.caption())
                        .fontWeight(.medium)
                        .foregroundStyle(SpendlyColors.secondary)
                        .padding(.horizontal, SpendlySpacing.sm)
                        .padding(.vertical, SpendlySpacing.xs)
                        .background(SpendlyColors.backgroundLight)
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
                }
            }
            .padding(SpendlySpacing.lg)

            // Bottom border
            Rectangle()
                .fill(SpendlyColors.secondary.opacity(0.15))
                .frame(height: 1)
        }
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Message List

    private var chatMessageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: SpendlySpacing.xl) {
                    ForEach(viewModel.messages) { message in
                        messageView(for: message)
                            .id(message.id)
                    }
                }
                .padding(SpendlySpacing.lg)
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                if let lastID = viewModel.messages.last?.id {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastID, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Message Routing

    @ViewBuilder
    private func messageView(for message: TeamChatMessage) -> some View {
        switch message.kind {
        case .system:
            systemMessageView(message)
        case .text:
            if message.isOutgoing {
                outgoingMessageView(message)
            } else {
                incomingMessageView(message)
            }
        case .image:
            if message.isOutgoing {
                outgoingPhotoMessageView(message)
            } else {
                incomingPhotoMessageView(message)
            }
        }
    }

    // MARK: - System Message

    private func systemMessageView(_ message: TeamChatMessage) -> some View {
        HStack {
            Spacer()
            let isImportant = message.content.lowercased().hasPrefix("system:")
            Text(isImportant
                ? "\(message.content) \u{2022} \(viewModel.timeString(from: message.timestamp))"
                : message.content
            )
                .font(.system(size: 11, weight: isImportant ? .bold : .medium))
                .tracking(isImportant ? 0.5 : 0)
                .textCase(isImportant ? .uppercase : nil)
                .foregroundStyle(isImportant ? SpendlyColors.accent : SpendlyColors.secondary)
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.xs)
                .background(
                    isImportant
                        ? SpendlyColors.accent.opacity(0.1)
                        : SpendlyColors.secondary.opacity(0.1)
                )
                .clipShape(Capsule())
                .overlay(
                    isImportant
                    ? Capsule().strokeBorder(SpendlyColors.accent.opacity(0.2), lineWidth: 1)
                    : nil
                )
            Spacer()
        }
    }

    // MARK: - Incoming Message

    private func incomingMessageView(_ message: TeamChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: SpendlySpacing.md) {
            SPAvatar(
                imageURL: message.senderAvatarURL,
                initials: message.senderInitials ?? "??",
                size: .sm
            )

            VStack(alignment: .leading, spacing: 2) {
                if let name = message.senderName, let role = message.senderRole {
                    Text("\(name) - \(role)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(SpendlyColors.secondary)
                        .padding(.leading, SpendlySpacing.xs)
                }

                Text(message.content)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .padding(SpendlySpacing.md)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(IncomingBubbleShape())
                    .overlay(
                        IncomingBubbleShape()
                            .strokeBorder(SpendlyColors.secondary.opacity(0.15), lineWidth: 1)
                    )
            }

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Outgoing Message

    private func outgoingMessageView(_ message: TeamChatMessage) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(message.content)
                .font(SpendlyFont.body())
                .foregroundStyle(.white)
                .padding(SpendlySpacing.md)
                .background(SpendlyColors.primary)
                .clipShape(OutgoingBubbleShape())

            if message.isRead {
                Text("Read \(viewModel.timeString(from: message.timestamp))")
                    .font(.system(size: 10))
                    .foregroundStyle(SpendlyColors.secondary.opacity(0.7))
                    .padding(.trailing, SpendlySpacing.xs)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.leading, 40)
    }

    // MARK: - Incoming Photo Message

    private func incomingPhotoMessageView(_ message: TeamChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: SpendlySpacing.md) {
            SPAvatar(
                imageURL: message.senderAvatarURL,
                initials: message.senderInitials ?? "??",
                size: .sm
            )

            VStack(alignment: .leading, spacing: 2) {
                if let name = message.senderName, let role = message.senderRole {
                    Text("\(name) - \(role)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(SpendlyColors.secondary)
                        .padding(.leading, SpendlySpacing.xs)
                }

                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    // Photo placeholder
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .fill(SpendlyColors.secondary.opacity(0.15))
                        .frame(height: 160)
                        .overlay(
                            VStack(spacing: SpendlySpacing.sm) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                                Text("Photo Attachment")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                            }
                        )

                    if !message.content.isEmpty {
                        Text(message.content)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .padding(.horizontal, SpendlySpacing.xs)
                    }
                }
                .padding(SpendlySpacing.sm)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(IncomingBubbleShape())
                .overlay(
                    IncomingBubbleShape()
                        .strokeBorder(SpendlyColors.secondary.opacity(0.15), lineWidth: 1)
                )
            }

            Spacer(minLength: 40)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Outgoing Photo Message

    private func outgoingPhotoMessageView(_ message: TeamChatMessage) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            VStack(alignment: .trailing, spacing: SpendlySpacing.sm) {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 160)
                    .overlay(
                        Image(systemName: "photo.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white.opacity(0.7))
                    )

                if !message.content.isEmpty {
                    Text(message.content)
                        .font(SpendlyFont.body())
                        .foregroundStyle(.white)
                        .padding(.horizontal, SpendlySpacing.xs)
                }
            }
            .padding(SpendlySpacing.sm)
            .background(SpendlyColors.primary)
            .clipShape(OutgoingBubbleShape())

            if message.isRead {
                Text("Read \(viewModel.timeString(from: message.timestamp))")
                    .font(.system(size: 10))
                    .foregroundStyle(SpendlyColors.secondary.opacity(0.7))
                    .padding(.trailing, SpendlySpacing.xs)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.leading, 40)
    }

    // MARK: - Typing Indicator

    @ViewBuilder
    private var typingIndicatorBar: some View {
        if let typingText = viewModel.typingIndicatorText {
            HStack(spacing: SpendlySpacing.sm) {
                TypingDotsView()
                Text(typingText)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
                Spacer()
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.xs)
            .background(SpendlyColors.background(for: colorScheme))
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Input Bar

    private var chatInputBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(SpendlyColors.secondary.opacity(0.15))
                .frame(height: 1)

            HStack(spacing: SpendlySpacing.sm) {
                // Attachment button
                Button {
                    viewModel.isShowingAttachmentPicker = true
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 24))
                        .foregroundStyle(SpendlyColors.secondary)
                        .frame(width: 40, height: 40)
                }

                // Text input with image button overlay
                ZStack(alignment: .trailing) {
                    TextField("Type a message...", text: $viewModel.messageText)
                        .font(SpendlyFont.body())
                        .padding(.horizontal, SpendlySpacing.lg)
                        .padding(.trailing, 36) // space for image button
                        .padding(.vertical, SpendlySpacing.sm + 2)
                        .background(SpendlyColors.backgroundLight)
                        .clipShape(Capsule())
                        .focused($isInputFocused)
                        .onSubmit {
                            viewModel.sendMessage()
                        }

                    Button {
                        viewModel.isShowingImagePicker = true
                    } label: {
                        Image(systemName: "photo")
                            .font(.system(size: 18))
                            .foregroundStyle(SpendlyColors.secondary)
                            .frame(width: 32, height: 32)
                    }
                    .padding(.trailing, SpendlySpacing.sm)
                }

                // Send button
                Button {
                    viewModel.sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(SpendlyColors.primary)
                        .clipShape(Circle())
                        .shadow(color: SpendlyColors.primary.opacity(0.3), radius: 6, y: 2)
                }
                .disabled(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(viewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
            }
            .padding(SpendlySpacing.lg)
        }
        .background(SpendlyColors.surface(for: colorScheme))
    }
}

// MARK: - Bubble Shapes

struct IncomingBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let tailRadius: CGFloat = 4

        var path = Path()
        // Start from bottom-left (where tail removes corner radius)
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Left side up
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        // Top-left corner
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        // Top-right corner
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        // Right side down
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        // Bottom-right corner
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        // Bottom edge back to small tail corner
        path.addLine(to: CGPoint(x: rect.minX + tailRadius, y: rect.maxY))
        // Tiny bottom-left (tail effect)
        path.addArc(
            center: CGPoint(x: rect.minX + tailRadius, y: rect.maxY - tailRadius),
            radius: tailRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

struct OutgoingBubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 16
        let tailRadius: CGFloat = 4

        var path = Path()
        // Start from bottom-right (tail)
        path.move(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Bottom edge to left
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        // Bottom-left corner
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        // Left side up
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        // Top-left corner
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        // Top-right corner
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        // Right side down to tail
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - tailRadius))
        // Tiny bottom-right (tail effect)
        path.addArc(
            center: CGPoint(x: rect.maxX - tailRadius, y: rect.maxY - tailRadius),
            radius: tailRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

// MARK: - Insettable Bubble Shape Conformances

extension IncomingBubbleShape: InsettableShape {
    func inset(by amount: CGFloat) -> some InsettableShape {
        IncomingBubbleInset(amount: amount)
    }
}

struct IncomingBubbleInset: InsettableShape {
    var amount: CGFloat

    func inset(by amount: CGFloat) -> IncomingBubbleInset {
        IncomingBubbleInset(amount: self.amount + amount)
    }

    func path(in rect: CGRect) -> Path {
        IncomingBubbleShape().path(in: rect.insetBy(dx: amount, dy: amount))
    }
}

extension OutgoingBubbleShape: InsettableShape {
    func inset(by amount: CGFloat) -> some InsettableShape {
        OutgoingBubbleInset(amount: amount)
    }
}

struct OutgoingBubbleInset: InsettableShape {
    var amount: CGFloat

    func inset(by amount: CGFloat) -> OutgoingBubbleInset {
        OutgoingBubbleInset(amount: self.amount + amount)
    }

    func path(in rect: CGRect) -> Path {
        OutgoingBubbleShape().path(in: rect.insetBy(dx: amount, dy: amount))
    }
}

// MARK: - Typing Dots Animation

struct TypingDotsView: View {
    @State private var animatingDot: Int = 0

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(SpendlyColors.secondary)
                    .frame(width: 6, height: 6)
                    .scaleEffect(animatingDot == index ? 1.3 : 0.8)
                    .opacity(animatingDot == index ? 1.0 : 0.4)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                animatingDot = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    animatingDot = 1
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                    animatingDot = 2
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let vm = TeamChatViewModel()
    ChatRoomView(
        viewModel: vm,
        room: TeamChatMockData.chatRooms[0]
    )
}
