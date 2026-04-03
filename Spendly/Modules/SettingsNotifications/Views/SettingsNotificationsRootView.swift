import SwiftUI
import SpendlyCore

// MARK: - SettingsNotificationsRootView

public struct SettingsNotificationsRootView: View {

    @State private var viewModel = SettingsNotificationsViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                SpendlyColors.background(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        profileHeader
                        notificationsSection
                        securitySection
                        appPreferencesSection
                        supportSection
                    }
                    .padding(.bottom, SpendlySpacing.xxxl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }
            .sheet(item: $viewModel.activeSheet) { sheet in
                switch sheet {
                case .notifications:
                    NotificationSettingsView(viewModel: viewModel)
                case .general:
                    GeneralSettingsView(viewModel: viewModel)
                default:
                    EmptyView()
                }
            }
            .preferredColorScheme(viewModel.darkModeColorScheme)
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: SpendlySpacing.lg) {
            // Avatar
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(SpendlyColors.primary.opacity(0.1))
                    .frame(width: 96, height: 96)
                    .overlay(
                        Image(systemName: SpendlyIcon.personFill.systemName)
                            .font(.system(size: 40))
                            .foregroundStyle(SpendlyColors.primary)
                    )

                Circle()
                    .fill(SpendlyColors.accent)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: SpendlyIcon.edit.systemName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(SpendlyColors.surface(for: colorScheme), lineWidth: 2)
                    )
            }

            // Name & Role
            VStack(spacing: SpendlySpacing.xs) {
                Text(SettingsNotificationsMockData.sampleUserName)
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text(SettingsNotificationsMockData.sampleUserRole)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondary)

                Text("Employee ID: \(SettingsNotificationsMockData.sampleEmployeeID)")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .foregroundStyle(SpendlyColors.accent)
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .padding(.top, SpendlySpacing.xs)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SpendlySpacing.xxl)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("NOTIFICATIONS")

            SPCard(elevation: .low, padding: 0) {
                VStack(spacing: 0) {
                    // Push Notifications
                    settingsToggleRow(
                        icon: "bell.badge.fill",
                        label: "Push Notifications",
                        isOn: $viewModel.pushNotificationsEnabled
                    )

                    rowDivider

                    // Email Alerts
                    settingsToggleRow(
                        icon: "envelope.fill",
                        label: "Email Alerts",
                        isOn: $viewModel.emailAlertsEnabled
                    )

                    rowDivider

                    // SMS Reminders
                    settingsToggleRow(
                        icon: "message.fill",
                        label: "SMS Reminders",
                        isOn: $viewModel.smsRemindersEnabled
                    )

                    rowDivider

                    // Notification Preferences (navigates to detail)
                    settingsNavigationRow(
                        icon: "slider.horizontal.3",
                        label: "Notification Preferences",
                        detail: viewModel.notificationSummary
                    ) {
                        viewModel.activeSheet = .notifications
                    }
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
        }
        .padding(.top, SpendlySpacing.lg)
    }

    // MARK: - Security Section

    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("SECURITY")

            SPCard(elevation: .low, padding: 0) {
                VStack(spacing: 0) {
                    // Change Password
                    settingsNavigationRow(
                        icon: SpendlyIcon.lock.systemName,
                        label: "Change Password"
                    ) {
                        // Placeholder action
                    }

                    rowDivider

                    // Biometric Login
                    settingsToggleRow(
                        icon: SpendlyIcon.fingerprint.systemName,
                        label: "Biometric Login",
                        isOn: $viewModel.biometricLoginEnabled
                    )
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
        }
        .padding(.top, SpendlySpacing.xxl)
    }

    // MARK: - App Preferences Section

    private var appPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("APP PREFERENCES")

            SPCard(elevation: .low, padding: 0) {
                VStack(spacing: 0) {
                    // Dark Mode
                    settingsNavigationRow(
                        icon: "moon.fill",
                        label: "Dark Mode",
                        detail: viewModel.darkModePreference
                    ) {
                        viewModel.activeSheet = .general
                    }

                    rowDivider

                    // Language
                    settingsNavigationRow(
                        icon: "globe",
                        label: "Language",
                        detail: viewModel.selectedLanguage
                    ) {
                        viewModel.activeSheet = .general
                    }

                    rowDivider

                    // Measurement Units
                    settingsNavigationRow(
                        icon: "ruler",
                        label: "Measurement Units",
                        detail: viewModel.selectedMeasurementUnit
                    ) {
                        viewModel.activeSheet = .general
                    }
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
        }
        .padding(.top, SpendlySpacing.xxl)
    }

    // MARK: - Support & About Section

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("SUPPORT & ABOUT")

            SPCard(elevation: .low, padding: 0) {
                VStack(spacing: 0) {
                    // Help Center
                    settingsExternalRow(
                        icon: "questionmark.circle",
                        label: "Help Center"
                    )

                    rowDivider

                    // About Version
                    HStack(spacing: SpendlySpacing.md) {
                        Image(systemName: SpendlyIcon.info.systemName)
                            .font(.system(size: 16))
                            .foregroundStyle(SpendlyColors.primary)
                            .frame(width: 24)

                        Text("About Version \(SettingsNotificationsMockData.sampleAppVersion)")
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        Spacer()
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.vertical, SpendlySpacing.lg)

                    rowDivider

                    // Logout
                    Button {
                        // Logout action placeholder
                    } label: {
                        Text("Logout")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.error)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpendlySpacing.lg)
                    }
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
        }
        .padding(.top, SpendlySpacing.xxl)
    }

    // MARK: - Reusable Row Components

    private var rowDivider: some View {
        SPDivider()
            .padding(.horizontal, SpendlySpacing.lg)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(SpendlyFont.caption())
            .fontWeight(.bold)
            .foregroundStyle(SpendlyColors.primary)
            .tracking(1.2)
            .textCase(.uppercase)
            .padding(.horizontal, SpendlySpacing.xxl)
            .padding(.bottom, SpendlySpacing.sm)
            .padding(.top, SpendlySpacing.sm)
    }

    /// A row with an icon, label, and toggle switch.
    private func settingsToggleRow(
        icon: String,
        label: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: SpendlySpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(SpendlyColors.primary)
                .frame(width: 24)

            Text(label)
                .font(SpendlyFont.bodyMedium())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(SpendlyColors.primary)
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
    }

    /// A row with an icon, label, optional detail text, and chevron for navigation.
    private func settingsNavigationRow(
        icon: String,
        label: String,
        detail: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: SpendlySpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(SpendlyColors.primary)
                    .frame(width: 24)

                Text(label)
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                if let detail {
                    Text(detail)
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                Image(systemName: SpendlyIcon.chevronRight.systemName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.md)
        }
        .buttonStyle(.plain)
    }

    /// A row with an icon, label, and external link indicator.
    private func settingsExternalRow(
        icon: String,
        label: String
    ) -> some View {
        Button {
            // External link placeholder
        } label: {
            HStack(spacing: SpendlySpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(SpendlyColors.primary)
                    .frame(width: 24)

                Text(label)
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 14))
                    .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.md)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Settings Root") {
    SettingsNotificationsRootView()
}

#Preview("Settings Root - Dark") {
    SettingsNotificationsRootView()
        .preferredColorScheme(.dark)
}
