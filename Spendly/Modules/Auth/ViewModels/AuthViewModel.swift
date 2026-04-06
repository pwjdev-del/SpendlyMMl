import SwiftUI
import SpendlyCore
import LocalAuthentication

// MARK: - AuthViewModel

@Observable
public final class AuthViewModel {
    // MARK: Form Fields
    var email: String = ""
    var password: String = ""
    var rememberMe: Bool = false
    var isPasswordVisible: Bool = false

    // MARK: State
    var isLoading: Bool = false
    var errorMessage: String?
    var showForgotPassword: Bool = false
    var biometricError: String?
    var showBiometricEnrollment: Bool = false

    // MARK: Forgot Password
    var forgotPasswordEmail: String = ""
    var forgotPasswordSent: Bool = false
    var isSendingReset: Bool = false

    // MARK: Validation

    var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !password.isEmpty
    }

    var emailValidationError: String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        // Allow plain usernames or emails
        if trimmed.contains("@") && !trimmed.contains(".") {
            return "Enter a valid email address"
        }
        return nil
    }

    // MARK: Dependencies

    private let authService = AuthService()
    private let biometricAuth = BiometricAuth.shared

    // MARK: Biometric Support

    var canUseBiometrics: Bool {
        biometricAuth.canUseBiometrics()
    }

    var biometricTypeName: String {
        biometricAuth.biometricTypeName
    }

    /// The SF Symbol name for the current biometric type (faceid or touchid).
    var biometricIconName: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "faceid"
        }
        switch context.biometryType {
        case .faceID:  return "faceid"
        case .touchID: return "touchid"
        default:       return "faceid"
        }
    }

    /// Whether the biometric login button should be shown on the login screen.
    /// Requires: device supports biometrics, user has enabled biometric login, and saved credentials exist.
    var shouldShowBiometricLogin: Bool {
        canUseBiometrics
        && UserDefaults.standard.bool(forKey: "biometricEnabled")
        && UserDefaults.standard.string(forKey: "spendly_biometric_email") != nil
    }

    // MARK: App Version

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "v\(version) (\(build))"
    }

    // MARK: - Actions

    /// Sign in with email/password credentials.
    @MainActor
    func signIn(authState: AuthState) async {
        guard isFormValid else {
            errorMessage = "Please enter your email and password."
            return
        }

        isLoading = true
        errorMessage = nil

        await authService.signIn(email: email, password: password)

        if let serviceError = authService.errorMessage {
            errorMessage = serviceError
            isLoading = false
            return
        }

        // Route based on email (demo accounts) or user role
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch trimmedEmail {
        case "admin@spendly.io":
            authState.currentPortal = .admin
            authState.currentRole = .admin
        case "customer@spendly.io":
            authState.currentPortal = .customer
            authState.currentRole = .customer
        case "tech@spendly.io":
            authState.currentPortal = .oem
            authState.currentRole = .technician
        default:
            // Default: service manager (OEM portal)
            if let user = authService.currentUser {
                switch user.role {
                case .admin:
                    authState.currentPortal = .admin
                case .customer:
                    authState.currentPortal = .customer
                case .serviceManager, .technician:
                    authState.currentPortal = .oem
                }
                authState.currentRole = user.role
            } else {
                authState.currentPortal = .oem
                authState.currentRole = .serviceManager
            }
        }

        // Persist "Remember Me" session data
        if rememberMe {
            UserDefaults.standard.set(true, forKey: "spendly_isRemembered")
            UserDefaults.standard.set(email, forKey: "spendly_savedEmail")
            UserDefaults.standard.set(authState.currentPortal.rawValue, forKey: "spendly_savedPortal")
            UserDefaults.standard.set(authState.currentRole.rawValue, forKey: "spendly_savedRole")
        } else {
            UserDefaults.standard.set(false, forKey: "spendly_isRemembered")
            UserDefaults.standard.removeObject(forKey: "spendly_savedEmail")
            UserDefaults.standard.removeObject(forKey: "spendly_savedPortal")
            UserDefaults.standard.removeObject(forKey: "spendly_savedRole")
        }

        // Save portal/role for biometric re-login
        UserDefaults.standard.set(authState.currentPortal.rawValue, forKey: "spendly_biometric_portal")
        UserDefaults.standard.set(authState.currentRole.rawValue, forKey: "spendly_biometric_role")

        authState.login()
        isLoading = false

        // After successful password login, offer biometric enrollment if available and not yet enabled
        if canUseBiometrics && !UserDefaults.standard.bool(forKey: "biometricEnabled") {
            UserDefaults.standard.set(email, forKey: "spendly_biometric_email")
            showBiometricEnrollment = true
        } else if canUseBiometrics && UserDefaults.standard.bool(forKey: "biometricEnabled") {
            // Update saved email for biometric login on subsequent logins
            UserDefaults.standard.set(email, forKey: "spendly_biometric_email")
        }
    }

    /// Called when the user accepts biometric enrollment after a successful password login.
    func enableBiometricLogin() {
        UserDefaults.standard.set(true, forKey: "biometricEnabled")
        UserDefaults.standard.set(email, forKey: "spendly_biometric_email")
    }

    /// Authenticate with biometrics (Face ID / Touch ID).
    @MainActor
    func signInWithBiometrics(authState: AuthState) async {
        biometricError = nil

        guard UserDefaults.standard.bool(forKey: "biometricEnabled"),
              let savedEmail = UserDefaults.standard.string(forKey: "spendly_biometric_email") else {
            biometricError = "Biometric login is not set up. Please sign in with your password first."
            return
        }

        do {
            let success = try await biometricAuth.authenticateWithBiometrics()
            if success {
                email = savedEmail

                // Restore saved portal/role from last password login
                if let portalRaw = UserDefaults.standard.string(forKey: "spendly_biometric_portal"),
                   let portal = Portal(rawValue: portalRaw) {
                    authState.currentPortal = portal
                }
                if let roleRaw = UserDefaults.standard.string(forKey: "spendly_biometric_role"),
                   let role = UserRole(rawValue: roleRaw) {
                    authState.currentRole = role
                }

                authState.login()
            }
        } catch {
            biometricError = error.localizedDescription
        }
    }

    /// Send password reset email.
    @MainActor
    func sendPasswordReset() async {
        let trimmed = forgotPasswordEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }

        isSendingReset = true
        errorMessage = nil

        await authService.resetPassword(email: trimmed)

        if let serviceError = authService.errorMessage {
            errorMessage = serviceError
        } else {
            forgotPasswordSent = true
        }

        isSendingReset = false
    }

    /// Pre-fill saved email and restore "Remember Me" toggle state.
    func restoreSavedSession() {
        if let savedEmail = UserDefaults.standard.string(forKey: "spendly_savedEmail") {
            email = savedEmail
        }
        if UserDefaults.standard.bool(forKey: "spendly_isRemembered") {
            rememberMe = true
        }
    }
}
