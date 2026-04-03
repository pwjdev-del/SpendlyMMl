import SwiftUI
import SpendlyCore

struct SignUpView: View {
    @Environment(AuthState.self) private var authState
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var companyName = ""
    @State private var selectedRole: SignUpRole = .customer
    @State private var agreeToTerms = false

    @State private var isLoading = false
    @State private var isPasswordVisible = false
    @State private var showSuccess = false
    @State private var errorMessage: String?

    enum SignUpRole: String, CaseIterable, Identifiable {
        case customer = "Customer"
        case oem = "OEM / Manufacturer"
        case technician = "Independent Technician"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .customer: return "building.2"
            case .oem: return "gearshape.2"
            case .technician: return "wrench.and.screwdriver"
            }
        }

        var description: String {
            switch self {
            case .customer: return "I own machines and need service management"
            case .oem: return "I manufacture machines and provide after-sales service"
            case .technician: return "I'm an independent field service technician"
            }
        }

        var portal: Portal {
            switch self {
            case .customer: return .customer
            case .oem: return .oem
            case .technician: return .oem
            }
        }

        var userRole: UserRole {
            switch self {
            case .customer: return .customer
            case .oem: return .serviceManager
            case .technician: return .technician
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                    formSection
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(.container, edges: .top)
            .background(SpendlyColors.background(for: colorScheme))
            .alert("Error", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                if let msg = errorMessage { Text(msg) }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack {
            SpendlyColors.primary.ignoresSafeArea(.container, edges: .top)

            VStack(spacing: SpendlySpacing.sm) {
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .fill(.white.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundStyle(.white)
                    )
                    .padding(.top, 56)

                Text("Create Account")
                    .font(SpendlyFont.title())
                    .foregroundStyle(.white)

                Text("Join the Spendly service platform")
                    .font(SpendlyFont.body())
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.bottom, SpendlySpacing.xxl)
        }
        .frame(height: 220)
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: SpendlySpacing.xl) {

            // Account Type Selection
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("I am a...")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                ForEach(SignUpRole.allCases) { role in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedRole = role }
                    } label: {
                        HStack(spacing: SpendlySpacing.md) {
                            Image(systemName: role.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(selectedRole == role ? .white : SpendlyColors.primary)
                                .frame(width: 40, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                        .fill(selectedRole == role ? SpendlyColors.primary : SpendlyColors.primary.opacity(0.1))
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(role.rawValue)
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                Text(role.description)
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                            }

                            Spacer()

                            Image(systemName: selectedRole == role ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundStyle(selectedRole == role ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.4))
                        }
                        .padding(SpendlySpacing.md)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .strokeBorder(
                                    selectedRole == role ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.15),
                                    lineWidth: selectedRole == role ? 2 : 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            // Full Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Full Name")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                SPInput("John Smith", icon: "person", text: $fullName)
                    .textContentType(.name)
                    .autocorrectionDisabled()
            }

            // Company / Organization Name
            VStack(alignment: .leading, spacing: 6) {
                Text("Company / Organization")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                SPInput("Acme Manufacturing Inc.", icon: "building.2", text: $companyName)
                    .autocorrectionDisabled()
            }

            // Email
            VStack(alignment: .leading, spacing: 6) {
                Text("Email Address")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                SPInput("name@company.com", icon: "envelope", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            // Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: SpendlyIcon.lock.systemName)
                        .foregroundStyle(SpendlyColors.secondary)
                        .frame(width: 20)

                    if isPasswordVisible {
                        TextField("Min. 8 characters", text: $password)
                            .font(SpendlyFont.body())
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    } else {
                        SecureField("Min. 8 characters", text: $password)
                            .font(SpendlyFont.body())
                    }

                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? SpendlyIcon.visibilityOff.systemName : SpendlyIcon.visibility.systemName)
                            .foregroundStyle(SpendlyColors.secondary)
                            .frame(width: 20)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.md)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                )

                // Password strength indicator
                if !password.isEmpty {
                    HStack(spacing: SpendlySpacing.xs) {
                        ForEach(0..<4, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i < passwordStrength ? strengthColor : SpendlyColors.secondary.opacity(0.2))
                                .frame(height: 4)
                        }
                        Text(strengthLabel)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(strengthColor)
                    }
                }
            }

            // Confirm Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm Password")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                SPInput("Re-enter password", icon: "lock.shield", text: $confirmPassword, isSecure: true)
                    .textInputAutocapitalization(.never)

                if !confirmPassword.isEmpty && password != confirmPassword {
                    Text("Passwords do not match")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.error)
                }
            }

            // Terms
            HStack(alignment: .top, spacing: SpendlySpacing.sm) {
                Button {
                    agreeToTerms.toggle()
                } label: {
                    Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                        .font(.system(size: 22))
                        .foregroundStyle(agreeToTerms ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.4))
                }
                .buttonStyle(.plain)

                Text("I agree to the **Terms of Service** and **Privacy Policy**")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            // Create Account Button
            SPButton("CREATE ACCOUNT", icon: "person.badge.plus", style: .primary, isLoading: isLoading) {
                Task { await createAccount() }
            }
            .disabled(!isFormValid || isLoading)

            // Divider
            HStack(spacing: SpendlySpacing.md) {
                SPDivider()
                Text("Already have an account?")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
                    .fixedSize()
                SPDivider()
            }

            // Back to Sign In
            SPButton("SIGN IN", style: .secondary) {
                dismiss()
            }

            // Footer
            VStack(spacing: SpendlySpacing.xs) {
                Text("\u{00A9} \(Calendar.current.component(.year, from: Date())) Spendly. All rights reserved.")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }
            .padding(.bottom, SpendlySpacing.xl)
        }
        .padding(.horizontal, SpendlySpacing.xxl)
        .padding(.top, SpendlySpacing.xxl)
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !companyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && password.count >= 8
        && password == confirmPassword
        && agreeToTerms
    }

    private var passwordStrength: Int {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: .punctuationCharacters) != nil
            || password.rangeOfCharacter(from: .symbols) != nil { score += 1 }
        return score
    }

    private var strengthColor: Color {
        switch passwordStrength {
        case 0...1: return SpendlyColors.error
        case 2: return SpendlyColors.warning
        case 3: return SpendlyColors.accent
        default: return SpendlyColors.success
        }
    }

    private var strengthLabel: String {
        switch passwordStrength {
        case 0...1: return "Weak"
        case 2: return "Fair"
        case 3: return "Good"
        default: return "Strong"
        }
    }

    // MARK: - Create Account

    @MainActor
    private func createAccount() async {
        isLoading = true
        errorMessage = nil

        // Simulate network delay
        try? await Task.sleep(for: .seconds(1.5))

        // Mock: always succeeds and logs in
        authState.currentPortal = selectedRole.portal
        authState.currentRole = selectedRole.userRole
        authState.login()

        isLoading = false
    }
}

#Preview("Light") {
    SignUpView()
        .environment(AuthState())
}

#Preview("Dark") {
    SignUpView()
        .environment(AuthState())
        .preferredColorScheme(.dark)
}
