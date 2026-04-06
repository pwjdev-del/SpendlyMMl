import SwiftUI
import SpendlyCore

public struct TripReportRootView: View {
    @State private var viewModel = TripReportViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.lg) {
                    // Header
                    SPHeader(title: "Trip Reports") {
                        SPBadge(
                            "\(viewModel.completedTrips.count) Completed",
                            style: .success
                        )
                    }

                    // Search
                    SPInput(
                        "Search trips...",
                        icon: SpendlyIcon.search.systemName,
                        text: $viewModel.searchText
                    )

                    // Trip List
                    if viewModel.filteredTrips.isEmpty {
                        SPEmptyState(
                            icon: "doc.richtext",
                            title: "No Trip Reports",
                            message: "No completed trips match your search. Complete a service trip to generate a report."
                        )
                    } else {
                        LazyVStack(spacing: SpendlySpacing.md) {
                            ForEach(viewModel.filteredTrips) { trip in
                                TripListCard(trip: trip) {
                                    viewModel.selectTrip(trip)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: TripReportRoute.self) { route in
                switch route {
                case .completion(let id):
                    if let trip = viewModel.completedTrips.first(where: { $0.id == id }) {
                        TripCompletionView(trip: trip, viewModel: viewModel)
                    } else {
                        ContentUnavailableView("Trip Not Found", systemImage: "doc.text", description: Text("This trip report is no longer available."))
                    }
                case .pdfPreview(let id):
                    if let trip = viewModel.completedTrips.first(where: { $0.id == id }) {
                        TripReportPDFView(trip: trip, viewModel: viewModel)
                    } else {
                        ContentUnavailableView("Trip Not Found", systemImage: "doc.text", description: Text("This trip report is no longer available."))
                    }
                case .emailReport(let id):
                    if let trip = viewModel.completedTrips.first(where: { $0.id == id }) {
                        EmailReportView(trip: trip, viewModel: viewModel)
                    } else {
                        ContentUnavailableView("Trip Not Found", systemImage: "doc.text", description: Text("This trip report is no longer available."))
                    }
                case .sendSuccess(let sentTo):
                    SendSuccessView(sentEmails: sentTo, viewModel: viewModel)
                }
            }
        }
    }
}

// MARK: - Trip List Card

private struct TripListCard: View {
    let trip: TripReportDisplayModel
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: onTap) {
            SPCard(elevation: .low) {
                VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                    // Top row: report number and date
                    HStack {
                        Text(trip.reportNumber)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.primary)
                        Spacer()
                        Text(trip.shortDate)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }

                    SPDivider()

                    // Customer name
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "building.2")
                            .font(.system(size: 14))
                            .foregroundStyle(SpendlyColors.accent)
                        Text(trip.customerName)
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }

                    // Technician
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: SpendlyIcon.person.systemName)
                            .font(.system(size: 14))
                            .foregroundStyle(SpendlyColors.secondary)
                        Text(trip.technicianName)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }

                    SPDivider()

                    // Bottom row: tasks count and total
                    HStack {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: SpendlyIcon.checkCircle.systemName)
                                .font(.system(size: 12))
                                .foregroundStyle(SpendlyColors.success)
                            Text("\(trip.completedTasks.count) tasks")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        }

                        Spacer()

                        Text(CurrencyFormatter.shared.format(trip.grandTotal))
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.primary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    TripReportRootView()
}
