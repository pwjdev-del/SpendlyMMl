import SwiftUI
import SpendlyCore

// MARK: - InvoicingBillingViewModel

@Observable
final class InvoicingBillingViewModel {

    // MARK: - Data

    var invoices: [InvoiceDisplayModel] = InvoicingBillingMockData.invoices
    var readyToInvoiceJobs: [ReadyToInvoiceJob] = InvoicingBillingMockData.readyToInvoiceJobs
    var summary: BillingSummary = InvoicingBillingMockData.summary
    var branding: InvoiceBrandingConfig = InvoicingBillingMockData.branding

    // MARK: - UI State

    var searchText: String = ""
    var selectedTab: InvoiceTab = .draft
    var isSearchActive: Bool = false

    // MARK: - Navigation

    var selectedInvoice: InvoiceDisplayModel?
    var showInvoiceDetail: Bool = false
    var showCreateManualInvoice: Bool = false
    var showMoreOptionsFor: InvoiceDisplayModel?
    var showMoreOptions: Bool = false

    // MARK: - Actions State

    var isEmailingInvoice: Bool = false
    var isDownloadingPDF: Bool = false
    var isRecordingPayment: Bool = false
    var showPaymentSheet: Bool = false
    var showEmailConfirmation: Bool = false
    var showPDFSuccess: Bool = false

    // MARK: - Payment Recording

    var paymentAmount: String = ""
    var paymentMethod: PaymentMethod = .creditCard
    var paymentReference: String = ""

    // MARK: - Computed: Filtered Invoices

    var filteredInvoices: [InvoiceDisplayModel] {
        var results = invoices

        // Filter by tab status
        switch selectedTab {
        case .draft:   results = results.filter { $0.status == .draft }
        case .sent:    results = results.filter { $0.status == .sent }
        case .paid:    results = results.filter { $0.status == .paid }
        case .overdue: results = results.filter { $0.status == .overdue }
        }

        // Text search
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            results = results.filter {
                $0.customerName.lowercased().contains(query)
                || $0.invoiceNumber.lowercased().contains(query)
                || $0.jobTitle.lowercased().contains(query)
                || $0.jobNumber.lowercased().contains(query)
            }
        }

