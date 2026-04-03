import SwiftUI
import SpendlyCore

public struct EmailPreviewRootView: View {
    @State private var viewModel = EmailPreviewViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        ZStack {
            if viewModel.showSuccessScreen {
                sendSuccessContent
                    .transition(.opacity)
            } else {
                emailPreviewContent
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showSuccessScreen)
    }

    // MARK: - Email Preview (Bottom Sheet Style)

    private var emailPreviewContent: some View {
        ZStack(alignment: .bottom) {
            // Overlay background
            SpendlyColors.primary.opacity(0.4)
                .ignoresSafeArea()

            // Bottom sheet container
            VStack(spacing: 0) {
                // Handle bar
                handleBar

                // Header
                sheetHeader

                // Scrollable content
                ScrollView {
                    VStack(spacing: SpendlySpacing.xxl) {
                        recipientsSection
                        emailPreviewCard
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.vertical, SpendlySpacing.lg)
                }

                // Footer actions
                footerActions
            }
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: SpendlyRadius.xl,
                    topTrailingRadius: SpendlyRadius.xl,
                    style: .continuous
                )
            )
            .shadow(color: .black.opacity(0.2), radius: 24, y: -8)
        }
    }

    // MARK: - Handle Bar

    private var handleBar: some View {
        Capsule()
            .fill(SpendlyColors.secondary.opacity(0.3))
            .frame(width: 48, height: 6)
            .padding(.top, SpendlySpacing.sm)
            .padding(.bottom, SpendlySpacing.xs)
    }

    // MARK: - Sheet Header

    private var sheetHeader: some View {
        HStack(spacing: SpendlySpacing.md) {
            Image(systemName: "envelope")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(SpendlyColors.primary)

            Text("Review Email & Report")
                .font(SpendlyFont.title())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Spacer()

            Button {
                viewModel.goBackToEdit()
            } label: {
                Image(systemName: SpendlyIcon.close.systemName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .frame(width: 36, height: 36)
                    .background(
                        colorScheme == .dark
                            ? SpendlyColors.surfaceDark
                            : SpendlyColors.backgroundLight
                    )
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .overlay(alignment: .bottom) {
            SPDivider()
        }
    }

    // MARK: - Recipients Section

    private var recipientsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            Text("RECIPIENTS")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                .tracking(1.2)

            FlowLayout(spacing: SpendlySpacing.sm) {
                ForEach(viewModel.email.recipients) { recipient in
                    recipientChip(for: recipient)
                }
            }
        }
    }

    private func recipientChip(for recipient: EmailPreviewRecipient) -> some View {
        HStack(spacing: SpendlySpacing.sm) {
            Image(systemName: recipient.role.icon)
                .font(.system(size: 12))
                .foregroundStyle(
                    recipient.role.isPrimary
                        ? SpendlyColors.primary
                        : SpendlyColors.secondaryForeground(for: colorScheme)
                )

            Text("\(recipient.role.rawValue): \(recipient.name)")
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(
                    recipient.role.isPrimary
                        ? SpendlyColors.primary
                        : SpendlyColors.secondaryForeground(for: colorScheme)
                )
        }
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.vertical, SpendlySpacing.sm)
        .background(
            recipient.role.isPrimary
                ? SpendlyColors.primary.opacity(0.1)
                : (colorScheme == .dark ? SpendlyColors.surfaceDark : SpendlyColors.backgroundLight)
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                .strokeBorder(
                    recipient.role.isPrimary
                        ? SpendlyColors.primary.opacity(0.2)
                        : SpendlyColors.secondary.opacity(0.2),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Email Preview Card

    private var emailPreviewCard: some View {
        VStack(spacing: 0) {
            // Email metadata header
            emailMetadata

            // Email body
            emailBody

            // Attachment
            attachmentBar
        }
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.xl)
                .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    private var emailMetadata: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            HStack(spacing: 0) {
                Text("Subject:")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .frame(width: 64, alignment: .leading)

                Text(viewModel.email.subject)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            HStack(spacing: 0) {
                Text("From:")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .frame(width: 64, alignment: .leading)

                Text(viewModel.email.fromAddress)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }
        }
        .padding(SpendlySpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            colorScheme == .dark
                ? SpendlyColors.surfaceDark.opacity(0.5)
                : Color(hex: "#f8fafc")
        )
        .overlay(alignment: .bottom) {
            SPDivider()
        }
    }

    private var emailBody: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            // Greeting
            Text(viewModel.email.bodyGreeting)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            // Main text
            Text(viewModel.email.bodyText)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .lineSpacing(4)

            // Work summary callout
            workSummaryCallout

            // View Report PDF button
            HStack {
                Spacer()
                Button {
                    // PDF view placeholder
                } label: {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "doc.richtext")
                            .font(.system(size: 14, weight: .semibold))
                        Text("View Report PDF")
                            .font(SpendlyFont.bodySemibold())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, SpendlySpacing.xxl)
                    .padding(.vertical, SpendlySpacing.md)
                    .background(SpendlyColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                    .shadow(color: SpendlyColors.primary.opacity(0.3), radius: 8, y: 4)
                }
                Spacer()
            }
            .padding(.vertical, SpendlySpacing.lg)

            // Closing text
            Text(viewModel.email.closingText)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            // Sign-off
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text("Best regards,")
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                Text(viewModel.email.senderName)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.primary)
            }
            .padding(.top, SpendlySpacing.md)
        }
        .padding(SpendlySpacing.xxl)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Work Summary Callout

    private var workSummaryCallout: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("WORK SUMMARY")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(SpendlyColors.accent)
                .tracking(1)

            Text(viewModel.email.workSummary)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                .lineSpacing(3)
        }
        .padding(SpendlySpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            colorScheme == .dark
                ? SpendlyColors.surfaceDark.opacity(0.3)
                : Color(hex: "#f8fafc")
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(SpendlyColors.accent)
                .frame(width: 4)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: SpendlyRadius.medium,
                        bottomLeadingRadius: SpendlyRadius.medium,
                        style: .continuous
                    )
                )
        }
    }

    // MARK: - Attachment Bar

    private var attachmentBar: some View {
        HStack(spacing: SpendlySpacing.md) {
            // File type icon
            Image(systemName: viewModel.email.attachment.fileType.icon)
                .font(.system(size: 20))
                .foregroundStyle(viewModel.email.attachment.fileType.tintColor)
                .frame(width: 40, height: 40)
                .background(viewModel.email.attachment.fileType.tintColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small))

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.email.attachment.fileName)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text(viewModel.email.attachment.fileSize)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }

            Spacer()

            Button {
                // Download placeholder
            } label: {
                Image(systemName: SpendlyIcon.download.systemName)
                    .font(.system(size: 16))
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(
            colorScheme == .dark
                ? SpendlyColors.surfaceDark.opacity(0.5)
                : Color(hex: "#f8fafc")
        )
        .overlay(alignment: .top) {
            SPDivider()
        }
    }

    // MARK: - Footer Actions

    private var footerActions: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Send Now button
            SPButton(
                "Send Now",
                icon: SpendlyIcon.send.systemName,
                style: .primary,
                isLoading: viewModel.isSending
            ) {
                viewModel.sendEmail()
            }

            // Go Back to Edit button
            Button {
                viewModel.goBackToEdit()
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: SpendlyIcon.edit.systemName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(SpendlyColors.accent)
                    Text("Go Back to Edit")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpendlySpacing.md)
                .padding(.horizontal, SpendlySpacing.lg)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                        .strokeBorder(SpendlyColors.secondary.opacity(0.3), lineWidth: 1.5)
                )
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.lg)
        .background(
            colorScheme == .dark
                ? SpendlyColors.surfaceDark.opacity(0.5)
                : Color(hex: "#f8fafc")
        )
        .overlay(alignment: .top) {
            SPDivider()
        }
    }

    // MARK: - Send Success Content

    private var sendSuccessContent: some View {
        EmailSendSuccessView(viewModel: viewModel)
    }
}

