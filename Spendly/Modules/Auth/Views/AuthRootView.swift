import SwiftUI
import SpendlyCore

public struct AuthRootView: View {
    @Environment(AuthState.self) private var authState
    @Environment(\.colorScheme) private var colorScheme

    @State private var viewModel = AuthViewModel()
    @State private var showSignUp = false

    @Environment(\.horizontalSizeClass) private var sizeClass

    public var body: some View {
        NavigationStack {
            Group {
                if sizeClass == .regular {
                    iPadLoginLayout
                } else {
                    iPhoneLoginLayout
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(.container, edges: .top)
            .background(SpendlyColors.background(for: colorScheme))
            .sheet(isPresented: $viewModel.showForgotPassword) {
                ForgotPasswordView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $showSignUp) {
                SignUpView()
            }
            .alert("Authentication Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                if let msg = viewModel.errorMessage {
                    Text(msg)
                }
            }
            .alert("Biometric Error", isPresented: .init(
                get: { viewModel.biometricError != nil },
                set: { if !$0 { viewModel.biometricError = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.biometricError = nil }
            } message: {
                if let msg = viewModel.biometricError {
                    Text(msg)
                }
            }
            .alert("Enable \(viewModel.biometricTypeName)?",
                   isPresented: $viewModel.showBiometricEnrollment) {
                Button("Enable") {
                    viewModel.enableBiometricLogin()
                }
                Button("Not Now", role: .cancel) {}
            } message: {
                Text("Would you like to use \(viewModel.biometricTypeName) to sign in next time? You can change this later in Settings.")
            }
            .onAppear {
                viewModel.restoreSavedSession()
            }
        }
    }

    // MARK: - Header Section

    /// Navy (#19355c) branded header with shield icon, app name, and tagline.
    private var headerSection: some View {
        ZStack {
            SpendlyColors.primary
                .ignoresSafeArea(.container, edges: .top)

            VStack(spacing: SpendlySpacing.md) {
                // Shield icon badge
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .fill(.white.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: "shield.checkered")
                            .font(.system(size: 32, weight: .regular))
                            .foregroundStyle(.white)
                    )
                    .padding(.top, 60)

                // App name
                Text("Spendly")
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(.white)

                // Tagline
                Text("Secure Service Platform")
                    .font(SpendlyFont.body())
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.bottom, SpendlySpacing.xxxl)
        }
        .frame(height: 260)
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: SpendlySpacing.xl) {
            // Welcome heading
            HStack {
                Text("Welcome Back")
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
            }

            // Email field
            emailField

            // Password field
            passwordField

            // Remember Me toggle
            SPToggle(isOn: $viewModel.rememberMe, label: "Remember Me")

            // Sign In button
            signInButton

            // Biometric login (only shown when device supports it and user has enrolled)
            if viewModel.shouldShowBiometricLogin {
                orDivider
                biometricLoginButton
            }

            // Create Account link
            HStack(spacing: SpendlySpacing.xs) {
                Text("Don't have an account?")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondary)
                Button {
                    showSignUp = true
                } label: {
                    Text("Sign Up")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.accent)
                }
            }
            .padding(.top, SpendlySpacing.sm)

            // Demo credentials hint
            VStack(spacing: SpendlySpacing.sm) {
                SPDivider()
                    .padding(.vertical, SpendlySpacing.xs)

                Text("DEMO CREDENTIALS")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .foregroundStyle(SpendlyColors.secondary)
                    .tracking(1)

                VStack(spacing: SpendlySpacing.xs) {
                    demoCredentialRow(role: "Manager", email: "manager@spendly.io", password: "demo1234")
                    demoCredentialRow(role: "Technician", email: "tech@spendly.io", password: "demo1234")
                    demoCredentialRow(role: "Customer", email: "customer@spendly.io", password: "demo1234")
                    demoCredentialRow(role: "Admin", email: "admin@spendly.io", password: "demo1234")
                }
            }
            .padding(.top, SpendlySpacing.sm)
        }
        .padding(.horizontal, SpendlySpacing.xxl)
        .padding(.top, SpendlySpacing.xxl)
        .padding(.bottom, SpendlySpacing.lg)
    }

    // MARK: - Email Field

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email or Username")
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            SPInput("name@company.com", icon: "person", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if let error = viewModel.emailValidationError {
                Text(error)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.error)
            }
        }
    }

    // MARK: - Password Field

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Password")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                Button {
                    viewModel.showForgotPassword = true
                } label: {
                    Text("Forgot Password?")
                        .font(SpendlyFont.caption())
                        .fontWeight(.semibold)
                        .foregroundStyle(SpendlyColors.accent)
                }
            }

            // Custom password field with visibility toggle
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: SpendlyIcon.lock.systemName)
                    .foregroundStyle(SpendlyColors.secondary)
                    .frame(width: 20)

                if viewModel.isPasswordVisible {
                    TextField("", text: $viewModel.password)
                        .font(SpendlyFont.body())
                        .textContentType(.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } else {
                    SecureField("", text: $viewModel.password)
                        .font(SpendlyFont.body())
                        .textContentType(.password)
                }

                Button {
                    viewModel.isPasswordVisible.toggle()
                } label: {
                    Image(systemName: viewModel.isPasswordVisible
                          ? SpendlyIcon.visibilityOff.systemName
                          : SpendlyIcon.visibility.systemName)
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
        }
    }

    // MARK: - Sign In Button

    private var signInButton: some View {
        SPButton("SIGN IN", icon: "arrow.right", style: .primary, isLoading: viewModel.isLoading) {
            Task {
                await viewModel.signIn(authState: authState)
            }
        }
        .disabled(!viewModel.isFormValid && !viewModel.isLoading)
    }

    // MARK: - Or Divider

    private var orDivider: some View {
        HStack(spacing: SpendlySpacing.md) {
            SPDivider()
            Text("Or sign in with \(viewModel.biometricTypeName)")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
                .fixedSize()
            SPDivider()
        }
        .padding(.vertical, SpendlySpacing.xs)
    }

    // MARK: - Biometric Login Button

    /// A single adaptive biometric button that shows Face ID or Touch ID based on the device.
    private var biometricLoginButton: some View {
        Button {
            Task {
                await viewModel.signInWithBiometrics(authState: authState)
            }
        } label: {
            HStack(spacing: SpendlySpacing.md) {
                Image(systemName: viewModel.biometricIconName)
                    .font(.system(size: 24))
                    .foregroundStyle(SpendlyColors.primary)

                Text("Sign in with \(viewModel.biometricTypeName)")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.lg)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(
                        SpendlyColors.primary.opacity(0.3),
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Demo Credential Row

    private func demoCredentialRow(role: String, email: String, password: String) -> some View {
        Button {
            viewModel.email = email
            viewModel.password = password
        } label: {
            HStack(spacing: SpendlySpacing.sm) {
                Text(role)
                    .font(SpendlyFont.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(SpendlyColors.primary)
                    .frame(width: 72, alignment: .leading)

                Text(email)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                Image(systemName: "arrow.up.left.square")
                    .font(.system(size: 14))
                    .foregroundStyle(SpendlyColors.accent)
            }
            .padding(.horizontal, SpendlySpacing.md)
            .padding(.vertical, SpendlySpacing.sm)
            .background(SpendlyColors.primary.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: - iPad Login Layout (Split: hero left, form right)

    private var iPadLoginLayout: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                // Left: branding hero panel
                ZStack {
                    SpendlyColors.primary
                        .ignoresSafeArea()

                    VStack(spacing: SpendlySpacing.xl) {
                        Spacer()

                        RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                            .fill(.white.opacity(0.15))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "shield.checkered")
                                    .font(.system(size: 40, weight: .regular))
                                    .foregroundStyle(.white)
                            )

                        Text("Spendly")
                            .font(.custom("Inter-Bold", size: 36))
                            .foregroundStyle(.white)

                        Text("Secure Service Platform")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(.white.opacity(0.7))

                        Spacer()

                        // Version footer
                        VStack(spacing: SpendlySpacing.xs) {
                            SpendlyColors.accent
                                .frame(height: 3)
                                .frame(maxWidth: 120)
                                .clipShape(Capsule())

                            Text("\u{00A9} \(Calendar.current.component(.year, from: Date())) Spendly")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        .padding(.bottom, SpendlySpacing.xxxl)
                    }
                }
                .frame(width: geo.size.width * 0.4)

                // Right: scrollable form
                ScrollView {
                    VStack(spacing: SpendlySpacing.xl) {
                        Spacer().frame(height: SpendlySpacing.xxxl)

                        Text("Welcome Back")
                            .font(.custom("Inter-Bold", size: 28))
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Sign in to your account to continue")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, -SpendlySpacing.md)

                        emailField
                        passwordField

                        SPToggle(isOn: $viewModel.rememberMe, label: "Remember Me")

                        signInButton

                        if viewModel.shouldShowBiometricLogin {
                            orDivider
                            biometricLoginButton
                        }

                        HStack(spacing: SpendlySpacing.xs) {
                            Text("Don't have an account?")
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.secondary)
                            Button {
                                showSignUp = true
                            } label: {
                                Text("Sign Up")
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.accent)
                            }
                        }

                        // Demo credentials
                        VStack(spacing: SpendlySpacing.sm) {
                            SPDivider()
                                .padding(.vertical, SpendlySpacing.xs)

                            Text("DEMO CREDENTIALS")
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                                .foregroundStyle(SpendlyColors.secondary)
                                .tracking(1)

                            VStack(spacing: SpendlySpacing.xs) {
                                demoCredentialRow(role: "Manager", email: "manager@spendly.io", password: "demo1234")
                                demoCredentialRow(role: "Technician", email: "tech@spendly.io", password: "demo1234")
                                demoCredentialRow(role: "Customer", email: "customer@spendly.io", password: "demo1234")
                                demoCredentialRow(role: "Admin", email: "admin@spendly.io", password: "demo1234")
                            }
                        }

                        Spacer().frame(height: SpendlySpacing.xxxl)
                    }
                    .padding(.horizontal, SpendlySpacing.xxxl + SpendlySpacing.lg)
                }
                .frame(width: geo.size.width * 0.6)
                .background(SpendlyColors.background(for: colorScheme))
            }
        }
    }

    // MARK: - iPhone Login Layout (original stacked)

    private var iPhoneLoginLayout: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                formSection
                footerSection
            }
        }
    }

    // MARK: - Footer Section

    /// Orange accent bar + version number footer.
    private var footerSection: some View {
        VStack(spacing: 0) {
            // Orange accent bar (matches Stitch design)
            SpendlyColors.accent
                .frame(height: 3)

            // Version + copyright
            VStack(spacing: SpendlySpacing.xs) {
                Text("\u{00A9} \(Calendar.current.component(.year, from: Date())) Spendly. All rights reserved.")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)

                Text(viewModel.appVersion)
                    .font(SpendlyFont.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(SpendlyColors.primary)
            }
            .padding(.vertical, SpendlySpacing.xl)
        }
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    AuthRootView()
        .environment(AuthState())
}

#Preview("Dark Mode") {
    AuthRootView()
        .environment(AuthState())
        .preferredColorScheme(.dark)
}