        return results
    }

    // MARK: - Tab Counts

    var draftCount: Int {
        invoices.filter { $0.status == .draft }.count
    }

    var sentCount: Int {
        invoices.filter { $0.status == .sent }.count
    }

    var paidCount: Int {
        invoices.filter { $0.status == .paid }.count
    }

    var overdueCount: Int {
        invoices.filter { $0.status == .overdue }.count
    }

    func countForTab(_ tab: InvoiceTab) -> Int {
        switch tab {
        case .draft:   return draftCount
        case .sent:    return sentCount
        case .paid:    return paidCount
        case .overdue: return overdueCount
        }
    }

    // MARK: - Navigation Actions

    func selectInvoice(_ invoice: InvoiceDisplayModel) {
        selectedInvoice = invoice
        showInvoiceDetail = true
    }

    func showOptions(for invoice: InvoiceDisplayModel) {
        showMoreOptionsFor = invoice
        showMoreOptions = true
    }

    // MARK: - Invoice Creation from Job

    func createInvoice(from job: ReadyToInvoiceJob) {
        let invoiceNumber = "INV-2026-\(String(format: "%03d", invoices.count + 43))"

        let lineItems: [InvoiceLineItem]
        if job.partsCost > 0 {
            lineItems = [
                InvoiceLineItem(id: UUID(), itemDescription: "Labor", quantity: 1, unitPrice: job.laborCost),
                InvoiceLineItem(id: UUID(), itemDescription: "Parts & Materials", quantity: 1, unitPrice: job.partsCost)
            ]
        } else {
            lineItems = [
                InvoiceLineItem(id: UUID(), itemDescription: "Service - \(job.jobTitle)", quantity: 1, unitPrice: job.amount)
            ]
        }

        let taxAmount = job.amount * 0.08
        let total = job.amount + taxAmount

        let newInvoice = InvoiceDisplayModel(
            id: UUID(),
            invoiceNumber: invoiceNumber,
            customerName: job.customerName,
            customerAddress: "",
            jobTitle: job.jobTitle,
            jobNumber: job.jobNumber,
            status: .draft,
            subtotal: job.amount,
            laborCost: job.laborCost,
            partsCost: job.partsCost,
            taxRate: 0.08,
            taxAmount: taxAmount,
            total: total,
            dueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            paidAt: nil,
            completedDate: job.completedDate,
            createdAt: Date(),
            notes: nil,
            lineItems: lineItems,
            paymentHistory: []
        )

        invoices.insert(newInvoice, at: 0)
        readyToInvoiceJobs.removeAll { $0.id == job.id }
        selectedTab = .draft

        // Update summary
        summary.totalOutstanding += total
        summary.outstandingCount += 1
    }

    // MARK: - Invoice Actions

    func sendInvoice(_ invoice: InvoiceDisplayModel) {
        guard let index = invoices.firstIndex(where: { $0.id == invoice.id }) else { return }
        invoices[index].status = .sent
    }

    func emailInvoice(_ invoice: InvoiceDisplayModel) {
        isEmailingInvoice = true
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.isEmailingInvoice = false
            self.showEmailConfirmation = true

            // Auto-dismiss confirmation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.showEmailConfirmation = false
            }
        }
    }

    func downloadPDF(_ invoice: InvoiceDisplayModel) {
        isDownloadingPDF = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.isDownloadingPDF = false
            self.showPDFSuccess = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.showPDFSuccess = false
            }
        }
    }

    func recordPayment(for invoice: InvoiceDisplayModel) {
        guard let amount = Double(paymentAmount), amount > 0 else { return }
        guard let index = invoices.firstIndex(where: { $0.id == invoice.id }) else { return }

        let payment = PaymentRecord(
            id: UUID(),
            amount: amount,
            method: paymentMethod,
            date: Date(),
            reference: paymentReference.isEmpty ? nil : paymentReference
        )

        invoices[index].paymentHistory.append(payment)

        // Check if fully paid
        let totalPaid = invoices[index].paymentHistory.reduce(0) { $0 + $1.amount }
        if totalPaid >= invoices[index].total {
            invoices[index].status = .paid
            invoices[index].paidAt = Date()
            summary.totalPaidMTD += invoices[index].total
            summary.paidCount += 1
            summary.totalOutstanding -= invoices[index].total
            summary.outstandingCount -= 1
        }

        // Reset payment form
        paymentAmount = ""
        paymentMethod = .creditCard
        paymentReference = ""
        showPaymentSheet = false

        // Update selected invoice reference
        selectedInvoice = invoices[index]
    }

    func markAsOverdue(_ invoice: InvoiceDisplayModel) {
        guard let index = invoices.firstIndex(where: { $0.id == invoice.id }) else { return }
        invoices[index].status = .overdue
        summary.totalOverdue += invoices[index].total
        summary.overdueCount += 1
    }

    func cancelInvoice(_ invoice: InvoiceDisplayModel) {
        guard let index = invoices.firstIndex(where: { $0.id == invoice.id }) else { return }
        invoices[index].status = .cancelled
        summary.totalOutstanding -= invoices[index].total
        summary.outstandingCount -= 1
    }

    func duplicateInvoice(_ invoice: InvoiceDisplayModel) {
        var copy = invoice
        copy = InvoiceDisplayModel(
            id: UUID(),
            invoiceNumber: "INV-2026-\(String(format: "%03d", invoices.count + 43))",
            customerName: invoice.customerName,
            customerAddress: invoice.customerAddress,
            jobTitle: invoice.jobTitle,
            jobNumber: invoice.jobNumber,
            status: .draft,
            subtotal: invoice.subtotal,
            laborCost: invoice.laborCost,
            partsCost: invoice.partsCost,
            taxRate: invoice.taxRate,
            taxAmount: invoice.taxAmount,
            total: invoice.total,
            dueDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()),
            paidAt: nil,
            completedDate: invoice.completedDate,
            createdAt: Date(),
            notes: invoice.notes,
            lineItems: invoice.lineItems,
            paymentHistory: []
        )
        invoices.insert(copy, at: 0)
    }

    // MARK: - Formatters

    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}