// MARK: - Send Success View

private struct EmailSendSuccessView: View {
    @Bindable var viewModel: EmailPreviewViewModel
    @Environment(\.colorScheme) private var colorScheme

    @State private var checkmarkScale: CGFloat = 0.3
    @State private var checkmarkOpacity: Double = 0
    @State private var contentOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button {
                    viewModel.backToSchedule()
                } label: {
                    Image(systemName: SpendlyIcon.close.systemName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .frame(width: 48, height: 48)
                }

                Spacer()

                Text("Confirmation")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                Color.clear.frame(width: 48, height: 48)
            }
            .padding(.horizontal, SpendlySpacing.sm)

            Spacer()

            // Success icon
            VStack(spacing: SpendlySpacing.xl) {
                ZStack {
                    Circle()
                        .fill(SpendlyColors.success.opacity(0.15))
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)

                    Circle()
                        .fill(SpendlyColors.success)
                        .frame(width: 128, height: 128)
                        .shadow(color: SpendlyColors.success.opacity(0.3), radius: 16, y: 8)
                        .overlay(
                            Image(systemName: SpendlyIcon.checkCircle.systemName)
                                .font(.system(size: 56, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                }
                .scaleEffect(checkmarkScale)
                .opacity(checkmarkOpacity)

                VStack(spacing: SpendlySpacing.sm) {
                    Text("Success!")
                        .font(SpendlyFont.financialTitle())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Text("Trip Report Sent")
                        .font(SpendlyFont.title())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                }
                .opacity(contentOpacity)
            }

            // Recipients display
            VStack(spacing: SpendlySpacing.md) {
                Text("RECIPIENTS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(SpendlyColors.primary.opacity(0.7))
                    .tracking(1.5)

                VStack(spacing: SpendlySpacing.xs) {
                    ForEach(viewModel.email.recipients) { recipient in
                        Text(recipient.name)
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
            }
            .padding(SpendlySpacing.lg)
            .frame(maxWidth: .infinity)
            .background(SpendlyColors.primary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.xl)
                    .strokeBorder(SpendlyColors.primary.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, SpendlySpacing.xxl)
            .padding(.top, SpendlySpacing.xxxl)
            .opacity(contentOpacity)

            Spacer()

            // Action buttons
            VStack(spacing: SpendlySpacing.md) {
                SPButton("Back to Schedule", icon: SpendlyIcon.calendar.systemName, style: .primary) {
                    viewModel.backToSchedule()
                }

                SPButton("View Sent Report", icon: SpendlyIcon.visibility.systemName, style: .accent) {
                    viewModel.viewSentReport()
                }

                Button {
                    viewModel.startNewJob()
                } label: {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 14, weight: .semibold))
                        Text("New Job")
                            .font(SpendlyFont.bodySemibold())
                    }
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.md)
                    .padding(.horizontal, SpendlySpacing.lg)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                            .strokeBorder(SpendlyColors.primary.opacity(0.2), lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal, SpendlySpacing.xxl)
            .padding(.bottom, SpendlySpacing.xxl)
        }
        .background(SpendlyColors.surface(for: colorScheme).ignoresSafeArea())
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                checkmarkScale = 1.0
                checkmarkOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.4).delay(0.4)) {
                contentOpacity = 1.0
            }
        }
    }
}

// MARK: - Flow Layout (for wrapping recipient chips)

private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    private struct LayoutResult {
        var size: CGSize
        var positions: [CGPoint]
        var sizes: [CGSize]
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            sizes.append(size)

            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalHeight = currentY + lineHeight
        }

        return LayoutResult(
            size: CGSize(width: maxWidth, height: totalHeight),
            positions: positions,
            sizes: sizes
        )
    }
}

// MARK: - Preview

#Preview {
    EmailPreviewRootView()
}
