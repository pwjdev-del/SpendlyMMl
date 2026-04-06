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

    // MARK: PDF State

    var generatedPDFData: Data?
    var showingShareSheet: Bool = false

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
        selectedEstimate = nil
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
                    taxRate: estimate.taxRate,
                    comments: self.commentText
                )
                self.estimates[idx] = updated
                self.lastApprovedEstimate = updated
            }
            self.isProcessing = false
            self.selectedEstimate = nil
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
                    taxRate: estimate.taxRate,
                    comments: self.rejectionReason
                )
                self.estimates[idx] = updated
            }
            self.isProcessing = false
            self.showingRejectConfirmation = false
            self.selectedEstimate = nil
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
                    taxRate: estimate.taxRate,
                    comments: self.changesRequestText
                )
                self.estimates[idx] = updated
            }
            self.isProcessing = false
            self.showingRequestChanges = false
            self.selectedEstimate = nil
            self.showingDetail = false
        }
    }

    func dismissSuccess() {
        showingSuccess = false
        lastApprovedEstimate = nil
    }

    // MARK: PDF Generation

    #if canImport(UIKit)
    func generateAndSharePDF(for estimate: EstimateApprovalItem) {
        generatedPDFData = buildEstimatePDF(estimate)
        if generatedPDFData != nil {
            showingShareSheet = true
        }
    }

    private func buildEstimatePDF(_ estimate: EstimateApprovalItem) -> Data {
        let pageWidth: CGFloat = 612   // US Letter
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let contentWidth = pageWidth - margin * 2

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        return renderer.pdfData { context in
            context.beginPage()
            var y: CGFloat = margin

            // --- Helper closures ---
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: UIColor.label
            ]
            let headingAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.label
            ]
            let bodyBoldAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
            let totalAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.label
            ]

            func drawText(_ text: String, attrs: [NSAttributedString.Key: Any], x: CGFloat, maxWidth: CGFloat) -> CGFloat {
                let attrStr = NSAttributedString(string: text, attributes: attrs)
                let boundingRect = attrStr.boundingRect(
                    with: CGSize(width: maxWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    context: nil
                )
                attrStr.draw(in: CGRect(x: x, y: y, width: maxWidth, height: boundingRect.height))
                return boundingRect.height
            }

            func drawLine(at yPos: CGFloat) {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: yPos))
                path.addLine(to: CGPoint(x: pageWidth - margin, y: yPos))
                UIColor.separator.setStroke()
                path.lineWidth = 0.5
                path.stroke()
            }

            func checkPage(needed: CGFloat) {
                if y + needed > pageHeight - margin {
                    context.beginPage()
                    y = margin
                }
            }

            // --- Header ---
            y += drawText("ESTIMATE", attrs: titleAttrs, x: margin, maxWidth: contentWidth)
            y += 6

            let estNumStr = NSAttributedString(string: estimate.estimateNumber, attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.secondaryLabel
            ])
            estNumStr.draw(at: CGPoint(x: margin, y: y))
            y += 22
            drawLine(at: y)
            y += 16

            // --- Customer Info ---
            y += drawText("CUSTOMER", attrs: headingAttrs, x: margin, maxWidth: contentWidth)
            y += 4
            y += drawText(estimate.customerName, attrs: bodyBoldAttrs, x: margin, maxWidth: contentWidth)
            y += 2
            y += drawText(estimate.customerEmail, attrs: bodyAttrs, x: margin, maxWidth: contentWidth)
            y += 12

            // --- Project & Dates ---
            y += drawText("PROJECT", attrs: headingAttrs, x: margin, maxWidth: contentWidth)
            y += 4
            y += drawText(estimate.projectTitle, attrs: bodyAttrs, x: margin, maxWidth: contentWidth)
            y += 8
            y += drawText("Issued: \(formatDate(estimate.issuedDate))    Valid Until: \(formatDate(estimate.validUntilDate))", attrs: bodyAttrs, x: margin, maxWidth: contentWidth)
            y += 8
            y += drawText("Status: \(statusLabel(for: estimate.status))", attrs: bodyBoldAttrs, x: margin, maxWidth: contentWidth)
            y += 16
            drawLine(at: y)
            y += 16

            // --- Line Items Helper ---
            func drawLineItems(sectionTitle: String, items: [EstimateLineItem]) {
                checkPage(needed: 60)
                y += drawText(sectionTitle.uppercased(), attrs: headingAttrs, x: margin, maxWidth: contentWidth)
                y += 10

                // Column headers
                let colTask: CGFloat = margin
                let colQty: CGFloat = margin + contentWidth * 0.55
                let colPrice: CGFloat = margin + contentWidth * 0.70
                let colTotal: CGFloat = margin + contentWidth * 0.85

                for attr in [("Item", colTask), ("Qty", colQty), ("Price", colPrice), ("Total", colTotal)] {
                    let a = NSAttributedString(string: attr.0, attributes: headingAttrs)
                    a.draw(at: CGPoint(x: attr.1, y: y))
                }
                y += 18

                for item in items {
                    checkPage(needed: 36)

                    // Task name and description
                    y += drawText(item.task, attrs: bodyBoldAttrs, x: colTask, maxWidth: contentWidth * 0.50)
                    let descY = y
                    y += drawText(item.description, attrs: bodyAttrs, x: colTask, maxWidth: contentWidth * 0.50)

                    // Qty, price, total on the first line of the item
                    let qtyStr = NSAttributedString(string: "\(item.quantity)", attributes: bodyAttrs)
                    qtyStr.draw(at: CGPoint(x: colQty, y: descY - 16))
                    let priceStr = NSAttributedString(string: formatCurrency(item.unitPrice), attributes: bodyAttrs)
                    priceStr.draw(at: CGPoint(x: colPrice, y: descY - 16))
                    let totalStr = NSAttributedString(string: formatCurrency(item.total), attributes: bodyBoldAttrs)
                    totalStr.draw(at: CGPoint(x: colTotal, y: descY - 16))

                    y += 8
                }

                y += 8
            }

            // --- Labor Items ---
            if !estimate.laborItems.isEmpty {
                drawLineItems(sectionTitle: "Tasks & Labor", items: estimate.laborItems)
            }

            // --- Material Items ---
            if !estimate.materialItems.isEmpty {
                drawLineItems(sectionTitle: "Materials", items: estimate.materialItems)
            }

            // --- Totals ---
            checkPage(needed: 100)
            drawLine(at: y)
            y += 12

            // Subtotal
            let subtotalLabel = NSAttributedString(string: "Subtotal", attributes: bodyAttrs)
            subtotalLabel.draw(at: CGPoint(x: margin, y: y))
            let subtotalVal = NSAttributedString(string: formatCurrency(estimate.subtotal), attributes: bodyBoldAttrs)
            let subtotalValSize = subtotalVal.size()
            subtotalVal.draw(at: CGPoint(x: pageWidth - margin - subtotalValSize.width, y: y))
            y += 20

            // Tax
            let taxLabel = NSAttributedString(string: "Tax (\(estimate.taxPercentageLabel))", attributes: bodyAttrs)
            taxLabel.draw(at: CGPoint(x: margin, y: y))
            let taxVal = NSAttributedString(string: formatCurrency(estimate.taxAmount), attributes: bodyBoldAttrs)
            let taxValSize = taxVal.size()
            taxVal.draw(at: CGPoint(x: pageWidth - margin - taxValSize.width, y: y))
            y += 24
            drawLine(at: y)
            y += 12

            // Grand total
            let grandLabel = NSAttributedString(string: "Total Estimate", attributes: totalAttrs)
            grandLabel.draw(at: CGPoint(x: margin, y: y))
            let grandVal = NSAttributedString(string: formatCurrency(estimate.grandTotal), attributes: totalAttrs)
            let grandValSize = grandVal.size()
            grandVal.draw(at: CGPoint(x: pageWidth - margin - grandValSize.width, y: y))
            y += 30

            // --- Comments (if any) ---
            if !estimate.comments.isEmpty {
                checkPage(needed: 60)
                drawLine(at: y)
                y += 12
                y += drawText("COMMENTS", attrs: headingAttrs, x: margin, maxWidth: contentWidth)
                y += 4
                y += drawText(estimate.comments, attrs: bodyAttrs, x: margin, maxWidth: contentWidth)
            }
        }
    }
    #endif

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
        let last = parts.count > 1 ? (parts.last?.prefix(1) ?? "") : ""
        return "\(first)\(last)".uppercased()
    }
}
