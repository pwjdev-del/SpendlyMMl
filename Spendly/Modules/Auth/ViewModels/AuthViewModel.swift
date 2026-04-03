import SwiftUI
import SpendlyCore

// MARK: - AuthViewModel

@Observable
public final class AuthViewModel {
    // MARK: Form Fields
    var email: String = ""
    var password: String = ""
    var keepLoggedIn: Bool = false
    var isPasswordVisible: Bool = false

    // MARK: State
    var isLoading: Bool = false
    var errorMessage: String?
    var showForgotPassword: Bool = false
    var biometricError: String?

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

        // Persist "keep logged in" preference
        if keepLoggedIn {
            UserDefaults.standard.set(true, forKey: "spendly_keep_logged_in")
            UserDefaults.standard.set(email, forKey: "spendly_saved_email")
        } else {
            UserDefaults.standard.removeObject(forKey: "spendly_keep_logged_in")
            UserDefaults.standard.removeObject(forKey: "spendly_saved_email")
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

        authState.login()
        isLoading = false
    }

    /// Authenticate with biometrics (Face ID / Touch ID).
    @MainActor
    func signInWithBiometrics(authState: AuthState) async {
        biometricError = nil

        do {
            let success = try await biometricAuth.authenticateWithBiometrics()
            if success {
                // Load saved email if available
                if let savedEmail = UserDefaults.standard.string(forKey: "spendly_saved_email") {
                    email = savedEmail
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

    /// Restore saved session if "Keep me logged in" was enabled.
    func restoreSavedSession() {
        if UserDefaults.standard.bool(forKey: "spendly_keep_logged_in"),
           let savedEmail = UserDefaults.standard.string(forKey: "spendly_saved_email") {
            email = savedEmail
            keepLoggedIn = true
        }
    }
}
