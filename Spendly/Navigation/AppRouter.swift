import SwiftUI
import SpendlyCore

// MARK: - Portal

public enum Portal: String, CaseIterable, Identifiable {
    case admin
    case oem
    case customer

    public var id: String { rawValue }
}

// MARK: - AuthState

@Observable
public final class AuthState {
    public var isAuthenticated: Bool = false
    public var currentPortal: Portal = .oem
    public var currentRole: UserRole = .serviceManager

    public init() {}

    public func login() {
        isAuthenticated = true
    }

    public func logout() {
        isAuthenticated = false
        currentPortal = .oem
        currentRole = .serviceManager

        // Clear "Remember Me" session data
        UserDefaults.standard.set(false, forKey: "spendly_isRemembered")
        UserDefaults.standard.removeObject(forKey: "spendly_savedEmail")
        UserDefaults.standard.removeObject(forKey: "spendly_savedPortal")
        UserDefaults.standard.removeObject(forKey: "spendly_savedRole")
    }

    /// Restore a remembered session on app launch, skipping the login screen.
    public func restoreRememberedSessionIfNeeded() {
        guard UserDefaults.standard.bool(forKey: "spendly_isRemembered"),
              let portalRaw = UserDefaults.standard.string(forKey: "spendly_savedPortal"),
              let roleRaw = UserDefaults.standard.string(forKey: "spendly_savedRole"),
              let portal = Portal(rawValue: portalRaw),
              let role = UserRole(rawValue: roleRaw)
        else { return }

        currentPortal = portal
        currentRole = role
        login()
    }
}

// MARK: - AppRouter

public struct AppRouter: View {
    @Environment(AuthState.self) private var authState

    public var body: some View {
        Group {
            if authState.isAuthenticated {
                switch authState.currentPortal {
                case .admin:
                    AdminTabRouter()
                case .oem:
                    OEMTabRouter()
                case .customer:
                    CustomerTabRouter()
                }
            } else {
                AuthRootView()
            }
        }
    }
}

#Preview {
    AppRouter()
        .environment(AuthState())
}
