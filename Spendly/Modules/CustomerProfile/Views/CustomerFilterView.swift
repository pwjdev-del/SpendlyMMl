import SwiftUI
import SpendlyCore

// MARK: - CustomerFilterView
//
// A standalone filter view that wraps SPFilterModal with the customer-specific
// filter sections. This can be used in a sheet if the caller prefers that
// presentation over the inline overlay already wired in CustomerProfileRootView.

struct CustomerFilterView: View {

    @Binding var isPresented: Bool
    @Binding var filterSections: [SPFilterSection]

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SPFilterModal(
            isPresented: $isPresented,
            sections: $filterSections
        )
    }

    // MARK: - Factory

    /// Creates the default filter sections for customer profiles.
    /// Call this once to seed the ViewModel or use it in previews.
    static func defaultSections() -> [SPFilterSection] {
        [
            SPFilterSection(
                title: "Payment Status",
                type: .checkbox,
                options: PaymentStatusType.allCases.map {
                    SPFilterOption(label: $0.rawValue)
                }
            ),
            SPFilterSection(
                title: "Region",
                type: .checkbox,
                options: [
                    SPFilterOption(label: "North"),
                    SPFilterOption(label: "South"),
                    SPFilterOption(label: "East"),
                    SPFilterOption(label: "West")
                ]
            ),
            SPFilterSection(
                title: "Contract Type",
                type: .checkbox,
                options: ContractType.allCases.map {
                    SPFilterOption(label: $0.rawValue)
                }
            ),
            SPFilterSection(
                title: "Account Balance",
                type: .range(min: -10000, max: 100000),
                options: []
            ),
            SPFilterSection(
                title: "Budget Range",
                type: .range(min: 0, max: 200000),
                options: []
            ),
            SPFilterSection(
                title: "Creation Date",
                type: .dateRange,
                options: []
            ),
            SPFilterSection(
                title: "Last Activity",
                type: .radio,
                options: [
                    SPFilterOption(label: "Last 7 days"),
                    SPFilterOption(label: "Last 30 days"),
                    SPFilterOption(label: "Last 90 days"),
                    SPFilterOption(label: "Over 90 days")
                ]
            ),
            SPFilterSection(
                title: "Client Tier",
                type: .checkbox,
                options: [
                    SPFilterOption(label: "Premium"),
                    SPFilterOption(label: "Standard")
                ]
            )
        ]
    }
}

// MARK: - Preview

#Preview("Customer Filter") {
    CustomerFilterView(
        isPresented: .constant(true),
        filterSections: .constant(CustomerFilterView.defaultSections())
    )
}
