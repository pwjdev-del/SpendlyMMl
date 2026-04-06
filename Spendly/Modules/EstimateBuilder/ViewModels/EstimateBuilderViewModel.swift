import SwiftUI
import SpendlyCore

// MARK: - EstimateBuilderViewModel

@Observable
final class EstimateBuilderViewModel {

    // MARK: - Persistence

    private static let storageKey = "estimates"
    private let storage = LocalStorageService.shared

    // MARK: - Data

    var estimates: [EstimateDisplayModel] = EstimateBuilderMockData.estimates
    var customers: [CustomerOption] = EstimateBuilderMockData.customers
    var taskTemplates: [TaskTemplate] = EstimateBuilderMockData.taskTemplates

    // MARK: - Init

    init() {
        loadPersistedData()
    }

    private func loadPersistedData() {
        if let saved: [EstimateDisplayModel] = storage.load(forKey: Self.storageKey) {
            let mockIDs = Set(EstimateBuilderMockData.estimates.map(\.id))
            let userCreated = saved.filter { !mockIDs.contains($0.id) }
            var merged = EstimateBuilderMockData.estimates
            for (index, mockItem) in merged.enumerated() {
                if let savedVersion = saved.first(where: { $0.id == mockItem.id }) {
                    merged[index] = savedVersion
                }
            }
            estimates = userCreated + merged
        }
    }

    private func persistEstimates() {
        storage.save(estimates, forKey: Self.storageKey)
    }

    // MARK: - List Search & Filter State

    var searchText: String = ""
    var showFilterModal: Bool = false

    var filterSections: [SPFilterSection] = [
        SPFilterSection(
            title: "Estimate Status",
            type: .checkbox,
            options: [
                SPFilterOption(label: "Draft"),
                SPFilterOption(label: "Sent"),
                SPFilterOption(label: "Approved"),
                SPFilterOption(label: "Rejected"),
                SPFilterOption(label: "Expired")
            ]
        ),
        SPFilterSection(
            title: "Total Amount Range",
            type: .radio,
            options: [
                SPFilterOption(label: "Under $500"),
                SPFilterOption(label: "$500 - $2,000"),
                SPFilterOption(label: "Over $2,000")
            ]
        ),
        SPFilterSection(
            title: "Project Type",
            type: .checkbox,
            options: [
                SPFilterOption(label: "Installation"),
                SPFilterOption(label: "Maintenance"),
                SPFilterOption(label: "Emergency Repair")
            ]
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
            title: "Technician",
            type: .checkbox,
            options: [
                SPFilterOption(label: "Amit Shah"),
                SPFilterOption(label: "Priya Nair"),
                SPFilterOption(label: "Vikram Desai")
            ]
        ),
        SPFilterSection(
            title: "Creation Date",
            type: .dateRange,
            options: []
        ),
        SPFilterSection(
            title: "Budget Range",
            type: .range(min: 0, max: 10000),
            options: []
        ),
        SPFilterSection(
            title: "Payment Status",
            type: .checkbox,
            options: [
                SPFilterOption(label: "Unpaid"),
                SPFilterOption(label: "Partial"),
                SPFilterOption(label: "Paid")
            ]
        ),
        SPFilterSection(
            title: "Project Status",
            type: .checkbox,
            options: [
                SPFilterOption(label: "Not Started"),
                SPFilterOption(label: "In Progress"),
                SPFilterOption(label: "Completed")
            ]
        ),
        SPFilterSection(
            title: "Material Costs",
            type: .radio,
            options: [
                SPFilterOption(label: "Under $200"),
                SPFilterOption(label: "$200 - $1,000"),
                SPFilterOption(label: "Over $1,000")
            ]
        ),
        SPFilterSection(
            title: "Time Options",
            type: .radio,
            options: [
                SPFilterOption(label: "Last 7 days"),
                SPFilterOption(label: "Last 30 days"),
                SPFilterOption(label: "Last 90 days"),
                SPFilterOption(label: "Over 90 days")
            ]
        )
    ]

