import SwiftUI
import SpendlyCore

struct DispatchConfirmationView: View {

    @Bindable var viewModel: SchedulingDispatchViewModel
    let technicianID: UUID
    let eventID: UUID?
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private var technician: Technician? {
        viewModel.technicians.first(where: { $0.id == technicianID })
    }

    private var event: ScheduleEvent? {
        guard let eventID else { return nil }
        return viewModel.events.first(where: { $0.id == eventID })
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: SpendlySpacing.lg) {
                    technicianProfileCard
                    serviceDetailsSection
                    dispatchNoteSection
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.top, SpendlySpacing.sm)
                .padding(.bottom, 120)
            }

            // Sticky footer
            footerAction
        }
        .navigationTitle("Confirm Dispatch")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Dispatch Confirmed", isPresented: $viewModel.showDispatchSuccess) {
            Button("OK") {
                // Pop back to root
                viewModel.navigationPath.removeAll()
            }
        } message: {
            Text("\(technician?.name ?? "Technician") has been dispatched and will receive a notification. ETA will be shared with the customer.")
        }
    }

    // MARK: - Technician Profile Card

    private var technicianProfileCard: some View {
        HStack(spacing: SpendlySpacing.lg) {
            // Avatar
            SPAvatar(
                initials: technician?.initials ?? "??",
                size: .lg,
                statusDot: technician?.availability.dotColor
            )
            .overlay(
                Circle()
                    .strokeBorder(SpendlyColors.primary, lineWidth: 2)
                    .frame(width: 60, height: 60)
            )

            // Info
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text(technician?.name ?? "Unknown")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text(technician?.specialty ?? "Technician")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.secondary)

                if let tech = technician {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(SpendlyColors.warning)
                        Text(String(format: "%.1f", tech.rating))
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("(\(tech.reviewCount)+ visits)")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.primary.opacity(colorScheme == .dark ? 0.1 : 0.04))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(SpendlyColors.primary.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Service Details

    private var serviceDetailsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            Text("Service Details")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .padding(.leading, SpendlySpacing.xs)

            // Scheduled Time
            serviceDetailRow(
                icon: "calendar",
                title: "Scheduled Time",
                value: event?.timeRangeText ?? scheduledTimeDefault
            )

            // Location
            locationCard

            // Issue Summary
            issueCard

            // ETA card
            etaCard
        }
    }

    private var scheduledTimeDefault: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d \u{2022} h:mm a"
        return "Today, \(formatter.string(from: Date()))"
    }

    private func serviceDetailRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: SpendlySpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(SpendlyColors.primary.opacity(0.08))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(SpendlyColors.primary)
            }

            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text(title)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Text(value)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            Spacer()
        }
        .padding(SpendlySpacing.lg)
        .background(
            SpendlyColors.background(for: colorScheme)
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(SpendlyColors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    private var locationCard: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: SpendlySpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .fill(SpendlyColors.primary.opacity(0.08))
                        .frame(width: 44, height: 44)
                    Image(systemName: SpendlyIcon.location.systemName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(SpendlyColors.primary)
                }

                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text("Service Location")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text(event?.address ?? "123 Maple Avenue, Springfield, IL 62704")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                Spacer()
            }
            .padding(SpendlySpacing.lg)

            // Map placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(SpendlyColors.secondary.opacity(0.1))
                    .frame(height: 120)

                VStack(spacing: SpendlySpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(SpendlyColors.primary)
                            .frame(width: 40, height: 40)
                        Image(systemName: SpendlyIcon.location.systemName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    Text("Map View")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
        .background(
            SpendlyColors.background(for: colorScheme)
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(SpendlyColors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    private var issueCard: some View {
        HStack(alignment: .top, spacing: SpendlySpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(SpendlyColors.primary.opacity(0.08))
                    .frame(width: 44, height: 44)
                Image(systemName: "doc.text")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(SpendlyColors.primary)
            }

            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text("Issue Summary")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Text(event?.notes ?? "Customer reported a loud grinding noise from the HVAC unit during startup. Unit is currently not cooling effectively. Basement access via side door.")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondary)
                    .italic()
                    .lineSpacing(3)
            }

            Spacer()
        }
        .padding(SpendlySpacing.lg)
        .background(
            SpendlyColors.background(for: colorScheme)
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(SpendlyColors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    private var etaCard: some View {
        HStack(spacing: SpendlySpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(SpendlyColors.success.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: "car.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(SpendlyColors.success)
            }

            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text("Estimated Arrival")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                HStack(spacing: SpendlySpacing.sm) {
                    // Bug 8: Dynamic ETA based on technician distance/availability
                    Text(technician.map { viewModel.estimatedETAText(for: $0) } ?? "-- mins")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.success)

                    if let tech = technician {
                        Text("\u{2022} \(String(format: "%.1f", tech.distance)) mi away")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.success.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(SpendlyColors.success.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Dispatch Note

    private var dispatchNoteSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("Send Dispatch Note (Optional)")
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .padding(.leading, SpendlySpacing.xs)

            TextEditor(text: $viewModel.dispatchNote)
                .font(SpendlyFont.body())
                .frame(minHeight: 100)
                .padding(SpendlySpacing.md)
                .scrollContentBackground(.hidden)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                        .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                )
                .overlay(alignment: .topLeading) {
                    if viewModel.dispatchNote.isEmpty {
                        Text("Add specific instructions for \(technician?.name.components(separatedBy: " ").first ?? "technician")...")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                            .padding(.horizontal, SpendlySpacing.lg)
                            .padding(.vertical, SpendlySpacing.lg)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    // MARK: - Footer Action

    private var footerAction: some View {
        VStack(spacing: SpendlySpacing.sm) {
            SPButton(
                "Confirm Dispatch",
                icon: SpendlyIcon.send.systemName,
                style: .primary,
                isLoading: viewModel.isDispatching
            ) {
                viewModel.confirmDispatch()
            }

            Text("\(technician?.name ?? "Technician") will receive notification and ETA will be shared with the customer.")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
        .overlay(alignment: .top) {
            Divider().foregroundStyle(SpendlyColors.secondary.opacity(0.15))
        }
    }
}

// MARK: - Preview

#Preview("Dispatch Confirmation") {
    NavigationStack {
        DispatchConfirmationView(
            viewModel: {
                let vm = SchedulingDispatchViewModel()
                vm.selectedTechnicianID = vm.technicians.first?.id
                return vm
            }(),
            technicianID: SchedulingMockData.technicians[0].id,
            eventID: nil
        )
    }
}
