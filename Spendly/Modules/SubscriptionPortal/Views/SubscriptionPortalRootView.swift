import SwiftUI
import SpendlyCore

// MARK: - Root View

public struct SubscriptionPortalRootView: View {
    @State private var viewModel = SubscriptionPortalViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        SPScreenWrapper(theme: .aeon) {
            VStack(spacing: SpendlySpacing.xxl) {

                // MARK: Breadcrumb & Page Header
                pageHeader

                // MARK: Active Plan Card
                activePlanCard

                // MARK: Feature-Level Billing Breakdown
                featureBreakdownCard

                // MARK: Billing Contact
                billingContactCard

                // MARK: Recent Invoice History
                invoiceHistoryCard

                // MARK: Annual Savings Insight
                annualSavingsCard

                // MARK: Subscription Plans Comparison
                planComparisonSection
            }
        }
        .sheet(isPresented: $viewModel.showAllTransactions) {
            allTransactionsSheet
        }
        .sheet(isPresented: $viewModel.showManageModules) {
            manageModulesSheet
        }
        .sheet(isPresented: $viewModel.showUpdateBilling) {
            updateBillingSheet
        }
        .sheet(isPresented: $viewModel.showCustomizePlan) {
            customizePlanSheet
        }
        .alert("Invoice Downloaded", isPresented: $viewModel.showDownloadConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("\(viewModel.downloadedInvoiceTitle) has been saved to your device.")
        }
    }
}

// MARK: - Page Header

private extension SubscriptionPortalRootView {

    var pageHeader: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            // Breadcrumb
            HStack(spacing: SpendlySpacing.xs) {
                Text("ACCOUNT")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(SpendlyColors.aeonSecondary)

                Image(systemName: SpendlyIcon.chevronRight.systemName)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(SpendlyColors.aeonSecondary)

                Text("SUBSCRIPTION MANAGEMENT")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(SpendlyColors.aeonPrimary)
            }

            // Title
            Text("Plan & Billing")
                .font(SpendlyFont.financialTitle())
                .foregroundStyle(SpendlyColors.aeonPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Active Plan Card

private extension SubscriptionPortalRootView {

    var activePlanCard: some View {
        VStack(spacing: 0) {
            // Main Content
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                // Top-right badge
                HStack {
                    Spacer()
                    Text("CURRENT PLAN")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(Color(hex: "#00201c"))
                        .padding(.horizontal, SpendlySpacing.md)
                        .padding(.vertical, SpendlySpacing.xs + 2)
                        .background(SpendlyColors.aeonAccent.opacity(0.3))
                        .clipShape(Capsule())
                }

                // Plan name label
                Text("MY ACTIVE PLAN")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.8)
                    .foregroundStyle(SpendlyColors.aeonSecondary)

                // Plan name
                Text(viewModel.currentPlanName)
                    .font(SpendlyFont.financialHeadline())
                    .foregroundStyle(SpendlyColors.aeonPrimary)

                // Price
                HStack(alignment: .firstTextBaseline, spacing: SpendlySpacing.xs) {
                    Text(viewModel.formattedMonthlyTotal)
                        .font(.system(size: 34, weight: .heavy))
                        .monospacedDigit()
                        .foregroundStyle(SpendlyColors.aeonPrimary)

                    Text("/ MONTHLY TOTAL")
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(SpendlyColors.aeonSecondary)
                }

                // Status badge + Customize button
                HStack(spacing: SpendlySpacing.md) {
                    // Payment status badge
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: SpendlyIcon.verified.systemName)
                            .font(.system(size: 16))
                        Text(viewModel.paymentStatus.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.8)
                    }
                    .foregroundStyle(Color(hex: "#1d9385"))
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.vertical, SpendlySpacing.sm + 2)
                    .background(Color(hex: "#1d9385").opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                    Spacer()

                    // Customize Plan button
                    Button {
                        viewModel.showCustomizePlan = true
                    } label: {
                        Text("Customize Plan")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, SpendlySpacing.xl)
                            .padding(.vertical, SpendlySpacing.md)
                            .background(SpendlyColors.aeonSurface)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }
                }

