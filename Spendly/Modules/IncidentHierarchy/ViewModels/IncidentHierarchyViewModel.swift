import SwiftUI
import SpendlyCore

// MARK: - Local Models

struct HierarchyBranch: Identifiable {
    let id: UUID
    var name: String
    var icon: String
    var assemblies: [SubCategoryAssembly]
    var isExpanded: Bool

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        assemblies: [SubCategoryAssembly] = [],
        isExpanded: Bool = true
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.assemblies = assemblies
        self.isExpanded = isExpanded
    }
}

struct SubCategoryAssembly: Identifiable {
    let id: UUID
    var name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

struct IssueTemplate: Identifiable {
    let id: UUID
    var categoryPath: String
    var title: String
    var descriptionSnippet: String

    init(
        id: UUID = UUID(),
        categoryPath: String,
        title: String,
        descriptionSnippet: String
    ) {
        self.id = id
        self.categoryPath = categoryPath
        self.title = title
        self.descriptionSnippet = descriptionSnippet
    }
}

struct AssetImage: Identifiable {
    let id: UUID
    var label: String
    var systemIcon: String

    init(id: UUID = UUID(), label: String, systemIcon: String) {
        self.id = id
        self.label = label
        self.systemIcon = systemIcon
    }
}

// MARK: - ViewModel

@Observable
final class IncidentHierarchyViewModel {

    // MARK: Data

    var branches: [HierarchyBranch] = []
    var issueTemplates: [IssueTemplate] = []
    var assetImages: [AssetImage] = []
    var searchText: String = ""

    // MARK: Sheet State

    var showAddBranchSheet: Bool = false
    var showAddAssemblySheet: Bool = false
    var showCreateTemplateSheet: Bool = false
    var showEditBranchSheet: Bool = false
    var showEditAssemblySheet: Bool = false
    var showEditTemplateSheet: Bool = false
    var showDeleteConfirmation: Bool = false

    // MARK: Edit Targets

    var editingBranch: HierarchyBranch?
    var editingAssembly: SubCategoryAssembly?
    var editingTemplate: IssueTemplate?
    var assemblyTargetBranchID: UUID?
    var deleteTarget: DeleteTarget?

    // MARK: Form Fields

    var formName: String = ""
    var formIcon: String = "bolt"
    var formCategoryPath: String = ""
    var formDescription: String = ""

    // MARK: Filtered Data

    var filteredBranches: [HierarchyBranch] {
        guard !searchText.isEmpty else { return branches }
        let query = searchText.lowercased()
        return branches.compactMap { branch in
            let branchMatches = branch.name.lowercased().contains(query)
            let matchingAssemblies = branch.assemblies.filter {
                $0.name.lowercased().contains(query)
            }
            if branchMatches || !matchingAssemblies.isEmpty {
                var copy = branch
                if !branchMatches {
                    copy.assemblies = matchingAssemblies
                }
                return copy
            }
            return nil
        }
    }

    var filteredTemplates: [IssueTemplate] {
        guard !searchText.isEmpty else { return issueTemplates }
        let query = searchText.lowercased()
        return issueTemplates.filter {
            $0.title.lowercased().contains(query)
            || $0.categoryPath.lowercased().contains(query)
            || $0.descriptionSnippet.lowercased().contains(query)
        }
    }

    // MARK: Init

    init() {
        loadMockData()
    }

    // MARK: - Branch Actions

    func toggleBranchExpansion(_ branch: HierarchyBranch) {
        guard let index = branches.firstIndex(where: { $0.id == branch.id }) else { return }
        branches[index].isExpanded.toggle()
    }

    func beginAddBranch() {
        formName = ""
        formIcon = "bolt"
        showAddBranchSheet = true
    }

    func confirmAddBranch() {
        guard !formName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let branch = HierarchyBranch(name: formName, icon: formIcon)
        branches.append(branch)
        showAddBranchSheet = false
    }

    func beginEditBranch(_ branch: HierarchyBranch) {
        editingBranch = branch
        formName = branch.name
        formIcon = branch.icon
        showEditBranchSheet = true
    }

    func confirmEditBranch() {
        guard let editing = editingBranch,
              let index = branches.firstIndex(where: { $0.id == editing.id }) else { return }
        branches[index].name = formName
        branches[index].icon = formIcon
        showEditBranchSheet = false
        editingBranch = nil
    }

    func requestDeleteBranch(_ branch: HierarchyBranch) {
        deleteTarget = .branch(branch.id)
        showDeleteConfirmation = true
    }

    // MARK: - Assembly Actions

    func beginAddAssembly(for branchID: UUID) {
        assemblyTargetBranchID = branchID
        formName = ""
        showAddAssemblySheet = true
    }

