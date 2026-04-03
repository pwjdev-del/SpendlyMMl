import SwiftUI
import SpendlyCore

struct ApprovalSuccessView: View {
    @Bindable var vm: ClientApprovalViewModel

    @Environment(\.colorScheme) private var colorScheme
    @State private var checkmarkScale: CGFloat = 0.3
    @State private var checkmarkOpacity: Double = 0.0
    @State private var contentOpacity: Double = 0.0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            // Main Content
            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: SpendlySpacing.xxxl) {
                    // Success Icon with glow
                    successIcon

                    // Success Message
                    successMessage

                    // Assigned Team Card
                    assignedTeamCard

                    // Action Buttons
                    actionButtons
                }
                .frame(maxWidth: 400)
                .padding(.horizontal, SpendlySpacing.xl)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(SpendlyColors.background(for: colorScheme))
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1)) {
                checkmarkScale = 1.0
                checkmarkOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                contentOpacity = 1.0
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: SpendlySpacing.md) {
            Button {
                vm.dismissSuccess()
            } label: {
                Image(systemName: SpendlyIcon.arrowBack.systemName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            Spacer()

            Text("Service Platform")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Spacer()

            // Invisible spacer to center the title
            Color.clear
                .frame(width: 18, height: 18)
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Success Icon

    private var successIcon: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(SpendlyColors.accent.opacity(0.15))
                .frame(width: 130, height: 130)
                .blur(radius: 20)

            // Main circle
            Circle()
                .fill(SpendlyColors.accent)
                .frame(width: 96, height: 96)
                .shadow(color: SpendlyColors.accent.opacity(0.4), radius: 16, y: 4)
                .overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(.white)
                )
        }
        .scaleEffect(checkmarkScale)
        .opacity(checkmarkOpacity)
    }

    // MARK: - Success Message

    private var successMessage: some View {
        VStack(spacing: SpendlySpacing.md) {
            Text("Estimate Approved!")
                .font(SpendlyFont.financialTitle())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .multilineTextAlignment(.center)

            Text("Success! The service team has been notified and will be in touch shortly to schedule the work. A confirmation has been sent to your email.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .opacity(contentOpacity)
    }

    // MARK: - Assigned Team Card

    private var assignedTeamCard: some View {
        HStack(spacing: SpendlySpacing.md) {
            // Team avatar
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .fill(SpendlyColors.accent.opacity(0.15))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(SpendlyColors.accent)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Assigned Team: \(vm.assignedTeam.name)")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Text("Response time: \(vm.assignedTeam.responseTime.lowercased())")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            Spacer()
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.accent.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(SpendlyColors.accent.opacity(0.1), lineWidth: 1)
        )
        .opacity(contentOpacity)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Download PDF
            SPButton("Download PDF Estimate", icon: "arrow.down.doc", style: .primary) {
                // Download PDF placeholder
            }

            // Return to Portal
            Button {
                vm.dismissSuccess()
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Return to Portal")
                        .font(SpendlyFont.bodySemibold())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpendlySpacing.md)
                .padding(.horizontal, SpendlySpacing.lg)
                .foregroundStyle(SpendlyColors.accent)
                .background(SpendlyColors.accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            }
        }
        .opacity(contentOpacity)
    }
}

// MARK: - Preview

#Preview {
    let vm = ClientApprovalViewModel()
    vm.lastApprovedEstimate = ClientApprovalMockData.sampleEstimates[0]
    return ApprovalSuccessView(vm: vm)
}
