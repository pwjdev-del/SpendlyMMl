import SwiftUI
import SpendlyCore

struct DiagnosticWizardView: View {
    @Bindable var viewModel: AIDiagnosticsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Bar
                ProgressView(value: viewModel.wizardProgress)
                    .tint(SpendlyColors.primary)
                    .padding(.horizontal, SpendlySpacing.md)
                    .padding(.top, SpendlySpacing.sm)

                // Step Title
                Text(viewModel.currentWizardStep.title)
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(SpendlySpacing.md)

                // Step Content
                ScrollView {
                    stepContent
                        .padding(SpendlySpacing.md)
                }

                // Navigation Buttons
                HStack(spacing: SpendlySpacing.md) {
                    if viewModel.currentWizardStep != .systemSelection {
                        Button {
                            viewModel.previousWizardStep()
                        } label: {
                            Label("Back", systemImage: "chevron.left")
                                .font(SpendlyFont.headline())
                                .frame(maxWidth: .infinity)
                                .padding(SpendlySpacing.sm)
                        }
                        .buttonStyle(.bordered)
                    }

                    if viewModel.currentWizardStep == .impact {
                        Button {
                            viewModel.submitDiagnosticReport()
                            dismiss()
                        } label: {
                            Text("Submit Report")
                                .font(SpendlyFont.headline())
                                .frame(maxWidth: .infinity)
                                .padding(SpendlySpacing.sm)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SpendlyColors.primary)
                    } else {
                        Button {
                            viewModel.nextWizardStep()
                        } label: {
                            Label("Next", systemImage: "chevron.right")
                                .font(SpendlyFont.headline())
                                .frame(maxWidth: .infinity)
                                .padding(SpendlySpacing.sm)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SpendlyColors.primary)
                        .disabled(!viewModel.canProceedWizard)
                    }
                }
                .padding(SpendlySpacing.md)
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Step Content

    @ViewBuilder
    private var stepContent: some View {
        switch viewModel.currentWizardStep {
        case .systemSelection:
            systemSelectionStep
        case .componentSelection:
            componentSelectionStep
        case .symptoms:
            symptomsStep
        case .evidence:
            evidenceStep
        case .impact:
            impactStep
        }
    }

    // MARK: - System Selection

    private var systemSelectionStep: some View {
        LazyVStack(spacing: SpendlySpacing.sm) {
            ForEach(viewModel.systemTypes) { systemType in
                Button {
                    viewModel.selectSystemType(systemType)
                } label: {
                    HStack(spacing: SpendlySpacing.md) {
                        Image(systemName: systemType.icon)
                            .font(.title2)
                            .foregroundStyle(viewModel.selectedSystemType == systemType ? SpendlyColors.primary : SpendlyColors.secondary)
                            .frame(width: 40)
                        Text(systemType.name)
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Spacer()
                        if viewModel.selectedSystemType == systemType {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(SpendlyColors.primary)
                        }
                    }
                    .padding(SpendlySpacing.md)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.large)
                            .stroke(viewModel.selectedSystemType == systemType ? SpendlyColors.primary : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Component Selection

    private var componentSelectionStep: some View {
        LazyVStack(spacing: SpendlySpacing.sm) {
            ForEach(viewModel.components) { component in
                Button {
                    viewModel.selectedComponent = component
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(component.name)
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text(component.detail)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                        Spacer()
                        if viewModel.selectedComponent == component {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(SpendlyColors.primary)
                        }
                    }
                    .padding(SpendlySpacing.md)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.large)
                            .stroke(viewModel.selectedComponent == component ? SpendlyColors.primary : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Symptoms

    private var symptomsStep: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            // Symptom Chips
            FlowLayout(spacing: SpendlySpacing.sm) {
                ForEach(viewModel.symptomChips) { chip in
                    Button {
                        viewModel.toggleSymptomChip(chipID: chip.id)
                    } label: {
                        Text(chip.name)
                            .font(SpendlyFont.caption())
                            .padding(.horizontal, SpendlySpacing.md)
                            .padding(.vertical, SpendlySpacing.sm)
                            .background(chip.isSelected ? SpendlyColors.primary.opacity(0.15) : SpendlyColors.surface(for: colorScheme))
                            .foregroundStyle(chip.isSelected ? SpendlyColors.primary : SpendlyColors.foreground(for: colorScheme))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(chip.isSelected ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.3), lineWidth: 1))
                    }
                }
            }

            // Detail Description
            Text("Additional Details")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            TextEditor(text: $viewModel.detailDescription)
                .frame(minHeight: 80)
                .font(SpendlyFont.body())
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                        .stroke(SpendlyColors.secondary.opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: - Evidence

    private var evidenceStep: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            Text("Upload photos or videos of the issue.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)

            HStack(spacing: SpendlySpacing.md) {
                ForEach(0..<viewModel.uploadedPhotoCount, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                        .fill(SpendlyColors.surface(for: colorScheme))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(SpendlyColors.secondary)
                        )
                }

                if viewModel.uploadedPhotoCount < viewModel.maxPhotos {
                    Button {
                        viewModel.uploadedPhotoCount += 1
                    } label: {
                        RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                            .foregroundStyle(SpendlyColors.secondary)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "plus")
                                    .foregroundStyle(SpendlyColors.primary)
                            )
                    }
                }
            }

            Text("\(viewModel.uploadedPhotoCount)/\(viewModel.maxPhotos) photos uploaded")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
        }
    }

    // MARK: - Impact

    private var impactStep: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            Text("Select the urgency level for this issue.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)

            ForEach(UrgencyLevel.allCases) { level in
                Button {
                    viewModel.selectedUrgency = level
                } label: {
                    HStack {
                        Text(level.rawValue)
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Spacer()
                        if viewModel.selectedUrgency == level {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(SpendlyColors.primary)
                        }
                    }
                    .padding(SpendlySpacing.md)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.large)
                            .stroke(viewModel.selectedUrgency == level ? SpendlyColors.primary : Color.clear, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Flow Layout Helper

private struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(in: bounds.width, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(in maxWidth: CGFloat, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
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
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