                // Divider
                SPDivider()
                    .padding(.top, SpendlySpacing.sm)

                // Next billing date + Payment method
                HStack(spacing: SpendlySpacing.xxxl) {
                    // Next Billing Date
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("NEXT BILLING DATE")
                            .font(.system(size: 9, weight: .bold))
                            .tracking(1.5)
                            .foregroundStyle(SpendlyColors.aeonSecondary)

                        Text(viewModel.formattedNextBillingDate)
                            .font(SpendlyFont.bodySemibold())
                            .monospacedDigit()
                            .foregroundStyle(SpendlyColors.aeonPrimary)
                    }

                    // Payment Method
                    if let method = viewModel.paymentMethod {
                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text("PAYMENT METHOD")
                                .font(.system(size: 9, weight: .bold))
                                .tracking(1.5)
                                .foregroundStyle(SpendlyColors.aeonSecondary)

                            HStack(spacing: SpendlySpacing.sm) {
                                Image(systemName: "creditcard")
                                    .font(.system(size: 14))
                                    .foregroundStyle(SpendlyColors.aeonSecondary)

                                Text(method.maskedDisplay)
                                    .font(SpendlyFont.bodySemibold())
                                    .monospacedDigit()
                                    .foregroundStyle(SpendlyColors.aeonPrimary)
                            }
                        }
                    }
                }
            }
            .padding(SpendlySpacing.xxl)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous))
        .shadow(color: Color(hex: "#171C25").opacity(0.06), radius: 16, x: 0, y: 6)
    }
}

// MARK: - Feature-Level Billing Breakdown

private extension SubscriptionPortalRootView {

    var featureBreakdownCard: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
            Text("Included in your custom plan")
                .font(SpendlyFont.financialHeadline())
                .foregroundStyle(SpendlyColors.aeonPrimary)

            // Module list
            VStack(spacing: SpendlySpacing.lg) {
                ForEach(viewModel.billingModules) { module in
                    moduleRow(module)
                }
            }

            // Manage modules link
            Button {
                viewModel.showManageModules = true
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Text("MANAGE INDIVIDUAL MODULES")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(SpendlyColors.aeonSecondary)

                    Image(systemName: "arrow.forward")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(SpendlyColors.aeonSecondary)
                }
            }
            .padding(.top, SpendlySpacing.sm)
        }
        .padding(SpendlySpacing.xxl)
        .background(SpendlyColors.aeonBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous))
    }

    func moduleRow(_ module: BillingModule) -> some View {
        HStack(spacing: SpendlySpacing.md) {
            // Checkmark circle
            ZStack {
                Circle()
                    .fill(Color(hex: "#1d9385").opacity(0.1))
                    .frame(width: 24, height: 24)

                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(hex: "#1d9385"))
            }

            Text(module.name)
                .font(SpendlyFont.bodyMedium())
                .foregroundStyle(SpendlyColors.aeonPrimary)

            Spacer()

            Text(String(format: "$%.2f/mo", module.monthlyCost))
                .font(SpendlyFont.caption())
                .fontWeight(.semibold)
                .monospacedDigit()
                .foregroundStyle(SpendlyColors.aeonSecondary)
        }
    }
}

// MARK: - Billing Contact

private extension SubscriptionPortalRootView {

    var billingContactCard: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
            Text("Billing Contact")
                .font(SpendlyFont.financialHeadline())
                .foregroundStyle(SpendlyColors.aeonPrimary)

