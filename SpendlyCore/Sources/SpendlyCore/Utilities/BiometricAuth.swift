import Foundation
import LocalAuthentication

public class BiometricAuth {
    public static let shared = BiometricAuth()

    public init() {}

    /// Returns whether biometric authentication (Face ID / Touch ID) is available on this device.
    public func canUseBiometrics() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// Prompts the user for biometric authentication.
    /// - Returns: `true` if authentication succeeds, `false` otherwise.
    /// - Throws: An error if biometrics are not available or the evaluation fails.
    public func authenticateWithBiometrics() async throws -> Bool {
        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                throw error
            }
            return false
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access Spendly"
            )
            return success
        } catch {
            throw error
        }
    }

    /// Returns a human-readable name for the available biometric type.
    public var biometricTypeName: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "None"
        }

        switch context.biometryType {
        case .none:
            return "None"
        case .faceID:
            return "Face ID"
        case .touchID:
            return "Touch ID"
        case .opticID:
            return "Optic ID"
        @unknown default:
            return "Biometrics"
        }
    }
}
