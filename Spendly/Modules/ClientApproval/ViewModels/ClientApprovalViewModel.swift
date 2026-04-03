import Foundation
import SwiftUI
import SpendlyCore

#if canImport(UIKit)
import UIKit
#endif

// MARK: - View Model

@Observable
final class ClientApprovalViewModel {

    // MARK: Estimate List

    var estimates: [EstimateApprovalItem] = ClientApprovalMockData.sampleEstimates
    var searchText: String = ""

    var filteredEstimates: [EstimateApprovalItem] {
        guard !searchText.isEmpty else { return estimates }
        let query = searchText.lowercased()
        return estimates.filter {
            $0.estimateNumber.lowercased().contains(query) ||
            $0.customerName.lowercased().contains(query) ||
            $0.projectTitle.lowercased().contains(query)
        }
    }

    var pendingEstimates: [EstimateApprovalItem] {
        filteredEstimates.filter { $0.status == .pending }
    }

    var completedEstimates: [EstimateApprovalItem] {
        filteredEstimates.filter { $0.status != .pending }
    }

    // MARK: Detail / Approval State

    var selectedEstimate: EstimateApprovalItem?
    var showingDetail: Bool = false

    var commentText: String = ""
    var agreedToTerms: Bool = false

    #if canImport(UIKit)
    var signatureImage: UIImage?
    #endif

    var isProcessing: Bool = false

    // MARK: Success State

    var showingSuccess: Bool = false
    var lastApprovedEstimate: EstimateApprovalItem?
    var assignedTeam: AssignedTeam = ClientApprovalMockData.eliteTeam

    // MARK: Request Changes State

    var showingRequestChanges: Bool = false
    var changesRequestText: String = ""

    // MARK: Reject State

    var showingRejectConfirmation: Bool = false
    var rejectionReason: String = ""

    // MARK: Navigation

    func openEstimate(_ estimate: EstimateApprovalItem) {
        selectedEstimate = estimate
        resetApprovalForm()
        showingDetail = true
    }

    func dismissDetail() {
        showingDetail = false
        resetApprovalForm()
    }

    // MARK: Validation

    var canApprove: Bool {
        #if canImport(UIKit)
        return agreedToTerms && signatureImage != nil
        #else
        return agreedToTerms
        #endif
    }

    // MARK: Actions

    func approveEstimate() {
        guard let estimate = selectedEstimate, canApprove else { return }
        isProcessing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self else { return }
            // Update status in list
            if let idx = self.estimates.firstIndex(where: { $0.id == estimate.id }) {
                let updated = EstimateApprovalItem(
                    id: estimate.id,
                    estimateNumber: estimate.estimateNumber,
                    issuedDate: estimate.issuedDate,
                    validUntilDate: estimate.validUntilDate,
                    customerName: estimate.customerName,
                    customerEmail: estimate.customerEmail,
                    projectTitle: estimate.projectTitle,
                    status: .approved,
                    laborItems: estimate.laborItems,
                    materialItems: estimate.materialItems,
                    taxRate: estimate.taxRate
                )
                self.estimates[idx] = updated
            }
            self.lastApprovedEstimate = estimate
            self.isProcessing = false
            self.showingDetail = false
            self.showingSuccess = true
        }
    }

    func rejectEstimate() {
        guard let estimate = selectedEstimate else { return }
        isProcessing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            if let idx = self.estimates.firstIndex(where: { $0.id == estimate.id }) {
                let updated = EstimateApprovalItem(
                    id: estimate.id,
                    estimateNumber: estimate.estimateNumber,
                    issuedDate: estimate.issuedDate,
                    validUntilDate: estimate.validUntilDate,
                    customerName: estimate.customerName,
                    customerEmail: estimate.customerEmail,
                    projectTitle: estimate.projectTitle,
                    status: .rejected,
                    laborItems: estimate.laborItems,
                    materialItems: estimate.materialItems,
                    taxRate: estimate.taxRate
                )
                self.estimates[idx] = updated
            }
            self.isProcessing = false
            self.showingRejectConfirmation = false
            self.showingDetail = false
        }
    }

    func requestChanges() {
        guard let estimate = selectedEstimate else { return }
        isProcessing = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            if let idx = self.estimates.firstIndex(where: { $0.id == estimate.id }) {
                let updated = EstimateApprovalItem(
                    id: estimate.id,
                    estimateNumber: estimate.estimateNumber,
                    issuedDate: estimate.issuedDate,
                    validUntilDate: estimate.validUntilDate,
                    customerName: estimate.customerName,
                    customerEmail: estimate.customerEmail,
                    projectTitle: estimate.projectTitle,
                    status: .changesRequested,
                    laborItems: estimate.laborItems,
                    materialItems: estimate.materialItems,
                    taxRate: estimate.taxRate
                )
                self.estimates[idx] = updated
            }
            self.isProcessing = false
            self.showingRequestChanges = false
            self.showingDetail = false
        }
    }

    func dismissSuccess() {
        showingSuccess = false
        lastApprovedEstimate = nil
    }

    // MARK: Reset

    private func resetApprovalForm() {
        commentText = ""
        agreedToTerms = false
        changesRequestText = ""
        rejectionReason = ""
        isProcessing = false
        showingRequestChanges = false
        showingRejectConfirmation = false
        #if canImport(UIKit)
        signatureImage = nil
        #endif
    }

    // MARK: Formatting

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f
    }()

    static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        return f
    }()

    func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    func formatCurrency(_ value: Double) -> String {
        Self.currencyFormatter.string(from: NSNumber(value: value)) ?? "$\(String(format: "%.2f", value))"
    }

    func badgeStyle(for status: ApprovalStatus) -> SPBadgeStyle {
        switch status {
        case .pending:          return .warning
        case .approved:         return .success
        case .rejected:         return .error
        case .changesRequested: return .info
        }
    }

    func statusLabel(for status: ApprovalStatus) -> String {
        switch status {
        case .pending:          return "Awaiting Approval"
        case .approved:         return "Approved"
        case .rejected:         return "Rejected"
        case .changesRequested: return "Changes Requested"
        }
    }

    func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(first)\(last)".uppercased()
    }
}
