import SwiftUI
import SpendlyCore

/// White-label variant of the login screen. Reads `BrandingConfiguration` from the
/// environment to apply custom primary color, logo URL, and corner style. Falls back
/// to neutral slate tones (matching the Stitch `white_label_login_screen` design)
/// when no branding overrides are provided.
public struct WhiteLabelLoginView: View {
    @Environment(AuthState.self) private var authState
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.brandingConfiguration) private var branding

    @State private var viewModel = AuthViewModel()

    // MARK: - Derived Branding

    /// The resolved primary color -- custom branding or the neutral slate-700 default.
    private var brandPrimary: Color {
        branding.customPrimaryColor ?? Color(hex: "#334155")
    }

    /// Accent color used for Forgot Password link and biometric hover states.
    private var brandAccent: Color {
        branding.customSecondaryColor ?? Color(hex: "#64748b")
    }

    /// Corner radius based on branding corner style.
    private var brandRadius: CGFloat {
        branding.cornerStyle.designRadius
    }

    // MARK: - Body

    @Environment(\.horizontalSizeClass) private var sizeClass

    public var body: some View {
        NavigationStack {
            Group {
                if sizeClass == .regular {
                    iPadWhiteLabelLayout
                } else {
                    iPhoneWhiteLabelLayout
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .ignoresSafeArea(.container, edges: .top)
            .background(SpendlyColors.background(for: colorScheme))
            .sheet(isPresented: $viewModel.showForgotPassword) {
                ForgotPasswordView(viewModel: viewModel)
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
            .onAppear {
                viewModel.restoreSavedSession()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Logo area
            if let logoURL = branding.customLogoURL, !logoURL.isEmpty {
                AsyncImage(url: URL(string: logoURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: brandRadius, style: .continuous))
                    default:
                        defaultLogoIcon
                    }
                }
            } else {
                defaultLogoIcon
            }

            // Platform name
            Text("Service Platform")
                .font(SpendlyFont.largeTitle())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            // Subtitle
            Text("Secure Credential Management")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
        }
        .padding(.top, 72)
        .padding(.bottom, SpendlySpacing.xxl)
        .frame(maxWidth: .infinity)
    }

    private var defaultLogoIcon: some View {
        RoundedRectangle(cornerRadius: brandRadius, style: .continuous)
            .fill(
                colorScheme == .dark
                    ? Color.white.opacity(0.08)
                    : Color(hex: "#f1f5f9")
            )
            .frame(width: 64, height: 64)
            .overlay(
                RoundedRectangle(cornerRadius: brandRadius, style: .continuous)
                    .strokeBorder(
                        colorScheme == .dark
                            ? Color.white.opacity(0.1)
                            : Color(hex: "#e2e8f0"),
                        lineWidth: 1
                    )
            )
            .overlay(
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 28))
                    .foregroundStyle(brandPrimary)
            )
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

            // Remember Me
            SPToggle(isOn: $viewModel.rememberMe, label: "Remember Me")

            // Sign In button (uses brand primary)
            signInButton

            // Biometric divider
            orDivider

            // Biometric options
            biometricButtons
        }
        .padding(.horizontal, SpendlySpacing.xxl)
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
                        .foregroundStyle(brandAccent)
                }
            }

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
            .clipShape(RoundedRectangle(cornerRadius: brandRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: brandRadius, style: .continuous)
                    .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
            )
        }
    }

    // MARK: - Sign In Button

    private var signInButton: some View {
        Button {
            Task {
                await viewModel.signIn(authState: authState)
            }
        } label: {
            HStack(spacing: SpendlySpacing.sm) {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("SIGN IN")
                        .font(SpendlyFont.bodySemibold())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.md)
            .padding(.horizontal, SpendlySpacing.lg)
            .foregroundStyle(.white)
            .background(brandPrimary)
            .clipShape(RoundedRectangle(cornerRadius: brandRadius, style: .continuous))
        }
        .disabled(!viewModel.isFormValid || viewModel.isLoading)
    }

    // MARK: - Or Divider

    private var orDivider: some View {
        HStack(spacing: SpendlySpacing.md) {
            SPDivider()
            Text("Or use biometrics")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
                .fixedSize()
            SPDivider()
        }
        .padding(.vertical, SpendlySpacing.xs)
    }

    // MARK: - Biometric Buttons

    private var biometricButtons: some View {
        HStack(spacing: SpendlySpacing.lg) {
            whiteLabelBiometricTile(
                icon: SpendlyIcon.face.systemName,
                label: "Face ID"
            )
            whiteLabelBiometricTile(
                icon: SpendlyIcon.fingerprint.systemName,
                label: "Fingerprint"
            )
        }
    }

    private func whiteLabelBiometricTile(icon: String, label: String) -> some View {
        Button {
            Task {
                await viewModel.signInWithBiometrics(authState: authState)
            }
        } label: {
            VStack(spacing: SpendlySpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(
                        colorScheme == .dark
                            ? SpendlyColors.secondary
                            : Color(hex: "#475569")
                    )

                Text(label)
                    .font(SpendlyFont.caption())
                    .fontWeight(.medium)
                    .foregroundStyle(SpendlyColors.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.lg)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: brandRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: brandRadius, style: .continuous)
                    .strokeBorder(
                        colorScheme == .dark
                            ? Color.white.opacity(0.1)
                            : SpendlyColors.secondary.opacity(0.15),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - iPad Layout (Split: brand left, form right)

    private var iPadWhiteLabelLayout: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                // Left: branding hero
                ZStack {
                    brandPrimary
                        .ignoresSafeArea()

                    VStack(spacing: SpendlySpacing.xl) {
                        Spacer()

                        if let logoURL = branding.customLogoURL, !logoURL.isEmpty {
                            AsyncImage(url: URL(string: logoURL)) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable().scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: brandRadius, style: .continuous))
                                default:
                                    whiteLabelHeroIcon
                                }
                            }
                        } else {
                            whiteLabelHeroIcon
                        }

                        Text("Service Platform")
                            .font(.custom("Inter-Bold", size: 32))
                            .foregroundStyle(.white)

                        Text("Secure Credential Management")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(.white.opacity(0.7))

                        Spacer()

                        Text("v1.0.0-white-label")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(.white.opacity(0.4))
                            .padding(.bottom, SpendlySpacing.xxxl)
                    }
                }
                .frame(width: geo.size.width * 0.4)

                // Right: form
                ScrollView {
                    VStack(spacing: SpendlySpacing.xl) {
                        Spacer().frame(height: SpendlySpacing.xxxl)

                        Text("Welcome Back")
                            .font(.custom("Inter-Bold", size: 28))
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .frame(maxWidth: .infinity, alignment: .leading)

                        emailField
                        passwordField

                        SPToggle(isOn: $viewModel.rememberMe, label: "Remember Me")

                        signInButton

                        orDivider
                        biometricButtons

                        Spacer().frame(height: SpendlySpacing.xxxl)
                    }
                    .padding(.horizontal, SpendlySpacing.xxxl + SpendlySpacing.lg)
                }
                .frame(width: geo.size.width * 0.6)
                .background(SpendlyColors.background(for: colorScheme))
            }
        }
    }

    private var whiteLabelHeroIcon: some View {
        RoundedRectangle(cornerRadius: brandRadius, style: .continuous)
            .fill(.white.opacity(0.15))
            .frame(width: 80, height: 80)
            .overlay(
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            )
    }

    // MARK: - iPhone Layout (original stacked)

    private var iPhoneWhiteLabelLayout: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                formSection
                footerSection
            }
        }
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        VStack(spacing: 0) {
            // Neutral accent bar (matches white-label Stitch: slate-200 / slate-800)
            (colorScheme == .dark ? Color.white.opacity(0.08) : Color(hex: "#e2e8f0"))
                .frame(height: 3)

            VStack(spacing: SpendlySpacing.xs) {
                Text("\u{00A9} \(Calendar.current.component(.year, from: Date())) Service Platform. All rights reserved.")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)

                Text("v1.0.0-white-label")
                    .font(SpendlyFont.caption())
                    .fontWeight(.semibold)
                    .foregroundStyle(brandAccent)
            }
            .padding(.vertical, SpendlySpacing.xl)
        }
    }
}

// MARK: - Previews

#Preview("White Label - Default") {
    WhiteLabelLoginView()
        .environment(AuthState())
}

#Preview("White Label - Custom Branding") {
    let config = BrandingConfiguration(
        customPrimaryColor: Color(hex: "#ec5b13"),
        customSecondaryColor: Color(hex: "#d94f0e"),
        customLogoURL: nil,
        fontChoice: .sansSerif,
        cornerStyle: .extraRounded
    )
    return WhiteLabelLoginView()
        .environment(AuthState())
        .brandingConfiguration(config)
}

#Preview("White Label - Dark") {
    WhiteLabelLoginView()
        .environment(AuthState())
        .preferredColorScheme(.dark)
}
