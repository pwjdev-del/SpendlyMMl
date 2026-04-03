import SwiftUI
import SpendlyCore

struct NewTicketFormView: View {

    @Bindable var viewModel: TicketManagementViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: FormField?

    private enum FormField: Hashable {
        case title
        case description
    }

    // Form step tracking
    @State private var currentStep: Int = 1
    private let totalSteps: Int = 5

    var body: some View {
        NavigationStack {
            ZStack {
                SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: SpendlySpacing.xl) {
                        progressIndicator
                        categorySection
                        machineSection
                        descriptionSection
                        mediaSection
                        urgencySection
                        actionButtons
                        footerNote
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.bottom, SpendlySpacing.xxxl * 2)
                }

                // Success overlay
                if viewModel.showSubmitSuccess {
                    successOverlay
                }
            }
            .navigationTitle("Report New Issue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.resetNewTicketForm()
                        dismiss()
                    } label: {
                        Image(systemName: SpendlyIcon.close.systemName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Help action
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        HStack(spacing: SpendlySpacing.md) {
            ForEach(1...totalSteps, id: \.self) { step in
                HStack(spacing: SpendlySpacing.sm) {
                    Circle()
                        .fill(stepColor(for: step))
                        .frame(width: 10, height: 10)

                    if step < totalSteps {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(step < currentStep ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.2))
                            .frame(height: 2)
                    }
                }
            }
        }
        .padding(.vertical, SpendlySpacing.lg)
        .padding(.horizontal, SpendlySpacing.xl)
        .background(
            SpendlyColors.surface(for: colorScheme).opacity(0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    private func stepColor(for step: Int) -> Color {
        if step <= currentStep {
            return SpendlyColors.primary
        }
        return SpendlyColors.secondary.opacity(0.3)
    }

    // MARK: - Category Section (Step 1)

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            stepHeader(number: 1, title: "Issue Category")

            // Category chips - Electrical/Mechanical/Pneumatic/Other
            VStack(spacing: SpendlySpacing.sm) {
                ForEach(TicketCategory.allCases, id: \.self) { category in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.newTicketCategory = category.rawValue
                            if currentStep < 2 { currentStep = 2 }
                        }
                    } label: {
                        HStack(spacing: SpendlySpacing.md) {
                            Image(systemName: category.icon)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(category.color)
                                .frame(width: 36, height: 36)
                                .background(category.color.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                            Text(category.rawValue)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            Spacer()

                            if viewModel.newTicketCategory == category.rawValue {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(category.color)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 20))
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.3))
                            }
                        }
                        .padding(SpendlySpacing.md)
                        .background(
                            viewModel.newTicketCategory == category.rawValue
                                ? category.color.opacity(0.06)
                                : SpendlyColors.surface(for: colorScheme)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                                .strokeBorder(
                                    viewModel.newTicketCategory == category.rawValue
                                        ? category.color.opacity(0.5)
                                        : SpendlyColors.secondary.opacity(0.1),
                                    lineWidth: viewModel.newTicketCategory == category.rawValue ? 2 : 1
                                )
                        )
                    }
                }
            }

            // Subcategory chips (contextual based on selected category)
            if !viewModel.newTicketCategory.isEmpty {
                subcategoryChips
            }
        }
    }

    private var subcategoryChips: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("Sub-category (optional)")
                .font(SpendlyFont.caption())
                .fontWeight(.semibold)
                .foregroundStyle(SpendlyColors.secondary)
                .textCase(.uppercase)
                .tracking(0.5)

            let subcategories = subcategoriesFor(viewModel.newTicketCategory)
            let chipColor = TicketCategory.allCases.first(where: { $0.rawValue == viewModel.newTicketCategory })?.color ?? SpendlyColors.secondary

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpendlySpacing.sm) {
                    ForEach(subcategories, id: \.self) { sub in
                        Text(sub)
                            .font(.system(size: 12, weight: .medium))
                            .padding(.horizontal, SpendlySpacing.md)
                            .padding(.vertical, SpendlySpacing.sm)
                            .foregroundStyle(chipColor)
                            .background(chipColor.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private func subcategoriesFor(_ category: String) -> [String] {
        switch category {
        case "Electrical":
            return ["Servo & Drive Faults", "Control Logic", "Wiring & Connectors", "PLC / HMI"]
        case "Mechanical":
            return ["Seal Array Failure", "Web & Film Handling", "Bearings & Gearbox", "Blade / Cutter"]
        case "Pneumatic":
            return ["Cylinder Failures", "Air Supply", "Valve Assembly", "Pressure Regulation"]
        case "Other":
            return ["Operator Cabin", "Safety Systems", "Structural", "Cosmetic"]
        default:
            return []
        }
    }

    // MARK: - Machine Section (Step 2)

    private var machineSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            stepHeader(number: 2, title: "Machine & Customer")

            SPSelect(
                "Machine",
                options: [
                    "CNC-900 Machining Center (SN: CNC900-4821)",
                    "Vega 285 PM (SN: V285-1190-PM)",
                    "ConvertPro 750P (SN: CP750-3305-TRB)",
                    "BF-3200 Blown Film Line (SN: BF32-0078-CX)",
                    "SP-60 Sachet Machine (SN: SP60-5512-ML)",
                ],
                selection: $viewModel.newTicketMachine
            )
            .onChange(of: viewModel.newTicketMachine) { _, _ in
                if currentStep < 3 { currentStep = 3 }
            }

            SPSelect(
                "Customer",
                options: [
                    "Industrial Logistics Corp.",
                    "Pacific Foods Inc.",
                    "Global Wrap Solutions",
                ],
                selection: $viewModel.newTicketCustomer
            )
        }
    }

    // MARK: - Description Section (Step 3)

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            stepHeader(number: 3, title: "Issue Description")

            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Title")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                SPInput(
                    "Brief issue title",
                    icon: "textformat",
                    text: $viewModel.newTicketTitle
                )
                .focused($focusedField, equals: .title)
                .onChange(of: viewModel.newTicketTitle) { _, _ in
                    if currentStep < 4 { currentStep = 4 }
                }
            }

            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Symptom Description")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                TextEditor(text: $viewModel.newTicketDescription)
                    .font(SpendlyFont.body())
                    .frame(minHeight: 120)
                    .padding(SpendlySpacing.sm)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                            .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .focused($focusedField, equals: .description)
                    .overlay(alignment: .topLeading) {
                        if viewModel.newTicketDescription.isEmpty {
                            Text("Describe what happened, any error codes shown, and when it occurred...")
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                                .padding(.horizontal, SpendlySpacing.md)
                                .padding(.vertical, SpendlySpacing.md)
                                .allowsHitTesting(false)
                        }
                    }
            }
        }
    }

    // MARK: - Media Section (Step 4)

    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            stepHeader(number: 4, title: "Media Upload")

            SPPhotoGrid(
                images: [],
                onAdd: {
                    // Camera / photo picker trigger
                    if currentStep < 5 { currentStep = 5 }
                },
                onRemove: { _ in }
            )

            Text("Up to 5 photos or videos. Max file size 20MB.")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
                .italic()
        }
    }

    // MARK: - Urgency Section (Step 5)

    private var urgencySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            stepHeader(number: 5, title: "Priority Level")

            HStack(spacing: SpendlySpacing.sm) {
                ForEach(TicketUrgency.allCases, id: \.self) { urgency in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.newTicketUrgency = urgency.rawValue
                        }
                    } label: {
                        VStack(spacing: SpendlySpacing.sm) {
                            Image(systemName: urgency.icon)
                                .font(.system(size: 20))
                                .foregroundStyle(urgencyColor(urgency))

                            Text(urgency.rawValue)
                                .font(SpendlyFont.caption())
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    viewModel.newTicketUrgency == urgency.rawValue
                                        ? urgencyColor(urgency)
                                        : SpendlyColors.foreground(for: colorScheme)
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SpendlySpacing.md)
                        .background(
                            viewModel.newTicketUrgency == urgency.rawValue
                                ? urgencyColor(urgency).opacity(0.1)
                                : SpendlyColors.surface(for: colorScheme)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous)
                                .strokeBorder(
                                    viewModel.newTicketUrgency == urgency.rawValue
                                        ? urgencyColor(urgency)
                                        : SpendlyColors.secondary.opacity(0.1),
                                    lineWidth: viewModel.newTicketUrgency == urgency.rawValue ? 2 : 1
                                )
                        )
                    }
                }
            }
        }
    }

    private func urgencyColor(_ urgency: TicketUrgency) -> Color {
        switch urgency {
        case .low:      return SpendlyColors.success
        case .medium:   return SpendlyColors.warning
        case .high:     return SpendlyColors.error
        case .critical: return colorScheme == .dark ? .white : .black
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: SpendlySpacing.md) {
            SPDivider()

            HStack(spacing: SpendlySpacing.md) {
                // Save Draft
                Button {
                    viewModel.saveDraft()
                } label: {
                    Text("Save Draft")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SpendlySpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous)
                                .strokeBorder(SpendlyColors.primary, lineWidth: 2)
                        )
                }

                // Submit Issue
                Button {
                    viewModel.submitNewTicket()
                } label: {
                    HStack(spacing: SpendlySpacing.sm) {
                        if viewModel.isSubmittingTicket {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Submit Issue")
                                .font(SpendlyFont.bodySemibold())
                            Image(systemName: SpendlyIcon.send.systemName)
                                .font(.system(size: 14, weight: .semibold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous)
                            .fill(isFormValid ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.3))
                    )
                    .shadow(color: isFormValid ? SpendlyColors.primary.opacity(0.3) : .clear, radius: 8, y: 4)
                }
                .disabled(!isFormValid || viewModel.isSubmittingTicket)
            }
        }
        .padding(.top, SpendlySpacing.lg)
    }

    private var isFormValid: Bool {
        !viewModel.newTicketTitle.isEmpty && !viewModel.newTicketCategory.isEmpty
    }

    // MARK: - Footer Note

    private var footerNote: some View {
        Text("Our support team typically responds within 4 hours for high-priority issues.")
            .font(SpendlyFont.caption())
            .foregroundStyle(SpendlyColors.secondary.opacity(0.6))
            .multilineTextAlignment(.center)
            .padding(.vertical, SpendlySpacing.lg)
    }

    // MARK: - Success Overlay

    private var successOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: SpendlySpacing.xl) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(SpendlyColors.success)

                Text("Ticket Submitted!")
                    .font(SpendlyFont.title())
                    .foregroundStyle(.white)

                Text("Your issue has been logged and our team has been notified.")
                    .font(SpendlyFont.body())
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding(SpendlySpacing.xxxl)
        }
        .transition(.opacity)
    }

    // MARK: - Step Header Helper

    private func stepHeader(number: Int, title: String) -> some View {
        HStack(spacing: SpendlySpacing.md) {
            Text("\(number)")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(number <= currentStep ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.3))
                )

            Text(title)
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
        }
    }
}

// MARK: - Previews

#Preview("New Ticket Form - Light") {
    NewTicketFormView(viewModel: TicketManagementViewModel())
        .preferredColorScheme(.light)
}

#Preview("New Ticket Form - Dark") {
    NewTicketFormView(viewModel: TicketManagementViewModel())
        .preferredColorScheme(.dark)
}
