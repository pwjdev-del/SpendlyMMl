import SwiftUI
import SpendlyCore

/// Localization & Finance settings section matching the Stitch
/// `admin_branding_finance_settings` design. Covers features #19-22.
struct CurrencySettingsView: View {

    @Bindable var viewModel: WhiteLabelBrandingViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            sectionHeader
            currencyAndTaxRow
            displayFormatPicker
            regionalOverridesToggle
        }
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        HStack {
            Text("LOCALIZATION & FINANCE")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .tracking(1.2)

            Spacer()

            SPBadge("GLOBAL", style: .success)
        }
        .padding(.top, SpendlySpacing.lg)
    }

    // MARK: - Currency + Tax Rate Row

    private var currencyAndTaxRow: some View {
        HStack(alignment: .top, spacing: SpendlySpacing.lg) {
            // Default Currency
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Default Currency")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Menu {
                    ForEach(CurrencyOption.allCases) { option in
                        Button {
                            viewModel.selectedCurrency = option.rawValue
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if option.rawValue == viewModel.selectedCurrency {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    currencyMenuLabel
                }
            }
            .frame(maxWidth: .infinity)

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
            .frame(maxWidth: .infinity)
        }
    }

    private var currencyMenuLabel: some View {
        HStack {
            Text(viewModel.selectedCurrency.isEmpty ? "Select..." : viewModel.selectedCurrency)
                .font(SpendlyFont.body())
                .foregroundStyle(
                    viewModel.selectedCurrency.isEmpty
                        ? SpendlyColors.secondary
                        : SpendlyColors.foreground(for: colorScheme)
                )
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .font(.system(size: 12))
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

    // MARK: - Display Format

    private var displayFormatPicker: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("Currency Display Format")
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Menu {
                ForEach(CurrencyDisplayFormat.allCases) { format in
                    Button {
                        viewModel.selectedDisplayFormat = format.rawValue
                    } label: {
                        HStack {
                            Text(format.rawValue)
                            if format.rawValue == viewModel.selectedDisplayFormat {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedDisplayFormat.isEmpty ? "Select..." : viewModel.selectedDisplayFormat)
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
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
        }
    }

    // MARK: - Regional Overrides

    private var regionalOverridesToggle: some View {
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
        .padding(.vertical, SpendlySpacing.sm)
    }
}

// MARK: - Preview

#Preview("Currency Settings") {
    SPScreenWrapper {
        CurrencySettingsView(
            viewModel: WhiteLabelBrandingMockData.makeViewModel()
        )
    }
}

#Preview("Dark Mode") {
    SPScreenWrapper {
        CurrencySettingsView(
            viewModel: WhiteLabelBrandingMockData.makeViewModel()
        )
    }
    .preferredColorScheme(.dark)
}