            if let contact = viewModel.billingContact {
                // Contact info row
                HStack(alignment: .top, spacing: SpendlySpacing.lg) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#c2dcff"))
                            .frame(width: 40, height: 40)

                        Image(systemName: SpendlyIcon.person.systemName)
                            .font(.system(size: 16))
                            .foregroundStyle(Color(hex: "#48617e"))
                    }

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(contact.name)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.aeonPrimary)

                        Text(contact.email)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.aeonSecondary)

                        Text(contact.phone)
                            .font(SpendlyFont.caption())
                            .monospacedDigit()
                            .foregroundStyle(SpendlyColors.aeonSecondary)
                    }
                }
                .padding(SpendlySpacing.lg)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            }

            // Update button
            Button {
                viewModel.showUpdateBilling = true
            } label: {
                Text("Update Details")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.aeonPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.md)
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                            .strokeBorder(SpendlyColors.aeonSecondary.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(SpendlySpacing.xxl)
        .background(Color(hex: "#dee2f0"))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous))
    }
}

// MARK: - Invoice History

private extension SubscriptionPortalRootView {

    var invoiceHistoryCard: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
            // Header with download icon
            HStack {
                Text("Recent History")
                    .font(SpendlyFont.financialHeadline())
                    .foregroundStyle(SpendlyColors.aeonPrimary)

                Spacer()

                Button {
                    if let first = viewModel.recentInvoices.first {
                        viewModel.downloadInvoice(first)
                    }
                } label: {
                    Image(systemName: SpendlyIcon.download.systemName)
                        .font(.system(size: 18))
                        .foregroundStyle(SpendlyColors.aeonSecondary)
                }
            }

            // Invoice rows
            VStack(spacing: SpendlySpacing.md) {
                ForEach(viewModel.recentInvoices) { invoice in
                    invoiceRow(invoice)
                }
            }

            // View All Transactions
            Button {
                viewModel.showAllTransactions = true
            } label: {
                Text("VIEW ALL TRANSACTIONS")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(SpendlyColors.aeonSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.sm)
            }
        }
        .padding(SpendlySpacing.xxl)
        .background(SpendlyColors.aeonBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous))
    }

    func invoiceRow(_ invoice: Invoice) -> some View {
        Button {
            viewModel.viewInvoiceDetail(invoice)
        } label: {
            HStack(spacing: SpendlySpacing.lg) {
                // Receipt icon
                ZStack {
                    RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                        .fill(Color(hex: "#f1f5f9"))
                        .frame(width: 40, height: 40)

                    Image(systemName: "doc.plaintext")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "#94a3b8"))
                }

                // Invoice details
                VStack(alignment: .leading, spacing: 2) {
                    Text(invoice.title)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.aeonPrimary)

                    Text("\(invoice.status.rawValue.uppercased()) \u{00B7} \(viewModel.shortDate(invoice.date))")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(1.2)
                        .monospacedDigit()
                        .foregroundStyle(SpendlyColors.aeonSecondary)
                }

                Spacer()

                // Amount
                Text(viewModel.formattedAmount(invoice.amount))
                    .font(SpendlyFont.bodySemibold())
                    .fontWeight(.heavy)
                    .monospacedDigit()
                    .foregroundStyle(SpendlyColors.aeonPrimary)
            }
            .padding(SpendlySpacing.lg)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Annual Savings Card

private extension SubscriptionPortalRootView {

    var annualSavingsCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Dark navy background
            RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            SpendlyColors.aeonSurface,
                            SpendlyColors.aeonPrimary
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Subtle pattern overlay
            RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous)
                .fill(Color.white.opacity(0.03))

            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                Text("INSIGHT")
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(3)
                    .foregroundStyle(SpendlyColors.aeonAccent)

                Text(viewModel.annualSavingsMessage)
                    .font(SpendlyFont.financialHeadline())
                    .foregroundStyle(.white)
                    .lineSpacing(4)

                Button {} label: {
                    Text("View efficiency report")
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(.white.opacity(0.8))
                        .underline(true, color: SpendlyColors.aeonAccent)
                }
                .padding(.top, SpendlySpacing.sm)
            }
            .padding(SpendlySpacing.xxl)
        }
        .frame(minHeight: 180)
    }
}

// MARK: - Plan Comparison Section

private extension SubscriptionPortalRootView {