    // MARK: - Navigation

    var showEditor: Bool = false
    var showCreateNew: Bool = false
    var selectedEstimate: EstimateDisplayModel?

    // MARK: - Filter Date/Range State (for dateRange and range filter types)

    var filterDateFrom: Date = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date() {
        didSet { isCreationDateFilterActive = true }
    }
    var filterDateTo: Date = Date() {
        didSet { isCreationDateFilterActive = true }
    }
    var filterBudgetMax: Double = 10000 {
        didSet { isBudgetRangeFilterActive = (filterBudgetMax < 10000) }
    }
    var isCreationDateFilterActive: Bool = false
    var isBudgetRangeFilterActive: Bool = false

    // MARK: - Saved Templates

    var savedTemplates: [EstimateDisplayModel] = []

    // MARK: - Editor State

    var editorSelectedCustomerID: UUID?
    var editorTasks: [EstimateTaskItem] = []
    var editorTaxRate: Double = 0.08
    var editorDiscountPercent: Double = 0.0
    var editorExpiresAt: Date = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
    var showTaskTemplatePicker: Bool = false
    var isGenerating: Bool = false

    // MARK: - Computed: Filtered List

    var filteredEstimates: [EstimateDisplayModel] {
        var results = estimates

        // Text search
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            results = results.filter {
                $0.customerName.lowercased().contains(query)
                || $0.estimateNumber.lowercased().contains(query)
                || $0.customerAddress.lowercased().contains(query)
                || $0.technicianName.lowercased().contains(query)
            }
        }

        // Estimate Status filter
        let selectedStatuses = activeOptions(for: "Estimate Status")
        if !selectedStatuses.isEmpty {
            results = results.filter { selectedStatuses.contains($0.statusLabel) }
        }

        // Project Type filter
        let selectedProjectTypes = activeOptions(for: "Project Type")
        if !selectedProjectTypes.isEmpty {
            results = results.filter { selectedProjectTypes.contains($0.projectType) }
        }

        // Region filter
        let selectedRegions = activeOptions(for: "Region")
        if !selectedRegions.isEmpty {
            results = results.filter { selectedRegions.contains($0.region) }
        }

        // Technician filter
        let selectedTechs = activeOptions(for: "Technician")
        if !selectedTechs.isEmpty {
            results = results.filter { selectedTechs.contains($0.technicianName) }
        }

        // Total Amount Range filter
        let selectedAmounts = activeOptions(for: "Total Amount Range")
        if !selectedAmounts.isEmpty {
            results = results.filter { estimate in
                for range in selectedAmounts {
                    switch range {
                    case "Under $500":
                        if estimate.grandTotal < 500 { return true }
                    case "$500 - $2,000":
                        if estimate.grandTotal >= 500 && estimate.grandTotal <= 2000 { return true }
                    case "Over $2,000":
                        if estimate.grandTotal > 2000 { return true }
                    default:
                        break
                    }
                }
                return false
            }
        }

        // Creation Date filter (dateRange type — only active after user changes dates)
        if isCreationDateFilterActive {
            results = results.filter { estimate in
                estimate.createdAt >= filterDateFrom && estimate.createdAt <= filterDateTo
            }
        }

        // Budget Range filter (range type — only active after user lowers the max)
        if isBudgetRangeFilterActive {
            results = results.filter { estimate in
                estimate.grandTotal <= filterBudgetMax
            }
        }

        // Payment Status filter
        let selectedPayments = activeOptions(for: "Payment Status")
        if !selectedPayments.isEmpty {
            results = results.filter { selectedPayments.contains($0.paymentStatus) }
        }

        // Project Status filter
        let selectedProjectStatuses = activeOptions(for: "Project Status")
        if !selectedProjectStatuses.isEmpty {
            results = results.filter { selectedProjectStatuses.contains($0.projectStatus) }
        }

