import SwiftUI
import SpendlyCore

public struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @Bindable var viewModel: AuthViewModel

    public var body: some View {
        NavigationStack {
            VStack(spacing: SpendlySpacing.xxl) {
                // MARK: - Icon + Title
                headerContent

                if viewModel.forgotPasswordSent {
                    // MARK: - Success State
                    successContent
                } else {
                    // MARK: - Email Form
                    formContent
                }

                Spacer()
            }
            .padding(.horizontal, SpendlySpacing.xxl)
            .padding(.top, SpendlySpacing.xxxl)
            .background(SpendlyColors.background(for: colorScheme))
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        resetAndDismiss()
                    } label: {
                        Image(systemName: SpendlyIcon.close.systemName)
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                if let msg = viewModel.errorMessage {
                    Text(msg)
                }
            }
        }
    }

    // MARK: - Header

    private var headerContent: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Lock icon in a circle
            Circle()
                .fill(SpendlyColors.primary.opacity(0.1))
                .frame(width: 72, height: 72)
                .overlay(
                    Image(systemName: SpendlyIcon.lock.systemName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(SpendlyColors.primary)
                )

            Text("Forgot your password?")
                .font(SpendlyFont.title())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .multilineTextAlignment(.center)

            Text("Enter your email address and we'll send you a link to reset your password.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Form

    private var formContent: some View {
        VStack(spacing: SpendlySpacing.xl) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Email Address")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                SPInput("name@company.com", icon: "envelope", text: $viewModel.forgotPasswordEmail)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }

            SPButton("Send Reset Link", icon: "paperplane", style: .primary, isLoading: viewModel.isSendingReset) {
                Task {
                    await viewModel.sendPasswordReset()
                }
            }
            .disabled(viewModel.forgotPasswordEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            Button {
                resetAndDismiss()
            } label: {
                Text("Back to Sign In")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.primary)
            }
        }
    }

    // MARK: - Success State

    private var successContent: some View {
        VStack(spacing: SpendlySpacing.xl) {
            // Success icon
            Circle()
                .fill(SpendlyColors.success.opacity(0.1))
                .frame(width: 64, height: 64)
                .overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(SpendlyColors.success)
                )

            Text("Check your inbox")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Text("We've sent a password reset link to **\(viewModel.forgotPasswordEmail)**. Please check your email and follow the instructions.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            SPButton("Back to Sign In", style: .primary) {
                resetAndDismiss()
            }
        }
    }

    // MARK: - Helpers

    private func resetAndDismiss() {
        viewModel.forgotPasswordEmail = ""
        viewModel.forgotPasswordSent = false
        viewModel.errorMessage = nil
        dismiss()
    }
}

// MARK: - Preview

#Preview("Forgot Password") {
    ForgotPasswordView(viewModel: AuthViewModel())
}

#Preview("Forgot Password - Dark") {
    ForgotPasswordView(viewModel: AuthViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Forgot Password - Success") {
    let vm = AuthViewModel()
    vm.forgotPasswordSent = true
    vm.forgotPasswordEmail = "kathan@spendly.com"
    return ForgotPasswordView(viewModel: vm)
}
