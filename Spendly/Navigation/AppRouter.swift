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
