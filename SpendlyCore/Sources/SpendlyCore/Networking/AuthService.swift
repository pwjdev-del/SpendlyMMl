import Foundation
import SwiftUI

@Observable
public class AuthService {
    public var currentUser: SPUser?
    public var isAuthenticated: Bool = false
    public var isLoading: Bool = false
    public var errorMessage: String?

    public init() {}

    /// Signs in with email and password.
    /// Currently uses mock behavior -- will be replaced with Supabase auth.
    public func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Mock: create a service manager user
        let mockUser = SPUser(
            id: UUID(),
            orgID: UUID(uuidString: "00000000-0000-0000-0000-000000000001") ?? UUID(),
            email: email,
            fullName: "Kathan Patel",
            role: .serviceManager,
            phone: "+1-555-0100",
            isActive: true,
            createdAt: Date()
        )

        currentUser = mockUser
        isAuthenticated = true
        isLoading = false
    }

    /// Signs out the current user.
    public func signOut() async {
        isLoading = true

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        currentUser = nil
        isAuthenticated = false
        isLoading = false
    }

    /// Sends a password reset email.
    /// Currently mock -- will be replaced with Supabase auth.
    public func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Mock: just succeed
        isLoading = false
    }
}
