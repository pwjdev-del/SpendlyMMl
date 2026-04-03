import SwiftUI
import SpendlyCore

struct ServiceTrackerView: View {

    let viewModel: CustomerPortalViewModel
    let serviceID: UUID

    @Environment(\.colorScheme) private var colorScheme
    @State private var showCancelAlert: Bool = false

    private var service: ActiveService? {
        viewModel.service(for: serviceID)
    }

    var body: some View {
        ZStack {
            SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                .ignoresSafeArea()

            if let service {
                ScrollView {
                    VStack(spacing: SpendlySpacing.lg) {
                        headerSection(service)
                        mapPlaceholder(service)
                        progressSection(service)
                        timelineSection(service)
                        technicianSection(service)
                        actionButtons(service)
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.top, SpendlySpacing.sm)
                    .padding(.bottom, SpendlySpacing.xxxl)
                }
            } else {
                VStack(spacing: SpendlySpacing.md) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 36))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                    Text("Service not found")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
        .navigationTitle("Service Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Cancel Service?", isPresented: $showCancelAlert) {
            Button("Keep Service", role: .cancel) { }
            Button("Cancel Service", role: .destructive) {
                viewModel.confirmCancelService(serviceID: serviceID)
            }
        } message: {
            Text("Are you sure you want to cancel this service request? The technician will be notified.")
        }
    }

    // MARK: - Header

    private func headerSection(_ service: ActiveService) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                HStack {
                    SPBadge(service.currentStatus.rawValue, style: .custom(service.currentStatus.color))
                    Spacer()
                    Text(service.ticketNumber)
                        .font(SpendlyFont.caption())
                        .fontWeight(.semibold)
                        .foregroundStyle(SpendlyColors.secondary)
                }

