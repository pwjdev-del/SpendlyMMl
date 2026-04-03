import SwiftUI
import SpendlyCore

public struct AssetTransferRootView: View {
    @State private var vm = AssetTransferViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            SPHeader(title: "Asset Transfer") {
                Button {
                    vm.beginTransfer()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(SpendlyColors.primary)
                }
            }

            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.lg) {
                    // Search
                    SPSearchBar(searchText: $vm.listSearchText)

                    // Summary row
                    HStack(spacing: SpendlySpacing.md) {
                        summaryPill(
                            count: vm.pendingTransfers.count,
                            label: "Pending",
                            color: SpendlyColors.warning
                        )
                        summaryPill(
                            count: vm.completedTransfers.count,
                            label: "Completed",
                            color: SpendlyColors.success
                        )
                        Spacer()
                    }

                    // Pending transfers section
                    if !vm.pendingTransfers.isEmpty {
                        sectionHeader("Pending Transfers")
                        ForEach(vm.pendingTransfers) { transfer in
                            transferCard(transfer)
                        }
                    }

                    // Completed transfers section
                    if !vm.completedTransfers.isEmpty {
                        sectionHeader("Completed Transfers")
                        ForEach(vm.completedTransfers) { transfer in
                            transferCard(transfer)
                        }
                    }

                    // Empty state
                    if vm.filteredTransfers.isEmpty {
                        emptyState
                    }

                    // Initiate button at bottom
                    SPButton("Initiate Transfer", icon: "plus", style: .primary) {
                        vm.beginTransfer()
                    }
                    .padding(.top, SpendlySpacing.md)
                }
            }
        }
        .sheet(isPresented: $vm.showingInitiateSheet) {
            InitiateTransferView(vm: vm)
        }
        .sheet(isPresented: $vm.showingCustodyLog) {
            CustodyLogView(vm: vm)
        }
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            Spacer()
        }
    }

    // MARK: - Transfer Card

    private func transferCard(_ transfer: TransferDisplayItem) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                // Top row: machine name + status badge
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(transfer.machineName)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("S/N: \(transfer.machineSerial)")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                    Spacer()
                    SPBadge(
                        vm.statusLabel(for: transfer.status),
                        style: vm.badgeStyle(for: transfer.status)
                    )
                }

                // Transfer direction
                HStack(spacing: SpendlySpacing.sm) {
                    SPAvatar(initials: vm.initials(for: transfer.fromCustomerName), size: .sm)
                    Text(transfer.fromCustomerName)
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .lineLimit(1)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(SpendlyColors.accent)

                    SPAvatar(initials: vm.initials(for: transfer.toCustomerName), size: .sm)
                    Text(transfer.toCustomerName)
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .lineLimit(1)
                }

                // Bottom row: date + actions
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundStyle(SpendlyColors.secondary)
                    Text(vm.formatDate(transfer.date))
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)

                    if transfer.includesAudit {
                        SPBadge("Audit", style: .info)
                    }

                    Spacer()

                    Button {
                        vm.openCustodyLog(for: transfer)
                    } label: {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "clock.arrow.counterclockwise")
                                .font(.system(size: 12))
                            Text("Custody Log")
                                .font(SpendlyFont.caption())
                        }
                        .foregroundStyle(SpendlyColors.primary)
                    }
                }
            }
        }
    }

    // MARK: - Summary Pill

    private func summaryPill(count: Int, label: String, color: Color) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Text("\(count)")
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(color)
            Text(label)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
        }
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.vertical, SpendlySpacing.sm)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: SpendlySpacing.lg) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 40))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
            Text("No Transfers Found")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            Text("Initiate a transfer to move machine ownership between customers.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SpendlySpacing.xxxl)
    }
}

#Preview {
    AssetTransferRootView()
}
