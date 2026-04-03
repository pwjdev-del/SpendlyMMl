import Foundation
import SwiftUI
import SpendlyCore

// MARK: - View Model

@Observable
final class ExpenseLoggingViewModel {

    // MARK: Expense List

    var expenses: [ExpenseDisplayItem] = ExpenseLoggingMockData.sampleExpenses

    var recentExpenses: [ExpenseDisplayItem] {
        Array(expenses.prefix(10))
    }

    // MARK: Form State

    var amountText: String = ""
    var selectedCategory: String = ""
    var selectedProject: String = ""
    var hasReceipt: Bool = false

    var isFormValid: Bool {
        guard let amount = Double(amountText), amount > 0 else { return false }
        return !selectedCategory.isEmpty && !selectedProject.isEmpty
    }

    // MARK: Detail / Edit State

    var selectedExpense: ExpenseDisplayItem?
    var showingDetail: Bool = false

    var editTitle: String = ""
    var editAmountText: String = ""
    var editCategory: String = ""
    var editProject: String = ""

    // MARK: Manager Approval

    var showingRejectSheet: Bool = false
    var rejectionReason: String = ""
    var expenseToReject: ExpenseDisplayItem?

    // MARK: Alerts

    var showingSubmitConfirmation: Bool = false
    var showingDeleteConfirmation: Bool = false
    var expenseToDelete: ExpenseDisplayItem?

    // MARK: Dropdown Options

    var categoryOptions: [String] {
        ExpenseLoggingMockData.categories.map {
            ExpenseLoggingMockData.categoryDisplayName($0)
        }
    }

    var projectOptions: [String] {
        ExpenseLoggingMockData.projects.map { $0.name }
    }

    // MARK: Actions — Submit

    func submitExpense() {
        guard let amount = Double(amountText), amount > 0 else { return }
        guard let category = resolveCategory(from: selectedCategory) else { return }

        let newExpense = ExpenseDisplayItem(
            id: UUID(),
            title: titleForCategory(category),
            amount: amount,
            category: category,
            projectName: selectedProject,
            date: Date(),
            status: .pending,
            receiptURL: hasReceipt ? "receipt_new.jpg" : nil,
            rejectionReason: nil,
            reimbursedDate: nil
        )

        withAnimation(.easeInOut(duration: 0.25)) {
            expenses.insert(newExpense, at: 0)
        }

        resetForm()
        showingSubmitConfirmation = true
    }

    func resetForm() {
        amountText = ""
        selectedCategory = ""
        selectedProject = ""
        hasReceipt = false
    }

    // MARK: Actions — Edit

    func openDetail(_ expense: ExpenseDisplayItem) {
        selectedExpense = expense
        editTitle = expense.title
        editAmountText = String(format: "%.2f", expense.amount)
        editCategory = ExpenseLoggingMockData.categoryDisplayName(expense.category)
        editProject = expense.projectName
        showingDetail = true
    }

    func saveEdit() {
        guard let expense = selectedExpense else { return }
        guard let idx = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        guard let amount = Double(editAmountText), amount > 0 else { return }
        guard let category = resolveCategory(from: editCategory) else { return }

        expenses[idx].title = editTitle.isEmpty ? titleForCategory(category) : editTitle
        expenses[idx].amount = amount
        expenses[idx].category = category
        expenses[idx].projectName = editProject

        showingDetail = false
        selectedExpense = nil
    }

    var canEditSelectedExpense: Bool {
        guard let expense = selectedExpense else { return false }
        return expense.status == .pending || expense.status == .rejected
    }

    // MARK: Actions — Delete

    func confirmDelete(_ expense: ExpenseDisplayItem) {
        expenseToDelete = expense
        showingDeleteConfirmation = true
    }

    func executeDelete() {
        guard let expense = expenseToDelete else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            expenses.removeAll { $0.id == expense.id }
        }
        expenseToDelete = nil
        showingDeleteConfirmation = false

        // Dismiss detail if the deleted expense was open
        if selectedExpense?.id == expense.id {
            showingDetail = false
            selectedExpense = nil
        }
    }

    // MARK: Actions — Manager Approval

    func approveExpense(_ expense: ExpenseDisplayItem) {
        guard let idx = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            expenses[idx].status = .approved
        }
    }

    func beginReject(_ expense: ExpenseDisplayItem) {
        expenseToReject = expense
        rejectionReason = ""
        showingRejectSheet = true
    }

    func executeReject() {
        guard let expense = expenseToReject else { return }
        guard let idx = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            expenses[idx].status = .rejected
            expenses[idx].rejectionReason = rejectionReason.isEmpty ? "No reason provided" : rejectionReason
        }
        showingRejectSheet = false
        expenseToReject = nil
        rejectionReason = ""
    }

    // MARK: Actions — Reimbursement

    func markReimbursed(_ expense: ExpenseDisplayItem) {
        guard let idx = expenses.firstIndex(where: { $0.id == expense.id }) else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            expenses[idx].status = .reimbursed
            expenses[idx].reimbursedDate = Date()
        }
    }

    // MARK: Formatting

    func badgeStyle(for status: ExpenseStatus) -> SPBadgeStyle {
        switch status {
        case .pending:    return .warning
        case .approved:   return .success
        case .rejected:   return .error
        case .reimbursed: return .info
        }
    }

    func statusLabel(for status: ExpenseStatus) -> String {
        switch status {
        case .pending:    return "Pending"
        case .approved:   return "Approved"
        case .rejected:   return "Rejected"
        case .reimbursed: return "Reimbursed"
        }
    }

    func formatAmount(_ amount: Double) -> String {
        String(format: "$%.2f", amount)
    }

    static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    static let fullDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f
    }()

    func formatShortDate(_ date: Date) -> String {
        Self.shortDateFormatter.string(from: date)
    }

    func formatFullDate(_ date: Date) -> String {
        Self.fullDateFormatter.string(from: date)
    }

    // MARK: Helpers

    private func resolveCategory(from displayName: String) -> ExpenseCategory? {
        ExpenseLoggingMockData.categories.first {
            ExpenseLoggingMockData.categoryDisplayName($0) == displayName
        }
    }

    private func titleForCategory(_ category: ExpenseCategory) -> String {
        switch category {
        case .mileage:               return "Mileage Claim"
        case .partsAndMaterials:     return "Parts Purchase"
        case .mealsAndEntertainment: return "Meal Expense"
        case .travel:                return "Travel Expense"
        case .other:                 return "Expense"
        }
    }
}
