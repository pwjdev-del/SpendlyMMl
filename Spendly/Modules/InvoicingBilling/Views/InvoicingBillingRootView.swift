import SwiftUI
import SpendlyCore

// MARK: - InvoicingBillingRootView

public struct InvoicingBillingRootView: View {

    @State private var viewModel = InvoicingBillingViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        SPScreenWrapper {
            VStack(spacing: SpendlySpacing.lg) {
                // MARK: Header
                headerSection

                // MARK: Search Bar (matching white-label Stitch)
                if viewModel.isSearchActive {
                    SPSearchBar(searchText: $viewModel.searchText)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // MARK: Stat Cards (3-column grid from Stitch)
                statCardsSection

                // MARK: Tab Navigation (Draft / Sent / Paid / Overdue)
                tabNavigationSection

                // MARK: Tab Content
                if viewModel.filteredInvoices.isEmpty && viewModel.searchText.isEmpty {
                    // Show Ready to Invoice when no invoices in current tab
                    if viewModel.selectedTab == .draft && !viewModel.readyToInvoiceJobs.isEmpty {
                        readyToInvoiceSection
                    } else {
                        emptyTabState
                    }
                } else if viewModel.filteredInvoices.isEmpty {
                    SPEmptyState(
                        icon: "doc.text.magnifyingglass",
                        title: "No Results",
                        message: "No invoices match your search. Try a different keyword."
                    )
                } else {
                    invoiceListSection
                }

                // MARK: Ready to Invoice (always visible on Draft tab if jobs exist)
                if viewModel.selectedTab == .draft
                    && !viewModel.readyToInvoiceJobs.isEmpty
                    && !viewModel.filteredInvoices.isEmpty {
                    readyToInvoiceSection
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.showInvoiceDetail) {
            if let invoice = viewModel.selectedInvoice {
                InvoiceDetailView(viewModel: viewModel, invoice: invoice)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.isSearchActive)
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedTab)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        HStack(alignment: .center) {
            HStack(spacing: SpendlySpacing.md) {
                // Receipt icon matching Stitch
                Image(systemName: "doc.plaintext.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(SpendlyColors.primary)
                    .frame(width: 40, height: 40)
                    .background(SpendlyColors.primary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Invoicing & Billing")
                        .font(SpendlyFont.title())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    if !viewModel.branding.companyName.isEmpty {
                        Text(viewModel.branding.companyName)
                            .font(.system(size: 10, weight: .bold))
                            .textCase(.uppercase)
                            .tracking(0.8)
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }

            Spacer()

            HStack(spacing: SpendlySpacing.sm) {
                // Search toggle button
                Button {
                    withAnimation {
                        viewModel.isSearchActive.toggle()
                        if !viewModel.isSearchActive {
                            viewModel.searchText = ""
                        }
                    }
                } label: {
                    Image(systemName: SpendlyIcon.search.systemName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(viewModel.isSearchActive ? .white : SpendlyColors.primary)
                        .frame(width: 40, height: 40)
                        .background(
                            viewModel.isSearchActive
                                ? SpendlyColors.primary
                                : SpendlyColors.primary.opacity(0.1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }

                // Add invoice button
                Button {
                    viewModel.showCreateManualInvoice = true
                } label: {
                    Image(systemName: SpendlyIcon.add.systemName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(SpendlyColors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }
            }
        }
    }

    // MARK: - Stat Cards Section (3 cards matching Stitch)

    private var statCardsSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Total Outstanding
            billingStatCard(
                title: "Total Outstanding",
                value: viewModel.formatCurrency(viewModel.summary.totalOutstanding),
                subtitle: "\(viewModel.summary.outstandingCount) Unpaid Invoices",
                trend: viewModel.summary.outstandingTrend,
                trendDirection: .up
            )

            HStack(spacing: SpendlySpacing.md) {
                // Overdue
                billingStatCard(
                    title: "Overdue",
                    value: viewModel.formatCurrency(viewModel.summary.totalOverdue),
                    subtitle: "\(viewModel.summary.overdueCount) Overdue Items",
                    trend: viewModel.summary.overdueTrend,
                    trendDirection: .up,
                    trendColor: SpendlyColors.error
                )

                // Paid MTD
                billingStatCard(
                    title: "Paid (MTD)",
                    value: viewModel.formatCurrency(viewModel.summary.totalPaidMTD),
                    subtitle: "\(viewModel.summary.paidCount) Completed Invoices",
                    trend: viewModel.summary.paidTrend,
                    trendDirection: .up,
                    trendColor: SpendlyColors.success
                )
            }
        }
    }

    private func billingStatCard(
        title: String,
        value: String,
        subtitle: String,
        trend: String,
        trendDirection: SPTrendDirection,
        trendColor: Color? = nil
    ) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                HStack {
                    Text(title)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                    Spacer()

                    // Trend badge matching Stitch design
                    Text(trend)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(trendColor ?? SpendlyColors.success)
                        .padding(.horizontal, SpendlySpacing.sm)
                        .padding(.vertical, 2)
                        .background((trendColor ?? SpendlyColors.success).opacity(0.1))
                        .clipShape(Capsule())
                }

                Text(value)
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .monospacedDigit()

                Text(subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(SpendlyColors.secondary)
            }
        }
    }

    // MARK: - Tab Navigation (pill-style tabs from Stitch)

    private var tabNavigationSection: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpendlySpacing.xxxl) {
                    ForEach(InvoiceTab.allCases) { tab in
                        tabButton(tab)
                    }
                }
            }

            // Divider line
            Rectangle()
                .fill(SpendlyColors.primary.opacity(0.1))
                .frame(height: 1)
        }
    }

    private func tabButton(_ tab: InvoiceTab) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedTab = tab
            }
        } label: {
            VStack(spacing: 0) {
                Text(tab.rawValue)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(
                        viewModel.selectedTab == tab
                            ? SpendlyColors.primary
                            : SpendlyColors.secondary
                    )
                    .padding(.vertical, SpendlySpacing.sm)
                    .padding(.horizontal, SpendlySpacing.xs)

                // Active indicator line
                Rectangle()
                    .fill(viewModel.selectedTab == tab ? SpendlyColors.primary : .clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Invoice List Section

    private var invoiceListSection: some View {
        LazyVStack(spacing: SpendlySpacing.md) {
            ForEach(viewModel.filteredInvoices) { invoice in
                InvoiceListCard(
                    invoice: invoice,
                    viewModel: viewModel,
                    onTap: {
                        viewModel.selectInvoice(invoice)
                    }
                )
            }
        }
    }

    // MARK: - Ready to Invoice Section (from Stitch)

    private var readyToInvoiceSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Section header
            HStack {
                Text("Ready to Invoice")
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                Button {
                    // View all action
                } label: {
                    Text("View All")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.primary)
                }
            }
            .padding(.horizontal, SpendlySpacing.xs)

            // Job cards
            ForEach(viewModel.readyToInvoiceJobs) { job in
                ReadyToInvoiceCard(job: job, viewModel: viewModel)
            }
        }
    }

