import SwiftUI
import SpendlyCore

// MARK: - EstimateEditorView

struct EstimateEditorView: View {

    @Bindable var viewModel: EstimateBuilderViewModel
    let editingEstimate: EstimateDisplayModel?

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            // Main scrollable content
            ScrollView {
                VStack(spacing: SpendlySpacing.xl) {
                    // MARK: Customer Selection Section
                    customerSelectionSection

                    // MARK: Valid Until Date Section
                    validUntilSection

                    // MARK: Tasks & Services Section
                    tasksSection

                    // MARK: Pricing Breakdown
                    pricingBreakdownSection

                    // Spacer for footer
                    Color.clear.frame(height: 120)
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.top, SpendlySpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SpendlyColors.background(for: colorScheme))

            // MARK: Sticky Footer
            stickyFooter
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(editingEstimate != nil ? "Edit Estimate" : "Create Estimate")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        viewModel.saveAsTemplate()
                    } label: {
                        Label("Save as Template", systemImage: "doc.badge.plus")
                    }
                    Button {
                        viewModel.saveAsDraft()
                    } label: {
                        Label("Save as Draft", systemImage: "square.and.pencil")
                    }
                } label: {
                    Image(systemName: SpendlyIcon.moreVert.systemName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(SpendlyColors.primary)
                }
            }
        }
        .sheet(isPresented: $viewModel.showTaskTemplatePicker) {
            TaskTemplatePickerSheet(viewModel: viewModel)
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Customer Selection Section

    private var customerSelectionSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            // Section header
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: SpendlyIcon.person.systemName)
                    .foregroundStyle(SpendlyColors.primary)
                    .font(.system(size: 18))

                Text("Customer Selection")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            // Customer picker card
            SPCard(elevation: .low) {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Search and Select Customer")
                        .font(SpendlyFont.bodyMedium())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                    Menu {
                        ForEach(viewModel.customers) { customer in
                            Button {
                                viewModel.editorSelectedCustomerID = customer.id
                            } label: {
                                HStack {
                                    Text(customer.displayLabel)
                                    if customer.id == viewModel.editorSelectedCustomerID {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: SpendlySpacing.sm) {
                            Image(systemName: SpendlyIcon.search.systemName)
                                .foregroundStyle(SpendlyColors.secondary)

                            Text(viewModel.selectedCustomerName.isEmpty
                                 ? "Select a customer..."
                                 : viewModel.selectedCustomerName)
                                .font(SpendlyFont.body())
                                .foregroundStyle(
                                    viewModel.selectedCustomerName.isEmpty
                                    ? SpendlyColors.secondary
                                    : SpendlyColors.foreground(for: colorScheme)
                                )
                                .lineLimit(1)

                            Spacer()

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12))
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                        .padding(.horizontal, SpendlySpacing.md)
                        .padding(.vertical, SpendlySpacing.md)
                        .background(SpendlyColors.background(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Valid Until Date Section

    private var validUntilSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: "calendar.badge.clock")
                    .foregroundStyle(SpendlyColors.primary)
                    .font(.system(size: 18))

                Text("Valid Until")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            SPCard(elevation: .low) {
                HStack {
                    Text("Expiration Date")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                    Spacer()

                    DatePicker(
                        "",
                        selection: $viewModel.editorExpiresAt,
                        in: Date()...,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .tint(SpendlyColors.primary)
                }
            }
        }
    }

    // MARK: - Tasks & Services Section

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            // Section header
            HStack {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "wrench.and.screwdriver")
                        .foregroundStyle(SpendlyColors.primary)
                        .font(.system(size: 18))

                    Text("Tasks & Services")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }

                Spacer()

                Button {
                    viewModel.showTaskTemplatePicker = true
                } label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: SpendlyIcon.addCircle.systemName)
                            .font(.system(size: 16))
                        Text("Add Task")
                            .font(SpendlyFont.bodySemibold())
                    }
                    .foregroundStyle(SpendlyColors.primary)
                }
            }

            // Task cards
            if viewModel.editorTasks.isEmpty {
                // Empty state dashed button
                addTaskDashedButton
            } else {
                VStack(spacing: SpendlySpacing.md) {
                    ForEach(viewModel.editorTasks) { task in
                        TaskCardView(task: task) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                viewModel.deleteTask(task)
                            }
                        }
                    }

                    // Dashed "add another" button
                    addTaskDashedButton
                }
            }
        }
    }

    // MARK: - Add Task Dashed Button

    private var addTaskDashedButton: some View {
        Button {
            viewModel.showTaskTemplatePicker = true
        } label: {
            VStack(spacing: SpendlySpacing.sm) {
                Image(systemName: SpendlyIcon.addCircle.systemName)
                    .font(.system(size: 28))
                Text("Add another service or task")
                    .font(SpendlyFont.bodyMedium())
            }
            .foregroundStyle(SpendlyColors.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.xxl)
            .background(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(
                        SpendlyColors.secondary.opacity(0.3),
                        style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                    )
            )
        }
    }

    // MARK: - Pricing Breakdown Section

    private var pricingBreakdownSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: "dollarsign.circle")
                    .foregroundStyle(SpendlyColors.primary)
                    .font(.system(size: 18))

                Text("Pricing Breakdown")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            SPCard(elevation: .low) {
                VStack(spacing: SpendlySpacing.md) {
                    pricingRow(label: "Subtotal", value: viewModel.editorSubtotal)

                    // Tax rate
                    HStack {
                        Text("Tax (\(Int(viewModel.editorTaxRate * 100))%)")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        Spacer()
                        Text(formatCurrency(viewModel.editorTaxAmount))
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }

                    // Discount
                    if viewModel.editorDiscountPercent > 0 {
                        HStack {
                            Text("Discount (\(Int(viewModel.editorDiscountPercent * 100))%)")
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.success)
                            Spacer()
                            Text("-\(formatCurrency(viewModel.editorDiscountAmount))")
                                .font(SpendlyFont.bodyMedium())
                                .foregroundStyle(SpendlyColors.success)
                        }
                    }

                    SPDivider()

                    // Tax rate picker
                    HStack {
                        Text("Tax Rate")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                        Spacer()
                        Menu {
                            Button("0%") { viewModel.editorTaxRate = 0.0 }
                            Button("5%") { viewModel.editorTaxRate = 0.05 }
                            Button("6%") { viewModel.editorTaxRate = 0.06 }
                            Button("7%") { viewModel.editorTaxRate = 0.07 }
                            Button("8%") { viewModel.editorTaxRate = 0.08 }
                            Button("10%") { viewModel.editorTaxRate = 0.10 }
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(Int(viewModel.editorTaxRate * 100))%")
                                    .font(SpendlyFont.bodyMedium())
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10))
                            }
                            .foregroundStyle(SpendlyColors.primary)
                        }
                    }

                    // Discount picker
                    HStack {
                        Text("Discount")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                        Spacer()
                        Menu {
                            Button("None") { viewModel.editorDiscountPercent = 0.0 }
                            Button("5%") { viewModel.editorDiscountPercent = 0.05 }
                            Button("10%") { viewModel.editorDiscountPercent = 0.10 }
                            Button("15%") { viewModel.editorDiscountPercent = 0.15 }
                            Button("20%") { viewModel.editorDiscountPercent = 0.20 }
                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.editorDiscountPercent > 0
                                     ? "\(Int(viewModel.editorDiscountPercent * 100))%"
                                     : "None")
                                    .font(SpendlyFont.bodyMedium())
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 10))
                            }
                            .foregroundStyle(SpendlyColors.primary)
                        }
                    }
                }
            }
        }
    }

    private func pricingRow(label: String, value: Double) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            Spacer()
            Text(formatCurrency(value))
                .font(SpendlyFont.bodyMedium())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
    }

    // MARK: - Sticky Footer

    private var stickyFooter: some View {
        VStack(spacing: 0) {
            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TOTAL ESTIMATED AMOUNT")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(1)
                        .foregroundStyle(SpendlyColors.secondary)

                    Text(formatCurrency(viewModel.editorGrandTotal))
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }

                Spacer()

                Button {
                    viewModel.generateEstimate()
                } label: {
                    HStack(spacing: SpendlySpacing.sm) {
                        if viewModel.isGenerating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "doc.plaintext")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Text(viewModel.isGenerating ? "Generating..." : "Generate Estimate")
                            .font(SpendlyFont.bodySemibold())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.vertical, SpendlySpacing.md)
                    .background(SpendlyColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }
                .disabled(viewModel.isGenerating || viewModel.editorTasks.isEmpty)
                .opacity(viewModel.editorTasks.isEmpty ? 0.5 : 1.0)
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.md)
            .background(
                SpendlyColors.surface(for: colorScheme)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: -4)
            )
        }
    }

    // MARK: - Currency Formatter

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()

    private func formatCurrency(_ value: Double) -> String {
        Self.currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Task Card View

private struct TaskCardView: View {
    let task: EstimateTaskItem
    let onDelete: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SPCard(elevation: .medium, padding: 0) {
            HStack(spacing: 0) {
                // Left image area
                taskImageArea

                // Right content area
                VStack(alignment: .leading, spacing: 0) {
                    // Top: title + delete
                    HStack(alignment: .top) {
                        Text(task.name)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .lineLimit(1)

                        Spacer()

                        Button(action: onDelete) {
                            Image(systemName: SpendlyIcon.delete.systemName)
                                .font(.system(size: 14))
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                    }

                    // Description
                    Text(task.description)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        .lineLimit(2)
                        .padding(.top, SpendlySpacing.xs)

                    Spacer(minLength: SpendlySpacing.sm)

                    // Bottom: hours/rate + total
                    SPDivider()
                        .padding(.vertical, SpendlySpacing.sm)

                    HStack {
                        Text("Est: \(formatHours(task.estimatedHours)) Hours | Rate: \(formatRate(task.hourlyRate))/hr")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(SpendlyColors.secondary)

                        Spacer()

                        Text(formatCurrency(task.lineTotal))
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
                .padding(SpendlySpacing.md)
            }
        }
        .frame(minHeight: 120)
    }

    // MARK: - Task Image Area

    private var taskImageArea: some View {
        Rectangle()
            .fill(SpendlyColors.primary.opacity(0.08))
            .frame(width: 100)
            .overlay(
                VStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: task.imageName)
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(SpendlyColors.primary.opacity(0.6))
                }
            )
    }

    // MARK: - Formatters

    private static let rateFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter
    }()

    private func formatHours(_ hours: Double) -> String {
        hours.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", hours)
            : String(format: "%.1f", hours)
    }

    private func formatRate(_ rate: Double) -> String {
        Self.rateFormatter.string(from: NSNumber(value: rate)) ?? "$0"
    }

    private func formatCurrency(_ value: Double) -> String {
        Self.currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}

// MARK: - Task Template Picker Sheet

private struct TaskTemplatePickerSheet: View {
    @Bindable var viewModel: EstimateBuilderViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: SpendlySpacing.md) {
                    ForEach(viewModel.taskTemplates) { template in
                        Button {
                            viewModel.addTaskFromTemplate(template)
                            dismiss()
                        } label: {
                            templateRow(template)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(SpendlySpacing.lg)
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(SpendlyFont.bodyMedium())
                    .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
    }

    private func templateRow(_ template: TaskTemplate) -> some View {
        SPCard(elevation: .low) {
            HStack(spacing: SpendlySpacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .fill(SpendlyColors.primary.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: template.imageName)
                        .font(.system(size: 20))
                        .foregroundStyle(SpendlyColors.primary)
                }

                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text(template.name)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Text(template.description)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        .lineLimit(2)

                    HStack(spacing: SpendlySpacing.md) {
                        Text("\(formatHours(template.defaultHours)) hrs")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.accent)

                        Text("\(formatRate(template.defaultRate))/hr")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.accent)
                    }
                }

                Spacer()

                Image(systemName: SpendlyIcon.addCircle.systemName)
                    .font(.system(size: 22))
                    .foregroundStyle(SpendlyColors.primary)
            }
        }
    }

    private func formatHours(_ hours: Double) -> String {
        hours.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", hours)
            : String(format: "%.1f", hours)
    }

    private static let rateFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    private func formatRate(_ rate: Double) -> String {
        Self.rateFormatter.string(from: NSNumber(value: rate)) ?? "$0"
    }
}

// MARK: - Previews

#Preview("Editor - New") {
    NavigationStack {
        EstimateEditorView(
            viewModel: {
                let vm = EstimateBuilderViewModel()
                vm.editorTasks = [
                    EstimateBuilderMockData.estimates[0].tasks[0],
                    EstimateBuilderMockData.estimates[0].tasks[1]
                ]
                vm.editorSelectedCustomerID = EstimateBuilderMockData.customers[0].id
                return vm
            }(),
            editingEstimate: nil
        )
    }
}

#Preview("Editor - Empty") {
    NavigationStack {
        EstimateEditorView(
            viewModel: EstimateBuilderViewModel(),
            editingEstimate: nil
        )
    }
}

#Preview("Editor - Dark") {
    NavigationStack {
        EstimateEditorView(
            viewModel: {
                let vm = EstimateBuilderViewModel()
                vm.editorTasks = Array(EstimateBuilderMockData.estimates[1].tasks)
                return vm
            }(),
            editingEstimate: nil
        )
    }
    .preferredColorScheme(.dark)
}
