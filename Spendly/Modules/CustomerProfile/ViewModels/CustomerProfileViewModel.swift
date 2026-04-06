import SwiftUI
import SpendlyCore

// MARK: - CustomerProfileViewModel

@Observable
final class CustomerProfileViewModel {

    // MARK: - Persistence

    private static let storageKey = "customers"
    private let storage = LocalStorageService.shared

    // MARK: - Data

    var customers: [CustomerDisplayModel] = CustomerProfileMockData.customers

    // MARK: - Init

    init() {
        loadPersistedData()
    }

    private func loadPersistedData() {
        if let saved: [CustomerDisplayModel] = storage.load(forKey: Self.storageKey) {
            let mockIDs = Set(CustomerProfileMockData.customers.map(\.id))
            let userCreated = saved.filter { !mockIDs.contains($0.id) }
            var merged = CustomerProfileMockData.customers
            for (index, mockItem) in merged.enumerated() {
                if let savedVersion = saved.first(where: { $0.id == mockItem.id }) {
                    merged[index] = savedVersion
                }
            }
            customers = userCreated + merged
        }
    }

    private func persistCustomers() {
        storage.save(customers, forKey: Self.storageKey)
    }

    // MARK: - Search & Filter State

    var searchText: String = ""
    var showFilterModal: Bool = false

    var filterSections: [SPFilterSection] = [
        SPFilterSection(
            title: "Payment Status",
            type: .checkbox,
            options: PaymentStatusType.allCases.map { SPFilterOption(label: $0.rawValue) }
        ),
        SPFilterSection(
            title: "Region",
            type: .checkbox,
            options: [
                SPFilterOption(label: "North"),
                SPFilterOption(label: "South"),
                SPFilterOption(label: "East"),
                SPFilterOption(label: "West")
            ]
        ),
        SPFilterSection(
            title: "Contract Type",
            type: .checkbox,
            options: ContractType.allCases.map { SPFilterOption(label: $0.rawValue) }
        ),
        SPFilterSection(
            title: "Account Balance",
            type: .range(min: -10000, max: 100000),
            options: []
        ),
        SPFilterSection(
            title: "Creation Date",
            type: .dateRange,
            options: []
        ),
        SPFilterSection(
            title: "Last Activity",
            type: .radio,
            options: [
                SPFilterOption(label: "Last 7 days"),
                SPFilterOption(label: "Last 30 days"),
                SPFilterOption(label: "Last 90 days"),
                SPFilterOption(label: "Over 90 days")
            ]
        ),
        SPFilterSection(
            title: "Client Tier",
            type: .checkbox,
            options: [
                SPFilterOption(label: "Premium"),
                SPFilterOption(label: "Standard")
            ]
        )
    ]

    // MARK: - Navigation

    var selectedCustomer: CustomerDisplayModel?
    var showDetail: Bool = false

    // MARK: - Filtered List

    var filteredCustomers: [CustomerDisplayModel] {
        var results = customers

        // Text search
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            results = results.filter {
                $0.name.lowercased().contains(query)
                || $0.companyName.lowercased().contains(query)
                || $0.email.lowercased().contains(query)
                || $0.city.lowercased().contains(query)
            }
        }

        // Payment status filter
        let selectedPaymentStatuses = activeOptions(for: "Payment Status")
        if !selectedPaymentStatuses.isEmpty {
            results = results.filter { selectedPaymentStatuses.contains($0.paymentStatus.rawValue) }
        }

        // Region filter
        let selectedRegions = activeOptions(for: "Region")
        if !selectedRegions.isEmpty {
            results = results.filter { selectedRegions.contains($0.region) }
        }

        // Contract type filter
        let selectedContracts = activeOptions(for: "Contract Type")
        if !selectedContracts.isEmpty {
            results = results.filter { selectedContracts.contains($0.contractType) }
        }

        // Client tier filter
        let selectedTiers = activeOptions(for: "Client Tier")
        if !selectedTiers.isEmpty {
            results = results.filter { customer in
                if selectedTiers.contains("Premium") && customer.isPremium { return true }
                if selectedTiers.contains("Standard") && !customer.isPremium { return true }
                return false
            }
        }

        return results
    }

    // MARK: - Stats

    var totalCustomers: Int { customers.count }

    var premiumCount: Int { customers.filter(\.isPremium).count }

    var overdueCount: Int { customers.filter { $0.paymentStatus == .overdue }.count }

    var activeFilterCount: Int {
        filterSections.reduce(0) { total, section in
            total + section.options.filter(\.isSelected).count
        }
    }

    // MARK: - Actions

    func selectCustomer(_ customer: CustomerDisplayModel) {
        selectedCustomer = customer
        showDetail = true
    }

    func addCustomer(name: String, email: String, company: String, phone: String) {
        let newCustomer = CustomerDisplayModel(
            id: UUID(),
            name: name,
            companyName: company,
            contactTitle: "",
            email: email,
            phone: phone,
            address: "",
            city: "",
            state: "",
            postalCode: "",
            avatarURL: nil,
            isPremium: false,
            accountBalance: 0,
            budgetAllocated: 0,
            region: "North",
            contractType: "Standard",
            paymentStatus: .current,
            lastActivityDate: Date(),
            createdAt: Date(),
            notes: [],
            machines: [],
            jobHistory: []
        )
        customers.insert(newCustomer, at: 0)
        persistCustomers()
    }

    // MARK: - Helpers

    private func activeOptions(for sectionTitle: String) -> Set<String> {
        guard let section = filterSections.first(where: { $0.title == sectionTitle }) else {
            return []
        }
        let selected = section.options.filter(\.isSelected).map(\.label)
        return Set(selected)
    }
}
