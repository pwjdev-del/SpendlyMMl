import Foundation
import SwiftUI
import SpendlyCore
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Navigation State

enum TripReportRoute: Hashable {
    case completion(UUID)
    case pdfPreview(UUID)
    case emailReport(UUID)
    case sendSuccess(sentTo: [String])
}

// MARK: - TripReportViewModel

@Observable
final class TripReportViewModel {

    // MARK: Navigation

    var navigationPath = NavigationPath()

    // MARK: Trip List

    var completedTrips: [TripReportDisplayModel] = TripReportMockData.completedTrips
    var searchText: String = ""

    var filteredTrips: [TripReportDisplayModel] {
        guard !searchText.isEmpty else { return completedTrips }
        let query = searchText.lowercased()
        return completedTrips.filter {
            $0.customerName.lowercased().contains(query) ||
            $0.reportNumber.lowercased().contains(query) ||
            $0.technicianName.lowercased().contains(query)
        }
    }

    // MARK: Trip Completion Form

    var selectedTrip: TripReportDisplayModel?
    var additionalWorkText: String = ""
    var tripNotes: String = ""
    var manualStartTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    var manualEndTime: Date = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!
    var manualBreakMinutes: Int = 0
    var showManualTimeEntry: Bool = false

    #if canImport(UIKit)
    var customerSignature: UIImage?
    var technicianSignature: UIImage?
    #endif

    // MARK: PDF Preview

    var isGeneratingPDF: Bool = false
    var pdfData: Data?

    // MARK: Email

    var recipients: [EmailRecipient] = TripReportMockData.defaultRecipients
    var additionalEmails: String = ""
    var copyToTechnician: Bool = false
    var isSendingEmail: Bool = false
    var emailBody: String = ""

    var selectedRecipientEmails: [String] {
        var emails = recipients.filter(\.isSelected).map(\.email)
        let additional = additionalEmails
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        emails.append(contentsOf: additional)
        if copyToTechnician, let trip = selectedTrip {
            emails.append(trip.technicianEmail)
        }
        return emails
    }

    var selectedRecipientCount: Int {
        selectedRecipientEmails.count
    }

    // MARK: Computed Charge Lines

    func chargeLines(for trip: TripReportDisplayModel) -> [ChargeLineItem] {
        var lines: [ChargeLineItem] = []
        lines.append(ChargeLineItem(
            id: UUID(),
            description: "Labor (\(String(format: "%.1f", trip.laborHours)) hrs @ \(CurrencyFormatter.shared.format(trip.laborRate))/hr)",
            amount: trip.laborTotal
        ))
        if trip.materialsTotal > 0 {
            lines.append(ChargeLineItem(
                id: UUID(),
                description: "Materials & Parts",
                amount: trip.materialsTotal
            ))
        }
        if trip.additionalWorkTotal > 0 {
            lines.append(ChargeLineItem(
                id: UUID(),
                description: "Additional Work Total",
                amount: trip.additionalWorkTotal
            ))
        }
        if trip.travelCharge > 0 {
            lines.append(ChargeLineItem(
                id: UUID(),
                description: "Travel Charge",
                amount: trip.travelCharge
            ))
        }
        return lines
    }

    var manualHoursWorked: Double {
        let interval = manualEndTime.timeIntervalSince(manualStartTime)
        let breakInterval = Double(manualBreakMinutes) * 60
        return max(0, (interval - breakInterval) / 3600)
    }

    // MARK: Actions

    func selectTrip(_ trip: TripReportDisplayModel) {
        selectedTrip = trip
        tripNotes = trip.tripNotes
        if let timeEntry = trip.manualTimeEntry {
            manualStartTime = timeEntry.startTime
            manualEndTime = timeEntry.endTime
            manualBreakMinutes = timeEntry.breakMinutes
            showManualTimeEntry = true
        }
        generateEmailBody(for: trip)
        navigationPath.append(TripReportRoute.completion(trip.id))
    }

    func navigateToPDFPreview() {
        guard let trip = selectedTrip else { return }
        navigationPath.append(TripReportRoute.pdfPreview(trip.id))
    }

    func navigateToEmailReport() {
        guard let trip = selectedTrip else { return }
        navigationPath.append(TripReportRoute.emailReport(trip.id))
    }

    func generatePDF() {
        isGeneratingPDF = true
        // Simulate PDF generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            if let trip = self.selectedTrip {
                self.pdfData = PDFGenerator.shared.generateTripReportPDF(trip: ServiceTrip())
            }
            self.isGeneratingPDF = false
        }
    }

    func sendEmail() {
        guard !selectedRecipientEmails.isEmpty else { return }
        isSendingEmail = true
        let emails = selectedRecipientEmails
        // Simulate send
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.isSendingEmail = false
            self.navigationPath.append(TripReportRoute.sendSuccess(sentTo: emails))
        }
    }

    func toggleRecipient(_ recipient: EmailRecipient) {
        if let index = recipients.firstIndex(where: { $0.id == recipient.id }) {
            recipients[index].isSelected.toggle()
        }
    }

    func resetToRoot() {
        navigationPath = NavigationPath()
        selectedTrip = nil
        #if canImport(UIKit)
        customerSignature = nil
        technicianSignature = nil
        #endif
        additionalWorkText = ""
        tripNotes = ""
        showManualTimeEntry = false
        recipients = TripReportMockData.defaultRecipients
        additionalEmails = ""
        copyToTechnician = false
    }

    func clearCustomerSignature() {
        #if canImport(UIKit)
        customerSignature = nil
        #endif
    }

    func clearTechnicianSignature() {
        #if canImport(UIKit)
        technicianSignature = nil
        #endif
    }

    // MARK: Email Body Generation

    private func generateEmailBody(for trip: TripReportDisplayModel) {
        emailBody = """
        Dear Customer,

        Please find attached the Trip Completion Report for the service performed on \(trip.formattedServiceDate).

        Report: \(trip.reportNumber)
        Technician: \(trip.technicianName)
        Total: \(CurrencyFormatter.shared.format(trip.grandTotal))

        If you have any questions about this report, please don't hesitate to reach out.

        Best regards,
        \(trip.companyName)
        """
    }
}
