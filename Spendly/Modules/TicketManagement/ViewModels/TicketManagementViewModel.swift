import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Sort Option

enum TicketSortOption: String, CaseIterable {
    case newest      = "Newest First"
    case oldest      = "Oldest First"
    case urgencyHigh = "Urgency (High-Low)"
    case urgencyLow  = "Urgency (Low-High)"
    case titleAZ     = "Title (A-Z)"
}

// MARK: - ViewModel

@Observable
final class TicketManagementViewModel {

    // MARK: Data

    var allTickets: [DisplayTicket] = TicketManagementMockData.tickets
    var selectedTicket: DisplayTicket?

    // MARK: UI State

    var searchText: String = ""
    var selectedTab: TicketDisplayStatus = .all
    var sortOption: TicketSortOption = .newest
    var showDetail: Bool = false
    var showNewTicketForm: Bool = false
    var showFilterModal: Bool = false

    // MARK: New Ticket Form State

    var newTicketTitle: String = ""
    var newTicketDescription: String = ""
    var newTicketCategory: String = ""
    var newTicketUrgency: String = "Medium"
    var newTicketMachine: String = ""
    var newTicketCustomer: String = ""
    var isSubmittingTicket: Bool = false
    var showSubmitSuccess: Bool = false
    var newTicketIsDraft: Bool = false

    // MARK: Filter Sections

    var filterSections: [SPFilterSection] = [
        SPFilterSection(
            title: "Category",
            type: .checkbox,
            options: [
                SPFilterOption(label: "Electrical"),
                SPFilterOption(label: "Mechanical"),
                SPFilterOption(label: "Pneumatic"),
                SPFilterOption(label: "Other"),
            ]
        ),
        SPFilterSection(
            title: "Urgency",
            type: .checkbox,
            options: [
                SPFilterOption(label: "Low"),
                SPFilterOption(label: "Medium"),
                SPFilterOption(label: "High"),
                SPFilterOption(label: "Critical"),
            ]
        ),
        SPFilterSection(
            title: "Source",
            type: .checkbox,
            options: [
                SPFilterOption(label: "Manual"),
                SPFilterOption(label: "Incoming Call"),
                SPFilterOption(label: "Diagnostic"),
                SPFilterOption(label: "Offline Sync"),
            ]
        ),
    ]

    // MARK: - Computed Properties