                Text(service.title)
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                HStack(spacing: SpendlySpacing.sm) {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 11))
                        Text(service.machineName)
                            .font(SpendlyFont.caption())
                    }
                    .foregroundStyle(SpendlyColors.secondary)

                    Text("\u{2022}")
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.4))

                    Text(service.machineID)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: SpendlyIcon.location.systemName)
                        .font(.system(size: 11))
                    Text(service.address)
                        .font(SpendlyFont.caption())
                        .lineLimit(1)
                }
                .foregroundStyle(SpendlyColors.secondary)
            }
        }
    }

    // MARK: - Map Placeholder

    private func mapPlaceholder(_ service: ActiveService) -> some View {
        SPCard(elevation: .low, padding: 0) {
            ZStack {
                // Map background
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                SpendlyColors.primary.opacity(0.06),
                                SpendlyColors.info.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)

                VStack(spacing: SpendlySpacing.md) {
                    // Simulated route dots
                    ZStack {
                        // Route line
                        Path { path in
                            path.move(to: CGPoint(x: 60, y: 80))
                            path.addQuadCurve(
                                to: CGPoint(x: 260, y: 60),
                                control: CGPoint(x: 160, y: 20)
                            )
                        }
                        .stroke(
                            SpendlyColors.accent,
                            style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                        )
                        .frame(width: 300, height: 120)

                        // Technician position
                        VStack(spacing: 2) {
                            Image(systemName: "car.fill")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(SpendlySpacing.sm)
                                .background(SpendlyColors.accent)
                                .clipShape(Circle())

                            if let eta = service.technician.etaMinutes {
                                Text("\(eta) min")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, SpendlySpacing.sm)
                                    .padding(.vertical, 2)
                                    .background(SpendlyColors.accent)
                                    .clipShape(Capsule())
                            }
                        }
                        .offset(x: -40, y: 10)

                        // Destination pin
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(SpendlyColors.error)
                            .offset(x: 100, y: -10)
                    }

                    Text("Live technician tracking")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
    }

    // MARK: - Progress Section

    private func progressSection(_ service: ActiveService) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                Text("Job Progress")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                // Step indicator
                let steps = ServiceJobStatus.allCases
                let currentIdx = service.currentStatus.stepIndex

                VStack(spacing: SpendlySpacing.sm) {
                    // Progress bar with step nodes
                    GeometryReader { geo in
                        let totalWidth = geo.size.width
                        let segmentWidth = totalWidth / CGFloat(steps.count - 1)

                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 3)
                                .fill(SpendlyColors.secondary.opacity(0.12))
                                .frame(height: 4)

                            // Filled track
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [SpendlyColors.info, SpendlyColors.accent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: segmentWidth * CGFloat(currentIdx), height: 4)

                            // Step circles
                            ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                                let isCompleted = idx < currentIdx
                                let isCurrent = idx == currentIdx
                                let xPos = segmentWidth * CGFloat(idx)

                                ZStack {
                                    if isCurrent {
                                        Circle()
                                            .fill(step.color.opacity(0.2))
                                            .frame(width: 24, height: 24)
                                    }

                                    Circle()
                                        .fill(
                                            isCompleted || isCurrent
                                                ? step.color
                                                : SpendlyColors.secondary.opacity(0.25)
                                        )
                                        .frame(width: isCurrent ? 16 : 12, height: isCurrent ? 16 : 12)
                                        .overlay(
                                            Group {
                                                if isCompleted {
                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 7, weight: .bold))
                                                        .foregroundStyle(.white)
                                                }
                                            }
                                        )
                                }
                                .position(x: xPos, y: 12)
                            }
                        }
                    }
                    .frame(height: 24)

                    // Step labels
                    HStack(spacing: 0) {
                        ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                            VStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: step.icon)
                                    .font(.system(size: 12))
                                    .foregroundStyle(
                                        idx <= currentIdx
                                            ? step.color
                                            : SpendlyColors.secondary.opacity(0.4)
                                    )
                                Text(step.rawValue)
                                    .font(.system(size: 10, weight: idx <= currentIdx ? .bold : .regular))
                                    .foregroundStyle(
                                        idx <= currentIdx
                                            ? SpendlyColors.foreground(for: colorScheme)
                                            : SpendlyColors.secondary.opacity(0.5)
                                    )
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Timeline Section

    private func timelineSection(_ service: ActiveService) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                Text("Activity Timeline")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                SPTimeline(items: service.timeline.map { entry in
                    SPTimelineItem(
                        title: entry.step.rawValue,
                        subtitle: entry.subtitle,
                        status: timelineStatus(for: entry),
                        time: entry.time
                    )
                })
            }
        }
    }

    private func timelineStatus(for entry: ServiceTimelineEntry) -> SPTimelineStatus {
        if entry.isCompleted { return .completed }
        if entry.isActive { return .active }
        return .upcoming
    }

    // MARK: - Technician Section

    private func technicianSection(_ service: ActiveService) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                Text("Your Technician")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                HStack(spacing: SpendlySpacing.md) {
                    SPAvatar(
                        imageURL: service.technician.avatarURL,
                        initials: service.technician.initials,
                        size: .lg,
                        statusDot: SpendlyColors.success
                    )

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(service.technician.name)
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        Text(service.technician.specialty)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)

                        HStack(spacing: SpendlySpacing.xs) {
                            HStack(spacing: 2) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(SpendlyColors.warning)
                                Text(String(format: "%.1f", service.technician.rating))
                                    .font(SpendlyFont.caption())
                                    .fontWeight(.semibold)
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            }

                            if let eta = service.technician.etaMinutes {
                                Text("\u{2022}")
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                                HStack(spacing: 2) {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 10))
                                    Text("ETA \(eta) min")
                                        .font(SpendlyFont.caption())
                                        .fontWeight(.medium)
                                }
                                .foregroundStyle(SpendlyColors.accent)
                            }
                        }
                    }

                    Spacer()
                }

                // Contact button
                SPButton("Contact Technician", icon: SpendlyIcon.call.systemName, style: .primary) {
                    viewModel.contactTechnician(phone: service.technician.phone)
                }
            }
        }
    }

    // MARK: - Action Buttons

    private func actionButtons(_ service: ActiveService) -> some View {
        VStack(spacing: SpendlySpacing.sm) {
            SPButton("Cancel Service Request", icon: "xmark.circle", style: .destructive) {
                showCancelAlert = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Service Tracker - Light") {
    NavigationStack {
        ServiceTrackerView(
            viewModel: CustomerPortalViewModel(),
            serviceID: CustomerPortalMockData.activeService.id
        )
    }
    .preferredColorScheme(.light)
}

#Preview("Service Tracker - Dark") {
    NavigationStack {
        ServiceTrackerView(
            viewModel: CustomerPortalViewModel(),
            serviceID: CustomerPortalMockData.activeService.id
        )
    }
    .preferredColorScheme(.dark)
}
