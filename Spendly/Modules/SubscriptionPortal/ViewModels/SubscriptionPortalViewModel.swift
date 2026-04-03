import SwiftUI
import SpendlyCore

// MARK: - ViewModel

@Observable
final class SubscriptionPortalViewModel {

    // MARK: - Plan Data

    var currentPlanName: String = ""
    var currentMonthlyTotal: Double = 0
    var paymentStatus: String = ""
    var billingCycle: String = ""
    var nextBillingDate: Date = Date()

    // MARK: - Payment & Billing

    var paymentMethod: SubscriptionPaymentMethod?
    var billingContact: BillingContact?
    var billingModules: [BillingModule] = []

    // MARK: - History

    var invoices: [Invoice] = []
    var transactions: [Transaction] = []

    // MARK: - Plans

    var availablePlans: [SubscriptionPlan] = []
    var annualSavingsAmount: Double = 0
    var annualSavingsMessage: String = ""

    // MARK: - UI State

    var showAllTransactions: Bool = false
    var showPlanComparison: Bool = false
    var showManageModules: Bool = false
    var showUpdateBilling: Bool = false
    var showCustomizePlan: Bool = false
    var showInvoiceDetail: Bool = false
    var showDownloadConfirmation: Bool = false
    var isAnnualToggle: Bool = false

    var selectedInvoice: Invoice?
    var downloadedInvoiceTitle: String = ""

    // MARK: - Computed

    var recentInvoices: [Invoice] {
        Array(invoices.prefix(3))
    }

    var formattedMonthlyTotal: String {
        String(format: "$%.2f", currentMonthlyTotal)
    }

    var formattedNextBillingDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: nextBillingDate)
    }

    var modulesTotal: Double {
        billingModules.filter(\.isActive).reduce(0) { $0 + $1.monthlyCost }
    }

    // MARK: - Init

    init() {
        loadMockData()
    }

    // MARK: - Actions

    func downloadInvoice(_ invoice: Invoice) {
        downloadedInvoiceTitle = invoice.title
        showDownloadConfirmation = true
    }

    func viewInvoiceDetail(_ invoice: Invoice) {
        selectedInvoice = invoice
        showInvoiceDetail = true
    }

    func toggleModule(_ module: BillingModule) {
        guard let index = billingModules.firstIndex(where: { $0.id == module.id }) else { return }
        billingModules[index].isActive.toggle()
    }

    func formattedAmount(_ amount: Double) -> String {
        if amount < 0 {
            return String(format: "-$%.2f", abs(amount))
        }
        return String(format: "$%.2f", amount)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: date)
    }

    func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter.string(from: date)
    }

    func statusColor(for status: SubscriptionInvoiceStatus) -> Color {
        switch status {
        case .paid:     return SpendlyColors.success
        case .pending:  return SpendlyColors.warning
        case .overdue:  return SpendlyColors.error
        case .refunded: return SpendlyColors.info
        }
    }

    func transactionTypeColor(for type: TransactionType) -> Color {
        switch type {
        case .charge:     return SpendlyColors.aeonPrimary
        case .refund:     return SpendlyColors.success
        case .credit:     return SpendlyColors.aeonAccent
        case .adjustment: return SpendlyColors.warning
        }
    }

    func planPrice(_ plan: SubscriptionPlan) -> String {
        if isAnnualToggle {
            return String(format: "$%.2f", plan.annualPrice / 12)
        }
        return String(format: "$%.2f", plan.monthlyPrice)
    }

    func annualSavingsForPlan(_ plan: SubscriptionPlan) -> String {
        let savings = (plan.monthlyPrice * 12) - plan.annualPrice
        return String(format: "$%.0f", savings)
    }

    // MARK: - Mock Data

    private func loadMockData() {
        currentPlanName = SubscriptionPortalMockData.currentPlanName
        currentMonthlyTotal = SubscriptionPortalMockData.currentMonthlyTotal
        paymentStatus = SubscriptionPortalMockData.paymentStatus
        billingCycle = SubscriptionPortalMockData.billingCycle
        nextBillingDate = SubscriptionPortalMockData.nextBillingDate
        paymentMethod = SubscriptionPortalMockData.paymentMethod
        billingContact = SubscriptionPortalMockData.billingContact
        billingModules = SubscriptionPortalMockData.billingModules
        invoices = SubscriptionPortalMockData.invoices
        transactions = SubscriptionPortalMockData.transactions
        availablePlans = SubscriptionPortalMockData.availablePlans
        annualSavingsAmount = SubscriptionPortalMockData.annualSavingsAmount
        annualSavingsMessage = SubscriptionPortalMockData.annualSavingsMessage
    }
}