    var filteredTickets: [DisplayTicket] {
        var result = allTickets

        // Tab filter (status)
        if let coreStatus = selectedTab.coreStatus {
            let statusLabel = selectedTab.rawValue
            result = result.filter { $0.status.rawValue == statusLabel }
        }

        // Search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { ticket in
                ticket.title.lowercased().contains(query) ||
                ticket.ticketNumber.lowercased().contains(query) ||
                ticket.customerName.lowercased().contains(query) ||
                ticket.description.lowercased().contains(query) ||
                (ticket.machineName?.lowercased().contains(query) ?? false) ||
                (ticket.assignedTechnician?.lowercased().contains(query) ?? false) ||
                ticket.category.rawValue.lowercased().contains(query)
            }
        }

        // Category filter
        let categorySection = filterSections.first(where: { $0.title == "Category" })
        let selectedCategories = categorySection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedCategories.isEmpty {
            result = result.filter { ticket in
                selectedCategories.contains(ticket.category.rawValue)
            }
        }

        // Urgency filter
        let urgencySection = filterSections.first(where: { $0.title == "Urgency" })
        let selectedUrgencies = urgencySection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedUrgencies.isEmpty {
            result = result.filter { ticket in
                selectedUrgencies.contains(ticket.urgency.rawValue)
            }
        }

        // Source filter
        let sourceSection = filterSections.first(where: { $0.title == "Source" })
        let selectedSources = sourceSection?.options.filter(\.isSelected).map(\.label) ?? []
        if !selectedSources.isEmpty {
            result = result.filter { ticket in
                selectedSources.contains(ticket.source.rawValue)
            }
        }

        // Sort
        switch sortOption {
        case .newest:
            result.sort { $0.createdAt > $1.createdAt }
        case .oldest:
            result.sort { $0.createdAt < $1.createdAt }
        case .urgencyHigh:
            result.sort { urgencyOrder($0.urgency) > urgencyOrder($1.urgency) }
        case .urgencyLow:
            result.sort { urgencyOrder($0.urgency) < urgencyOrder($1.urgency) }
        case .titleAZ:
            result.sort { $0.title < $1.title }
        }

        return result
    }

    var activeFilterCount: Int {
        filterSections.flatMap(\.options).filter(\.isSelected).count
    }

    // MARK: - Stats

    var totalTickets: Int { allTickets.count }

    var openCount: Int {
        allTickets.filter { $0.status == .open }.count
    }

    var inProgressCount: Int {
        allTickets.filter { $0.status == .inProgress }.count
    }

    var resolvedCount: Int {
        allTickets.filter { $0.status == .resolved || $0.status == .closed }.count
    }

    var criticalCount: Int {
        allTickets.filter { $0.urgency == .critical || $0.urgency == .high }.count
    }

    // MARK: - Status Tabs (with counts)

    var statusTabs: [(TicketDisplayStatus, Int)] {
        [
            (.all, allTickets.count),
            (.open, openCount),
            (.inProgress, inProgressCount),
            (.onHold, allTickets.filter { $0.status == .onHold }.count),
            (.resolved, resolvedCount),
        ]
    }

    // MARK: - Actions

    func selectTicket(_ ticket: DisplayTicket) {
        selectedTicket = ticket
        showDetail = true
    }

    func submitNewTicket() {
        guard !newTicketTitle.isEmpty, !newTicketCategory.isEmpty else { return }

        isSubmittingTicket = true

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }

            let category = TicketCategory.allCases.first(where: { $0.rawValue == self.newTicketCategory }) ?? .other
            let urgency = TicketUrgency.allCases.first(where: { $0.rawValue == self.newTicketUrgency }) ?? .medium

            let newTicket = DisplayTicket(
                ticketNumber: "TK-2026-\(String(format: "%03d", self.allTickets.count + 1))",
                title: self.newTicketTitle,
                description: self.newTicketDescription,
                category: category,
                urgency: urgency,
                status: self.newTicketIsDraft ? .open : .open,
                source: .manual,
                customerName: self.newTicketCustomer.isEmpty ? "Unknown Customer" : self.newTicketCustomer,
                machineName: self.newTicketMachine.isEmpty ? nil : self.newTicketMachine,
                createdAt: Date(),
                updatedAt: Date(),
                photoCount: 0,
                timeline: [
                    TicketTimelineEvent(
                        title: "Submitted",
                        description: "Ticket created via mobile app.",
                        date: Date(),
                        status: .open,
                        performedBy: "Current User"
                    ),
                ],
                isSyncedOffline: true
            )

            self.allTickets.insert(newTicket, at: 0)
            self.isSubmittingTicket = false
            self.showSubmitSuccess = true
            self.resetNewTicketForm()

            // Dismiss success after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.showSubmitSuccess = false
                self.showNewTicketForm = false
            }
        }
    }

    func saveDraft() {
        newTicketIsDraft = true
        submitNewTicket()
    }

    func resetNewTicketForm() {
        newTicketTitle = ""
        newTicketDescription = ""
        newTicketCategory = ""
        newTicketUrgency = "Medium"
        newTicketMachine = ""
        newTicketCustomer = ""
        newTicketIsDraft = false
    }

    // MARK: - Helpers

    private func urgencyOrder(_ urgency: TicketUrgency) -> Int {
        switch urgency {
        case .low:      return 0
        case .medium:   return 1
        case .high:     return 2
        case .critical: return 3
        }
    }
}
