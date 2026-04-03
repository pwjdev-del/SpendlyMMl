import SwiftUI
import SpendlyCore

struct CustodyLogView: View {
    @Bindable var vm: AssetTransferViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Machine info header card
                machineInfoBar

                SPScreenWrapper {
                    VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                        // Append-only badge
                        HStack(spacing: SpendlySpacing.sm) {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 14))
                                .foregroundStyle(SpendlyColors.primary)
                            Text("Chain of Custody")
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Spacer()
                            SPBadge("Append-Only", style: .custom(SpendlyColors.primary))
                        }

                        Text("Immutable record of all ownership changes. Entries cannot be edited or deleted after creation.")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)

                        // Timeline
                        custodyTimeline

                        // Custody cards for detail
                        ForEach(vm.custodyEntries) { entry in
                            custodyCard(entry)
                        }

                        // Compliance footer
                        complianceFooter
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Custody Log")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: SpendlyIcon.close.systemName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
            }
        }
    }

    // MARK: - Machine Info Bar

    private var machineInfoBar: some View {
        SPCard(elevation: .low, padding: SpendlySpacing.md) {
            HStack(spacing: SpendlySpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .fill(SpendlyColors.primary.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "gearshape.2")
                        .font(.system(size: 18))
                        .foregroundStyle(SpendlyColors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(vm.custodyMachineName)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text("S/N: \(vm.custodyMachineSerial)")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(vm.custodyEntries.count)")
                        .font(SpendlyFont.title())
                        .foregroundStyle(SpendlyColors.primary)
                    Text("Owners")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.top, SpendlySpacing.sm)
    }

    // MARK: - Timeline

    private var custodyTimeline: some View {
        let items = vm.custodyEntries.map { entry in
            SPTimelineItem(
                title: entry.ownerName,
                subtitle: timelineSubtitle(for: entry),
                status: entry.isCurrent ? .active : .completed,
                time: vm.formatShortDate(entry.startDate)
            )
        }
        return SPTimeline(items: items)
    }

    private func timelineSubtitle(for entry: CustodyEntry) -> String {
        if entry.isCurrent {
            return "\(entry.organizationName) — Current Owner"
        } else if let end = entry.endDate {
            return "\(entry.organizationName) — until \(vm.formatShortDate(end))"
        } else {
            return entry.organizationName
        }
    }

    // MARK: - Custody Card

    private func custodyCard(_ entry: CustodyEntry) -> some View {
        SPCard(elevation: entry.isCurrent ? .medium : .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                // Owner row
                HStack(spacing: SpendlySpacing.md) {
                    SPAvatar(
                        initials: vm.initials(for: entry.ownerName),
                        size: .md,
                        statusDot: entry.isCurrent ? SpendlyColors.success : nil
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.ownerName)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text(entry.organizationName)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    Spacer()

                    if entry.isCurrent {
                        SPBadge("Current", style: .success)
                    } else {
                        SPBadge("Previous", style: .neutral)
                    }
                }

                // Date range
                HStack(spacing: SpendlySpacing.lg) {
                    dateColumn("Start Date", vm.formatShortDate(entry.startDate))
                    if let end = entry.endDate {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                            .foregroundStyle(SpendlyColors.secondary)
                        dateColumn("End Date", vm.formatShortDate(end))
                    } else {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                            .foregroundStyle(SpendlyColors.secondary)
                        dateColumn("End Date", "Present")
                    }
                    Spacer()
                    durationLabel(entry)
                }

                // Immutable indicator
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                    Text("Immutable record")
                        .font(.custom("Inter-Regular", size: 10))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                }
            }
        }
    }

    private func dateColumn(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.custom("Inter-Regular", size: 10))
                .foregroundStyle(SpendlyColors.secondary)
            Text(value)
                .font(SpendlyFont.bodyMedium())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
    }

    private func durationLabel(_ entry: CustodyEntry) -> some View {
        let end = entry.endDate ?? Date()
        let days = Calendar.current.dateComponents([.day], from: entry.startDate, to: end).day ?? 0
        let years = days / 365
        let remainingMonths = (days % 365) / 30

        var text = ""
        if years > 0 {
            text += "\(years)y "
        }
        text += "\(remainingMonths)m"

        return VStack(alignment: .trailing, spacing: 2) {
            Text("Duration")
                .font(.custom("Inter-Regular", size: 10))
                .foregroundStyle(SpendlyColors.secondary)
            Text(text)
                .font(SpendlyFont.tabularNumbers())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
    }

    // MARK: - Compliance Footer

    private var complianceFooter: some View {
        SPCard(elevation: .low, padding: SpendlySpacing.md) {
            HStack(alignment: .top, spacing: SpendlySpacing.sm) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 14))
                    .foregroundStyle(SpendlyColors.primary)
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text("Compliance Notice")
                        .font(SpendlyFont.bodyMedium())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text("This chain of custody log is append-only and immutable. Records are maintained in compliance with asset tracking requirements. No entries can be modified or deleted after creation. The OEM retains full visibility of all history, including pre-transfer records.")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
    }
}

#Preview {
    CustodyLogView(vm: AssetTransferViewModel())
}
