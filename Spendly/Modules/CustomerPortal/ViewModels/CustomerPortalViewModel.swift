import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Navigation Destination

enum CustomerPortalDestination: Hashable {
    case serviceTracker(serviceID: UUID)
    case reportIssue

    func hash(into hasher: inout Hasher) {
        switch self {
        case .serviceTracker(let id):
            hasher.combine("tracker")
            hasher.combine(id)
        case .reportIssue:
            hasher.combine("report")
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.serviceTracker(let a), .serviceTracker(let b)): return a == b
        case (.reportIssue, .reportIssue): return true
        default: return false
        }
    }
}

// MARK: - ViewModel

@Observable
final class CustomerPortalViewModel {

    // MARK: - Data

    var customerName: String = "Alex"
    var lastLogin: String = "Today, 09:41 AM"
    var stats: PortalDashboardStats = CustomerPortalMockData.stats

    var recentIssues: [PortalIssue] = CustomerPortalMockData.recentIssues
    var machines: [PortalMachine] = CustomerPortalMockData.machines
    var activeServices: [ActiveService] = [CustomerPortalMockData.activeService]
    var selfServiceFields: [SelfServiceFieldMap] = CustomerPortalMockData.selfServiceFieldMaps

    // MARK: - Navigation

    var navigationPath: [CustomerPortalDestination] = []
    var showCancelConfirmation: Bool = false
    var showReportIssue: Bool = false

    // MARK: - White-Label

    var portalTitle: String = "CustomerPortal"

    // MARK: - Computed

    var hasActiveService: Bool {
        !activeServices.isEmpty
    }

    var primaryActiveService: ActiveService? {
        activeServices.first
    }

    var activeIssueCount: Int {
        stats.activeIssues
    }

    var resolvedCount: Int {
        stats.resolvedCount
    }

    // MARK: - Actions

    func navigateToServiceTracker(serviceID: UUID) {
        navigationPath.append(.serviceTracker(serviceID: serviceID))
    }

    func navigateToReportIssue() {
        showReportIssue = true
    }

    func requestCancelService() {
        showCancelConfirmation = true
    }

    func confirmCancelService(serviceID: UUID) {
        withAnimation(.easeInOut(duration: 0.3)) {
            activeServices.removeAll { $0.id == serviceID }
            showCancelConfirmation = false
        }
    }

    func contactTechnician(phone: String) {
        // In production, this would open tel:// URL
        if let url = URL(string: "tel://\(phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))") {
            #if os(iOS)
            UIApplication.shared.open(url)
            #endif
        }
    }

    func service(for id: UUID) -> ActiveService? {
        activeServices.first { $0.id == id }
    }

    /// Returns the step-progress fraction (0.0-1.0) for a given service status.
    func progressFraction(for status: ServiceJobStatus) -> Double {
        switch status {
        case .dispatched: return 0.25
        case .enRoute:    return 0.50
        case .onSite:     return 0.75
        case .completed:  return 1.0
        }
    }
}
