import SwiftUI
import SpendlyCore

struct EstimateApprovalView: View {
    @Bindable var vm: ClientApprovalViewModel
    let estimate: EstimateApprovalItem

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header

            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.xxl) {
                    // Branding & Status
                    brandingSection

                    // Tasks & Labor
                    if !estimate.laborItems.isEmpty {
                        lineItemSection(title: "Tasks & Labor", items: estimate.laborItems)
                    }

                    // Materials
                    if !estimate.materialItems.isEmpty {
                        lineItemSection(title: "Materials", items: estimate.materialItems)
                    }

                    // Cost Summary
                    costSummary

                    // Client Approval Section
                    if estimate.status == .pending {
                        approvalSection
                    }
                }
            }
        }
        .alert("Decline Estimate", isPresented: $vm.showingRejectConfirmation) {
            TextField("Reason (optional)", text: $vm.rejectionReason)
            Button("Cancel", role: .cancel) { }
            Button("Decline", role: .destructive) {
                vm.rejectEstimate()
            }
        } message: {
            Text("Are you sure you want to decline \(estimate.estimateNumber)? This action cannot be undone.")
        }
        .sheet(isPresented: $vm.showingRequestChanges) {
            requestChangesSheet
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: SpendlySpacing.md) {
            Button {
                dismiss()
            } label: {
                Image(systemName: SpendlyIcon.arrowBack.systemName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            HStack(spacing: SpendlySpacing.md) {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(SpendlyColors.accent)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "doc.text")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(estimate.estimateNumber)
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text("Issued \(vm.formatDate(estimate.issuedDate))")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                        .textCase(.uppercase)
                }
            }

            Spacer()

            Button {
                // Download action placeholder
            } label: {
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 18))
                    .foregroundStyle(SpendlyColors.secondary)
                    .frame(width: 40, height: 40)
                    .background(SpendlyColors.background(for: colorScheme))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Branding & Status Section

    private var brandingSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            HStack(spacing: SpendlySpacing.md) {
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .fill(SpendlyColors.background(for: colorScheme))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(SpendlyColors.accent)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Service Platform")
                        .font(SpendlyFont.title())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text(estimate.projectTitle)
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                Spacer()
            }

            HStack(spacing: SpendlySpacing.lg) {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundStyle(SpendlyColors.secondary)
                    Text("Valid until \(vm.formatDate(estimate.validUntilDate))")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "person")
                        .font(.system(size: 14))
                        .foregroundStyle(SpendlyColors.secondary)
                    Text(estimate.customerName)
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                }
            }

            HStack {
                Spacer()
                SPBadge(
                    vm.statusLabel(for: estimate.status),
                    style: vm.badgeStyle(for: estimate.status)
                )
            }

            SPDivider()
        }
    }

    // MARK: - Line Item Section

    private func lineItemSection(title: String, items: [EstimateLineItem]) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            Text(title)
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(SpendlyColors.secondary)
                .textCase(.uppercase)
                .tracking(1.5)

            VStack(spacing: 0) {
                ForEach(items) { item in
                    lineItemRow(item)

                    if item.id != items.last?.id {
                        SPDivider()
                    }
                }
            }

            SPDivider()
        }
    }

    private func lineItemRow(_ item: EstimateLineItem) -> some View {
        HStack(alignment: .center, spacing: SpendlySpacing.md) {
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .fill(SpendlyColors.background(for: colorScheme))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: item.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(SpendlyColors.secondary)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(item.task)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Text(item.description)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Text(vm.formatCurrency(item.total))
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .monospacedDigit()
        }
        .padding(.vertical, SpendlySpacing.md)
    }

    // MARK: - Cost Summary

    private var costSummary: some View {
        SPCard(elevation: .low, padding: SpendlySpacing.xl) {
            VStack(spacing: SpendlySpacing.md) {
                HStack {
                    Text("Subtotal")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                    Spacer()
                    Text(vm.formatCurrency(estimate.subtotal))
                        .font(SpendlyFont.bodyMedium())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .monospacedDigit()
                }

                HStack {
                    Text("Estimated Tax (\(estimate.taxPercentageLabel))")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                    Spacer()
                    Text(vm.formatCurrency(estimate.taxAmount))
                        .font(SpendlyFont.bodyMedium())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .monospacedDigit()
                }

                SPDivider()
                    .padding(.top, SpendlySpacing.sm)

                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total Estimate")
                            .font(SpendlyFont.caption())
                            .fontWeight(.bold)
                            .foregroundStyle(SpendlyColors.accent)
                            .textCase(.uppercase)
                        Text(vm.formatCurrency(estimate.grandTotal))
                            .font(SpendlyFont.financialTitle())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .monospacedDigit()
                    }

                    Spacer()

                    Text("Includes labor and materials listed above.")
                        .font(.system(size: 10))
                        .foregroundStyle(SpendlyColors.secondary)
                        .multilineTextAlignment(.trailing)
                        .frame(maxWidth: 140)
                }
            }
        }
    }

    // MARK: - Approval Section

    private var approvalSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Client Approval")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Text("Please review the details above. By signing and clicking approve, you agree to the terms of service and project scope.")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            // Comments
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Comments (optional)")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                TextEditor(text: $vm.commentText)
                    .font(SpendlyFont.body())
                    .frame(minHeight: 80)
                    .padding(SpendlySpacing.sm)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                            .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                    )
            }

            // Digital Signature
            #if canImport(UIKit)
            SPSignatureCapture(signature: $vm.signatureImage)
            #endif

            // Terms checkbox
            HStack(spacing: SpendlySpacing.sm) {
                Button {
                    vm.agreedToTerms.toggle()
                } label: {
                    Image(systemName: vm.agreedToTerms ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundStyle(vm.agreedToTerms ? SpendlyColors.accent : SpendlyColors.secondary)
                }

                Text("I agree to the ")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
                + Text("Terms & Conditions")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.accent)
            }

            // Action Buttons
            VStack(spacing: SpendlySpacing.md) {
                // Approve
                SPButton("Approve Estimate", icon: "checkmark.circle", style: .primary, isLoading: vm.isProcessing) {
                    vm.approveEstimate()
                }
                .disabled(!vm.canApprove)
                .opacity(vm.canApprove ? 1.0 : 0.5)

                HStack(spacing: SpendlySpacing.md) {
                    // Reject
                    Button {
                        vm.showingRejectConfirmation = true
                    } label: {
                        HStack(spacing: SpendlySpacing.sm) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Decline")
                                .font(SpendlyFont.bodySemibold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SpendlySpacing.md)
                        .padding(.horizontal, SpendlySpacing.lg)
                        .foregroundStyle(SpendlyColors.error)
                        .background(SpendlyColors.error.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }

                    // Request Changes
                    Button {
                        vm.showingRequestChanges = true
                    } label: {
                        HStack(spacing: SpendlySpacing.sm) {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Changes")
                                .font(SpendlyFont.bodySemibold())
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SpendlySpacing.md)
                        .padding(.horizontal, SpendlySpacing.lg)
                        .foregroundStyle(SpendlyColors.warning)
                        .background(SpendlyColors.warning.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }
                }
            }
            .padding(.top, SpendlySpacing.md)
            .padding(.bottom, SpendlySpacing.xxxl)
        }
    }

    // MARK: - Request Changes Sheet

    private var requestChangesSheet: some View {
        NavigationStack {
            VStack(spacing: SpendlySpacing.xl) {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("What changes would you like?")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text("Describe the modifications you need for \(estimate.estimateNumber). The service team will revise and resubmit.")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                }

                TextEditor(text: $vm.changesRequestText)
                    .font(SpendlyFont.body())
                    .frame(minHeight: 150)
                    .padding(SpendlySpacing.sm)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                            .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                    )

                SPButton(
                    "Submit Change Request",
                    icon: "paperplane.fill",
                    style: .primary,
                    isLoading: vm.isProcessing
                ) {
                    vm.requestChanges()
                }
                .disabled(vm.changesRequestText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(vm.changesRequestText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)

                Spacer()
            }
            .padding(SpendlySpacing.lg)
            .background(SpendlyColors.background(for: colorScheme))
            .navigationTitle("Request Changes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.showingRequestChanges = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Preview

#Preview {
    let vm = ClientApprovalViewModel()
    EstimateApprovalView(
        vm: vm,
        estimate: ClientApprovalMockData.sampleEstimates[0]
    )
}
