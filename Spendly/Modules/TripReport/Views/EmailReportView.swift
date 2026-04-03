import SwiftUI
import SpendlyCore

struct EmailReportView: View {
    let trip: TripReportDisplayModel
    @Bindable var viewModel: TripReportViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: SpendlySpacing.xxl) {
                    // PDF Preview Mini
                    pdfPreviewMini

                    // Distribution & Email section
                    distributionSection

                    // Email Body Preview
                    emailBodySection

                    // Bottom spacer
                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.top, SpendlySpacing.lg)
            }
            .background(SpendlyColors.background(for: colorScheme))

            // Floating action bar
            floatingActionBar
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: SpendlyIcon.arrowBack.systemName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Send Report")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
        }
    }

    // MARK: - PDF Preview Mini

    private var pdfPreviewMini: some View {
        SPCard(elevation: .medium) {
            VStack(spacing: SpendlySpacing.md) {
                HStack(spacing: SpendlySpacing.md) {
                    Image(systemName: "doc.richtext")
                        .font(.system(size: 32))
                        .foregroundStyle(SpendlyColors.primary)

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("Trip Completion Report")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("#\(trip.reportNumber)")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.primary)
                        Text("\(trip.customerName) - \(trip.shortDate)")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }

                    Spacer()

                    Text(CurrencyFormatter.shared.format(trip.grandTotal))
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.primary)
                }
            }
        }
    }

    // MARK: - Distribution Section

    private var distributionSection: some View {
        VStack(spacing: 0) {
            // Section header
            HStack {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "envelope")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                    Text("DISTRIBUTION & EMAIL")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(.white)
                        .tracking(0.5)
                }

                Spacer()

                // Add contact button
                Button {
                    // Add new contact placeholder
                } label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 12))
                        Text("Add New Contact")
                            .font(SpendlyFont.caption())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, SpendlySpacing.md)
                    .padding(.vertical, SpendlySpacing.xs)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.lg)
            .background(SpendlyColors.primary)

            // Recipients
            VStack(spacing: SpendlySpacing.lg) {
                Text("Select the recipients for this Trip Completion Report. Contacts are managed via Customer Master File.")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .italic()

                // Recipient Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: SpendlySpacing.md),
                    GridItem(.flexible(), spacing: SpendlySpacing.md)
                ], spacing: SpendlySpacing.md) {
                    ForEach(viewModel.recipients) { recipient in
                        RecipientCard(
                            recipient: recipient,
                            onToggle: { viewModel.toggleRecipient(recipient) }
                        )
                    }
                }

                SPDivider()

                // Additional recipients input
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("ADDITIONAL RECIPIENTS (COMMA SEPARATED)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        .tracking(0.5)

                    SPInput(
                        "e.g. manager@client.com, service@hq.com",
                        icon: "at",
                        text: $viewModel.additionalEmails
                    )
                }

                // Copy to technician toggle
                HStack(spacing: SpendlySpacing.md) {
                    Image(systemName: "at")
                        .font(.system(size: 16))
                        .foregroundStyle(SpendlyColors.primary)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Copy Me (Technician)")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("Send a copy to \(trip.technicianEmail)")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }

                    Spacer()

                    Toggle("", isOn: $viewModel.copyToTechnician)
                        .labelsHidden()
                        .tint(SpendlyColors.primary)
                }
                .padding(SpendlySpacing.md)
                .background(
                    colorScheme == .dark
                        ? SpendlyColors.surfaceDark.opacity(0.5)
                        : Color(hex: "#f8fafc")
                )
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                        .strokeBorder(SpendlyColors.secondary.opacity(0.1), lineWidth: 1)
                )
            }
            .padding(SpendlySpacing.lg)
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large)
                .strokeBorder(SpendlyColors.secondary.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Email Body Section

    private var emailBodySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: "text.alignleft")
                    .font(.system(size: 14))
                    .foregroundStyle(SpendlyColors.accent)
                Text("Email Body Preview")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            TextEditor(text: $viewModel.emailBody)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .frame(minHeight: 160)
                .padding(SpendlySpacing.md)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                        .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                )
        }
    }

    // MARK: - Floating Action Bar

    private var floatingActionBar: some View {
        HStack(spacing: SpendlySpacing.md) {
            // Edit button
            Button {
                dismiss()
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: SpendlyIcon.edit.systemName)
                        .font(.system(size: 16))
                    Text("Edit")
                        .font(SpendlyFont.bodySemibold())
                }
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.vertical, SpendlySpacing.md)
                .background(
                    colorScheme == .dark
                        ? SpendlyColors.surfaceDark
                        : Color(hex: "#f1f5f9")
                )
                .clipShape(Capsule())
            }

            // Print button
            Button {
                // Print placeholder
            } label: {
                Image(systemName: "printer")
                    .font(.system(size: 16))
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .frame(width: 44, height: 44)
                    .background(
                        colorScheme == .dark
                            ? SpendlyColors.surfaceDark
                            : Color(hex: "#f1f5f9")
                    )
                    .clipShape(Circle())
            }

            Rectangle()
                .fill(SpendlyColors.secondary.opacity(0.2))
                .frame(width: 1, height: 24)

            // Send Email button
            Button {
                viewModel.sendEmail()
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    if viewModel.isSendingEmail {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: SpendlyIcon.send.systemName)
                            .font(.system(size: 14))
                    }
                    Text("Send Email")
                        .font(SpendlyFont.bodySemibold())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, SpendlySpacing.xxl)
                .padding(.vertical, SpendlySpacing.md)
                .background(SpendlyColors.primary)
                .clipShape(Capsule())
                .shadow(color: SpendlyColors.primary.opacity(0.3), radius: 8, y: 4)
            }
            .disabled(viewModel.isSendingEmail || viewModel.selectedRecipientCount == 0)
            .opacity(viewModel.selectedRecipientCount == 0 ? 0.5 : 1)
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(
            SpendlyColors.surface(for: colorScheme)
                .shadow(color: .black.opacity(0.1), radius: 16, y: -4)
        )
        .clipShape(Capsule())
        .padding(.bottom, SpendlySpacing.xxl)
    }
}

// MARK: - Recipient Card

private struct RecipientCard: View {
    let recipient: EmailRecipient
    let onToggle: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var roleColor: Color {
        recipient.isSelected ? SpendlyColors.primary : SpendlyColors.accent
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: SpendlySpacing.md) {
                // Checkbox
                Image(systemName: recipient.isSelected ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundStyle(recipient.isSelected ? SpendlyColors.primary : SpendlyColors.secondary)

                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text(recipient.role.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(roleColor)

                    Text(recipient.name)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Text(recipient.email)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(SpendlySpacing.lg)
            .background(
                recipient.isSelected
                    ? (colorScheme == .dark ? SpendlyColors.surfaceDark.opacity(0.5) : Color(hex: "#f8fafc").opacity(0.5))
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                    .strokeBorder(
                        recipient.isSelected ? SpendlyColors.primary.opacity(0.3) : SpendlyColors.secondary.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EmailReportView(
            trip: TripReportMockData.completedTrips[0],
            viewModel: TripReportViewModel()
        )
    }
}