        // Material Costs filter
        let selectedMaterialCosts = activeOptions(for: "Material Costs")
        if !selectedMaterialCosts.isEmpty {
            results = results.filter { estimate in
                for range in selectedMaterialCosts {
                    switch range {
                    case "Under $200":
                        if estimate.materialCost < 200 { return true }
                    case "$200 - $1,000":
                        if estimate.materialCost >= 200 && estimate.materialCost <= 1000 { return true }
                    case "Over $1,000":
                        if estimate.materialCost > 1000 { return true }
                    default:
                        break
                    }
                }
                return false
            }
        }

        // Time Options filter
        let selectedTimeOptions = activeOptions(for: "Time Options")
        if !selectedTimeOptions.isEmpty {
            let now = Date()
            results = results.filter { estimate in
                let daysSinceCreation = Calendar.current.dateComponents([.day], from: estimate.createdAt, to: now).day ?? 0
                for option in selectedTimeOptions {
                    switch option {
                    case "Last 7 days":
                        if daysSinceCreation <= 7 { return true }
                    case "Last 30 days":
                        if daysSinceCreation <= 30 { return true }
                    case "Last 90 days":
                        if daysSinceCreation <= 90 { return true }
                    case "Over 90 days":
                        if daysSinceCreation > 90 { return true }
                    default:
                        break
                    }
                }
                return false
            }
        }

