import Foundation
import SpendlyCore

// MARK: - Territory Display Model

/// Lightweight display model used within the Territory & Region module.
/// Wraps the SpendlyCore `Territory` @Model with regional-config fields.
struct TerritoryDisplayModel: Identifiable, Equatable {
    let id: UUID
    var name: String
    var regionCode: String
    var timezone: String
    var taxRate: Double
    var currency: String
    var assignedTechnicians: [TechnicianStub]
    var stateList: String
    var territoryCount: Int
    var isActive: Bool

    static func == (lhs: TerritoryDisplayModel, rhs: TerritoryDisplayModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Technician Stub

struct TechnicianStub: Identifiable, Hashable {
    let id: UUID
    let name: String
    let initials: String
    let email: String
}

// MARK: - Mock Technicians

enum MockTechnicians {
    static let all: [TechnicianStub] = [
        TechnicianStub(id: UUID(), name: "Sarah Jenkins", initials: "SJ", email: "s.jenkins@spendly.com"),
        TechnicianStub(id: UUID(), name: "Michael Chen", initials: "MC", email: "m.chen@spendly.com"),
        TechnicianStub(id: UUID(), name: "Arjun Patel", initials: "AP", email: "a.patel@spendly.com"),
        TechnicianStub(id: UUID(), name: "Lisa Torres", initials: "LT", email: "l.torres@spendly.com"),
        TechnicianStub(id: UUID(), name: "David Kim", initials: "DK", email: "d.kim@spendly.com"),
        TechnicianStub(id: UUID(), name: "Emily Watson", initials: "EW", email: "e.watson@spendly.com"),
        TechnicianStub(id: UUID(), name: "Carlos Rivera", initials: "CR", email: "c.rivera@spendly.com"),
        TechnicianStub(id: UUID(), name: "Amanda Brooks", initials: "AB", email: "a.brooks@spendly.com"),
    ]
}

// MARK: - Mock Territories

enum MockTerritoryData {

    static let territories: [TerritoryDisplayModel] = [
        TerritoryDisplayModel(
            id: UUID(),
            name: "Northeast Region",
            regionCode: "US-NE",
            timezone: "America/New_York",
            taxRate: 8.25,
            currency: "USD ($)",
            assignedTechnicians: Array(MockTechnicians.all.prefix(3)),
            stateList: "NY, NJ, CT, MA, PA",
            territoryCount: 12,
            isActive: true
        ),
        TerritoryDisplayModel(
            id: UUID(),
            name: "Southeast Region",
            regionCode: "US-SE",
            timezone: "America/New_York",
            taxRate: 7.00,
            currency: "USD ($)",
            assignedTechnicians: Array(MockTechnicians.all[2...4]),
            stateList: "FL, GA, NC, SC, VA",
            territoryCount: 10,
            isActive: true
        ),
        TerritoryDisplayModel(
            id: UUID(),
            name: "West Coast",
            regionCode: "US-WC",
            timezone: "America/Los_Angeles",
            taxRate: 9.50,
            currency: "USD ($)",
            assignedTechnicians: Array(MockTechnicians.all[4...6]),
            stateList: "CA, OR, WA, NV",
            territoryCount: 8,
            isActive: true
        ),
        TerritoryDisplayModel(
            id: UUID(),
            name: "Central Region",
            regionCode: "US-CT",
            timezone: "America/Chicago",
            taxRate: 6.75,
            currency: "USD ($)",
            assignedTechnicians: Array(MockTechnicians.all[5...7]),
            stateList: "IL, IN, MI, OH, WI",
            territoryCount: 15,
            isActive: false
        ),
    ]

    // MARK: Picker Options

    static let timezoneOptions: [String] = [
        "America/New_York",
        "America/Chicago",
        "America/Denver",
        "America/Los_Angeles",
        "America/Phoenix",
        "America/Anchorage",
        "Pacific/Honolulu",
    ]

    static let currencyOptions: [String] = [
        "USD ($)",
        "CAD ($)",
        "EUR (\u{20AC})",
        "GBP (\u{00A3})",
        "MXN ($)",
        "INR (\u{20B9})",
    ]
}