    // MARK: - Empty Tab State

    private var emptyTabState: some View {
        SPEmptyState(
            icon: tabEmptyIcon,
            title: tabEmptyTitle,
            message: tabEmptyMessage
        )
    }

    private var tabEmptyIcon: String {
        switch viewModel.selectedTab {
        case .draft:   return "doc.text"
        case .sent:    return "paperplane"
        case .paid:    return "checkmark.circle"
        case .overdue: return "exclamationmark.triangle"
        }
    }

    private var tabEmptyTitle: String {
        switch viewModel.selectedTab {
        case .draft:   return "No Drafts"
        case .sent:    return "No Sent Invoices"
        case .paid:    return "No Paid Invoices"
        case .overdue: return "No Overdue Invoices"
        }
    }

    private var tabEmptyMessage: String {
        switch viewModel.selectedTab {
        case .draft:   return "Create an invoice from a completed job or add one manually."
        case .sent:    return "Invoices you send to clients will appear here."
        case .paid:    return "Paid invoices will appear here once payment is recorded."
        case .overdue: return "Great news! You have no overdue invoices."
        }
    }
}

// MARK: - Invoice List Card

private struct InvoiceListCard: View {
    let invoice: InvoiceDisplayModel
    let viewModel: InvoicingBillingViewModel
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTap) {
            SPCard(elevation: .medium, padding: 0) {
                VStack(spacing: 0) {
                    // Status color bar
                    Rectangle()
                        .fill(invoice.statusBadgeStyle.foregroundColor)
                        .frame(height: 3)

                    VStack(spacing: SpendlySpacing.md) {
                        // Top row: customer info + amount
                        HStack(alignment: .top, spacing: SpendlySpacing.md) {
                            // Customer avatar
                            SPAvatar(
                                initials: invoice.customerInitials,
                                size: .lg,
                                statusDot: invoice.status == .paid
                                    ? SpendlyColors.success
                                    : invoice.status == .overdue
                                        ? SpendlyColors.error
                                        : nil
                            )

                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text(invoice.customerName)
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                    .lineLimit(1)

                                Text(invoice.invoiceNumber)
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                                Text(invoice.jobTitle)
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.7))
                                    .lineLimit(1)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                                SPBadge(invoice.statusLabel, style: invoice.statusBadgeStyle)

                                Text(viewModel.formatCurrency(invoice.total))
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.primary)
                                    .monospacedDigit()
                            }
                        }

                        SPDivider()

                        // Bottom row: due date + job info
                        HStack {
                            if let dueDate = invoice.dueDate {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(invoice.status == .paid ? "Paid" : "Due")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondary)

                                    Text(invoice.status == .paid
                                         ? viewModel.formatDate(invoice.paidAt ?? dueDate)
                                         : viewModel.formatDate(dueDate))
                                        .font(SpendlyFont.bodyMedium())
                                        .foregroundStyle(
                                            invoice.isOverdue
                                                ? SpendlyColors.error
                                                : SpendlyColors.foreground(for: colorScheme)
                                        )
                                }
                            }

                            Spacer()

                            // Job number chip
                            HStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: "wrench.and.screwdriver")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(SpendlyColors.accent)

                                Text("Job #\(invoice.jobNumber)")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            }
                            .padding(.horizontal, SpendlySpacing.sm)
                            .padding(.vertical, SpendlySpacing.xs + 2)
                            .background(SpendlyColors.accent.opacity(0.06))
                            .clipShape(Capsule())

                            Image(systemName: SpendlyIcon.chevronRight.systemName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                        }
                    }
                    .padding(SpendlySpacing.lg)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ready to Invoice Card (matches Stitch exactly)

