import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Wizard Step

enum TransferWizardStep: Int, CaseIterable {
    case selectMachine = 0
    case selectOwner = 1
    case preAudit = 2
    case confirmation = 3

    var title: String {
        switch self {
        case .selectMachine: return "Select Machine"
        case .selectOwner:   return "New Owner"
        case .preAudit:      return "Pre-Transfer Audit"
        case .confirmation:  return "Confirm Transfer"
        }
    }

    var stepNumber: Int { rawValue + 1 }
    static var totalSteps: Int { allCases.count }
}

// MARK: - View Model

@Observable
final class AssetTransferViewModel {

    // MARK: Transfer List

    var transfers: [TransferDisplayItem] = AssetTransferMockData.sampleTransfers
    var listSearchText: String = ""

    var filteredTransfers: [TransferDisplayItem] {
        guard !listSearchText.isEmpty else { return transfers }
        let query = listSearchText.lowercased()
        return transfers.filter {
            $0.machineName.lowercased().contains(query) ||
            $0.fromCustomerName.lowercased().contains(query) ||
            $0.toCustomerName.lowercased().contains(query) ||
            $0.machineSerial.lowercased().contains(query)
        }
    }

    var pendingTransfers: [TransferDisplayItem] {
        filteredTransfers.filter { $0.status == .pending || $0.status == .inTransit }
    }

    var completedTransfers: [TransferDisplayItem] {
        filteredTransfers.filter { $0.status == .completed || $0.status == .cancelled }
    }

    // MARK: Wizard State

    var currentStep: TransferWizardStep = .selectMachine
    var showingInitiateSheet: Bool = false

    // Step 1 — Machine selection
    var machineSearchText: String = ""
    var selectedMachine: MachineOption?

    var filteredMachines: [MachineOption] {
        let all = AssetTransferMockData.machines
        guard !machineSearchText.isEmpty else { return all }
        let query = machineSearchText.lowercased()
        return all.filter {
            $0.name.lowercased().contains(query) ||
            $0.model.lowercased().contains(query) ||
            $0.serialNumber.lowercased().contains(query) ||
            $0.currentOwner.lowercased().contains(query)
        }
    }

    // Step 2 — New owner selection
    var customerSearchText: String = ""
    var selectedCustomer: TransferCustomerOption?

    var filteredCustomers: [TransferCustomerOption] {
        let all = AssetTransferMockData.customers
        guard !customerSearchText.isEmpty else { return all }
        let query = customerSearchText.lowercased()
        return all.filter {
            $0.name.lowercased().contains(query) ||
            $0.contactName.lowercased().contains(query) ||
            $0.city.lowercased().contains(query)
        }
    }

    // Step 3 — Pre-transfer audit
    var includePreTransferAudit: Bool = false
    var auditNotes: String = ""

    // Step 4 — Confirmation
    var isConfirming: Bool = false
    var showConfirmationAlert: Bool = false
    var transferComplete: Bool = false

    // MARK: Custody Log

    var custodyEntries: [CustodyEntry] = AssetTransferMockData.custodyChainForM200
    var showingCustodyLog: Bool = false
    var custodyMachineName: String = "M-200 FFS Packaging Line"
    var custodyMachineSerial: String = "22-42490227"

    // MARK: Navigation

    var canAdvance: Bool {
        switch currentStep {
        case .selectMachine:  return selectedMachine != nil
        case .selectOwner:    return selectedCustomer != nil
        case .preAudit:       return true // audit is optional
        case .confirmation:   return true
        }
    }

    func advance() {
        guard let nextRaw = TransferWizardStep(rawValue: currentStep.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = nextRaw
        }
    }

    func goBack() {
        guard let prevRaw = TransferWizardStep(rawValue: currentStep.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            currentStep = prevRaw
        }
    }

    // MARK: Actions

    func beginTransfer() {
        resetWizard()
        showingInitiateSheet = true
    }

    func confirmTransfer() {
        showConfirmationAlert = true
    }

    func executeTransfer() {
        guard let machine = selectedMachine, let customer = selectedCustomer else { return }
        isConfirming = true

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }

            let newTransfer = TransferDisplayItem(
                id: UUID(),
                machineName: machine.name,
                machineSerial: machine.serialNumber,
                machineModel: machine.model,
                fromCustomerName: machine.currentOwner,
                toCustomerName: customer.name,
                date: Date(),
                status: .pending,
                includesAudit: self.includePreTransferAudit,
                notes: self.auditNotes.isEmpty ? nil : self.auditNotes
            )
            self.transfers.insert(newTransfer, at: 0)
            self.isConfirming = false
            self.transferComplete = true
        }
    }

    func resetWizard() {
        currentStep = .selectMachine
        selectedMachine = nil
        selectedCustomer = nil
        machineSearchText = ""
        customerSearchText = ""
        includePreTransferAudit = false
        auditNotes = ""
        isConfirming = false
        transferComplete = false
        showConfirmationAlert = false
    }

    func dismissSheet() {
        showingInitiateSheet = false
        resetWizard()
    }

    func openCustodyLog(for transfer: TransferDisplayItem) {
        custodyMachineName = transfer.machineName
        custodyMachineSerial = transfer.machineSerial
        // In production this would fetch the real custody chain for the machine
        custodyEntries = AssetTransferMockData.custodyChainForM200
        showingCustodyLog = true
    }

    // MARK: Formatting

    func badgeStyle(for status: TransferStatus) -> SPBadgeStyle {
        switch status {
        case .pending:   return .warning
        case .inTransit: return .info
        case .completed: return .success
        case .cancelled: return .error
        }
    }

    func statusLabel(for status: TransferStatus) -> String {
        switch status {
        case .pending:   return "Pending"
        case .inTransit: return "In Transit"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }

    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f
    }()

    func formatDate(_ date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }

    func formatShortDate(_ date: Date) -> String {
        Self.shortDateFormatter.string(from: date)
    }

    func initials(for name: String) -> String {
        let parts = name.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last = parts.count > 1 ? parts.last!.prefix(1) : ""
        return "\(first)\(last)".uppercased()
    }
}
