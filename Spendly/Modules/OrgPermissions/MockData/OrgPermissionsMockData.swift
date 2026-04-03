import Foundation
import SpendlyCore

// MARK: - Mock Data

enum OrgPermissionsMockData {

    /// Default role permission states matching the Stitch design:
    /// - Admin: all enabled, locked (Full Access badge)
    /// - Manager: View Costs ON, Edit Pricing OFF, Approve Estimates ON
    /// - Technician: all OFF
    static var defaultRoles: [RolePermissions] {
        [
            RolePermissions(
                roleName: "Admin",
                badgeText: "FULL ACCESS",
                badgeStyle: .info,
                isLocked: true,
                viewCosts: true,
                editPricing: true,
                approveEstimates: true
            ),
            RolePermissions(
                roleName: "Manager",
                badgeText: nil,
                badgeStyle: nil,
                isLocked: false,
                viewCosts: true,
                editPricing: false,
                approveEstimates: true
            ),
            RolePermissions(
                roleName: "Technician",
                badgeText: nil,
                badgeStyle: nil,
                isLocked: false,
                viewCosts: false,
                editPricing: false,
                approveEstimates: false
            )
        ]
    }
}
