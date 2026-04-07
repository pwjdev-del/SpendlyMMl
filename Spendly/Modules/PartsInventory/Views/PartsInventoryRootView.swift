import SwiftUI
import SpendlyCore

struct PartsInventoryRootView: View {
    @State private var viewModel = PartsInventoryViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SPScreenWrapper {
            VStack(spacing: 0) {
                // KPI Cards
                kpiSection

                // Tab Selector
                tabSelector

                // Search Bar
                SPSearchBar(text: $viewModel.searchText, placeholder: "Search parts, orders...")
                    .padding(.horizontal, SpendlySpacing.md)
                    .padding(.bottom, SpendlySpacing.sm)

                // Content
                ScrollView {
                    LazyVStack(spacing: SpendlySpacing.sm) {
                        if viewModel.selectedTab == .inventory {
                            inventoryList
                        } else {
                            ordersList
                        }
                    }
                    .padding(.horizontal, SpendlySpacing.md)
                    .padding(.bottom, SpendlySpacing.xxl)
                }
            }
        }
        .navigationTitle("Parts & Inventory")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.showFilterModal = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .foregroundStyle(viewModel.activeFilterCount > 0 ? SpendlyColors.primary : SpendlyColors.secondaryForeground(for: colorScheme))
                }
            }
        }
        .sheet(isPresented: $viewModel.showFilterModal) {
            SPFilterModal(sections: $viewModel.filterSections, isPresented: $viewModel.showFilterModal)
        }
        .sheet(isPresented: $viewModel.showOrderForm) {
            orderFormSheet
        }
        .sheet(isPresented: $viewModel.showPartDetail) {
            partDetailSheet
        }
    }

    // MARK: - KPI Section

    private var kpiSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpendlySpacing.sm) {
                SPMetricCard(title: "Total Parts", value: "\(viewModel.totalPartsCount)", trend: nil, trendDirection: .flat)
                SPMetricCard(title: "Low/Out of Stock", value: "\(viewModel.lowStockCount)", trend: viewModel.lowStockCount > 0 ? "Action Needed" : "OK", trendDirection: viewModel.lowStockCount > 0 ? .down : .flat)
                SPMetricCard(title: "Stock Value", value: viewModel.totalStockValue, trend: nil, trendDirection: .flat)
                SPMetricCard(title: "Pending Orders", value: "\(viewModel.pendingOrdersCount)", trend: nil, trendDirection: .flat)
            }
            .padding(.horizontal, SpendlySpacing.md)
        }
        .padding(.vertical, SpendlySpacing.sm)
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: SpendlySpacing.sm) {
            ForEach(InventoryTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(SpendlyFont.bodySmall(weight: viewModel.selectedTab == tab ? .semibold : .regular))
                        .foregroundStyle(viewModel.selectedTab == tab ? .white : SpendlyColors.secondaryForeground(for: colorScheme))
                        .padding(.horizontal, SpendlySpacing.md)
                        .padding(.vertical, SpendlySpacing.xs)
                        .background(
                            viewModel.selectedTab == tab ? SpendlyColors.primary : SpendlyColors.secondaryBackground(for: colorScheme),
                            in: Capsule()
                        )
                }
            }
            Spacer()
        }
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.bottom, SpendlySpacing.sm)
    }

    // MARK: - Inventory List

    private var inventoryList: some View {
        Group {
            if viewModel.filteredParts.isEmpty {
                SPEmptyState(title: "No Parts Found", subtitle: "Try adjusting your search or filters.", icon: "shippingbox")
            } else {
                // Category quick-filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: SpendlySpacing.xs) {
                        ForEach(PartCategory.allCases, id: \.self) { category in
                            Button {
                                viewModel.setCategoryFilter(category)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 10))
                                    Text(category.rawValue)
                                        .font(SpendlyFont.caption(weight: .medium))
                                }
                                .padding(.horizontal, SpendlySpacing.sm)
                                .padding(.vertical, 6)
                                .background(
                                    viewModel.selectedCategoryFilter == category ? category.color.opacity(0.15) : SpendlyColors.secondaryBackground(for: colorScheme),
                                    in: Capsule()
                                )
                                .foregroundStyle(viewModel.selectedCategoryFilter == category ? category.color : SpendlyColors.secondaryForeground(for: colorScheme))
                            }
                        }
                    }
                }
                .padding(.bottom, SpendlySpacing.xs)

                ForEach(viewModel.filteredParts) { part in
                    partCard(part)
                }
            }
        }
    }

    private func partCard(_ part: DisplayPart) -> some View {
        SPCard {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(part.name)
                            .font(SpendlyFont.bodySmall(weight: .semibold))
                            .foregroundStyle(SpendlyColors.primaryForeground(for: colorScheme))
                        Text(part.partNumber)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }
                    Spacer()
                    SPBadge(text: part.stockStatus.rawValue, style: part.stockStatus.badgeStyle)
                }

                SPDivider()

                HStack {
                    Label("\(part.stockQuantity) units", systemImage: "shippingbox")
                    Spacer()
                    Label(part.formattedUnitCost, systemImage: "dollarsign.circle")
                    Spacer()
                    Label(part.supplierName, systemImage: "building.2")
                }
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                if part.stockStatus == .lowStock || part.stockStatus == .outOfStock {
                    HStack {
                        Spacer()
                        SPButton(title: "Order Now", style: .primary, size: .small) {
                            viewModel.startOrder(for: part)
                        }
                    }
                }
            }
        }
        .onTapGesture {
            viewModel.selectPart(part)
        }
    }

    // MARK: - Orders List

    private var ordersList: some View {
        Group {
            if viewModel.filteredOrders.isEmpty {
                SPEmptyState(title: "No Orders Found", subtitle: "Orders you place will appear here.", icon: "doc.text")
            } else {
                ForEach(viewModel.filteredOrders) { order in
                    SPCard {
                        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(order.orderNumber)
                                        .font(SpendlyFont.bodySmall(weight: .semibold))
                                        .foregroundStyle(SpendlyColors.primaryForeground(for: colorScheme))
                                    Text(order.partName)
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                                }
                                Spacer()
                                SPBadge(text: order.status.rawValue, style: order.status.badgeStyle)
                            }

                            SPDivider()

                            HStack {
                                Label("Qty: \(order.quantity)", systemImage: "number")
                                Spacer()
                                Label(String(format: "$%.2f", order.totalCost), systemImage: "dollarsign.circle")
                                Spacer()
                                if let eta = order.expectedDeliveryAt {
                                    Label(viewModel.formattedDate(eta), systemImage: "calendar")
                                }
                            }
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                            HStack {
                                Text("Ordered by \(order.orderedBy)")
                                Spacer()
                                Text(viewModel.relativeDate(order.orderedAt))
                            }
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme).opacity(0.7))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Order Form Sheet

    private var orderFormSheet: some View {
        NavigationStack {
            Form {
                if let part = viewModel.selectedPart {
                    Section("Part Details") {
                        LabeledContent("Part", value: part.name)
                        LabeledContent("Part #", value: part.partNumber)
                        LabeledContent("Supplier", value: part.supplierName)
                        LabeledContent("Unit Cost", value: part.formattedUnitCost)
                        LabeledContent("Lead Time", value: "\(part.leadTimeDays) days")
                    }

                    Section("Order") {
                        Stepper("Quantity: \(viewModel.orderQuantity)", value: $viewModel.orderQuantity, in: 1...999)
                        LabeledContent("Total Cost", value: String(format: "$%.2f", part.unitCost * Double(viewModel.orderQuantity)))
                        TextField("Notes (optional)", text: $viewModel.orderNotes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
            }
            .navigationTitle("New Order")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showOrderForm = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    SPButton(title: viewModel.isSubmittingOrder ? "Submitting..." : "Place Order", style: .primary, size: .small) {
                        viewModel.submitOrder()
                    }
                    .disabled(viewModel.isSubmittingOrder)
                }
            }
        }
    }

    // MARK: - Part Detail Sheet

    private var partDetailSheet: some View {
        NavigationStack {
            if let part = viewModel.selectedPart {
                ScrollView {
                    VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                        // Header
                        HStack {
                            Image(systemName: part.category.icon)
                                .font(.title2)
                                .foregroundStyle(part.category.color)
                                .frame(width: 44, height: 44)
                                .background(part.category.color.opacity(0.12), in: RoundedRectangle(cornerRadius: SpendlyCornerRadius.md))

                            VStack(alignment: .leading) {
                                Text(part.name)
                                    .font(SpendlyFont.headline())
                                Text(part.partNumber)
                                    .font(SpendlyFont.bodySmall())
                                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            }
                            Spacer()
                            SPBadge(text: part.stockStatus.rawValue, style: part.stockStatus.badgeStyle)
                        }

                        if let desc = part.description {
                            Text(desc)
                                .font(SpendlyFont.bodySmall())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        }

                        SPDivider()

                        // Details Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: SpendlySpacing.sm) {
                            detailCell(title: "Stock", value: "\(part.stockQuantity) units")
                            detailCell(title: "Min Stock", value: "\(part.minimumStock) units")
                            detailCell(title: "Unit Cost", value: part.formattedUnitCost)
                            detailCell(title: "Stock Value", value: String(format: "$%.2f", part.totalStockValue))
                            detailCell(title: "Supplier", value: part.supplierName)
                            detailCell(title: "Lead Time", value: "\(part.leadTimeDays) days")
                            if let location = part.warehouseLocation {
                                detailCell(title: "Location", value: location)
                            }
                            if let restocked = part.lastRestockedAt {
                                detailCell(title: "Last Restocked", value: viewModel.formattedDate(restocked))
                            }
                        }

                        if part.stockStatus == .lowStock || part.stockStatus == .outOfStock {
                            SPButton(title: "Place Order", style: .primary, size: .medium) {
                                viewModel.showPartDetail = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    viewModel.startOrder(for: part)
                                }
                            }
                        }
                    }
                    .padding(SpendlySpacing.md)
                }
                .navigationTitle("Part Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { viewModel.showPartDetail = false }
                    }
                }
            }
        }
    }

    private func detailCell(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            Text(value)
                .font(SpendlyFont.bodySmall(weight: .medium))
                .foregroundStyle(SpendlyColors.primaryForeground(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpendlySpacing.sm)
        .background(SpendlyColors.secondaryBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: SpendlyCornerRadius.sm))
    }
}

#Preview {
    NavigationStack {
        PartsInventoryRootView()
    }
}
