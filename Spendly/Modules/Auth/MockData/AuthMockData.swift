import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Auth Mock Data

/// Provides sample data and pre-configured states for Auth module previews and testing.
public enum AuthMockData {

    // MARK: - Mock Credentials

    static let validEmail = "kathan@spendly.com"
    static let validPassword = "password123"
    static let validUsername = "kpatel"

    // MARK: - Mock Users (by Role)

    static let adminUser = MockAuthUser(
        email: "admin@spendly.com",
        fullName: "Sarah Admin",
        role: .admin,
        portal: .admin
    )

    static let serviceManagerUser = MockAuthUser(
        email: "kathan@spendly.com",
        fullName: "Kathan Patel",
        role: .serviceManager,
        portal: .oem
    )

    static let technicianUser = MockAuthUser(
        email: "tech@spendly.com",
        fullName: "James Tech",
        role: .technician,
        portal: .oem
    )

    static let customerUser = MockAuthUser(
        email: "customer@acme.com",
        fullName: "Emily Client",
        role: .customer,
        portal: .customer
    )

    /// All mock users for iteration.
    static let allUsers: [MockAuthUser] = [
        adminUser,
        serviceManagerUser,
        technicianUser,
        customerUser
    ]

    // MARK: - Branding Configurations

    /// Default Spendly branding (navy + orange).
    static let defaultBranding = BrandingConfiguration()

    /// Orange-themed OEM branding (matches Stitch `updated_white_label_login`).
    static let orangeBranding = BrandingConfiguration(
        customPrimaryColor: Color(hex: "#ec5b13"),
        customSecondaryColor: Color(hex: "#d94f0e"),
        customLogoURL: nil,
        fontChoice: .sansSerif,
        cornerStyle: .extraRounded
    )

    /// Neutral slate branding (matches Stitch `white_label_login_screen`).
    static let slateBranding = BrandingConfiguration(
        customPrimaryColor: Color(hex: "#334155"),
        customSecondaryColor: Color(hex: "#64748b"),
        customLogoURL: nil,
        fontChoice: .sansSerif,
        cornerStyle: .rounded
    )

    /// Corporate blue branding example.
    static let corporateBlueBranding = BrandingConfiguration(
        customPrimaryColor: Color(hex: "#1e40af"),
        customSecondaryColor: Color(hex: "#3b82f6"),
        customLogoURL: nil,
        fontChoice: .sansSerif,
        cornerStyle: .rounded
    )

    /// Green eco branding example.
    static let greenBranding = BrandingConfiguration(
        customPrimaryColor: Color(hex: "#15803d"),
        customSecondaryColor: Color(hex: "#22c55e"),
        customLogoURL: nil,
        fontChoice: .sansSerif,
        cornerStyle: .extraRounded
    )

    // MARK: - Pre-Filled ViewModels

    /// A view model with pre-filled valid credentials.
    static func preFilledViewModel() -> AuthViewModel {
        let vm = AuthViewModel()
        vm.email = validEmail
        vm.password = validPassword
        vm.rememberMe = true
        return vm
    }

    /// A view model simulating a loading state.
    static func loadingViewModel() -> AuthViewModel {
        let vm = AuthViewModel()
        vm.email = validEmail
        vm.password = validPassword
        vm.isLoading = true
        return vm
    }

    /// A view model with an error message.
    static func errorViewModel() -> AuthViewModel {
        let vm = AuthViewModel()
        vm.email = "bad@email.com"
        vm.password = "wrong"
        vm.errorMessage = "Invalid email or password. Please try again."
        return vm
    }

    /// A view model showing the forgot password success state.
    static func forgotPasswordSuccessViewModel() -> AuthViewModel {
        let vm = AuthViewModel()
        vm.forgotPasswordEmail = validEmail
        vm.forgotPasswordSent = true
        return vm
    }
}

// MARK: - Mock Auth User

/// Lightweight mock user struct for Auth module testing.
/// Uses the same role/portal types as the main app but does not depend on SwiftData.
struct MockAuthUser: Identifiable {
    let id = UUID()
    let email: String
    let fullName: String
    let role: UserRole
    let portal: Portal

    /// The display name for the role.
    var roleDisplayName: String {
        switch role {
        case .admin:          return "Administrator"
        case .serviceManager: return "Service Manager"
        case .technician:     return "Field Technician"
        case .customer:       return "Customer"
        }
    }

    /// The portal this user should be routed to after login.
    var portalDisplayName: String {
        switch portal {
        case .admin:    return "Admin Portal"
        case .oem:      return "OEM Portal"
        case .customer: return "Customer Portal"
        }
    }
}

// MARK: - Preview Helpers

#Preview("Mock Data - Role Routing") {
    List {
        ForEach(AuthMockData.allUsers) { user in
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .font(SpendlyFont.bodySemibold())
                Text("\(user.roleDisplayName) -> \(user.portalDisplayName)")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
                Text(user.email)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.accent)
            }
            .padding(.vertical, 4)
        }
    }
}
