import SwiftUI
import SpendlyCore

struct TripReportPDFView: View {
    let trip: TripReportDisplayModel
    @Bindable var viewModel: TripReportViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: SpendlySpacing.xxl) {
                    // PDF Document Card
                    pdfDocumentView
                        .padding(.horizontal, SpendlySpacing.lg)
                        .padding(.top, SpendlySpacing.lg)

                    // Bottom spacer for floating buttons
                    Spacer().frame(height: 100)
                }
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
                Text("Preview Report")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: SpendlySpacing.xs) {
                    Button {
                        // Print action placeholder
                    } label: {
                        Image(systemName: "printer")
                            .font(.system(size: 16))
                            .foregroundStyle(SpendlyColors.primary)
                    }
                    Button {
                        // More options placeholder
                    } label: {
                        Image(systemName: SpendlyIcon.moreVert.systemName)
                            .font(.system(size: 16))
                            .foregroundStyle(SpendlyColors.primary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.generatePDF()
        }
    }

    // MARK: - PDF Document View

    private var pdfDocumentView: some View {
        VStack(spacing: 0) {
            // Document Header (white-label branded)
            documentHeader

            // Document Content
            VStack(alignment: .leading, spacing: SpendlySpacing.xxxl) {
                jobDetailsAndLocationSection
                serviceSummarySection
                additionalWorkSection
                financialBreakdownSection
                signaturesSection
                footerSection
            }
            .padding(SpendlySpacing.xxl)
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large)
                .strokeBorder(SpendlyColors.secondary.opacity(0.15), lineWidth: 1)
        )
        .spendlyShadow(.lg)
    }

    // MARK: - Document Header

    private var documentHeader: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                // Company branding
                HStack(spacing: SpendlySpacing.md) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(SpendlyColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.companyName.uppercased())
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.primary)
                            .tracking(1)
                        Text(trip.companyTagline.uppercased())
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }
                }

                Spacer()

                // Report info
                VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                    Text("Trip Completion Report")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text("Report ID: #\(trip.reportNumber)")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.primary)
                }
            }
            .padding(SpendlySpacing.xxl)
            .background(SpendlyColors.primary.opacity(0.05))

            // Bottom accent border
            Rectangle()
                .fill(SpendlyColors.primary)
                .frame(height: 4)
        }
    }

    // MARK: - Job Details + Location

    private var jobDetailsAndLocationSection: some View {
        VStack(spacing: SpendlySpacing.xxl) {
            HStack(alignment: .top, spacing: SpendlySpacing.xxl) {
                // Job Details
                VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                    pdfSectionTitle("Job Details")

                    VStack(spacing: SpendlySpacing.md) {
                        pdfDetailRow(label: "Customer", value: trip.customerName)
                        pdfDetailRow(label: "Service Date", value: trip.formattedServiceDate)
                        pdfDetailRow(label: "Technician", value: trip.technicianName)
                    }
                }

                // Service Location
                VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                    Text("SERVICE LOCATION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(SpendlyColors.primary)
                        .tracking(1)

                    HStack(alignment: .top, spacing: SpendlySpacing.sm) {
                        Image(systemName: SpendlyIcon.location.systemName)
                            .font(.system(size: 12))
                            .foregroundStyle(SpendlyColors.primary)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(trip.customerAddress)
                                .font(SpendlyFont.body())
                            Text("\(trip.customerCity), \(trip.customerState) \(trip.customerPostalCode)")
                                .font(SpendlyFont.body())
                        }
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }
                }
                .padding(SpendlySpacing.lg)
                .background(SpendlyColors.primary.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
            }
        }
    }

    // MARK: - Service Summary

    private var serviceSummarySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            pdfSectionTitle("Service Summary")

            VStack(spacing: SpendlySpacing.sm) {
                ForEach(trip.completedTasks) { task in
                    HStack(spacing: SpendlySpacing.md) {
                        Image(systemName: SpendlyIcon.checkCircle.systemName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(SpendlyColors.success)
                        Text(task.name)
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Spacer()
                    }
                    .padding(SpendlySpacing.md)
                    .background(
                        colorScheme == .dark
                            ? SpendlyColors.surfaceDark.opacity(0.5)
                            : Color(hex: "#f8fafc")
                    )
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                }
            }
        }
    }

    // MARK: - Additional Work

    private var additionalWorkSection: some View {
        Group {
            if !trip.additionalWorkItems.isEmpty {
                VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                    HStack {
                        Text("ADDITIONAL WORK PERFORMED")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(SpendlyColors.accent)
                            .tracking(1.5)
                        Spacer()
                    }
                    .padding(.bottom, SpendlySpacing.xs)
                    .overlay(
                        Rectangle()
                            .fill(SpendlyColors.accent.opacity(0.2))
                            .frame(height: 1),
                        alignment: .bottom
                    )

                    ForEach(trip.additionalWorkItems) { item in
                        HStack(alignment: .top, spacing: SpendlySpacing.md) {
                            Image(systemName: SpendlyIcon.warning.systemName)
                                .font(.system(size: 14))
                                .foregroundStyle(SpendlyColors.accent)

                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text(item.title)
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                Text(item.description)
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            }
                        }
                        .padding(SpendlySpacing.lg)
                        .background(SpendlyColors.accent.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                                .strokeBorder(SpendlyColors.accent.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [6, 3]))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                    }
                }
            }
        }
    }

    // MARK: - Financial Breakdown

    private var financialBreakdownSection: some View {
        VStack(spacing: 0) {
            // Table header
            HStack {
                Text("Description")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Amount")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(.white)
                    .frame(width: 100, alignment: .trailing)
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.md)
            .background(SpendlyColors.primary)

            // Table rows
            ForEach(viewModel.chargeLines(for: trip)) { line in
                HStack {
                    Text(line.description)
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(CurrencyFormatter.shared.format(line.amount))
                        .font(SpendlyFont.bodyMedium())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .frame(width: 100, alignment: .trailing)
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.vertical, SpendlySpacing.md)

                SPDivider()
            }

            // Total row
            HStack {
                Text("Total Amount Due")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(CurrencyFormatter.shared.format(trip.grandTotal))
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.primary)
                    .frame(width: 100, alignment: .trailing)
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.lg)
            .background(SpendlyColors.primary.opacity(0.05))
        }
        .background(
            colorScheme == .dark
                ? SpendlyColors.surfaceDark
                : Color(hex: "#f8fafc")
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                .strokeBorder(SpendlyColors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Signatures

    private var signaturesSection: some View {
        VStack(spacing: 0) {
            SPDivider(thickness: 1)
                .padding(.bottom, SpendlySpacing.xxl)

            HStack(alignment: .top, spacing: SpendlySpacing.xxxl) {
                // Technician signature
                VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                    Text("TECHNICIAN SIGNATURE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        .tracking(1)

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(trip.technicianName)
                            .font(.system(size: 18, design: .serif))
                            .italic()
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme).opacity(0.75))
                            .frame(height: 48, alignment: .bottom)

                        Rectangle()
                            .fill(SpendlyColors.secondary.opacity(0.3))
                            .frame(height: 1)

                        Text("Electronically Verified: \(trip.formattedServiceDate)")
                            .font(.system(size: 10))
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Customer signature
                VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                    Text("CUSTOMER AUTHORIZATION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        .tracking(1)

                    #if canImport(UIKit)
                    if let sig = viewModel.customerSignature {
                        Image(uiImage: sig)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 48)
                            .frame(maxWidth: .infinity)
                            .padding(SpendlySpacing.sm)
                            .background(
                                colorScheme == .dark
                                    ? SpendlyColors.surfaceDark
                                    : Color(hex: "#f8fafc")
                            )
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendlyRadius.small)
                                    .strokeBorder(SpendlyColors.secondary.opacity(0.15), lineWidth: 1)
                            )
                    } else {
                        signaturePlaceholder
                    }
                    #else
                    signaturePlaceholder
                    #endif
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var signaturePlaceholder: some View {
        HStack {
            Spacer()
            Text("Awaiting Signature")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                .italic()
            Spacer()
        }
        .frame(height: 48)
        .background(
            colorScheme == .dark
                ? SpendlyColors.surfaceDark
                : Color(hex: "#f8fafc")
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.small)
                .strokeBorder(SpendlyColors.secondary.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Footer

    private var footerSection: some View {
        Text("Thank you for choosing \(trip.companyName). Your comfort is our priority.")
            .font(.system(size: 10))
            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            .tracking(1)
            .textCase(.uppercase)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.top, SpendlySpacing.xxxl)
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
                    Text("Edit Report")
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

            Rectangle()
                .fill(SpendlyColors.secondary.opacity(0.2))
                .frame(width: 1, height: 24)

            // Send PDF button
            SPButton("Send PDF", icon: SpendlyIcon.send.systemName, style: .primary) {
                viewModel.navigateToEmailReport()
            }
            .clipShape(Capsule())
        }
        .padding(.horizontal, SpendlySpacing.xxl)
        .padding(.vertical, SpendlySpacing.md)
        .background(
            SpendlyColors.surface(for: colorScheme)
                .shadow(color: .black.opacity(0.1), radius: 16, y: -4)
        )
        .clipShape(Capsule())
        .padding(.bottom, SpendlySpacing.xxl)
    }

    // MARK: - Helpers

    private func pdfSectionTitle(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(SpendlyColors.primary)
                .tracking(1.5)

            Rectangle()
                .fill(SpendlyColors.primary.opacity(0.2))
                .frame(height: 1)
        }
    }

    private func pdfDetailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            Spacer()
            Text(value)
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TripReportPDFView(
            trip: TripReportMockData.completedTrips[0],
            viewModel: TripReportViewModel()
        )
    }
}
