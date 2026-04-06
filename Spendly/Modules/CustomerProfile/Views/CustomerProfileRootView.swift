import SwiftUI
import SpendlyCore

// MARK: - CustomerProfileRootView

public struct CustomerProfileRootView: View {

    @State private var viewModel = CustomerProfileViewModel()
    @State private var showAddCustomerSheet = false
    @State private var newCustomerName = ""
    @State private var newCustomerEmail = ""
    @State private var newCustomerCompany = ""
    @State private var newCustomerPhone = ""
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        ZStack {
            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.lg) {
                    // MARK: Header
                    headerSection

                    // MARK: Stats Row
                    statsRow

                    // MARK: Search Bar with Filter
                    SPSearchBar(
                        searchText: $viewModel.searchText,
                        showFilterButton: true,
                        onFilterTap: {
                            withAnimation {
                                viewModel.showFilterModal = true
                            }
                        }
                    )

                    // MARK: Active Filters Badge
                    if viewModel.activeFilterCount > 0 {
                        activeFiltersIndicator
                    }

                    // MARK: Customer List
                    if viewModel.filteredCustomers.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: SpendlySpacing.md) {
                            ForEach(viewModel.filteredCustomers) { customer in
                                CustomerCardView(customer: customer) {
                                    viewModel.selectCustomer(customer)
                                }
                            }
                        }
                    }
                }
            }

            // MARK: Filter Modal Overlay
            SPFilterModal(
                isPresented: $viewModel.showFilterModal,
                sections: $viewModel.filterSections
            )
        }
        .sheet(isPresented: $showAddCustomerSheet) {
            NavigationStack {
                Form {
                    Section("Customer Information") {
                        TextField("Name", text: $newCustomerName)
                        TextField("Email", text: $newCustomerEmail)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                        TextField("Company", text: $newCustomerCompany)
                        TextField("Phone", text: $newCustomerPhone)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationTitle("Add Customer")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showAddCustomerSheet = false
                            newCustomerName = ""
                            newCustomerEmail = ""
                            newCustomerCompany = ""
                            newCustomerPhone = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            viewModel.addCustomer(
                                name: newCustomerName,
                                email: newCustomerEmail,
                                company: newCustomerCompany,
                                phone: newCustomerPhone
                            )
                            showAddCustomerSheet = false
                            newCustomerName = ""
                            newCustomerEmail = ""
                            newCustomerCompany = ""
                            newCustomerPhone = ""
                        }
                        .disabled(newCustomerName.isEmpty)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.showDetail) {
            if let customer = viewModel.selectedCustomer {
                CustomerDetailView(customer: customer)
            } else {
                ContentUnavailableView("Customer Not Found", systemImage: "person.crop.circle.badge.questionmark", description: Text("This customer profile is no longer available."))
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text("Customers")
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text("Manage your client portfolio")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }

            Spacer()

            Button {
                showAddCustomerSheet = true
            } label: {
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: SpendlyIcon.add.systemName)
                        .font(.system(size: 12, weight: .bold))
                    Text("Add")
                        .font(SpendlyFont.bodySemibold())
                }
                .foregroundStyle(.white)
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.sm)
                .background(SpendlyColors.accent)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            }
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: SpendlySpacing.md) {
            statCard(
                icon: "person.2.fill",
                label: "Total",
                value: "\(viewModel.totalCustomers)"
            )
            statCard(
                icon: "star.fill",
                label: "Premium",
                value: "\(viewModel.premiumCount)"
            )
            statCard(
                icon: "exclamationmark.triangle.fill",
                label: "Overdue",
                value: "\(viewModel.overdueCount)",
                valueColor: viewModel.overdueCount > 0 ? SpendlyColors.error : nil
            )
        }
    }

    private func statCard(
        icon: String,
        label: String,
        value: String,
        valueColor: Color? = nil
    ) -> some View {
        SPCard(elevation: .low, padding: SpendlySpacing.md) {
            VStack(spacing: SpendlySpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(SpendlyColors.accent)

                Text(value)
                    .font(SpendlyFont.headline())
                    .foregroundStyle(valueColor ?? SpendlyColors.foreground(for: colorScheme))

                Text(label)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Active Filters Indicator

    private var activeFiltersIndicator: some View {
        HStack(spacing: SpendlySpacing.sm) {
            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(SpendlyColors.accent)

            Text("\(viewModel.activeFilterCount) filter\(viewModel.activeFilterCount == 1 ? "" : "s") applied")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.accent)

            Spacer()

            Button {
                // Clear all filters by resetting selections
                for sectionIndex in viewModel.filterSections.indices {
                    for optionIndex in viewModel.filterSections[sectionIndex].options.indices {
                        viewModel.filterSections[sectionIndex].options[optionIndex].isSelected = false
                    }
                }
            } label: {
                Text("Clear")
                    .font(SpendlyFont.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(SpendlyColors.error)
            }
        }
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.vertical, SpendlySpacing.sm)
        .background(SpendlyColors.accent.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: SpendlySpacing.lg) {
            Image(systemName: "person.crop.rectangle.badge.xmark")
                .font(.system(size: 48))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))

            Text("No customers found")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.secondary)

            Text("Try adjusting your search or filters.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary.opacity(0.7))
                .multilineTextAlignment(.center)

            SPButton("Add Customer", icon: SpendlyIcon.add.systemName, style: .primary) {
                showAddCustomerSheet = true
            }
            .frame(maxWidth: 200)
        }
        .padding(.vertical, SpendlySpacing.xxxl)
    }
}