    var planComparisonSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xl) {

            // Section Header
            HStack {
                Text("Subscription Plans")
                    .font(SpendlyFont.financialTitle())
                    .foregroundStyle(SpendlyColors.aeonPrimary)

                Spacer()
            }

            // Annual/Monthly Toggle
            HStack(spacing: SpendlySpacing.md) {
                Text("Monthly")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(!viewModel.isAnnualToggle ? SpendlyColors.aeonPrimary : SpendlyColors.aeonSecondary)

                Toggle("", isOn: $viewModel.isAnnualToggle)
                    .labelsHidden()
                    .tint(SpendlyColors.aeonAccent)

                Text("Annual")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(viewModel.isAnnualToggle ? SpendlyColors.aeonPrimary : SpendlyColors.aeonSecondary)

                if viewModel.isAnnualToggle {
                    Text("SAVE UP TO 20%")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(Color(hex: "#00201c"))
                        .padding(.horizontal, SpendlySpacing.sm)
                        .padding(.vertical, SpendlySpacing.xs)
                        .background(SpendlyColors.aeonAccent.opacity(0.3))
                        .clipShape(Capsule())
                }
            }

            // Plan Cards
            ForEach(viewModel.availablePlans) { plan in
                NavigationLink {
                    PlanDetailView(plan: plan, viewModel: viewModel)
                } label: {
                    planCard(plan)
                }
                .buttonStyle(.plain)
            }
        }
    }

    func planCard(_ plan: SubscriptionPlan) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            // Header row
            HStack {
                Text(plan.name)
                    .font(SpendlyFont.financialHeadline())
                    .foregroundStyle(SpendlyColors.aeonPrimary)

                Spacer()

                if plan.isPopular {
                    Text("POPULAR")
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(.white)
                        .padding(.horizontal, SpendlySpacing.md)
                        .padding(.vertical, SpendlySpacing.xs + 2)
                        .background(SpendlyColors.aeonAccent)
                        .clipShape(Capsule())
                }
            }

            // Price
            HStack(alignment: .firstTextBaseline, spacing: SpendlySpacing.xs) {
                Text(viewModel.planPrice(plan))
                    .font(.system(size: 28, weight: .heavy))
                    .monospacedDigit()
                    .foregroundStyle(SpendlyColors.aeonPrimary)

                Text("/ mo")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(SpendlyColors.aeonSecondary)
            }

            if viewModel.isAnnualToggle {
                Text("Save \(viewModel.annualSavingsForPlan(plan))/year")
                    .font(SpendlyFont.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "#1d9385"))
            }

            SPDivider()

            // Feature list (first 4)
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                ForEach(plan.features.prefix(4), id: \.self) { feature in
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color(hex: "#1d9385"))

                        Text(feature)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.aeonPrimary)
                    }
                }

                if plan.features.count > 4 {
                    Text("+ \(plan.features.count - 4) more features")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.aeonSecondary)
                        .padding(.top, SpendlySpacing.xs)
                }
            }

            // View Details
            HStack {
                Spacer()
                HStack(spacing: SpendlySpacing.xs) {
                    Text("View Details")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.aeonSecondary)

                    Image(systemName: SpendlyIcon.chevronRight.systemName)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(SpendlyColors.aeonSecondary)
                }
            }
        }
        .padding(SpendlySpacing.xxl)
        .background(
            plan.isPopular
                ? Color.white
                : SpendlyColors.aeonBackground
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous)
                .strokeBorder(
                    plan.isPopular
                        ? SpendlyColors.aeonAccent.opacity(0.5)
                        : Color.clear,
                    lineWidth: 2
                )
        )
        .shadow(
            color: plan.isPopular
                ? Color(hex: "#171C25").opacity(0.08)
                : .clear,
            radius: 12, x: 0, y: 4
        )
    }
}

// MARK: - All Transactions Sheet

private extension SubscriptionPortalRootView {

