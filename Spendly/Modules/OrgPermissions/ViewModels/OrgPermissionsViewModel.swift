import SwiftUI
import SpendlyCore

// MARK: - Permission Type

enum PermissionType: String, CaseIterable, Identifiable {
    case viewCosts = "View Costs"
    case editPricing = "Edit Pricing"
    case approveEstimates = "Approve Estimates"

    var id: String { rawValue }
}

// MARK: - Role Permission Set

struct RolePermissions: Identifiable {
    let id = UUID()
    let roleName: String
    let badgeText: String?
    let badgeStyle: SPBadgeStyle?
    let isLocked: Bool
    var viewCosts: Bool
    var editPricing: Bool
    var approveEstimates: Bool

    mutating func setPermission(_ type: PermissionType, to value: Bool) {
        switch type {
        case .viewCosts:        viewCosts = value
        case .editPricing:      editPricing = value
        case .approveEstimates: approveEstimates = value
        }
    }

    func permission(for type: PermissionType) -> Bool {
        switch type {
        case .viewCosts:        return viewCosts
        case .editPricing:      return editPricing
        case .approveEstimates: return approveEstimates
        }
    }
}

// MARK: - OrgPermissionsViewModel

@Observable
final class OrgPermissionsViewModel {

    // MARK: - State

    var oneManShowEnabled: Bool = false
    var roles: [RolePermissions] = []
    var isSaving: Bool = false
    var showSaveConfirmation: Bool = false
    var selectedTabIndex: Int = 1 // Team tab active

    // MARK: - Default permissions snapshot (for reset)

    private var defaultRoles: [RolePermissions] = []

    // MARK: - Init

    init() {
        loadDefaults()
    }

    // MARK: - Tab Items

    let tabItems: [SPTabItem] = [
        SPTabItem(icon: "house", activeIcon: "house.fill", title: "Home"),
        SPTabItem(icon: "person.2", activeIcon: "person.2.fill", title: "Team"),
        SPTabItem(icon: "gearshape", activeIcon: "gearshape.fill", title: "Settings")
    ]

    // MARK: - Actions

    func loadDefaults() {
        roles = OrgPermissionsMockData.defaultRoles
        defaultRoles = OrgPermissionsMockData.defaultRoles
    }

    func togglePermission(roleIndex: Int, permission: PermissionType) {
        guard roleIndex < roles.count, !roles[roleIndex].isLocked else { return }
        let current = roles[roleIndex].permission(for: permission)
        roles[roleIndex].setPermission(permission, to: !current)
    }

    func bindingForPermission(roleIndex: Int, permission: PermissionType) -> Binding<Bool> {
        Binding<Bool>(
            get: { [self] in
                guard roleIndex < roles.count else { return false }
                return roles[roleIndex].permission(for: permission)
            },
            set: { [self] newValue in
                guard roleIndex < roles.count, !roles[roleIndex].isLocked else { return }
                roles[roleIndex].setPermission(permission, to: newValue)
            }
        )
    }

    @MainActor
    func saveChanges() async {
        isSaving = true
        // Simulate network delay
        try? await Task.sleep(for: .seconds(1))
        isSaving = false
        showSaveConfirmation = true
    }

    func resetToDefaults() {
        roles = defaultRoles
        oneManShowEnabled = false
    }

    var hasChanges: Bool {
        guard roles.count == defaultRoles.count else { return true }
        for (current, original) in zip(roles, defaultRoles) {
            if current.viewCosts != original.viewCosts
                || current.editPricing != original.editPricing
                || current.approveEstimates != original.approveEstimates {
                return true
            }
        }
        return oneManShowEnabled
    }
}