// MARK: - Customer Card View

private struct CustomerCardView: View {
    let customer: CustomerDisplayModel
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTap) {
            SPCard(elevation: .medium, padding: 0) {
                VStack(spacing: 0) {
                    // Top accent bar for premium clients
                    if customer.isPremium {
                        Rectangle()
                            .fill(SpendlyColors.accent)
                            .frame(height: 3)
                    }

                    VStack(spacing: SpendlySpacing.md) {
                        // Top row: avatar + info + badge
                        HStack(alignment: .top, spacing: SpendlySpacing.md) {
                            SPAvatar(
                                imageURL: customer.avatarURL,
                                initials: customer.initials,
                                size: .lg,
                                statusDot: customer.paymentStatus == .overdue
                                    ? SpendlyColors.error
                                    : SpendlyColors.success
                            )

                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text(customer.name)
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                    .lineLimit(1)

                                Text(customer.companyName)
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                                    .lineLimit(1)

                                Text(customer.contactTitle)
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.7))
                                    .lineLimit(1)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: SpendlySpacing.xs) {
                                if customer.isPremium {
                                    premiumBadge
                                }
                                SPBadge(
                                    customer.paymentStatus.rawValue,
                                    style: customer.paymentStatus.badgeStyle
                                )
                            }
                        }

                        SPDivider()

                        // Quick Stats Row
                        HStack(spacing: SpendlySpacing.md) {
                            quickStatChip(
                                icon: "gearshape.2",
                                text: "\(customer.machines.count) Machine\(customer.machines.count == 1 ? "" : "s")"
                            )
                            quickStatChip(
                                icon: "wrench.and.screwdriver",
                                text: "\(customer.totalJobsCompleted) Jobs"
                            )
                            quickStatChip(
                                icon: "mappin",
                                text: customer.region
                            )
                        }

                        SPDivider()

                        // Bottom row: balance + chevron
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Balance")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)

                                Text(formatCurrency(customer.accountBalance))
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(
                                        customer.accountBalance < 0
                                            ? SpendlyColors.error
                                            : SpendlyColors.foreground(for: colorScheme)
                                    )
                            }

                            Spacer()

                            Text(customer.contractType)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                                .padding(.horizontal, SpendlySpacing.sm)
                                .padding(.vertical, SpendlySpacing.xs)
                                .background(SpendlyColors.secondary.opacity(0.08))
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

    // MARK: - Premium Badge

    private var premiumBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: SpendlyIcon.verified.systemName)
                .font(.system(size: 10))
            Text("PREMIUM")
                .font(.system(size: 9, weight: .bold))
                .tracking(0.8)
        }
        .foregroundStyle(SpendlyColors.primary)
        .padding(.horizontal, SpendlySpacing.sm)
        .padding(.vertical, 3)
        .background(SpendlyColors.primary.opacity(0.08))
        .clipShape(Capsule())
    }

    // MARK: - Quick Stat Chip

    private func quickStatChip(icon: String, text: String) -> some View {
        HStack(spacing: SpendlySpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(SpendlyColors.accent)

            Text(text)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
        .padding(.horizontal, SpendlySpacing.sm)
        .padding(.vertical, SpendlySpacing.xs + 2)
        .background(SpendlyColors.accent.opacity(0.06))
        .clipShape(Capsule())
    }

    // MARK: - Currency Formatter

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()

    private func formatCurrency(_ value: Double) -> String {
        Self.currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Previews

#Preview("Customer List") {
    NavigationStack {
        CustomerProfileRootView()
    }
}

#Preview("Customer List - Dark") {
    NavigationStack {
        CustomerProfileRootView()
    }
    .preferredColorScheme(.dark)
}