        return results
    }

    // MARK: - Stats

    var totalEstimates: Int { estimates.count }

    var draftCount: Int {
        estimates.filter { $0.status == .draft }.count
    }

    var approvedCount: Int {
        estimates.filter { $0.status == .approved }.count
    }

    var totalValue: Double {
        estimates.reduce(0) { $0 + $1.grandTotal }
    }

    var activeFilterCount: Int {
        var count = filterSections.reduce(0) { total, section in
            total + section.options.filter(\.isSelected).count
        }
        if isCreationDateFilterActive { count += 1 }
        if isBudgetRangeFilterActive { count += 1 }
        return count
    }

    // MARK: - Editor Computed

    var editorSubtotal: Double {
        editorTasks.reduce(0) { $0 + $1.lineTotal }
    }

    var editorTaxAmount: Double {
        editorSubtotal * editorTaxRate
    }

    var editorDiscountAmount: Double {
        editorSubtotal * editorDiscountPercent
    }

    var editorGrandTotal: Double {
        editorSubtotal + editorTaxAmount - editorDiscountAmount
    }

    var selectedCustomerName: String {
        guard let id = editorSelectedCustomerID,
              let customer = customers.first(where: { $0.id == id }) else {
            return ""
        }
        return customer.displayLabel
    }

    // MARK: - List Actions

    func selectEstimate(_ estimate: EstimateDisplayModel) {
        selectedEstimate = estimate
        // Populate editor state from existing estimate
        editorTasks = estimate.tasks
        editorTaxRate = estimate.taxRate
        editorDiscountPercent = estimate.discountPercent
        editorExpiresAt = estimate.expiresAt
        editorSelectedCustomerID = customers.first(where: { $0.name == estimate.customerName })?.id
        showEditor = true
    }

    func startNewEstimate() {
        selectedEstimate = nil
        editorTasks = []
        editorTaxRate = 0.08
        editorDiscountPercent = 0.0
        editorExpiresAt = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        editorSelectedCustomerID = nil
        showCreateNew = true
    }

    // MARK: - Editor Actions

    func addTaskFromTemplate(_ template: TaskTemplate) {
        let task = EstimateTaskItem(
            id: UUID(),
            name: template.name,
            description: template.description,
            imageName: template.imageName,
            estimatedHours: template.defaultHours,
            hourlyRate: template.defaultRate
        )
        editorTasks.append(task)
    }

    func deleteTask(at offsets: IndexSet) {
        editorTasks.remove(atOffsets: offsets)
    }

    func deleteTask(_ task: EstimateTaskItem) {
        editorTasks.removeAll { $0.id == task.id }
    }

    func generateEstimate() {
        isGenerating = true
        // Simulate async generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            let customer = self.customers.first(where: { $0.id == self.editorSelectedCustomerID })

            if let existing = self.selectedEstimate,
               let index = self.estimates.firstIndex(where: { $0.id == existing.id }) {
                // BUG 1 FIX: Update the existing estimate in place
                self.estimates[index].customerName = customer?.name ?? existing.customerName
                self.estimates[index].customerAddress = customer?.address ?? existing.customerAddress
                self.estimates[index].tasks = self.editorTasks
                self.estimates[index].taxRate = self.editorTaxRate
                self.estimates[index].discountPercent = self.editorDiscountPercent
                self.estimates[index].expiresAt = self.editorExpiresAt
            } else {
                // Create a brand-new estimate
                let newEstimate = EstimateDisplayModel(
                    id: UUID(),
                    estimateNumber: "EST-2026-\(String(format: "%03d", self.estimates.count + 1))",
                    customerName: customer?.name ?? "Unknown",
                    customerAddress: customer?.address ?? "",
                    status: .draft,
                    tasks: self.editorTasks,
                    taxRate: self.editorTaxRate,
                    discountPercent: self.editorDiscountPercent,
                    createdAt: Date(),
                    expiresAt: self.editorExpiresAt,
                    region: "North",
                    projectType: "Installation",
                    technicianName: "Unassigned",
                    paymentStatus: "Unpaid",
                    projectStatus: "Not Started",
                    materialCost: 0
                )
                self.estimates.insert(newEstimate, at: 0)
            }

            self.persistEstimates()
            self.isGenerating = false
            self.showCreateNew = false
            self.showEditor = false
        }
    }

    // MARK: - Save as Draft (BUG 3 FIX)

    func saveAsDraft() {
        let customer = customers.first(where: { $0.id == editorSelectedCustomerID })

        if let existing = selectedEstimate,
           let index = estimates.firstIndex(where: { $0.id == existing.id }) {
            // Update existing estimate as draft
            estimates[index].status = .draft
            estimates[index].customerName = customer?.name ?? existing.customerName
            estimates[index].customerAddress = customer?.address ?? existing.customerAddress
            estimates[index].tasks = editorTasks
            estimates[index].taxRate = editorTaxRate
            estimates[index].discountPercent = editorDiscountPercent
            estimates[index].expiresAt = editorExpiresAt
        } else {
            // Create new draft estimate
            let draft = EstimateDisplayModel(
                id: UUID(),
                estimateNumber: "EST-2026-\(String(format: "%03d", estimates.count + 1))",
                customerName: customer?.name ?? "Unknown",
                customerAddress: customer?.address ?? "",
                status: .draft,
                tasks: editorTasks,
                taxRate: editorTaxRate,
                discountPercent: editorDiscountPercent,
                createdAt: Date(),
                expiresAt: editorExpiresAt,
                region: "North",
                projectType: "Installation",
                technicianName: "Unassigned",
                paymentStatus: "Unpaid",
                projectStatus: "Not Started",
                materialCost: 0
            )
            estimates.insert(draft, at: 0)
        }

        persistEstimates()
        showCreateNew = false
        showEditor = false
    }

    // MARK: - Save as Template (BUG 3 FIX)

    func saveAsTemplate() {
        let customer = customers.first(where: { $0.id == editorSelectedCustomerID })
        let template = EstimateDisplayModel(
            id: UUID(),
            estimateNumber: "TMPL-\(String(format: "%03d", savedTemplates.count + 1))",
            customerName: customer?.name ?? "Template",
            customerAddress: customer?.address ?? "",
            status: .draft,
            tasks: editorTasks,
            taxRate: editorTaxRate,
            discountPercent: editorDiscountPercent,
            createdAt: Date(),
            expiresAt: editorExpiresAt,
            region: "North",
            projectType: "Installation",
            technicianName: "Unassigned",
            paymentStatus: "Unpaid",
            projectStatus: "Not Started",
            materialCost: 0
        )
        savedTemplates.append(template)
        showCreateNew = false
        showEditor = false
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
