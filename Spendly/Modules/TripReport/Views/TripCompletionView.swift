import SwiftUI
import SpendlyCore

struct TripCompletionView: View {
    let trip: TripReportDisplayModel
    @Bindable var viewModel: TripReportViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    jobDetailsSection
                    completedTasksSection
                    additionalWorkSection
                    partsUsedSection
                    manualTimeEntrySection
                    financialSummarySection
                    tripNotesSection
                    customerSignatureSection
                    technicianSignatureSection

                    // Bottom spacer for floating button
                    Spacer().frame(height: 100)
                }
            }
            .background(SpendlyColors.background(for: colorScheme))

            // Floating bottom button
            bottomButton
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: SpendlyIcon.arrowBack.systemName)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Trip Summary")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.navigateToPDFPreview()
                } label: {
                    Image(systemName: "doc.richtext")
                        .font(.system(size: 16))
                        .foregroundStyle(SpendlyColors.primary)
                        .frame(width: 40, height: 40)
                        .background(SpendlyColors.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                }
            }
        }
    }

    // MARK: - Job Details

    private var jobDetailsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            sectionHeader(icon: "doc.text", iconColor: SpendlyColors.accent, title: "Job Details")

            VStack(spacing: 0) {
                detailRow(label: "Customer Name", value: trip.customerName)
                detailRow(label: "Date", value: trip.shortDate)
                detailRow(label: "Technician", value: trip.technicianName)
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.xxl)
    }

    // MARK: - Completed Tasks

    private var completedTasksSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            sectionHeader(
                icon: SpendlyIcon.checkCircle.systemName,
                iconColor: SpendlyColors.success,
                title: "Completed Tasks"
            )

            VStack(spacing: SpendlySpacing.xs) {
                ForEach(trip.completedTasks) { task in
                    HStack(spacing: SpendlySpacing.md) {
                        Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                            .font(.system(size: 20))
                            .foregroundStyle(task.isCompleted ? SpendlyColors.primary : SpendlyColors.secondary)

                        Text(task.name)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        Spacer()
                    }
                    .padding(.vertical, SpendlySpacing.md)

                    if task.id != trip.completedTasks.last?.id {
                        SPDivider()
                    }
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.lg)
        .background(
            colorScheme == .dark
                ? SpendlyColors.surfaceDark.opacity(0.5)
                : Color(hex: "#f8fafc")
        )
    }

    // MARK: - Additional Work

    private var additionalWorkSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            HStack {
                sectionHeader(
                    icon: SpendlyIcon.addCircle.systemName,
                    iconColor: SpendlyColors.accent,
                    title: "Additional Work"
                )
                Spacer()
                SPBadge("New Items", style: .custom(SpendlyColors.accent))
            }

            if trip.additionalWorkItems.isEmpty {
                Text("No additional work performed")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .italic()
            } else {
                VStack(spacing: SpendlySpacing.md) {
                    ForEach(trip.additionalWorkItems) { item in
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text(item.title)
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                Text(item.description)
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            }
                            Spacer()
                            Text(CurrencyFormatter.shared.format(item.cost))
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        }
                        .padding(SpendlySpacing.md)
                        .background(SpendlyColors.accent.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                                .strokeBorder(SpendlyColors.accent.opacity(0.2), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                    }
                }
            }

            // Additional work text area
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Add more details")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                TextEditor(text: $viewModel.additionalWorkText)
                    .font(SpendlyFont.body())
                    .frame(minHeight: 80)
                    .padding(SpendlySpacing.sm)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                            .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.xxl)
    }

    // MARK: - Parts Used

    private var partsUsedSection: some View {
        Group {
            if !trip.partsUsed.isEmpty {
                VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                    sectionHeader(
                        icon: "shippingbox",
                        iconColor: SpendlyColors.info,
                        title: "Parts & Materials Used"
                    )

                    VStack(spacing: SpendlySpacing.sm) {
                        ForEach(trip.partsUsed) { part in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(part.name)
                                        .font(SpendlyFont.bodySemibold())
                                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                    Text("Qty: \(part.quantity) @ \(CurrencyFormatter.shared.format(part.unitPrice))")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                                }
                                Spacer()
                                Text(CurrencyFormatter.shared.format(part.lineTotal))
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            }
                            .padding(.vertical, SpendlySpacing.sm)

                            if part.id != trip.partsUsed.last?.id {
                                SPDivider()
                            }
                        }
                    }
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.vertical, SpendlySpacing.lg)
                .background(
                    colorScheme == .dark
                        ? SpendlyColors.surfaceDark.opacity(0.5)
                        : Color(hex: "#f8fafc")
                )
            }
        }
    }

    // MARK: - Manual Time Entry

    private var manualTimeEntrySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            HStack {
                sectionHeader(
                    icon: SpendlyIcon.timer.systemName,
                    iconColor: SpendlyColors.info,
                    title: "Time Entry"
                )
                Spacer()
                SPToggle(isOn: $viewModel.showManualTimeEntry, label: "")
            }

            if viewModel.showManualTimeEntry {
                VStack(spacing: SpendlySpacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text("Start Time")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            DatePicker("", selection: $viewModel.manualStartTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .tint(SpendlyColors.primary)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text("End Time")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            DatePicker("", selection: $viewModel.manualEndTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .tint(SpendlyColors.primary)
                        }
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text("Break (minutes)")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            Stepper("\(viewModel.manualBreakMinutes) min", value: $viewModel.manualBreakMinutes, in: 0...120, step: 15)
                                .font(SpendlyFont.body())
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                            Text("Total Hours")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            Text(String(format: "%.1f hrs", viewModel.manualHoursWorked))
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.primary)
                        }
                    }
                }
                .padding(SpendlySpacing.lg)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.large)
                        .strokeBorder(SpendlyColors.secondary.opacity(0.15), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.xxl)
    }

    // MARK: - Financial Summary

    private var financialSummarySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("Financial Summary")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            VStack(spacing: SpendlySpacing.md) {
                ForEach(viewModel.chargeLines(for: trip)) { line in
                    HStack {
                        Text(line.description)
                            .font(SpendlyFont.body())
                            .foregroundStyle(.white.opacity(0.9))
                        Spacer()
                        Text(CurrencyFormatter.shared.format(line.amount))
                            .font(SpendlyFont.body())
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }

                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 1)
                    .padding(.vertical, SpendlySpacing.xs)

                HStack {
                    Text("Final Amount")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(.white)
                    Spacer()
                    Text(CurrencyFormatter.shared.format(trip.grandTotal))
                        .font(SpendlyFont.largeTitle())
                        .foregroundStyle(SpendlyColors.accent)
                }
            }
            .padding(SpendlySpacing.xl)
            .background(SpendlyColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl))
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.xxl)
    }

    // MARK: - Trip Notes

    private var tripNotesSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            sectionHeader(
                icon: "note.text",
                iconColor: SpendlyColors.secondary,
                title: "Trip Notes"
            )

            TextEditor(text: $viewModel.tripNotes)
                .font(SpendlyFont.body())
                .frame(minHeight: 100)
                .padding(SpendlySpacing.sm)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                        .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.lg)
        .background(
            colorScheme == .dark
                ? SpendlyColors.surfaceDark.opacity(0.5)
                : Color(hex: "#f8fafc")
        )
    }

    // MARK: - Customer Signature

    private var customerSignatureSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("Customer Signature")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            #if canImport(UIKit)
            SPSignatureCapture(
                signature: Binding(
                    get: { viewModel.customerSignature },
                    set: { viewModel.customerSignature = $0 }
                ),
                onClear: { viewModel.clearCustomerSignature() }
            )
            #endif

            Text("I acknowledge that the work described above has been completed to my satisfaction.")
                .font(.system(size: 10))
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.xxl)
    }

    // MARK: - Technician Signature

    private var technicianSignatureSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("Technician Signature")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            #if canImport(UIKit)
            SPSignatureCapture(
                signature: Binding(
                    get: { viewModel.technicianSignature },
                    set: { viewModel.technicianSignature = $0 }
                ),
                onClear: { viewModel.clearTechnicianSignature() }
            )
            #endif
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.lg)
    }

    // MARK: - Bottom Button

    private var bottomButton: some View {
        VStack(spacing: 0) {
            SPDivider()
            SPButton("Finish & Send PDF", icon: SpendlyIcon.send.systemName, style: .primary) {
                viewModel.navigateToPDFPreview()
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.lg)
        }
        .background(
            SpendlyColors.surface(for: colorScheme)
                .shadow(color: .black.opacity(0.05), radius: 8, y: -4)
        )
    }

    // MARK: - Helpers

    private func sectionHeader(icon: String, iconColor: Color, title: String) -> some View {
        HStack(spacing: SpendlySpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
            Text(title)
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        VStack(spacing: 0) {
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
            .padding(.vertical, SpendlySpacing.md)

            SPDivider()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TripCompletionView(
            trip: TripReportMockData.completedTrips[0],
            viewModel: TripReportViewModel()
        )
    }
}
