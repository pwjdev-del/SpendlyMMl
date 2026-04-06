import SwiftUI
import PhotosUI
import SpendlyCore

public struct ExpenseLoggingRootView: View {
    @State private var vm = ExpenseLoggingViewModel()
    @State private var showAllExpenses = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var receiptImage: Image?
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            SPHeader(title: "Log Expense")

            ScrollView {
                VStack(spacing: 0) {
                    // Quick Capture Section
                    quickCaptureSection

                    // Form Section
                    formSection

                    // Recent Submissions
                    recentSubmissionsSection
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .sheet(item: $vm.selectedExpense) { expense in
            ExpenseDetailView(vm: vm, expenseID: expense.id)
        }
        .sheet(isPresented: $vm.showingRejectSheet) {
            rejectSheet
        }
        .alert("Expense Submitted", isPresented: $vm.showingSubmitConfirmation) {
            Button("OK", role: .cancel) {
                receiptImage = nil
                selectedPhotoItem = nil
            }
        } message: {
            Text("Your expense has been submitted for approval.")
        }
        .alert("Delete Expense", isPresented: $vm.showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                vm.expenseToDelete = nil
            }
            Button("Delete", role: .destructive) {
                vm.executeDelete()
            }
        } message: {
            Text("Are you sure you want to delete this expense? This action cannot be undone.")
        }
    }

    // MARK: - Quick Capture Section

    private var quickCaptureSection: some View {
        VStack(spacing: 0) {
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                VStack(spacing: SpendlySpacing.md) {
                    ZStack {
                        Circle()
                            .fill(SpendlyColors.primary)
                            .frame(width: 56, height: 56)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: SpendlyColors.primary.opacity(0.3), radius: 8, y: 4)

                    Text("Capture Receipt")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.primary)

                    Text("AI will automatically extract details")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpendlySpacing.xxl)
                .background(SpendlyColors.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                        .strokeBorder(
                            SpendlyColors.primary.opacity(0.3),
                            style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                        )
                )
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            }
            .buttonStyle(.plain)
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    if let newItem,
                       let data = try? await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        receiptImage = Image(uiImage: uiImage)
                        vm.hasReceipt = true
                    }
                }
            }

            if vm.hasReceipt, let receiptImage {
                VStack(spacing: SpendlySpacing.sm) {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(SpendlyColors.success)
                            .font(.system(size: 14))
                        Text("Receipt captured")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.success)
                        Spacer()
                        Button {
                            vm.hasReceipt = false
                            self.receiptImage = nil
                            selectedPhotoItem = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(SpendlyColors.secondary)
                                .font(.system(size: 14))
                        }
                    }
                    .padding(.top, SpendlySpacing.sm)

                    receiptImage
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .strokeBorder(SpendlyColors.secondary.opacity(0.15), lineWidth: 1)
                        )
                }
            }
        }
        .padding(SpendlySpacing.lg)
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("EXPENSE DETAILS")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .tracking(1.2)
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            // Amount Field
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Amount")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                HStack(spacing: 0) {
                    Text("$")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.secondary)
                        .frame(width: 28)

                    TextField("0.00", text: $vm.amountText)
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

            // Category Dropdown
            SPSelect("Category", options: vm.categoryOptions, selection: $vm.selectedCategory)

            // Project Dropdown
            SPSelect("Project", options: vm.projectOptions, selection: $vm.selectedProject)

            // Submit Button
            SPButton("Submit Expense", icon: "paperplane.fill", style: .primary) {
                vm.submitExpense()
            }
            .opacity(vm.isFormValid ? 1.0 : 0.5)
            .disabled(!vm.isFormValid)
            .padding(.top, SpendlySpacing.sm)
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.bottom, SpendlySpacing.xxl)
    }

    // MARK: - Recent Submissions Section

    private var recentSubmissionsSection: some View {
        VStack(spacing: SpendlySpacing.md) {
            HStack {
                Text("RECENT SUBMISSIONS")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .tracking(1.2)
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showAllExpenses.toggle()
                    }
                } label: {
                    Text(showAllExpenses ? "Show Less" : "View All")
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(SpendlyColors.primary)
                }
            }

            if vm.expenses.isEmpty {
                emptyState
            } else {
                let visibleExpenses = showAllExpenses
                    ? vm.expenses
                    : Array(vm.expenses.prefix(5))
                ForEach(visibleExpenses) { expense in
                    expenseCard(expense)
                }
            }
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.background(for: colorScheme))
    }

    // MARK: - Expense Card

    private func expenseCard(_ expense: ExpenseDisplayItem) -> some View {
        Button {
            vm.openDetail(expense)
        } label: {
            HStack(spacing: SpendlySpacing.lg) {
                // Category Icon
                ZStack {
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .fill(SpendlyColors.primary.opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: ExpenseLoggingMockData.categoryIcon(expense.category))
                        .font(.system(size: 18))
                        .foregroundStyle(SpendlyColors.primary)
                }

                // Details
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    HStack {
                        Text(expense.title)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .lineLimit(1)
                        Spacer()
                        Text(vm.formatAmount(expense.amount))
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }

                    HStack {
                        Text("\(expense.projectName) \u{2022} \(vm.formatShortDate(expense.date))")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                            .lineLimit(1)
                        Spacer()
                        SPBadge(
                            vm.statusLabel(for: expense.status),
                            style: vm.badgeStyle(for: expense.status)
                        )
                    }
                }
            }
            .padding(SpendlySpacing.lg)
            .background(SpendlyColors.surface(for: colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                    .strokeBorder(SpendlyColors.secondary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            if expense.status == .pending {
                Button {
                    vm.approveExpense(expense)
                } label: {
                    Label("Approve", systemImage: "checkmark.circle")
                }

                Button {
                    vm.beginReject(expense)
                } label: {
                    Label("Reject", systemImage: "xmark.circle")
                }
            }

            if expense.status == .approved {
                Button {
                    vm.markReimbursed(expense)
                } label: {
                    Label("Mark Reimbursed", systemImage: "dollarsign.circle")
                }
            }

            if expense.status == .pending || expense.status == .rejected {
                Button {
                    vm.openDetail(expense)
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }

            Button(role: .destructive) {
                vm.confirmDelete(expense)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: SpendlySpacing.lg) {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 40))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
            Text("No Expenses Yet")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            Text("Submit your first expense using the form above.")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SpendlySpacing.xxxl)
    }

    // MARK: - Reject Sheet

    private var rejectSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
                if let expense = vm.expenseToReject {
                    HStack(spacing: SpendlySpacing.md) {
                        ZStack {
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .fill(SpendlyColors.primary.opacity(0.1))
                                .frame(width: 44, height: 44)
                            Image(systemName: ExpenseLoggingMockData.categoryIcon(expense.category))
                                .font(.system(size: 18))
                                .foregroundStyle(SpendlyColors.primary)
                        }
                        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                            Text(expense.title)
                                .font(SpendlyFont.bodySemibold())
                            Text(vm.formatAmount(expense.amount))
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Reason for Rejection")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    TextEditor(text: $vm.rejectionReason)
                        .font(SpendlyFont.body())
                        .frame(minHeight: 120)
                        .padding(SpendlySpacing.sm)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                        )
                }

                SPButton("Reject Expense", icon: "xmark.circle", style: .destructive) {
                    vm.executeReject()
                }

                Spacer()
            }
            .padding(SpendlySpacing.lg)
            .navigationTitle("Reject Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.showingRejectSheet = false
                        vm.expenseToReject = nil
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    ExpenseLoggingRootView()
}
