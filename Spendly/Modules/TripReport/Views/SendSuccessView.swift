import SwiftUI
import SpendlyCore

struct SendSuccessView: View {
    let sentEmails: [String]
    @Bindable var viewModel: TripReportViewModel

    @Environment(\.colorScheme) private var colorScheme

    @State private var checkmarkScale: CGFloat = 0.3
    @State private var checkmarkOpacity: Double = 0
    @State private var contentOpacity: Double = 0

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button {
                    viewModel.resetToRoot()
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

                // Invisible spacer to balance layout
                Color.clear.frame(width: 48, height: 48)
            }
            .padding(.horizontal, SpendlySpacing.sm)

            Spacer()

            // Success icon
            VStack(spacing: SpendlySpacing.xl) {
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(SpendlyColors.success.opacity(0.15))
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)

                    // Checkmark circle
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
                    ForEach(sentEmails, id: \.self) { email in
                        Text(email)
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
                    viewModel.resetToRoot()
                }

                SPButton("View Sent Report", icon: SpendlyIcon.visibility.systemName, style: .accent) {
                    // Navigate back to PDF view - for now reset
                    viewModel.resetToRoot()
                }

                Button {
                    viewModel.resetToRoot()
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
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
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

// MARK: - Preview

#Preview {
    NavigationStack {
        SendSuccessView(
            sentEmails: ["manager@company.com", "client@example.com"],
            viewModel: TripReportViewModel()
        )
    }
}
