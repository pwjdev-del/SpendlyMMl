import SwiftUI
import SpendlyCore

// MARK: - EstimateBuilderViewModel

@Observable
final class EstimateBuilderViewModel {

    // MARK: - Data

    var estimates: [EstimateDisplayModel] = EstimateBuilderMockData.estimates
    var customers: [CustomerOption] = EstimateBuilderMockData.customers
    var taskTemplates: [TaskTemplate] = EstimateBuilderMockData.taskTemplates

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

    // MARK: - Editor State

    var editorSelectedCustomerID: UUID?
    var editorTasks: [EstimateTaskItem] = []
    var editorTaxRate: Double = 0.08
    var editorDiscountPercent: Double = 0.0
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
        filterSections.reduce(0) { total, section in
            total + section.options.filter(\.isSelected).count
        }
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
        editorSelectedCustomerID = customers.first(where: { $0.name == estimate.customerName })?.id
        showEditor = true
    }

    func startNewEstimate() {
        selectedEstimate = nil
        editorTasks = []
        editorTaxRate = 0.08
        editorDiscountPercent = 0.0
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
                expiresAt: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
                region: "North",
                projectType: "Installation",
                technicianName: "Unassigned"
            )
            self.estimates.insert(newEstimate, at: 0)
            self.isGenerating = false
            self.showCreateNew = false
            self.showEditor = false
        }
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
