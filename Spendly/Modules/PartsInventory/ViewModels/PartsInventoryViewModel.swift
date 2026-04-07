import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Inventory Tab

enum InventoryTab: String, CaseIterable {
    case inventory = "Inventory"
    case orders    = "Orders"
}

// MARK: - ViewModel

@Observable
final class PartsInventoryViewModel {

    // MARK: - Persistence

    private static let storageKey = "partsInventory"
    private let storage = LocalStorageService.shared

    // MARK: Data

    var parts: [DisplayPart] = PartsInventoryMockData.parts
    var orders: [DisplayPartsOrder] = PartsInventoryMockData.orders

    // MARK: UI State

    var selectedTab: InventoryTab = .inventory
    var searchText: String = ""
    var selectedCategoryFilter: PartCategory? = nil
    var showFilterModal: Bool = false
    var showOrderForm: Bool = false
    var selectedPart: DisplayPart? = nil
    var showPartDetail: Bool = false

    // MARK: Order Form State

    var orderQuantity: Int = 1
    var orderNotes: String = ""
    var isSubmittingOrder: Bool = false
    var showOrderSuccess: Bool = false

    // MARK: Filter Sections

    var filterSections: [SPFilterSection] = [
        SPFilterSection(
            title: "Category",
            type: .checkbox,
            options: PartCategory.allCases.map { SPFilterOption(label: $0.rawValue) }
        ),
        SPFilterSection(
            title: "Stock Status",
            type: .checkbox,
            options: [
                SPFilterOption(label: StockStatus.inStock.rawValue),
                SPFilterOption(label: StockStatus.lowStock.rawValue),
                SPFilterOption(label: StockStatus.outOfStock.rawValue),
            ]
        ),
    ]

    // MARK: - Computed

    var filteredParts: [DisplayPart] {
        var result = parts

        if let category = selectedCategoryFilter {
            result = result.filter { $0.category == category }
        }

        // Category filter from modal
        let categorySection = filterSections.first(where: { $0.title == "Category" })
        let selectedCategories = categorySection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedCategories.isEmpty {
            result = result.filter { selectedCategories.contains($0.category.rawValue) }
        }

        // Stock status filter
        let stockSection = filterSections.first(where: { $0.title == "Stock Status" })
        let selectedStocks = stockSection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedStocks.isEmpty {
            result = result.filter { selectedStocks.contains($0.stockStatus.rawValue) }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.partNumber.lowercased().contains(query) ||
                ($0.description?.lowercased().contains(query) ?? false) ||
                $0.supplierName.lowercased().contains(query)
            }
        }

        return result
    }

    var filteredOrders: [DisplayPartsOrder] {
        var result = orders

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter {
                $0.partName.lowercased().contains(query) ||
                $0.orderNumber.lowercased().contains(query) ||
                $0.partNumber.lowercased().contains(query) ||
                $0.supplierName.lowercased().contains(query)
            }
        }

        return result.sorted { $0.orderedAt > $1.orderedAt }
    }

    var activeFilterCount: Int {
        filterSections.flatMap(\.options).filter(\.isSelected).count
    }

    // MARK: KPIs

    var totalPartsCount: Int { parts.count }

    var lowStockCount: Int {
        parts.filter { $0.stockStatus == .lowStock || $0.stockStatus == .outOfStock }.count
    }

    var totalStockValue: String {
        let value = parts.reduce(0.0) { $0 + $1.totalStockValue }
        if value >= 1000 {
            return String(format: "$%.1fk", value / 1000)
        }
        return String(format: "$%.0f", value)
    }

    var pendingOrdersCount: Int {
        orders.filter { $0.status == .pending || $0.status == .confirmed || $0.status == .shipped }.count
    }

    // MARK: - Actions

    func selectPart(_ part: DisplayPart) {
        selectedPart = part
        showPartDetail = true
    }

    func startOrder(for part: DisplayPart) {
        selectedPart = part
        orderQuantity = part.minimumStock * 2
        orderNotes = ""
        showOrderForm = true
    }

    func submitOrder() {
        guard let part = selectedPart else { return }
        isSubmittingOrder = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }

            let order = DisplayPartsOrder(
                orderNumber: "PO-2026-\(String(format: "%03d", self.orders.count + 42))",
                partName: part.name,
                partNumber: part.partNumber,
                quantity: self.orderQuantity,
                unitCost: part.unitCost,
                supplierName: part.supplierName,
                status: .pending,
                orderedAt: Date(),
                expectedDeliveryAt: Calendar.current.date(byAdding: .day, value: part.leadTimeDays, to: Date()),
                orderedBy: "Current User"
            )

            self.orders.insert(order, at: 0)
            self.isSubmittingOrder = false
            self.showOrderSuccess = true
            self.showOrderForm = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showOrderSuccess = false
            }
        }
    }

    func setCategoryFilter(_ category: PartCategory?) {
        if selectedCategoryFilter == category {
            selectedCategoryFilter = nil
        } else {
            selectedCategoryFilter = category
        }
    }

    // MARK: - Formatting

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
