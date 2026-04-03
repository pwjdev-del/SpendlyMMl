import SwiftUI
import SpendlyCore

// MARK: - General Settings View

/// Dark mode toggle, language selection, dialect support,
/// API key management, task estimation settings, and regional
/// tax/currency manager.
struct GeneralSettingsView: View {

    @Bindable var viewModel: SettingsNotificationsViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                SpendlyColors.background(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: SpendlySpacing.xxl) {
                        appearanceSection
                        languageSection
                        apiKeySection
                        taskEstimationSection
                        regionalTaxSection
                        saveSection
                        Spacer(minLength: SpendlySpacing.xxxl)
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.top, SpendlySpacing.lg)
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
                    Text("General Settings")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }
            .alert("Settings Saved", isPresented: $viewModel.showSaveConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your settings have been updated successfully.")
            }
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            sectionHeader(title: "APPEARANCE", icon: "paintbrush")

            SPCard(elevation: .low) {
                VStack(spacing: SpendlySpacing.lg) {
                    // Dark Mode Toggle
                    HStack(alignment: .center) {
                        HStack(spacing: SpendlySpacing.md) {
                            Image(systemName: "moon.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(SpendlyColors.primary)

                            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                                Text("Dark Mode")
                                    .font(SpendlyFont.headline())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                                Text("Current: \(viewModel.darkModePreference)")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                            }
                        }

                        Spacer()
                    }

                    SPSelect(
                        "",
                        options: SettingsNotificationsMockData.darkModeOptions,
                        selection: $viewModel.darkModePreference
                    )

                    SPDivider()

                    // Measurement Units
                    HStack(spacing: SpendlySpacing.md) {
                        Image(systemName: "ruler")
                            .font(.system(size: 16))
                            .foregroundStyle(SpendlyColors.primary)

                        Text("Measurement Units")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }

                    SPSelect(
                        "",
                        options: SettingsNotificationsMockData.measurementOptions,
                        selection: $viewModel.selectedMeasurementUnit
                    )
                }
            }
        }
    }

    // MARK: - Language & Dialect Section

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            sectionHeader(title: "LANGUAGE & DIALECT", icon: "globe")

            SPCard(elevation: .low) {
                VStack(spacing: SpendlySpacing.lg) {
                    SPSelect(
                        "Language",
                        options: SettingsNotificationsMockData.languageOptions,
                        selection: $viewModel.selectedLanguage
                    )

                    SPDivider()

                    SPSelect(
                        "Dialect / Region",
                        options: SettingsNotificationsMockData.dialectOptions,
                        selection: $viewModel.selectedDialect
                    )

                    HStack(alignment: .top, spacing: SpendlySpacing.sm) {
                        Image(systemName: SpendlyIcon.info.systemName)
                            .font(.system(size: 12))
                            .foregroundStyle(SpendlyColors.info)
                            .padding(.top, 2)

                        Text("Dialect affects date formats, number separators, and localized terminology within the app.")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }
        }
    }

    // MARK: - API Key Management Section

    private var apiKeySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            sectionHeader(title: "API KEY MANAGEMENT", icon: "key")

            SPCard(elevation: .low) {
                VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Text("Gemini AI API Key")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        Text("Required for AI diagnostics and smart suggestions.")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    HStack(spacing: SpendlySpacing.sm) {
                        if viewModel.isAPIKeyVisible {
                            SPInput(
                                "Enter API key...",
                                icon: "key",
                                text: $viewModel.geminiAPIKey
                            )
                        } else {
                            HStack(spacing: SpendlySpacing.sm) {
                                Image(systemName: "key")
                                    .foregroundStyle(SpendlyColors.secondary)
                                    .frame(width: 20)

                                Text(viewModel.geminiAPIKey.isEmpty ? "No API key set" : viewModel.maskedAPIKey)
                                    .font(SpendlyFont.body())
                                    .foregroundStyle(
                                        viewModel.geminiAPIKey.isEmpty
                                            ? SpendlyColors.secondary
                                            : SpendlyColors.foreground(for: colorScheme)
                                    )

                                Spacer()
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

                    HStack(spacing: SpendlySpacing.md) {
                        Button {
                            viewModel.isAPIKeyVisible.toggle()
                        } label: {
                            HStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: viewModel.isAPIKeyVisible ? "eye.slash" : "eye")
                                    .font(.system(size: 13))
                                Text(viewModel.isAPIKeyVisible ? "Hide" : "Show")
                                    .font(SpendlyFont.bodySemibold())
                            }
                            .foregroundStyle(SpendlyColors.primary)
                        }

                        Spacer()

                        if viewModel.isAPIKeyValid {
                            SPBadge("Valid", style: .success)
                        } else if !viewModel.geminiAPIKey.isEmpty {
                            SPBadge("Unverified", style: .warning)
                        }

                        Button {
                            viewModel.validateAPIKey()
                        } label: {
                            Text("Validate")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, SpendlySpacing.md)
                                .padding(.vertical, SpendlySpacing.sm)
                                .background(SpendlyColors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Task Estimation Section

    private var taskEstimationSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            sectionHeader(title: "TASK ESTIMATION", icon: "clock.badge.questionmark")

            SPCard(elevation: .low) {
                VStack(spacing: SpendlySpacing.lg) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text("Auto-Estimate Tasks")
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            Text("Use AI to predict task duration based on historical data")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: $viewModel.autoEstimateEnabled)
                            .labelsHidden()
                            .tint(SpendlyColors.primary)
                    }

                    SPDivider()

                    HStack(alignment: .top, spacing: SpendlySpacing.lg) {
                        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                            Text("Default Hours")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            HStack(spacing: 0) {
                                TextField("2.0", text: $viewModel.defaultEstimationHours)
                                    .font(SpendlyFont.body())
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.leading)

                                Text("hrs")
                                    .font(SpendlyFont.body())
                                    .foregroundStyle(SpendlyColors.secondary)
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
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                            Text("Buffer (%)")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            HStack(spacing: 0) {
                                TextField("15", text: $viewModel.estimationBuffer)
                                    .font(SpendlyFont.body())
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.leading)

                                Text("%")
                                    .font(SpendlyFont.body())
                                    .foregroundStyle(SpendlyColors.secondary)
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
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    // MARK: - Regional Tax & Currency Section

    private var regionalTaxSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            sectionHeader(title: "REGIONAL TAX & CURRENCY", icon: "dollarsign.circle")

            SPCard(elevation: .low) {
                VStack(spacing: SpendlySpacing.lg) {
                    // Default Currency
                    SPSelect(
                        "Default Currency",
                        options: SettingsNotificationsMockData.currencyOptions,
                        selection: $viewModel.defaultCurrency
                    )

                    // Global Tax Rate
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Text("Global Tax Rate (%)")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        HStack(spacing: 0) {
                            TextField("0.00", text: $viewModel.globalTaxRate)
                                .font(SpendlyFont.body())
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.leading)

                            Text("%")
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.secondary)
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

                    SPDivider()

                    // Regional Overrides Toggle
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text("Allow Regional Overrides")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            Text("Permit technicians to adjust taxes for local jurisdictions")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }

                        Spacer()

                        Toggle("", isOn: $viewModel.allowRegionalOverrides)
                            .labelsHidden()
                            .tint(SpendlyColors.primary)
                    }

                    // Regional Tax Entries
                    if viewModel.allowRegionalOverrides {
                        SPDivider()

                        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                            HStack {
                                Text("Regional Tax Rules")
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                                Spacer()

                                Button {
                                    viewModel.addRegionalTaxEntry()
                                } label: {
                                    HStack(spacing: SpendlySpacing.xs) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 14))
                                        Text("Add")
                                            .font(SpendlyFont.bodySemibold())
                                    }
                                    .foregroundStyle(SpendlyColors.accent)
                                }
                            }

                            ForEach($viewModel.regionalTaxEntries) { $entry in
                                regionalTaxRow(entry: $entry)
                            }

                            if viewModel.regionalTaxEntries.isEmpty {
                                HStack {
                                    Spacer()
                                    VStack(spacing: SpendlySpacing.sm) {
                                        Image(systemName: "map")
                                            .font(.system(size: 24))
                                            .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                                        Text("No regional tax rules configured")
                                            .font(SpendlyFont.caption())
                                            .foregroundStyle(SpendlyColors.secondary)
                                    }
                                    .padding(.vertical, SpendlySpacing.lg)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Regional Tax Row

    private func regionalTaxRow(entry: Binding<RegionalTaxEntry>) -> some View {
        HStack(spacing: SpendlySpacing.sm) {
            VStack(spacing: SpendlySpacing.sm) {
                TextField("Region", text: entry.regionName)
                    .font(SpendlyFont.body())
                    .padding(.horizontal, SpendlySpacing.md)
                    .padding(.vertical, SpendlySpacing.sm)
                    .background(SpendlyColors.background(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
            }
            .frame(maxWidth: .infinity)

            HStack(spacing: 0) {
                TextField("0.00", text: entry.taxRate)
                    .font(SpendlyFont.body())
                    .keyboardType(.decimalPad)
                    .frame(width: 50)

                Text("%")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }
            .padding(.horizontal, SpendlySpacing.sm)
            .padding(.vertical, SpendlySpacing.sm)
            .background(SpendlyColors.background(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))

            Button {
                viewModel.removeRegionalTaxEntry(entry.wrappedValue)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundStyle(SpendlyColors.error)
            }
        }
    }

    // MARK: - Save Section

    private var saveSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            SPButton(
                "Save Settings",
                icon: "checkmark.circle.fill",
                style: .primary,
                isLoading: viewModel.isSaving
            ) {
                viewModel.saveGeneralSettings()
            }

            SPButton(
                "Reset to Defaults",
                icon: "arrow.counterclockwise",
                style: .ghost
            ) {
                viewModel.showResetAlert = true
            }
        }
        .alert("Reset Settings?", isPresented: $viewModel.showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetToDefaults()
            }
        } message: {
            Text("This will restore all settings to their default values. This action cannot be undone.")
        }
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: SpendlySpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(SpendlyColors.accent)

            Text(title)
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .tracking(1.2)

            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("General Settings") {
    GeneralSettingsView(
        viewModel: SettingsNotificationsMockData.makeViewModel()
    )
}

#Preview("General Settings - Dark") {
    GeneralSettingsView(
        viewModel: SettingsNotificationsMockData.makeViewModel()
    )
    .preferredColorScheme(.dark)
}
