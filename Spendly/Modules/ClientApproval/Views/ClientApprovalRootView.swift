import SwiftUI
import SpendlyCore

public struct ClientApprovalRootView: View {
    @State private var vm = ClientApprovalViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            SPHeader(title: "Client Approvals")

            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.lg) {
                    // Search
                    SPSearchBar(searchText: $vm.searchText)

                    // Summary pills
                    HStack(spacing: SpendlySpacing.md) {
                        summaryPill(
                            count: vm.pendingEstimates.count,
                            label: "Pending",
                            color: SpendlyColors.warning
                        )
                        summaryPill(
                            count: vm.completedEstimates.count,
                            label: "Reviewed",
                            color: SpendlyColors.success
                        )
                        Spacer()
                    }

                    // Pending estimates section
                    if !vm.pendingEstimates.isEmpty {
                        sectionHeader("Pending Approval")
                        ForEach(vm.pendingEstimates) { estimate in
                            estimateCard(estimate)
                                .onTapGesture {
                                    vm.openEstimate(estimate)
                                }
                        }
                    }

                    // Completed estimates section
                    if !vm.completedEstimates.isEmpty {
                        sectionHeader("Reviewed")
                        ForEach(vm.completedEstimates) { estimate in
                            estimateCard(estimate)
                                .onTapGesture {
                                    vm.openEstimate(estimate)
                                }
                        }
                    }

                    // Empty state
                    if vm.filteredEstimates.isEmpty {
                        SPEmptyState(
                            icon: "doc.text.magnifyingglass",
                            title: "No Estimates Found",
                            message: "There are no estimates matching your search criteria."
                        )
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $vm.showingDetail) {
            if let estimate = vm.selectedEstimate {
                EstimateApprovalView(vm: vm, estimate: estimate)
            }
        }
        .fullScreenCover(isPresented: $vm.showingSuccess) {
            ApprovalSuccessView(vm: vm)
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

    // MARK: - Estimate Card

    private func estimateCard(_ estimate: EstimateApprovalItem) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                // Top row: estimate number + status badge
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(estimate.estimateNumber)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text(estimate.projectTitle)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                    Spacer()
                    SPBadge(
                        vm.statusLabel(for: estimate.status),
                        style: vm.badgeStyle(for: estimate.status)
                    )
                }

                // Customer info row
                HStack(spacing: SpendlySpacing.sm) {
                    SPAvatar(initials: vm.initials(for: estimate.customerName), size: .sm)
                    Text(estimate.customerName)
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .lineLimit(1)
                    Spacer()
                }

                // Bottom row: date + total
                HStack {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundStyle(SpendlyColors.secondary)
                        Text(vm.formatDate(estimate.issuedDate))
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    Spacer()

                    Text(vm.formatCurrency(estimate.grandTotal))
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.accent)
                        .monospacedDigit()
                }

                // Review button for pending items
                if estimate.status == .pending {
                    HStack {
                        Spacer()
                        HStack(spacing: SpendlySpacing.xs) {
                            Text("Review & Approve")
                                .font(SpendlyFont.caption())
                            Image(systemName: SpendlyIcon.chevronRight.systemName)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(SpendlyColors.accent)
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
}

#Preview {
    ClientApprovalRootView()
}