    var allTransactionsSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpendlySpacing.md) {
                    ForEach(viewModel.transactions) { transaction in
                        transactionRow(transaction)
                    }
                }
                .padding(SpendlySpacing.lg)
            }
            .background(SpendlyColors.aeonBackground)
            .navigationTitle("All Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.showAllTransactions = false
                    }
                    .foregroundStyle(SpendlyColors.aeonPrimary)
                }
            }
        }
    }

    func transactionRow(_ transaction: Transaction) -> some View {
        HStack(spacing: SpendlySpacing.md) {
            // Type indicator
            Circle()
                .fill(viewModel.transactionTypeColor(for: transaction.type).opacity(0.15))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.aeonPrimary)
                    .lineLimit(1)

                HStack(spacing: SpendlySpacing.sm) {
                    Text(transaction.type.rawValue.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(viewModel.transactionTypeColor(for: transaction.type))

                    Text(viewModel.formattedDate(transaction.date))
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.aeonSecondary)
                }
            }

            Spacer()

            Text(viewModel.formattedAmount(transaction.amount))
                .font(SpendlyFont.bodySemibold())
                .monospacedDigit()
                .foregroundStyle(
                    transaction.amount < 0
                        ? SpendlyColors.success
                        : SpendlyColors.aeonPrimary
                )
        }
        .padding(SpendlySpacing.lg)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
    }
}

// MARK: - Manage Modules Sheet

private extension SubscriptionPortalRootView {

    var manageModulesSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpendlySpacing.lg) {
                    // Summary
                    HStack {
                        Text("Monthly Total")
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.aeonSecondary)

                        Spacer()

                        Text(String(format: "$%.2f", viewModel.modulesTotal))
                            .font(.system(size: 20, weight: .heavy))
                            .monospacedDigit()
                            .foregroundStyle(SpendlyColors.aeonPrimary)
                    }
                    .padding(SpendlySpacing.lg)
                    .background(SpendlyColors.aeonAccent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                    SPDivider()

                    // Module toggles
                    ForEach(viewModel.billingModules) { module in
                        HStack(spacing: SpendlySpacing.md) {
                            Image(systemName: module.icon)
                                .font(.system(size: 16))
                                .foregroundStyle(
                                    module.isActive
                                        ? Color(hex: "#1d9385")
                                        : SpendlyColors.aeonSecondary
                                )
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(module.name)
                                    .font(SpendlyFont.bodyMedium())
                                    .foregroundStyle(SpendlyColors.aeonPrimary)

                                Text(String(format: "$%.2f/mo", module.monthlyCost))
                                    .font(SpendlyFont.caption())
                                    .monospacedDigit()
                                    .foregroundStyle(SpendlyColors.aeonSecondary)
                            }

                            Spacer()

                            Toggle("", isOn: Binding(
                                get: { module.isActive },
                                set: { _ in viewModel.toggleModule(module) }
                            ))
                            .labelsHidden()
                            .tint(SpendlyColors.aeonAccent)
                        }
                        .padding(SpendlySpacing.md)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }
                }
                .padding(SpendlySpacing.lg)
            }
            .background(SpendlyColors.aeonBackground)
            .navigationTitle("Manage Modules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.showManageModules = false
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(SpendlyColors.aeonPrimary)
                }
            }
        }
    }
}

// MARK: - Update Billing Sheet

private extension SubscriptionPortalRootView {

