import SwiftUI
import SpendlyCore

// MARK: - Notification Settings View

/// Matches the Stitch `notification_settings/code.html` design.
/// Work Orders section (Status Updates, New Assignments) and
/// Communication section (Messages, Schedule Changes) with a
/// "Save Preferences" button and info banner.
struct NotificationSettingsView: View {

    @Bindable var viewModel: SettingsNotificationsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                SpendlyColors.background(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerDescription
                        workOrdersSection
                        communicationSection
                        infoNotice
                        saveButton
                        Spacer(minLength: SpendlySpacing.xxxl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: SpendlyIcon.arrowBack.systemName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }
            .alert("Preferences Saved", isPresented: $viewModel.showSaveConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your notification preferences have been updated successfully.")
            }
        }
    }

    // MARK: - Header Description

    private var headerDescription: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            HStack(spacing: SpendlySpacing.md) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(SpendlyColors.accent)

                Text("Push Notifications")
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            Text("Choose which updates you'd like to receive in real-time while on the field.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.xxl)
    }

    // MARK: - Work Orders Section

    private var workOrdersSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("WORK ORDERS")

            SPCard(elevation: .low, padding: 0) {
                VStack(spacing: 0) {
                    notificationToggleRow(
                        title: "Status Updates",
                        subtitle: "Get notified when a job status changes (e.g., In Progress, Completed)",
                        isOn: $viewModel.statusUpdatesEnabled
                    )

                    SPDivider()
                        .padding(.horizontal, SpendlySpacing.lg)

                    notificationToggleRow(
                        title: "New Assignments",
                        subtitle: "Alerts for newly dispatched service calls or emergency tasks",
                        isOn: $viewModel.newAssignmentsEnabled
                    )
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
        }
    }

    // MARK: - Communication Section

    private var communicationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("COMMUNICATION")
                .padding(.top, SpendlySpacing.xxl)

            SPCard(elevation: .low, padding: 0) {
                VStack(spacing: 0) {
                    notificationToggleRow(
                        title: "Messages",
                        subtitle: "Receive notifications for team chat and client direct messages",
                        isOn: $viewModel.messagesEnabled
                    )

                    SPDivider()
                        .padding(.horizontal, SpendlySpacing.lg)

                    notificationToggleRow(
                        title: "Schedule Changes",
                        subtitle: "Notification when your daily schedule is modified by dispatch",
                        isOn: $viewModel.scheduleChangesEnabled
                    )
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
        }
    }

    // MARK: - Info Notice

    private var infoNotice: some View {
        HStack(alignment: .top, spacing: SpendlySpacing.md) {
            Image(systemName: SpendlyIcon.info.systemName)
                .font(.system(size: 16))
                .foregroundStyle(SpendlyColors.primary)
                .padding(.top, 2)

            Text("Note: To stop all notifications, you may also need to adjust settings in your device's System Preferences. Changes here only affect the Field Service app alerts.")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
                .lineSpacing(2)
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.primary.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(SpendlyColors.primary.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.top, SpendlySpacing.xxl)
    }

    // MARK: - Save Button

    private var saveButton: some View {
        SPButton(
            "Save Preferences",
            icon: "checkmark.circle.fill",
            style: .primary,
            isLoading: viewModel.isSaving
        ) {
            viewModel.saveNotificationPreferences()
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.top, SpendlySpacing.lg)
    }

    // MARK: - Reusable Components

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(SpendlyFont.caption())
            .fontWeight(.bold)
            .foregroundStyle(SpendlyColors.primary)
            .tracking(1.2)
            .padding(.horizontal, SpendlySpacing.xxl)
            .padding(.bottom, SpendlySpacing.sm)
    }

    private func notificationToggleRow(
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(alignment: .center, spacing: SpendlySpacing.lg) {
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text(title)
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text(subtitle)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondary)
                    .lineSpacing(1.5)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(SpendlyColors.primary)
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .frame(minHeight: 72)
    }
}

// MARK: - Preview

#Preview("Notification Settings") {
    NotificationSettingsView(
        viewModel: SettingsNotificationsMockData.makeViewModel()
    )
}

#Preview("Notification Settings - Dark") {
    NotificationSettingsView(
        viewModel: SettingsNotificationsMockData.makeViewModel()
    )
    .preferredColorScheme(.dark)
}