private struct ReadyToInvoiceCard: View {
    let job: ReadyToInvoiceJob
    let viewModel: InvoicingBillingViewModel

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SPCard(elevation: .low) {
            VStack(spacing: SpendlySpacing.lg) {
                // Top row: job info + amount
                HStack(alignment: .top, spacing: SpendlySpacing.md) {
                    // Job icon
                    Image(systemName: job.iconName)
                        .font(.system(size: 20))
                        .foregroundStyle(SpendlyColors.primary)
                        .frame(width: 48, height: 48)
                        .background(
                            colorScheme == .dark
                                ? SpendlyColors.surfaceDark
                                : Color(hex: "#f1f5f9")
                        )
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(job.jobTitle)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .lineLimit(1)

                        Text("Job #\(job.jobNumber) \u{2022} Completed \(viewModel.formatShortDate(job.completedDate))")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                        Text(viewModel.formatCurrency(job.amount))
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.primary)
                            .monospacedDigit()

                        Text(job.costBreakdown)
                            .font(.system(size: 10))
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }

                // Action buttons
                HStack(spacing: SpendlySpacing.sm) {
                    // Create Invoice button (primary, matching Stitch)
                    SPButton("Create Invoice", icon: "plus.circle.fill", style: .primary) {
                        viewModel.createInvoice(from: job)
                    }

                    // More options button
                    Button {
                        // More options for job
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(SpendlyColors.secondary)
                            .frame(width: 44, height: 44)
                            .background(
                                colorScheme == .dark
                                    ? SpendlyColors.surfaceDark
                                    : Color(hex: "#f1f5f9")
                            )
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Invoicing & Billing") {
    NavigationStack {
        InvoicingBillingRootView()
    }
}

#Preview("Invoicing & Billing - Dark") {
    NavigationStack {
        InvoicingBillingRootView()
    }
    .preferredColorScheme(.dark)
}
