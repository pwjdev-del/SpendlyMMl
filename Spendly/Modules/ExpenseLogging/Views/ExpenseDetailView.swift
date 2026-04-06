import SwiftUI
import SpendlyCore

struct ExpenseDetailView: View {
    @Bindable var vm: ExpenseLoggingViewModel
    let expenseID: UUID
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    /// Always reads the latest version of the expense from the view model.
    private var expense: ExpenseDisplayItem {
        vm.expenses.first(where: { $0.id == expenseID })
            ?? ExpenseDisplayItem(
                id: expenseID,
                title: "Unknown",
                amount: 0,
                category: .other,
                projectName: "",
                date: Date(),
                status: .pending,
                receiptURL: nil,
                rejectionReason: nil,
                reimbursedDate: nil
            )
    }

    var body: some View {
        NavigationStack {
            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.xl) {
                    // Status & Amount Header
                    headerSection

                    // Expense Info Card
                    infoCard

                    // Edit Section (only for pending/rejected)
                    if vm.canEditSelectedExpense {
                        editSection
                    }

                    // Rejection Reason (if rejected)
                    if expense.status == .rejected, let reason = expense.rejectionReason {
                        rejectionCard(reason)
                    }

                    // Reimbursement Info (if reimbursed)
                    if expense.status == .reimbursed {
                        reimbursedCard
                    }

                    // Action Buttons
                    actionButtons

                    Spacer(minLength: SpendlySpacing.xxxl)
                }
            }
            .navigationTitle("Expense Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            ZStack {
                Circle()
                    .fill(SpendlyColors.primary.opacity(0.1))
                    .frame(width: 64, height: 64)
                Image(systemName: ExpenseLoggingMockData.categoryIcon(expense.category))
                    .font(.system(size: 28))
                    .foregroundStyle(SpendlyColors.primary)
            }

            Text(vm.formatAmount(expense.amount))
                .font(SpendlyFont.largeTitle())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            SPBadge(
                vm.statusLabel(for: expense.status),
                style: vm.badgeStyle(for: expense.status)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SpendlySpacing.md)
    }

    // MARK: - Info Card

    private var infoCard: some View {
        SPCard(elevation: .low) {
            VStack(spacing: SpendlySpacing.lg) {
                infoRow(icon: "tag.fill", label: "Title", value: expense.title)
                SPDivider()
                infoRow(icon: "folder.fill", label: "Category",
                        value: ExpenseLoggingMockData.categoryDisplayName(expense.category))
                SPDivider()
                infoRow(icon: "building.2.fill", label: "Project", value: expense.projectName)
                SPDivider()
                infoRow(icon: "calendar", label: "Date", value: vm.formatFullDate(expense.date))

                if expense.receiptURL != nil {
                    SPDivider()
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(SpendlyColors.primary)
                            .frame(width: 20)
                        Text("Receipt")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                        Spacer()
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(SpendlyColors.success)
                            Text("Attached")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.success)
                        }
                    }
                }
            }
        }
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: SpendlySpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(SpendlyColors.primary)
                .frame(width: 20)
            Text(label)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
            Spacer()
            Text(value)
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .lineLimit(1)
        }
    }

    // MARK: - Edit Section

    private var editSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("EDIT EXPENSE")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .tracking(1.2)
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            SPInput("Expense title", icon: "pencil", text: $vm.editTitle)

            // Amount
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Amount")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                HStack(spacing: 0) {
                    Text("$")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.secondary)
                        .frame(width: 28)

                    TextField("0.00", text: $vm.editAmountText)
                        .font(.custom("Inter-Bold", size: 18))
                        .keyboardType(.decimalPad)
                }
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.md)
                .frame(height: 56)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                )
            }

            SPSelect("Category", options: vm.categoryOptions, selection: $vm.editCategory)
            SPSelect("Project", options: vm.projectOptions, selection: $vm.editProject)

            SPButton("Save Changes", icon: "checkmark", style: .primary) {
                vm.saveEdit()
            }
        }
    }

    // MARK: - Rejection Card

    private func rejectionCard(_ reason: String) -> some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(SpendlyColors.error)
                    Text("Rejection Reason")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.error)
                }
                Text(reason)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
        }
    }

    // MARK: - Reimbursed Card

    private var reimbursedCard: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundStyle(SpendlyColors.info)
                    Text("Reimbursement")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.info)
                }
                if let reimbDate = expense.reimbursedDate {
                    Text("Reimbursed on \(vm.formatFullDate(reimbDate))")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                } else {
                    Text("This expense has been reimbursed.")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Manager actions for pending expenses
            if expense.status == .pending {
                HStack(spacing: SpendlySpacing.md) {
                    SPButton("Approve", icon: "checkmark.circle", style: .primary) {
                        vm.approveExpense(expense)
                        dismiss()
                    }

                    SPButton("Reject", icon: "xmark.circle", style: .destructive) {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            vm.beginReject(expense)
                        }
                    }
                }
            }

            // Reimbursement for approved expenses
            if expense.status == .approved {
                SPButton("Mark as Reimbursed", icon: "dollarsign.circle", style: .accent) {
                    vm.markReimbursed(expense)
                    dismiss()
                }
            }

            // Delete (always available)
            SPButton("Delete Expense", icon: "trash", style: .ghost) {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    vm.confirmDelete(expense)
                }
            }
        }
    }
}

#Preview {
    ExpenseDetailView(
        vm: ExpenseLoggingViewModel(),
        expenseID: ExpenseLoggingMockData.sampleExpenses[0].id
    )
}
