import SwiftUI
import SpendlyCore

// MARK: - OrgPermissionsRootView

public struct OrgPermissionsRootView: View {
    @State private var viewModel = OrgPermissionsViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main scrollable content
            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.lg) {
                    // MARK: - Page Header
                    pageHeader

                    // MARK: - One-Man Show Toggle
                    oneManShowSection

                    // MARK: - Roles Section
                    rolesSection

                    // MARK: - Footer Actions
                    footerActions
                }
            }

            // MARK: - Bottom Tab Bar
            SPTabBar(
                tabs: viewModel.tabItems,
                selectedIndex: $viewModel.selectedTabIndex
            )
        }
        .alert("Changes Saved", isPresented: $viewModel.showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your permission settings have been saved successfully.")
        }
    }

    // MARK: - Page Header

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text("Role & Permissions")
                .font(SpendlyFont.largeTitle())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Text("Manage what your team can see and do.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - One-Man Show Mode

    private var oneManShowSection: some View {
        HStack(alignment: .top, spacing: SpendlySpacing.lg) {
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text("One-Man Show Mode")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(Color(hex: "#1e3a5f"))

                Text("Simplifies the interface by hiding team management and assigning all permissions to you.")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(Color(hex: "#1d4ed8").opacity(0.8))
                    .lineSpacing(2)
            }

            Toggle("", isOn: $viewModel.oneManShowEnabled)
                .labelsHidden()
                .tint(SpendlyColors.info)
        }
        .padding(SpendlySpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .fill(oneManShowBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(oneManShowBorder, lineWidth: 1)
        )
    }

    private var oneManShowBackground: Color {
        colorScheme == .dark
            ? SpendlyColors.info.opacity(0.12)
            : Color(hex: "#eff6ff")
    }

    private var oneManShowBorder: Color {
        colorScheme == .dark
            ? SpendlyColors.info.opacity(0.25)
            : Color(hex: "#dbeafe")
    }

    // MARK: - Roles Section

    private var rolesSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("CONFIGURED ROLES")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(SpendlyColors.secondary)
                .tracking(1.2)

            ForEach(Array(viewModel.roles.enumerated()), id: \.element.id) { index, role in
                roleCard(role: role, index: index)
            }
        }
    }

    // MARK: - Role Card

    private func roleCard(role: RolePermissions, index: Int) -> some View {
        VStack(spacing: 0) {
            // Card Header
            HStack {
                Text(role.roleName)
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                if let badgeText = role.badgeText, let badgeStyle = role.badgeStyle {
                    SPBadge(badgeText, style: badgeStyle)
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.md)
            .background(roleCardHeaderBackground)

            SPDivider()

            // Permission Rows
            VStack(spacing: SpendlySpacing.lg) {
                ForEach(PermissionType.allCases) { permission in
                    permissionRow(
                        label: permission.rawValue,
                        isOn: viewModel.bindingForPermission(
                            roleIndex: index,
                            permission: permission
                        ),
                        isLocked: role.isLocked
                    )
                }
            }
            .padding(SpendlySpacing.lg)
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(cardBorderColor, lineWidth: 1)
        )
    }

    private var roleCardHeaderBackground: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.04)
            : Color(hex: "#f9fafb")
    }

    private var cardBorderColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color(hex: "#e5e7eb")
    }

    // MARK: - Permission Row

    private func permissionRow(
        label: String,
        isOn: Binding<Bool>,
        isLocked: Bool
    ) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.body())
                .foregroundStyle(
                    isLocked
                        ? SpendlyColors.secondaryForeground(for: colorScheme)
                        : SpendlyColors.foreground(for: colorScheme)
                )

            Spacer()

            checkboxView(isOn: isOn, isLocked: isLocked)
        }
    }

    // MARK: - Checkbox

    private func checkboxView(isOn: Binding<Bool>, isLocked: Bool) -> some View {
        Button {
            if !isLocked {
                isOn.wrappedValue.toggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                    .strokeBorder(
                        isOn.wrappedValue
                            ? SpendlyColors.info
                            : SpendlyColors.secondary.opacity(0.4),
                        lineWidth: 1.5
                    )
                    .frame(width: 22, height: 22)

                if isOn.wrappedValue {
                    RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                        .fill(SpendlyColors.info)
                        .frame(width: 22, height: 22)

                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .opacity(isLocked ? 0.6 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isLocked)
    }

    // MARK: - Footer Actions

    private var footerActions: some View {
        VStack(spacing: SpendlySpacing.md) {
            SPButton("Save Changes", style: .primary, isLoading: viewModel.isSaving) {
                Task {
                    await viewModel.saveChanges()
                }
            }

            Button {
                viewModel.resetToDefaults()
            } label: {
                Text("Reset to Defaults")
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.sm)
            }
        }
        .padding(.top, SpendlySpacing.lg)
        .padding(.bottom, SpendlySpacing.xxxl)
    }
}

// MARK: - Preview

#Preview("Light") {
    OrgPermissionsRootView()
}

#Preview("Dark") {
    OrgPermissionsRootView()
        .preferredColorScheme(.dark)
}
