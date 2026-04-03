import SwiftUI
import SpendlyCore

public struct FinancialHubRootView: View {
    @State private var vm = FinancialHubViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            SPHeader(title: "Financial Hub") {
                Button {
                    // Notifications action
                } label: {
                    Image(systemName: SpendlyIcon.notifications.systemName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }

            ScrollView {
                VStack(spacing: 0) {
                    // Summary Metric Cards
                    summarySection

                    // Bank Connection Card
                    bankConnectionSection

                    // Quick Actions
                    quickActionsSection

                    // Expense Status
                    expenseStatusSection

                    // Recent Payouts
                    recentPayoutsSection
                }
                .padding(.bottom, SpendlySpacing.xxxl)
            }
        }
        .background(SpendlyColors.background(for: colorScheme))
    }

    // MARK: - Summary Metric Cards

    private var summarySection: some View {
        HStack(spacing: SpendlySpacing.lg) {
            ForEach(vm.metrics) { metric in
                SPMetricCard(
                    title: metric.title,
                    value: metric.value,
                    trend: metric.trend,
                    trendDirection: metric.trendDirection
                )
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.lg)
    }

    // MARK: - Bank Connection Card

    private var bankConnectionSection: some View {
        SPCard(elevation: .low) {
            HStack(spacing: SpendlySpacing.lg) {
                // Bank Icon
                ZStack {
                    Circle()
                        .fill(SpendlyColors.primary.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(SpendlyColors.primary)
                }

                // Bank Details
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text("Bank Connection")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Text(vm.bankDisplayName)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)

                    Text(vm.connectionStatusText)
                        .font(.system(size: 10, weight: .bold))
                        .textCase(.uppercase)
                        .tracking(0.8)
                        .foregroundStyle(
                            vm.bankConnection.isConnected
                                ? SpendlyColors.success
                                : SpendlyColors.error
                        )
                }

                Spacer()

                // Manage Button
                Button {
                    vm.manageBankConnection()
                } label: {
                    Text("Manage")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, SpendlySpacing.lg)
                        .padding(.vertical, SpendlySpacing.sm)
                        .background(SpendlyColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.sm)
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        HStack(spacing: SpendlySpacing.md) {
            // Transfer Now (filled primary)
            Button {
                vm.transferNow()
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Transfer Now")
                        .font(SpendlyFont.bodySemibold())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(.white)
                .background(SpendlyColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                .shadow(color: SpendlyColors.primary.opacity(0.25), radius: 6, y: 3)
            }

            // Pay Now (outlined primary)
            Button {
                vm.payNow()
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Pay Now")
                        .font(SpendlyFont.bodySemibold())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(SpendlyColors.primary)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                        .strokeBorder(SpendlyColors.primary, lineWidth: 2)
                )
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.lg)
    }

    // MARK: - Expense Status Section

    private var expenseStatusSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("Expense Status")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            VStack(spacing: SpendlySpacing.md) {
                ForEach(vm.expenseStatusItems) { item in
                    expenseStatusRow(item)
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.top, SpendlySpacing.lg)
    }

    private func expenseStatusRow(_ item: ExpenseStatusItem) -> some View {
        HStack(spacing: SpendlySpacing.md) {
            // Status dot
            Circle()
                .fill(item.status.badgeStyle.foregroundColor)
                .frame(width: 8, height: 8)

            // Title & date
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text(item.title)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Text(item.requestedDate)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            Spacer()

            // Amount & status label
            VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                Text(vm.formatAmount(item.amount))
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text(item.status.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(item.status.badgeStyle.foregroundColor)
            }
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.background(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .strokeBorder(SpendlyColors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Recent Payouts Section

    private var recentPayoutsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            // Section header with View All
            HStack {
                Text("Recent Payouts")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
                Button {
                    vm.viewAllPayouts()
                } label: {
                    Text("View All")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.primary)
                }
            }

            // Payout rows
            VStack(spacing: SpendlySpacing.xs) {
                ForEach(Array(vm.recentPayouts.enumerated()), id: \.element.id) { index, payout in
                    payoutRow(payout, isLast: index == vm.recentPayouts.count - 1)
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.top, SpendlySpacing.xxxl)
    }

    private func payoutRow(_ payout: PayoutItem, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: SpendlySpacing.md) {
                // Payout icon
                ZStack {
                    RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                        .fill(SpendlyColors.primary.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: payout.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(SpendlyColors.primary)
                }

                // Title & date
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text(payout.title)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text(vm.formatPayoutDate(payout.date))
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                Spacer()

                // Amount
                Text(vm.formatPayoutAmount(payout.amount))
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
            .padding(.vertical, SpendlySpacing.md)

            if !isLast {
                Divider()
                    .background(SpendlyColors.secondary.opacity(0.1))
            }
        }
    }
}

#Preview {
    FinancialHubRootView()
}
