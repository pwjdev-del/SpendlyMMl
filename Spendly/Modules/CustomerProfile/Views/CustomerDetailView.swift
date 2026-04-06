import SwiftUI
import SpendlyCore

// MARK: - CustomerDetailView

struct CustomerDetailView: View {

    let customer: CustomerDisplayModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // MARK: Header
            SPHeader(
                title: "Customer Profile",
                showBackButton: true,
                backAction: { dismiss() }
            ) {
                Button {
                    // More actions placeholder
                } label: {
                    Image(systemName: SpendlyIcon.moreVert.systemName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }

            ScrollView {
                VStack(spacing: 0) {
                    // MARK: Hero Section
                    heroSection

                    // MARK: Quick Actions
                    quickActionsGrid

                    // MARK: Content Sections
                    VStack(spacing: SpendlySpacing.lg) {
                        contactInfoSection
                        preferencesSection
                        accountOverviewSection
                        machineListSection
                        jobHistorySection
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.top, SpendlySpacing.lg)
                    .padding(.bottom, SpendlySpacing.xxxl * 2)
                }
            }
        }
        .background(SpendlyColors.background(for: colorScheme).ignoresSafeArea())
        .navigationBarHidden(true)
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: SpendlySpacing.lg) {
            // Avatar
            ZStack {
                Circle()
                    .fill(SpendlyColors.primary.opacity(0.1))
                    .frame(width: 112, height: 112)

                if let url = customer.avatarURL, let imageURL = URL(string: url) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 104, height: 104)
                                .clipShape(Circle())
                        default:
                            avatarInitialsFallback
                        }
                    }
                } else {
                    avatarInitialsFallback
                }
            }

            // Name and info
            VStack(spacing: SpendlySpacing.xs) {
                Text("\(customer.companyName) - \(customer.name)")
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text("Primary Contact: \(customer.contactTitle)")
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                // Premium badge
                if customer.isPremium {
                    HStack(spacing: 6) {
                        Image(systemName: SpendlyIcon.verified.systemName)
                            .font(.system(size: 14))
                            .foregroundStyle(SpendlyColors.primary)

                        Text("PREMIUM CLIENT")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(SpendlyColors.primary)
                    }
                    .padding(.horizontal, SpendlySpacing.md)
                    .padding(.vertical, SpendlySpacing.xs + 2)
                    .background(SpendlyColors.primary.opacity(0.06))
                    .clipShape(Capsule())
                    .padding(.top, SpendlySpacing.xs)
                }
            }

            // Edit / View Map buttons
            HStack(spacing: SpendlySpacing.md) {
                SPButton("Edit Profile", icon: SpendlyIcon.edit.systemName, style: .secondary) {
                    // Edit profile placeholder
                }

                SPButton("View Map", icon: SpendlyIcon.map.systemName, style: .primary) {
                    // View map placeholder
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
        }
        .padding(.vertical, SpendlySpacing.xxl)
        .frame(maxWidth: .infinity)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    private var avatarInitialsFallback: some View {
        Circle()
            .fill(SpendlyColors.primary.opacity(0.15))
            .frame(width: 104, height: 104)
            .overlay(
                Text(customer.initials)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(SpendlyColors.primary)
            )
    }

    // MARK: - Quick Actions Grid

    private var quickActionsGrid: some View {
        HStack(spacing: SpendlySpacing.sm) {
            quickActionButton(
                icon: SpendlyIcon.call.systemName,
                label: "Call"
            ) {
                if let url = URL(string: "tel:\(customer.phone)") {
                    UIApplication.shared.open(url)
                }
            }

            quickActionButton(
                icon: SpendlyIcon.chatBubble.systemName,
                label: "Message"
            ) {
                if let url = URL(string: "sms:\(customer.phone)") {
                    UIApplication.shared.open(url)
                }
            }

            quickActionButton(
                icon: SpendlyIcon.requestQuote.systemName,
                label: "Estimate"
            ) {
                // Create estimate placeholder
            }
        }
        .padding(SpendlySpacing.lg)
        .background(
            colorScheme == .dark
                ? SpendlyColors.surfaceDark.opacity(0.5)
                : SpendlyColors.backgroundLight
        )
    }

    private func quickActionButton(
        icon: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: SpendlySpacing.sm) {
                ZStack {
                    Circle()
                        .fill(SpendlyColors.primary.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundStyle(SpendlyColors.primary)
                }

                Text(label)
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.md)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(
                        colorScheme == .dark
                            ? Color.white.opacity(0.06)
                            : Color.black.opacity(0.06),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Contact Information Section

    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            sectionHeader("Contact Information")

            SPCard(elevation: .low) {
                VStack(spacing: SpendlySpacing.lg) {
                    contactRow(
                        icon: "envelope.fill",
                        value: customer.email,
                        label: "Work Email"
                    )

                    SPDivider()

                    contactRow(
                        icon: SpendlyIcon.call.systemName,
                        value: customer.phone,
                        label: "Mobile Phone"
                    )

                    SPDivider()

                    contactRow(
                        icon: "mappin.circle.fill",
                        value: customer.fullAddress,
                        label: "Service Address"
                    )
                }
            }
        }
    }

    private func contactRow(icon: String, value: String, label: String) -> some View {
        HStack(alignment: .top, spacing: SpendlySpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(SpendlyColors.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text(label)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            Spacer()
        }
    }

    // MARK: - Preferences & Notes Section

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            if !customer.notes.isEmpty {
                SPCard(elevation: .low, padding: SpendlySpacing.lg) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                        HStack(spacing: SpendlySpacing.sm) {
                            Image(systemName: SpendlyIcon.info.systemName)
                                .font(.system(size: 16))
                                .foregroundStyle(SpendlyColors.primary)

                            Text("Preferences & Notes")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.primary)
                        }

                        ForEach(Array(customer.notes.enumerated()), id: \.offset) { _, note in
                            HStack(alignment: .top, spacing: SpendlySpacing.sm) {
                                Circle()
                                    .fill(SpendlyColors.primary)
                                    .frame(width: 6, height: 6)
                                    .padding(.top, 6)

                                Text(note)
                                    .font(SpendlyFont.body())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            }
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                        .strokeBorder(SpendlyColors.primary.opacity(0.12), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Account Overview Section

    private var accountOverviewSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            sectionHeader("Account Overview")

            HStack(spacing: SpendlySpacing.md) {
                // Balance card
                SPCard(elevation: .low, padding: SpendlySpacing.md) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(
                                    customer.accountBalance < 0
                                        ? SpendlyColors.error
                                        : SpendlyColors.success
                                )

                            Text("Balance")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }

                        Text(formatCurrency(customer.accountBalance))
                            .font(SpendlyFont.headline())
                            .foregroundStyle(
                                customer.accountBalance < 0
                                    ? SpendlyColors.error
                                    : SpendlyColors.foreground(for: colorScheme)
                            )

                        SPBadge(
                            customer.paymentStatus.rawValue,
                            style: customer.paymentStatus.badgeStyle
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Budget card
                SPCard(elevation: .low, padding: SpendlySpacing.md) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(SpendlyColors.info)

                            Text("Budget")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }

                        Text(formatCurrency(customer.budgetAllocated))
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        SPBadge(customer.contractType, style: .neutral)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    // MARK: - Machine List Section

    private var machineListSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            HStack {
                sectionHeader("Machines")
                Spacer()
                SPBadge(
                    "\(customer.machines.count) Total",
                    style: .neutral
                )
            }

            ForEach(customer.machines) { machine in
                SPCard(elevation: .low) {
                    HStack(spacing: SpendlySpacing.md) {
                        // Machine icon
                        ZStack {
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .fill(machineStatusColor(machine.status).opacity(0.12))
                                .frame(width: 48, height: 48)

                            Image(systemName: "gearshape.2.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(machineStatusColor(machine.status))
                        }

                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text(machine.name)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            Text("\(machine.model) \u{00B7} \(machine.serialNumber)")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                                .lineLimit(1)
                        }

                        Spacer()

                        SPBadge(
                            machineStatusLabel(machine.status),
                            style: machineStatusBadgeStyle(machine.status)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Job History Section

    private var jobHistorySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            HStack {
                sectionHeader("Recent Job History")
                Spacer()
                Button {
                    // View all placeholder
                } label: {
                    Text("View All")
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(SpendlyColors.primary)
                }
            }

            // Timeline
            VStack(spacing: 0) {
                ForEach(Array(customer.jobHistory.enumerated()), id: \.element.id) { index, job in
                    jobTimelineItem(job: job, isLast: index == customer.jobHistory.count - 1)
                }
            }
        }
    }

    private func jobTimelineItem(job: CustomerJobItem, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: SpendlySpacing.md) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(timelineDotColor(for: job.status))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .strokeBorder(SpendlyColors.surface(for: colorScheme), lineWidth: 2)
                    )

                if !isLast {
                    Rectangle()
                        .fill(SpendlyColors.secondary.opacity(0.15))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 12)

            // Job card
            SPCard(elevation: .low) {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    HStack {
                        SPBadge(job.status.rawValue, style: job.status.badgeStyle)
                        Spacer()
                        Text("ID: \(job.jobID)")
                            .font(.system(size: 10))
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    Text(job.title)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    HStack {
                        Text(formatJobDate(job.scheduledDate))
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)

                        if let amount = job.amount, amount > 0 {
                            Text("\u{00B7}")
                                .foregroundStyle(SpendlyColors.secondary)
                            Text(formatCurrency(amount))
                                .font(SpendlyFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        }
                    }

                    if let tech = job.technicianName {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(SpendlyColors.secondary)
                            Text(tech)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                    }
                }
            }
            .padding(.bottom, isLast ? 0 : SpendlySpacing.md)
        }
    }

    // MARK: - Section Header Helper

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(SpendlyFont.caption())
            .fontWeight(.bold)
            .foregroundStyle(SpendlyColors.secondary)
            .tracking(1.5)
    }

    // MARK: - Helpers

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    private func formatJobDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Today, \(formatter.string(from: date))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }

    private func timelineDotColor(for status: CustomerJobStatus) -> Color {
        switch status {
        case .inProgress: return SpendlyColors.success
        case .completed:  return SpendlyColors.secondary
        case .scheduled:  return SpendlyColors.primary
        case .cancelled:  return SpendlyColors.error
        }
    }

    private func machineStatusColor(_ status: MachineStatus) -> Color {
        switch status {
        case .operational:       return SpendlyColors.success
        case .needsMaintenance:  return SpendlyColors.warning
        case .underRepair:       return SpendlyColors.error
        case .decommissioned:    return SpendlyColors.secondary
        }
    }

    private func machineStatusLabel(_ status: MachineStatus) -> String {
        switch status {
        case .operational:       return "Operational"
        case .needsMaintenance:  return "Maintenance"
        case .underRepair:       return "Repairing"
        case .decommissioned:    return "Retired"
        }
    }

    private func machineStatusBadgeStyle(_ status: MachineStatus) -> SPBadgeStyle {
        switch status {
        case .operational:       return .success
        case .needsMaintenance:  return .warning
        case .underRepair:       return .error
        case .decommissioned:    return .neutral
        }
    }
}

// MARK: - Previews

#Preview("Customer Detail") {
    NavigationStack {
        CustomerDetailView(customer: CustomerProfileMockData.customers[0])
    }
}

#Preview("Customer Detail - Premium") {
    NavigationStack {
        CustomerDetailView(customer: CustomerProfileMockData.customers[3])
    }
}

#Preview("Customer Detail - Dark") {
    NavigationStack {
        CustomerDetailView(customer: CustomerProfileMockData.customers[0])
    }
    .preferredColorScheme(.dark)
}
