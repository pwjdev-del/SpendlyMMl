import SwiftUI
import SpendlyCore

struct InitiateTransferView: View {
    @Bindable var vm: AssetTransferViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Step indicator
                stepIndicator

                SPScreenWrapper {
                    VStack(spacing: SpendlySpacing.lg) {
                        // Success state
                        if vm.transferComplete {
                            transferSuccessView
                        } else {
                            // Wizard steps
                            switch vm.currentStep {
                            case .selectMachine:
                                selectMachineStep
                            case .selectOwner:
                                selectOwnerStep
                            case .preAudit:
                                preAuditStep
                            case .confirmation:
                                confirmationStep
                            }
                        }
                    }
                }

                // Bottom navigation bar
                if !vm.transferComplete {
                    bottomBar
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Initiate Transfer")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        vm.dismissSheet()
                    } label: {
                        Image(systemName: SpendlyIcon.close.systemName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
            }
            .alert("Confirm Transfer", isPresented: $vm.showConfirmationAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Transfer Now", role: .destructive) {
                    vm.executeTransfer()
                }
            } message: {
                Text("This action will transfer ownership of \(vm.selectedMachine?.name ?? "this machine") to \(vm.selectedCustomer?.name ?? "the new owner"). The previous owner will lose access immediately. This cannot be undone.")
            }
        }
    }

    // MARK: - Step Indicator

    private var stepIndicator: some View {
        VStack(spacing: SpendlySpacing.sm) {
            HStack(spacing: SpendlySpacing.xs) {
                ForEach(TransferWizardStep.allCases, id: \.rawValue) { step in
                    stepDot(step)
                }
            }
            Text("Step \(vm.currentStep.stepNumber) of \(TransferWizardStep.totalSteps): \(vm.currentStep.title)")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
        }
        .padding(.vertical, SpendlySpacing.md)
        .padding(.horizontal, SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    private func stepDot(_ step: TransferWizardStep) -> some View {
        RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
            .fill(stepColor(for: step))
            .frame(height: 4)
            .frame(maxWidth: .infinity)
    }

    private func stepColor(for step: TransferWizardStep) -> Color {
        if step.rawValue < vm.currentStep.rawValue {
            return SpendlyColors.success
        } else if step == vm.currentStep {
            return SpendlyColors.primary
        } else {
            return SpendlyColors.secondary.opacity(0.2)
        }
    }

    // MARK: - Step 1: Select Machine

    private var selectMachineStep: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("Select the machine to transfer")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            Text("Search by name, model, or serial number to find the machine in the vault.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)

            SPSearchBar(searchText: $vm.machineSearchText)

            ForEach(vm.filteredMachines) { machine in
                machineRow(machine)
            }

            if vm.filteredMachines.isEmpty {
                noResultsView("No machines match your search.")
            }
        }
    }

    private func machineRow(_ machine: MachineOption) -> some View {
        let isSelected = vm.selectedMachine == machine
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                vm.selectedMachine = isSelected ? nil : machine
            }
        } label: {
            SPCard(elevation: isSelected ? .medium : .low) {
                HStack(spacing: SpendlySpacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                            .fill(SpendlyColors.primary.opacity(0.1))
                            .frame(width: 44, height: 44)
                        Image(systemName: "gearshape.2")
                            .font(.system(size: 18))
                            .foregroundStyle(SpendlyColors.primary)
                    }

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(machine.name)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        HStack(spacing: SpendlySpacing.sm) {
                            Text("S/N: \(machine.serialNumber)")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                            Text("Owner: \(machine.currentOwner)")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: SpendlyIcon.checkCircle.systemName)
                            .foregroundStyle(SpendlyColors.success)
                            .font(.system(size: 20))
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(
                        isSelected ? SpendlyColors.primary : .clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 2: Select New Owner

    private var selectOwnerStep: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("Select the new owner")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            Text("Search and select the customer who will receive this machine.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)

            if let machine = vm.selectedMachine {
                SPCard(elevation: .low, padding: SpendlySpacing.md) {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "gearshape.2")
                            .font(.system(size: 14))
                            .foregroundStyle(SpendlyColors.primary)
                        Text(machine.name)
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Spacer()
                        SPBadge(machine.model, style: .info)
                    }
                }
            }

            SPSearchBar(searchText: $vm.customerSearchText)

            ForEach(vm.filteredCustomers) { customer in
                customerRow(customer)
            }

            if vm.filteredCustomers.isEmpty {
                noResultsView("No customers match your search.")
            }
        }
    }

    private func customerRow(_ customer: TransferCustomerOption) -> some View {
        let isSelected = vm.selectedCustomer == customer
        let isCurrentOwner = vm.selectedMachine?.currentOwner == customer.name

        return Button {
            guard !isCurrentOwner else { return }
            withAnimation(.easeInOut(duration: 0.15)) {
                vm.selectedCustomer = isSelected ? nil : customer
            }
        } label: {
            SPCard(elevation: isSelected ? .medium : .low) {
                HStack(spacing: SpendlySpacing.md) {
                    SPAvatar(initials: vm.initials(for: customer.name), size: .md)

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(customer.name)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(
                                isCurrentOwner
                                    ? SpendlyColors.secondary
                                    : SpendlyColors.foreground(for: colorScheme)
                            )
                        HStack(spacing: SpendlySpacing.sm) {
                            Text(customer.contactName)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                            Text("\(customer.city), \(customer.state)")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                    }

                    Spacer()

                    if isCurrentOwner {
                        SPBadge("Current Owner", style: .neutral)
                    } else if isSelected {
                        Image(systemName: SpendlyIcon.checkCircle.systemName)
                            .foregroundStyle(SpendlyColors.success)
                            .font(.system(size: 20))
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(
                        isSelected ? SpendlyColors.primary : .clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
        .opacity(isCurrentOwner ? 0.6 : 1.0)
    }

    // MARK: - Step 3: Pre-Transfer Audit

    private var preAuditStep: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("Pre-Transfer Audit")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            Text("Optionally run an audit to document the machine's condition before transferring ownership.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)

            SPCard(elevation: .low) {
                VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text("Include Pre-Transfer Audit")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text("Creates a snapshot of machine health and condition at the time of transfer.")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: $vm.includePreTransferAudit)
                            .tint(SpendlyColors.primary)
                            .labelsHidden()
                    }

                    if vm.includePreTransferAudit {
                        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                            Text("Audit Notes (Optional)")
                                .font(SpendlyFont.bodyMedium())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            TextEditor(text: $vm.auditNotes)
                                .font(SpendlyFont.body())
                                .frame(minHeight: 100)
                                .padding(SpendlySpacing.sm)
                                .background(SpendlyColors.surface(for: colorScheme))
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                        .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }

            // Info callout
            SPCard(elevation: .low, padding: SpendlySpacing.md) {
                HStack(alignment: .top, spacing: SpendlySpacing.sm) {
                    Image(systemName: SpendlyIcon.info.systemName)
                        .font(.system(size: 14))
                        .foregroundStyle(SpendlyColors.info)
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("What gets audited?")
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("Assembly ratings, efficiency scores, uptime impact, and overall machine health will be captured in an immutable record attached to this transfer.")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: vm.includePreTransferAudit)
    }

    // MARK: - Step 4: Confirmation

    private var confirmationStep: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("Review and Confirm")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            Text("Review the transfer details below. Once confirmed, the previous owner will lose access to this machine immediately.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)

            // Machine summary
            SPCard(elevation: .medium) {
                VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                    HStack {
                        Text("Machine")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                        Spacer()
                    }
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "gearshape.2")
                            .font(.system(size: 16))
                            .foregroundStyle(SpendlyColors.primary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(vm.selectedMachine?.name ?? "")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text("S/N: \(vm.selectedMachine?.serialNumber ?? "") | Model: \(vm.selectedMachine?.model ?? "")")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                    }
                }
            }

            // Transfer direction
            SPCard(elevation: .medium) {
                VStack(spacing: SpendlySpacing.lg) {
                    // From
                    HStack(spacing: SpendlySpacing.md) {
                        SPAvatar(
                            initials: vm.initials(for: vm.selectedMachine?.currentOwner ?? ""),
                            size: .md
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("From")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                            Text(vm.selectedMachine?.currentOwner ?? "")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        }
                        Spacer()
                        SPBadge("Current Owner", style: .neutral)
                    }

                    // Arrow
                    HStack {
                        Spacer()
                        Image(systemName: "arrow.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(SpendlyColors.accent)
                            .frame(width: 32, height: 32)
                            .background(SpendlyColors.accent.opacity(0.1))
                            .clipShape(Circle())
                        Spacer()
                    }

                    // To
                    HStack(spacing: SpendlySpacing.md) {
                        SPAvatar(
                            initials: vm.initials(for: vm.selectedCustomer?.name ?? ""),
                            size: .md,
                            statusDot: SpendlyColors.success
                        )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("To")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                            Text(vm.selectedCustomer?.name ?? "")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text("\(vm.selectedCustomer?.city ?? ""), \(vm.selectedCustomer?.state ?? "")")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                        Spacer()
                        SPBadge("New Owner", style: .success)
                    }
                }
            }

            // Audit info
            if vm.includePreTransferAudit {
                SPCard(elevation: .low, padding: SpendlySpacing.md) {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "checkmark.shield")
                            .font(.system(size: 14))
                            .foregroundStyle(SpendlyColors.info)
                        Text("Pre-transfer audit will be included")
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Spacer()
                        SPBadge("Audit", style: .info)
                    }
                }
            }

            // Data migration notice
            SPCard(elevation: .low, padding: SpendlySpacing.md) {
                HStack(alignment: .top, spacing: SpendlySpacing.sm) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14))
                        .foregroundStyle(SpendlyColors.success)
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("Full History Migration")
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("All service trips, audits, incidents, and photos will carry over to the new owner. Expense reports remain OEM-internal.")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }

            // Warning
            SPCard(elevation: .low, padding: SpendlySpacing.md) {
                HStack(alignment: .top, spacing: SpendlySpacing.sm) {
                    Image(systemName: SpendlyIcon.warning.systemName)
                        .font(.system(size: 14))
                        .foregroundStyle(SpendlyColors.warning)
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("Irreversible Action")
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("The current owner will lose access to this machine immediately after transfer. The chain of custody log is immutable and cannot be edited.")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Transfer Success

    private var transferSuccessView: some View {
        VStack(spacing: SpendlySpacing.xl) {
            Spacer().frame(height: SpendlySpacing.xxxl)

            ZStack {
                Circle()
                    .fill(SpendlyColors.success.opacity(0.1))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(SpendlyColors.success)
            }

            Text("Transfer Initiated")
                .font(SpendlyFont.title())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Text("\(vm.selectedMachine?.name ?? "Machine") is now being transferred to \(vm.selectedCustomer?.name ?? "the new owner").")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
                .multilineTextAlignment(.center)

            SPCard(elevation: .low, padding: SpendlySpacing.md) {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    summaryRow("Machine", vm.selectedMachine?.name ?? "")
                    summaryRow("From", vm.selectedMachine?.currentOwner ?? "")
                    summaryRow("To", vm.selectedCustomer?.name ?? "")
                    summaryRow("Status", "Pending")
                    if vm.includePreTransferAudit {
                        summaryRow("Audit", "Included")
                    }
                }
            }

            SPButton("Done", icon: "checkmark", style: .primary) {
                vm.dismissSheet()
            }
        }
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
                .frame(width: 70, alignment: .leading)
            Text(value)
                .font(SpendlyFont.bodyMedium())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            Spacer()
        }
    }

    // MARK: - No Results

    private func noResultsView(_ message: String) -> some View {
        VStack(spacing: SpendlySpacing.md) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
            Text(message)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SpendlySpacing.xxl)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: SpendlySpacing.md) {
            if vm.currentStep != .selectMachine {
                SPButton("Back", icon: "chevron.left", style: .secondary) {
                    vm.goBack()
                }
            }

            if vm.currentStep == .confirmation {
                SPButton(
                    "Confirm Transfer",
                    icon: "arrow.left.arrow.right",
                    style: .primary,
                    isLoading: vm.isConfirming
                ) {
                    vm.confirmTransfer()
                }
            } else {
                SPButton("Continue", icon: "chevron.right", style: .primary) {
                    vm.advance()
                }
                .opacity(vm.canAdvance ? 1.0 : 0.5)
                .disabled(!vm.canAdvance)
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
    }
}

#Preview {
    InitiateTransferView(vm: AssetTransferViewModel())
}
