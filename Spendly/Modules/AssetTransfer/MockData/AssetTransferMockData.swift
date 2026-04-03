import Foundation
import SpendlyCore

// MARK: - Display Models (Module-Local)

struct TransferDisplayItem: Identifiable {
    let id: UUID
    let machineName: String
    let machineSerial: String
    let machineModel: String
    let fromCustomerName: String
    let toCustomerName: String
    let date: Date
    let status: TransferStatus
    let includesAudit: Bool
    let notes: String?
}

struct CustodyEntry: Identifiable {
    let id: UUID
    let ownerName: String
    let organizationName: String
    let startDate: Date
    let endDate: Date?
    let isCurrent: Bool
}

struct TransferCustomerOption: Identifiable, Equatable {
    let id: UUID
    let name: String
    let contactName: String
    let city: String
    let state: String

    static func == (lhs: TransferCustomerOption, rhs: TransferCustomerOption) -> Bool {
        lhs.id == rhs.id
    }
}

struct MachineOption: Identifiable, Equatable {
    let id: UUID
    let name: String
    let model: String
    let serialNumber: String
    let currentOwner: String

    static func == (lhs: MachineOption, rhs: MachineOption) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mock Data

enum AssetTransferMockData {

    // MARK: Customers

    static let customers: [TransferCustomerOption] = [
        TransferCustomerOption(
            id: UUID(uuidString: "A1111111-1111-1111-1111-111111111111")!,
            name: "Hershey Chocolate Co.",
            contactName: "James Rivera",
            city: "Hershey",
            state: "PA"
        ),
        TransferCustomerOption(
            id: UUID(uuidString: "A2222222-2222-2222-2222-222222222222")!,
            name: "Mercer Foods LLC",
            contactName: "Sarah Chen",
            city: "Modesto",
            state: "CA"
        ),
        TransferCustomerOption(
            id: UUID(uuidString: "A3333333-3333-3333-3333-333333333333")!,
            name: "Albanese Confectionery",
            contactName: "Tom Albanese",
            city: "Merrillville",
            state: "IN"
        ),
        TransferCustomerOption(
            id: UUID(uuidString: "A4444444-4444-4444-4444-444444444444")!,
            name: "SunChips Manufacturing",
            contactName: "Diana Flores",
            city: "Modesto",
            state: "CA"
        ),
        TransferCustomerOption(
            id: UUID(uuidString: "A5555555-5555-5555-5555-555555555555")!,
            name: "Kettle Brand Foods",
            contactName: "Ryan Choi",
            city: "Salem",
            state: "OR"
        ),
    ]

    // MARK: Machines

    static let machines: [MachineOption] = [
        MachineOption(
            id: UUID(uuidString: "B1111111-1111-1111-1111-111111111111")!,
            name: "M-200 FFS Packaging Line",
            model: "M-200",
            serialNumber: "22-42490227",
            currentOwner: "Hershey Chocolate Co."
        ),
        MachineOption(
            id: UUID(uuidString: "B2222222-2222-2222-2222-222222222222")!,
            name: "Vega 285 PM Pouch Maker",
            model: "Vega 285 PM",
            serialNumber: "21-38741005",
            currentOwner: "Mercer Foods LLC"
        ),
        MachineOption(
            id: UUID(uuidString: "B3333333-3333-3333-3333-333333333333")!,
            name: "Win 750 P Wicketer",
            model: "Win 750 P",
            serialNumber: "23-50128344",
            currentOwner: "Albanese Confectionery"
        ),
        MachineOption(
            id: UUID(uuidString: "B4444444-4444-4444-4444-444444444444")!,
            name: "M-300 HFFS Line",
            model: "M-300",
            serialNumber: "20-31987620",
            currentOwner: "SunChips Manufacturing"
        ),
    ]

    // MARK: Sample Transfers (2 as required)

    static let sampleTransfers: [TransferDisplayItem] = [
        TransferDisplayItem(
            id: UUID(uuidString: "C1111111-1111-1111-1111-111111111111")!,
            machineName: "M-200 FFS Packaging Line",
            machineSerial: "22-42490227",
            machineModel: "M-200",
            fromCustomerName: "Hershey Chocolate Co.",
            toCustomerName: "Albanese Confectionery",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            status: .pending,
            includesAudit: true,
            notes: "Machine sold after warranty period. Buyer requested full audit before handover."
        ),
        TransferDisplayItem(
            id: UUID(uuidString: "C2222222-2222-2222-2222-222222222222")!,
            machineName: "Vega 285 PM Pouch Maker",
            machineSerial: "21-38741005",
            machineModel: "Vega 285 PM",
            fromCustomerName: "Mercer Foods LLC",
            toCustomerName: "Kettle Brand Foods",
            date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
            status: .completed,
            includesAudit: false,
            notes: nil
        ),
    ]

    // MARK: Custody Chain (3-owner chain as required)

    static let custodyChainForM200: [CustodyEntry] = [
        CustodyEntry(
            id: UUID(uuidString: "D1111111-1111-1111-1111-111111111111")!,
            ownerName: "SunChips Manufacturing",
            organizationName: "SunChips Manufacturing Inc.",
            startDate: dateFrom(year: 2020, month: 6, day: 15),
            endDate: dateFrom(year: 2022, month: 3, day: 10),
            isCurrent: false
        ),
        CustodyEntry(
            id: UUID(uuidString: "D2222222-2222-2222-2222-222222222222")!,
            ownerName: "Hershey Chocolate Co.",
            organizationName: "The Hershey Company",
            startDate: dateFrom(year: 2022, month: 3, day: 10),
            endDate: dateFrom(year: 2026, month: 3, day: 31),
            isCurrent: false
        ),
        CustodyEntry(
            id: UUID(uuidString: "D3333333-3333-3333-3333-333333333333")!,
            ownerName: "Albanese Confectionery",
            organizationName: "Albanese Confectionery Group Inc.",
            startDate: dateFrom(year: 2026, month: 3, day: 31),
            endDate: nil,
            isCurrent: true
        ),
    ]

    // MARK: Helpers

    private static func dateFrom(year: Int, month: Int, day: Int) -> Date {
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = day
        return Calendar.current.date(from: comps) ?? Date()
    }
}