    func confirmAddAssembly() {
        guard let branchID = assemblyTargetBranchID,
              let index = branches.firstIndex(where: { $0.id == branchID }),
              !formName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let assembly = SubCategoryAssembly(name: formName)
        branches[index].assemblies.append(assembly)
        showAddAssemblySheet = false
        assemblyTargetBranchID = nil
    }

    func beginEditAssembly(_ assembly: SubCategoryAssembly, in branchID: UUID) {
        editingAssembly = assembly
        assemblyTargetBranchID = branchID
        formName = assembly.name
        showEditAssemblySheet = true
    }

    func confirmEditAssembly() {
        guard let editing = editingAssembly,
              let branchID = assemblyTargetBranchID,
              let bIndex = branches.firstIndex(where: { $0.id == branchID }),
              let aIndex = branches[bIndex].assemblies.firstIndex(where: { $0.id == editing.id })
        else { return }
        branches[bIndex].assemblies[aIndex].name = formName
        showEditAssemblySheet = false
        editingAssembly = nil
        assemblyTargetBranchID = nil
    }

    func requestDeleteAssembly(_ assembly: SubCategoryAssembly, in branchID: UUID) {
        assemblyTargetBranchID = branchID
        deleteTarget = .assembly(assembly.id)
        showDeleteConfirmation = true
    }

    // MARK: - Template Actions

    func beginCreateTemplate() {
        formName = ""
        formCategoryPath = ""
        formDescription = ""
        showCreateTemplateSheet = true
    }

    func confirmCreateTemplate() {
        guard !formName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let template = IssueTemplate(
            categoryPath: formCategoryPath.isEmpty ? "General" : formCategoryPath,
            title: formName,
            descriptionSnippet: formDescription
        )
        issueTemplates.append(template)
        showCreateTemplateSheet = false
    }

    func beginEditTemplate(_ template: IssueTemplate) {
        editingTemplate = template
        formName = template.title
        formCategoryPath = template.categoryPath
        formDescription = template.descriptionSnippet
        showEditTemplateSheet = true
    }

    func confirmEditTemplate() {
        guard let editing = editingTemplate,
              let index = issueTemplates.firstIndex(where: { $0.id == editing.id }) else { return }
        issueTemplates[index].title = formName
        issueTemplates[index].categoryPath = formCategoryPath
        issueTemplates[index].descriptionSnippet = formDescription
        showEditTemplateSheet = false
        editingTemplate = nil
    }

    func requestDeleteTemplate(_ template: IssueTemplate) {
        deleteTarget = .template(template.id)
        showDeleteConfirmation = true
    }

    // MARK: - Delete Confirmation

    func confirmDelete() {
        guard let target = deleteTarget else { return }
        switch target {
        case .branch(let id):
            branches.removeAll { $0.id == id }
        case .assembly(let id):
            if let branchID = assemblyTargetBranchID,
               let bIndex = branches.firstIndex(where: { $0.id == branchID }) {
                branches[bIndex].assemblies.removeAll { $0.id == id }
            }
        case .template(let id):
            issueTemplates.removeAll { $0.id == id }
        }
        showDeleteConfirmation = false
        deleteTarget = nil
        assemblyTargetBranchID = nil
    }

    func cancelDelete() {
        showDeleteConfirmation = false
        deleteTarget = nil
        assemblyTargetBranchID = nil
    }

    var deleteTargetName: String {
        guard let target = deleteTarget else { return "this item" }
        switch target {
        case .branch(let id):
            return branches.first(where: { $0.id == id })?.name ?? "this branch"
        case .assembly(let id):
            for branch in branches {
                if let assembly = branch.assemblies.first(where: { $0.id == id }) {
                    return assembly.name
                }
            }
            return "this assembly"
        case .template(let id):
            return issueTemplates.first(where: { $0.id == id })?.title ?? "this template"
        }
    }

    // MARK: - Mock Data

    private func loadMockData() {
        branches = IncidentHierarchyMockData.branches
        issueTemplates = IncidentHierarchyMockData.issueTemplates
        assetImages = IncidentHierarchyMockData.assetImages
    }
}

// MARK: - Delete Target

enum DeleteTarget {
    case branch(UUID)
    case assembly(UUID)
    case template(UUID)
}

// MARK: - Branch Icon Options

enum BranchIconOption: String, CaseIterable {
    case bolt = "bolt"
    case gearshape = "gearshape"
    case wind = "wind"
    case wrench = "wrench.and.screwdriver"
    case cpu = "cpu"
    case flame = "flame"
    case drop = "drop"
    case antenna = "antenna.radiowaves.left.and.right"

    var displayName: String {
        switch self {
        case .bolt:     return "Electrical"
        case .gearshape: return "Mechanical"
        case .wind:     return "Pneumatic"
        case .wrench:   return "Tools"
        case .cpu:      return "Control"
        case .flame:    return "Thermal"
        case .drop:     return "Hydraulic"
        case .antenna:  return "Comms"
        }
    }
}
