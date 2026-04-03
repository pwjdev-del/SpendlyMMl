import SwiftUI
import SpendlyCore

// MARK: - TerritoryDetailView

struct TerritoryDetailView: View {
    @Bindable var viewModel: TerritoryRegionViewModel
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    private var isEditing: Bool {
        viewModel.selectedTerritory != nil
    }

    var body: some View {
        SPScreenWrapper {
            VStack(spacing: SpendlySpacing.lg) {
                // MARK: Section — Basic Info
                basicInfoSection

                // MARK: Section — Timezone
                timezoneSection

                // MARK: Section — Tax & Currency
                taxCurrencySection

                // MARK: Section — Assigned Technicians
                technicianSection

                // MARK: Save Button
                saveSection
            }
        }
        .navigationTitle(isEditing ? "Edit Territory" : "New Territory")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    onDismiss()
                }
                .foregroundStyle(SpendlyColors.secondary)
            }
        }
    }

    // MARK: - Basic Info Section

    private var basicInfoSection: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                sectionHeader(icon: "map", title: "Basic Information")

                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    fieldLabel("Territory Name")
                    SPInput("e.g. Northeast Region", icon: "textformat", text: $viewModel.editName)
                }

                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    fieldLabel("Region Code")
                    SPInput("e.g. US-NE", icon: "number", text: $viewModel.editRegionCode)
                }
            }
        }
    }

    // MARK: - Timezone Section

    private var timezoneSection: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                sectionHeader(icon: "clock", title: "Timezone Settings")

                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    fieldLabel("Timezone")

                    SPSelect(
                        "",
                        options: viewModel.timezoneOptions.map { viewModel.timezoneLabel(for: $0) },
                        selection: Binding(
                            get: {
                                viewModel.timezoneLabel(for: viewModel.editTimezone)
                            },
                            set: { newLabel in
                                if let match = viewModel.timezoneOptions.first(where: {
                                    viewModel.timezoneLabel(for: $0) == newLabel
                                }) {
                                    viewModel.editTimezone = match
                                }
                            }
                        )
                    )
                }

                // Current time preview
                if !viewModel.editTimezone.isEmpty,
                   let tz = TimeZone(identifier: viewModel.editTimezone) {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(SpendlyColors.info)

                        Text("Current time: \(currentTimeString(in: tz))")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }
                    .padding(SpendlySpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(SpendlyColors.info.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }
            }
        }
    }

    // MARK: - Tax & Currency Section

    private var taxCurrencySection: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                sectionHeader(icon: "percent", title: "Tax & Currency")

                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    fieldLabel("Tax Rate Override (%)")
                    SPInput("e.g. 8.25", icon: "percent", text: $viewModel.editTaxRate)
                        .keyboardType(.decimalPad)
                }

                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    fieldLabel("Currency Override")
                    SPSelect(
                        "",
                        options: viewModel.currencyOptions,
                        selection: $viewModel.editCurrency
                    )
                }

                // Tax rules toggles (matching Stitch design)
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    fieldLabel("Active Tax Rules")

                    taxRuleRow(label: "Tax on Labor", isEnabled: true)
                    taxRuleRow(label: "Tax on Parts", isEnabled: false)
                }
            }
        }
    }

    private func taxRuleRow(label: String, isEnabled: Bool) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Spacer()

            // Static display toggle (decorative for mock)
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isEnabled ? SpendlyColors.accent : SpendlyColors.secondary.opacity(0.2))
                .frame(width: 44, height: 24)
                .overlay(
                    Circle()
                        .fill(.white)
                        .frame(width: 18, height: 18)
                        .offset(x: isEnabled ? 10 : -10),
                    alignment: .center
                )
        }
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .strokeBorder(SpendlyColors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Technician Section

    private var technicianSection: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                HStack {
                    sectionHeader(icon: "person.2", title: "Assigned Technicians")
                    Spacer()
                    SPBadge(
                        "\(viewModel.editAssignedTechnicians.count) Selected",
                        style: viewModel.editAssignedTechnicians.isEmpty ? .neutral : .info
                    )
                }

                Text("Select technicians to assign to this territory.")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                // Selected technicians chips
                if !viewModel.editAssignedTechnicians.isEmpty {
                    selectedTechnicianChips
                }

                SPDivider()

                // All technicians list
                VStack(spacing: SpendlySpacing.sm) {
                    ForEach(viewModel.allTechnicians) { tech in
                        technicianRow(tech)
                    }
                }
            }
        }
    }

    private var selectedTechnicianChips: some View {
        let selected = viewModel.allTechnicians.filter { viewModel.editAssignedTechnicians.contains($0.id) }
        return FlowLayout(spacing: SpendlySpacing.sm) {
            ForEach(selected) { tech in
                HStack(spacing: SpendlySpacing.xs) {
                    Text(tech.initials)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(SpendlyColors.accent)
                        .clipShape(Circle())

                    Text(tech.name)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Button {
                        viewModel.editAssignedTechnicians.remove(tech.id)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
                .padding(.horizontal, SpendlySpacing.sm)
                .padding(.vertical, SpendlySpacing.xs + 2)
                .background(SpendlyColors.accent.opacity(0.08))
                .clipShape(Capsule())
            }
        }
    }

    private func technicianRow(_ tech: TechnicianStub) -> some View {
        let isSelected = viewModel.editAssignedTechnicians.contains(tech.id)

        return Button {
            if isSelected {
                viewModel.editAssignedTechnicians.remove(tech.id)
            } else {
                viewModel.editAssignedTechnicians.insert(tech.id)
            }
        } label: {
            HStack(spacing: SpendlySpacing.md) {
                // Avatar
                Text(tech.initials)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(isSelected ? SpendlyColors.accent : SpendlyColors.secondary.opacity(0.5))
                    .clipShape(Circle())

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(tech.name)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Text(tech.email)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                }

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? SpendlyColors.accent : SpendlyColors.secondary.opacity(0.3))
            }
            .padding(SpendlySpacing.md)
            .background(
                isSelected
                    ? SpendlyColors.accent.opacity(0.05)
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .strokeBorder(
                        isSelected ? SpendlyColors.accent.opacity(0.2) : SpendlyColors.secondary.opacity(0.1),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Save Section

    private var saveSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            SPButton(
                isEditing ? "Save Changes" : "Create Territory",
                icon: isEditing ? "checkmark" : "plus",
                style: .primary,
                isLoading: viewModel.isSaving
            ) {
                viewModel.saveTerritory()
                onDismiss()
            }
            .disabled(!viewModel.isFormValid)
            .opacity(viewModel.isFormValid ? 1.0 : 0.5)

            if isEditing {
                SPButton("Delete Territory", icon: "trash", style: .destructive) {
                    if let territory = viewModel.selectedTerritory {
                        viewModel.confirmDelete(territory)
                        onDismiss()
                    }
                }
            }
        }
        .padding(.top, SpendlySpacing.sm)
    }

    // MARK: - Reusable Helpers

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: SpendlySpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(SpendlyColors.accent)

            Text(title)
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .bold))
            .tracking(1.2)
            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
    }

    private func currentTimeString(in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "h:mm a zzz"
        return formatter.string(from: Date())
    }
}

// MARK: - FlowLayout

/// Simple horizontal wrapping layout for selected technician chips.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(result.sizes[index])
            )
        }
    }

    private struct ArrangeResult {
        var size: CGSize
        var positions: [CGPoint]
        var sizes: [CGSize]
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> ArrangeResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var sizes: [CGSize] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            sizes.append(size)
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return ArrangeResult(
            size: CGSize(width: maxX, height: y + rowHeight),
            positions: positions,
            sizes: sizes
        )
    }
}

// MARK: - Preview

#Preview("Edit Territory") {
    let vm = TerritoryRegionViewModel()
    let _ = vm.startEditing(MockTerritoryData.territories[0])
    NavigationStack {
        TerritoryDetailView(viewModel: vm, onDismiss: {})
    }
}

#Preview("New Territory") {
    let vm = TerritoryRegionViewModel()
    let _ = vm.startAddingNew()
    NavigationStack {
        TerritoryDetailView(viewModel: vm, onDismiss: {})
    }
}
