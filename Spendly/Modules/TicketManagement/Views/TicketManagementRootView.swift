import SwiftUI
import SpendlyCore

public struct TicketManagementRootView: View {

    @State private var viewModel = TicketManagementViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        ZStack {
            SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: SpendlySpacing.lg) {
                    headerSection
                    statsRow
                    statusTabBar
                    searchAndSort
                    ticketList
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.top, SpendlySpacing.sm)
                .padding(.bottom, SpendlySpacing.xxxl * 2)
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        viewModel.showNewTicketForm = true
                    } label: {
                        Image(systemName: SpendlyIcon.add.systemName)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(SpendlyColors.primary)
                            .clipShape(Circle())
                            .shadow(color: SpendlyColors.primary.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.trailing, SpendlySpacing.lg)
                    .padding(.bottom, SpendlySpacing.xxl)
                }
            }

            // Filter overlay
            SPFilterModal(
                isPresented: $viewModel.showFilterModal,
                sections: $viewModel.filterSections
            )
        }
        .sheet(item: $viewModel.selectedTicket) { ticket in
            TicketDetailView(ticket: ticket, viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showNewTicketForm) {
            NewTicketFormView(viewModel: viewModel)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text("Ticket Management")
                .font(SpendlyFont.largeTitle())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Text("Track, manage, and resolve service tickets")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, SpendlySpacing.sm)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: SpendlySpacing.sm) {
            miniStatCard(
                title: "Total",
                value: "\(viewModel.totalTickets)",
                color: SpendlyColors.primary
            )
            miniStatCard(
                title: "Open",
                value: "\(viewModel.openCount)",
                color: SpendlyColors.info
            )
            miniStatCard(
                title: "In Progress",
                value: "\(viewModel.inProgressCount)",
                color: SpendlyColors.accent
            )
            miniStatCard(
                title: "Critical",
                value: "\(viewModel.criticalCount)",
                color: SpendlyColors.error
            )
        }
    }

    private func miniStatCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text(title)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                .textCase(.uppercase)
                .tracking(0.5)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Text(value)
                .font(SpendlyFont.title())
                .foregroundStyle(color)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: - Status Tab Bar

    private var statusTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpendlySpacing.sm) {
                ForEach(viewModel.statusTabs, id: \.0) { tab, count in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedTab = tab
                        }
                    } label: {
                        HStack(spacing: SpendlySpacing.xs) {
                            Text(tab.rawValue)
                                .font(SpendlyFont.bodySemibold())
                            Text("\(count)")
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    viewModel.selectedTab == tab
                                        ? Color.white.opacity(0.25)
                                        : SpendlyColors.secondary.opacity(0.1)
                                )
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, SpendlySpacing.md)
                        .padding(.vertical, SpendlySpacing.sm)
                        .foregroundStyle(
                            viewModel.selectedTab == tab
                                ? .white
                                : SpendlyColors.foreground(for: colorScheme)
                        )
                        .background(
                            viewModel.selectedTab == tab
                                ? SpendlyColors.primary
                                : SpendlyColors.surface(for: colorScheme)
                        )
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }

    // MARK: - Search + Sort

    private var searchAndSort: some View {
        VStack(spacing: SpendlySpacing.sm) {
            SPSearchBar(
                searchText: $viewModel.searchText,
                showFilterButton: true,
                onFilterTap: {
                    withAnimation {
                        viewModel.showFilterModal = true
                    }
                }
            )

            // Active filter indicator + sort
            if viewModel.activeFilterCount > 0 || viewModel.sortOption != .newest {
                HStack {
                    if viewModel.activeFilterCount > 0 {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.system(size: 12))
                            Text("\(viewModel.activeFilterCount) filter\(viewModel.activeFilterCount == 1 ? "" : "s") active")
                                .font(SpendlyFont.caption())
                        }
                        .foregroundStyle(SpendlyColors.accent)
                    }

                    Spacer()

                    Menu {
                        ForEach(TicketSortOption.allCases, id: \.self) { option in
                            Button {
                                viewModel.sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if viewModel.sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 11))
                            Text(viewModel.sortOption.rawValue)
                                .font(SpendlyFont.caption())
                        }
                        .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Ticket List

    @ViewBuilder
    private var ticketList: some View {
        if viewModel.filteredTickets.isEmpty {
            SPEmptyState(
                icon: "ticket",
                title: "No Tickets Found",
                message: "Try adjusting your search, filters, or status tab to find tickets.",
                actionTitle: "Create Ticket"
            ) {
                viewModel.showNewTicketForm = true
            }
            .padding(.top, SpendlySpacing.xxxl)
        } else {
            LazyVStack(spacing: SpendlySpacing.sm) {
                ForEach(viewModel.filteredTickets) { ticket in
                    TicketListCard(ticket: ticket)
                        .onTapGesture {
                            viewModel.selectTicket(ticket)
                        }
                }
            }
        }
    }
}

// MARK: - Ticket List Card

private struct TicketListCard: View {

    let ticket: DisplayTicket
    @Environment(\.colorScheme) private var colorScheme

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, h:mm a"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top row: category color bar
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(ticket.category.color)
                    .frame(width: 4, height: 48)

                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    // Ticket number + status badge
                    HStack {
                        Text(ticket.ticketNumber)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(SpendlyColors.secondary)

                        Spacer()

                        SPBadge(ticket.status.rawValue, style: ticket.status.badgeStyle)
                    }

                    // Title
                    Text(ticket.title)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .lineLimit(2)

                    // Meta row
                    HStack(spacing: SpendlySpacing.md) {
                        // Category
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: ticket.category.icon)
                                .font(.system(size: 10))
                                .foregroundStyle(ticket.category.color)
                            Text(ticket.category.rawValue)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }

                        // Urgency
                        SPBadge(ticket.urgency.rawValue, style: ticket.urgency.badgeStyle)

                        Spacer()

                        // Sync indicator
                        if !ticket.isSyncedOffline {
                            HStack(spacing: 2) {
                                Image(systemName: "icloud.slash")
                                    .font(.system(size: 10))
                                Text("Pending")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundStyle(SpendlyColors.warning)
                        }
                    }

                    SPDivider()

                    // Bottom row
                    HStack(spacing: SpendlySpacing.md) {
                        // Customer
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "building.2")
                                .font(.system(size: 10))
                            Text(ticket.customerName)
                                .font(SpendlyFont.caption())
                                .lineLimit(1)
                        }
                        .foregroundStyle(SpendlyColors.secondary)

                        Spacer()

                        // Date
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text(dateFormatter.string(from: ticket.createdAt))
                                .font(SpendlyFont.caption())
                        }
                        .foregroundStyle(SpendlyColors.secondary)

                        // Photos indicator
                        if ticket.photoCount > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "photo")
                                    .font(.system(size: 10))
                                Text("\(ticket.photoCount)")
                                    .font(SpendlyFont.caption())
                            }
                            .foregroundStyle(SpendlyColors.secondary)
                        }
                    }

                    // Assigned technician row
                    if let tech = ticket.assignedTechnician {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 10))
                            Text(tech)
                                .font(SpendlyFont.caption())
                                .fontWeight(.medium)

                            if let scheduled = ticket.scheduledDate {
                                Spacer()
                                HStack(spacing: 2) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 10))
                                    Text(scheduledFormatter.string(from: scheduled))
                                        .font(SpendlyFont.caption())
                                }
                                .foregroundStyle(SpendlyColors.accent)
                            }
                        }
                        .foregroundStyle(SpendlyColors.primary)
                        .padding(.top, SpendlySpacing.xs)
                    }
                }
                .padding(.leading, SpendlySpacing.md)
            }
            .padding(SpendlySpacing.md)
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    private var scheduledFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }
}

// MARK: - Previews

#Preview("Ticket Management - Light") {
    TicketManagementRootView()
        .preferredColorScheme(.light)
}

#Preview("Ticket Management - Dark") {
    TicketManagementRootView()
        .preferredColorScheme(.dark)
}
