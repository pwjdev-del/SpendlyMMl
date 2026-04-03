import Foundation
import SwiftUI
import SpendlyCore

// MARK: - View Model

@Observable
final class FinancialHubViewModel {

    // MARK: Data

    var metrics: [FinancialMetric] = FinancialHubMockData.metrics
    var bankConnection: BankConnection = FinancialHubMockData.bankConnection
    var expenseStatusItems: [ExpenseStatusItem] = FinancialHubMockData.expenseStatusItems
    var recentPayouts: [PayoutItem] = FinancialHubMockData.recentPayouts

    // MARK: Formatting

    func formatAmount(_ amount: Double) -> String {
        String(format: "$%,.2f", amount)
    }

    func formatPayoutAmount(_ amount: Double) -> String {
        String(format: "+$%,.2f", amount)
    }

    func formatPayoutDate(_ date: Date) -> String {
        FinancialHubMockData.payoutDateFormatter.string(from: date)
    }

    // MARK: Bank Connection

    var bankDisplayName: String {
        "\(bankConnection.bankName) \u{2022}\u{2022}\u{2022}\u{2022} \(bankConnection.lastFour)"
    }

    var connectionStatusText: String {
        bankConnection.isConnected ? "Connected" : "Disconnected"
    }

    // MARK: Actions

    func transferNow() {
        // Future: navigate to transfer flow
    }

    func payNow() {
        // Future: navigate to pay flow
    }

    func manageBankConnection() {
        // Future: navigate to bank settings
    }

    func viewAllPayouts() {
        // Future: navigate to full payout list
    }
}