    var updateBillingSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpendlySpacing.xxl) {
                    // Current Payment Method
                    if let method = viewModel.paymentMethod {
                        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                            Text("Current Payment Method")
                                .font(SpendlyFont.financialHeadline())
                                .foregroundStyle(SpendlyColors.aeonPrimary)

                            HStack(spacing: SpendlySpacing.lg) {
                                Image(systemName: "creditcard.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(SpendlyColors.aeonSecondary)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(method.cardBrand) \(method.maskedDisplay)")
                                        .font(SpendlyFont.bodySemibold())
                                        .foregroundStyle(SpendlyColors.aeonPrimary)

                                    Text("Expires \(method.expiryDisplay)")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.aeonSecondary)
                                }

                                Spacer()

                                if method.isDefault {
                                    Text("DEFAULT")
                                        .font(.system(size: 9, weight: .bold))
                                        .tracking(0.5)
                                        .foregroundStyle(Color(hex: "#1d9385"))
                                        .padding(.horizontal, SpendlySpacing.sm)
                                        .padding(.vertical, SpendlySpacing.xs)
                                        .background(Color(hex: "#1d9385").opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(SpendlySpacing.lg)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        }
                    }

                    // Billing Contact
                    if let contact = viewModel.billingContact {
                        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                            Text("Billing Contact")
                                .font(SpendlyFont.financialHeadline())
                                .foregroundStyle(SpendlyColors.aeonPrimary)

                            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                                detailRow(label: "Name", value: contact.name)
                                SPDivider()
                                detailRow(label: "Email", value: contact.email)
                                SPDivider()
                                detailRow(label: "Phone", value: contact.phone)
                            }
                            .padding(SpendlySpacing.lg)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        }
                    }

                    // Placeholder save button
                    Button {} label: {
                        Text("Save Changes")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpendlySpacing.md)
                            .background(SpendlyColors.aeonSurface)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }
                }
                .padding(SpendlySpacing.lg)
            }
            .background(SpendlyColors.aeonBackground)
            .navigationTitle("Update Billing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.showUpdateBilling = false
                    }
                    .foregroundStyle(SpendlyColors.aeonPrimary)
                }
            }
        }
    }

    func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.aeonSecondary)
                .frame(width: 60, alignment: .leading)

            Text(value)
                .font(SpendlyFont.bodyMedium())
                .foregroundStyle(SpendlyColors.aeonPrimary)
        }
    }
}

// MARK: - Customize Plan Sheet

private extension SubscriptionPortalRootView {

    var customizePlanSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpendlySpacing.xxl) {
                    // Current plan summary
                    VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                        Text("Current Plan")
                            .font(SpendlyFont.financialHeadline())
                            .foregroundStyle(SpendlyColors.aeonPrimary)

                        HStack {
                            Text(viewModel.currentPlanName)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.aeonPrimary)

                            Spacer()

                            Text(viewModel.formattedMonthlyTotal + "/mo")
                                .font(.system(size: 20, weight: .heavy))
                                .monospacedDigit()
                                .foregroundStyle(SpendlyColors.aeonPrimary)
                        }
                        .padding(SpendlySpacing.lg)
                        .background(SpendlyColors.aeonAccent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }

                    // Available plans to switch to
                    VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                        Text("Switch Plan")
                            .font(SpendlyFont.financialHeadline())
                            .foregroundStyle(SpendlyColors.aeonPrimary)

                        ForEach(viewModel.availablePlans) { plan in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(plan.name)
                                        .font(SpendlyFont.bodySemibold())
                                        .foregroundStyle(SpendlyColors.aeonPrimary)

                                    Text("\(plan.maxTechnicians) technicians \u{00B7} \(plan.storageGB) GB storage")
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.aeonSecondary)
                                }

                                Spacer()

                                Text(viewModel.planPrice(plan) + "/mo")
                                    .font(SpendlyFont.bodySemibold())
                                    .monospacedDigit()
                                    .foregroundStyle(SpendlyColors.aeonPrimary)
                            }
                            .padding(SpendlySpacing.lg)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                    .strokeBorder(SpendlyColors.aeonSecondary.opacity(0.15), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(SpendlySpacing.lg)
            }
            .background(SpendlyColors.aeonBackground)
            .navigationTitle("Customize Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.showCustomizePlan = false
                    }
                    .foregroundStyle(SpendlyColors.aeonPrimary)
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Light") {
    NavigationStack {
        SubscriptionPortalRootView()
    }
    .environment(\.colorScheme, .light)
}

#Preview("Dark") {
    NavigationStack {
        SubscriptionPortalRootView()
    }
    .environment(\.colorScheme, .dark)
}
