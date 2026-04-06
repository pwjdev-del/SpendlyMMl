import Foundation
import SwiftUI
import SpendlyCore
#if canImport(UIKit)
import UIKit
#endif
#if canImport(MessageUI)
import MessageUI
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
    var manualStartTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    var manualEndTime: Date = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
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
    var showMailCompose: Bool = false
    var showEmailConfirmation: Bool = false
    var emailConfirmationMessage: String = ""

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
        // Refresh email body so additionalWorkText edits are captured
        refreshEmailBody()
        navigationPath.append(TripReportRoute.pdfPreview(trip.id))
    }

    func navigateToEmailReport() {
        guard let trip = selectedTrip else { return }
        // Refresh email body so additionalWorkText edits are captured
        refreshEmailBody()
        navigationPath.append(TripReportRoute.emailReport(trip.id))
    }

    func generatePDF() {
        isGeneratingPDF = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            if let trip = self.selectedTrip {
                let serviceTrip = self.buildServiceTrip(from: trip)
                self.pdfData = PDFGenerator.shared.generateTripReportPDF(trip: serviceTrip)
            }
            self.isGeneratingPDF = false
        }
    }

    /// Maps the current TripReportDisplayModel (plus any edits the user made
    /// on the completion form) into a ServiceTrip that the PDFGenerator expects.
    private func buildServiceTrip(from display: TripReportDisplayModel) -> ServiceTrip {
        // Build a JSON-encoded parts manifest from the display model's parts list
        let partsDescriptions = display.partsUsed.map { part in
            "\(part.name) x\(part.quantity) @ \(CurrencyFormatter.shared.format(part.unitPrice))"
        }

        // Append additional-work items so they are captured in the parts/summary blob
        let additionalWorkDescriptions = display.additionalWorkItems.map { item in
            "[Additional] \(item.title): \(item.description) (\(CurrencyFormatter.shared.format(item.cost)))"
        }

        let allParts = (partsDescriptions + additionalWorkDescriptions).joined(separator: "; ")

        // Build a comprehensive summary that includes task list, additional-work
        // notes entered by the technician, and the trip notes.
        var summaryParts: [String] = []

        // Completed tasks
        let taskList = display.completedTasks.map { task in
            "\(task.isCompleted ? "[Done]" : "[Open]") \(task.name)"
        }.joined(separator: "\n")
        if !taskList.isEmpty {
            summaryParts.append("Tasks:\n\(taskList)")
        }

        // BUG 3 FIX: Include additionalWorkText that the technician entered
        let trimmedAdditionalWork = additionalWorkText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedAdditionalWork.isEmpty {
            summaryParts.append("Additional Work Notes:\n\(trimmedAdditionalWork)")
        }

        let summary = summaryParts.joined(separator: "\n\n")

        // Combine trip notes with any additional work text for the technician notes
        var techNotes = tripNotes
        if !trimmedAdditionalWork.isEmpty {
            techNotes += "\n\nAdditional Work Notes:\n\(trimmedAdditionalWork)"
        }

        // Determine labor hours -- prefer manual time entry if the user toggled it on
        let effectiveHours: Double = showManualTimeEntry ? manualHoursWorked : display.laborHours

        return ServiceTrip(
            id: display.id,
            status: .completed,
            scheduledDate: display.serviceDate,
            startTime: display.manualTimeEntry?.startTime ?? manualStartTime,
            endTime: display.manualTimeEntry?.endTime ?? manualEndTime,
            summary: summary,
            technicianNotes: techNotes,
            partsUsed: allParts,
            hoursWorked: effectiveHours
        )
    }

    /// Whether the device can present the native mail composer (MessageUI).
    var canSendNativeMail: Bool {
        #if canImport(MessageUI)
        return MFMailComposeViewController.canSendMail()
        #else
        return false
        #endif
    }

    func sendEmail() {
        guard !selectedRecipientEmails.isEmpty else { return }
        let emails = selectedRecipientEmails

        // If the device supports native mail, present MFMailComposeViewController
        if canSendNativeMail {
            showMailCompose = true
            return
        }

        // Fallback: show a detailed confirmation alert with recipient list and trip summary,
        // then proceed to the success screen.
        isSendingEmail = true
        let tripSummary: String
        if let trip = selectedTrip {
            tripSummary = """
            Report: \(trip.reportNumber)
            Customer: \(trip.customerName)
            Date: \(trip.formattedServiceDate)
            Total: \(CurrencyFormatter.shared.format(trip.grandTotal))
            """
        } else {
            tripSummary = "(no trip selected)"
        }

        emailConfirmationMessage = """
        The following report will be sent to \(emails.count) recipient\(emails.count == 1 ? "" : "s"):

        \(emails.joined(separator: "\n"))

        \(tripSummary)

        Note: Native email is not available on this device. \
        In production the report will be sent via the server-side email service.
        """
        showEmailConfirmation = true
    }

    /// Called after the user confirms the email-send alert (fallback path).
    func confirmEmailSend() {
        isSendingEmail = true
        let emails = selectedRecipientEmails
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.isSendingEmail = false
            self.navigationPath.append(TripReportRoute.sendSuccess(sentTo: emails))
        }
    }

    /// Called when the native MFMailComposeViewController completes.
    func handleMailComposeResult(success: Bool) {
        showMailCompose = false
        if success {
            let emails = selectedRecipientEmails
            navigationPath.append(TripReportRoute.sendSuccess(sentTo: emails))
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

    /// Regenerates the email body. Call this whenever trip data or additionalWorkText changes
    /// so the email preview stays current.
    func refreshEmailBody() {
        guard let trip = selectedTrip else { return }
        generateEmailBody(for: trip)
    }

    private func generateEmailBody(for trip: TripReportDisplayModel) {
        let trimmedAdditionalWork = additionalWorkText.trimmingCharacters(in: .whitespacesAndNewlines)

        // BUG 3 FIX: Include additional work notes in the email body when present
        let additionalWorkSection: String
        if !trimmedAdditionalWork.isEmpty {
            additionalWorkSection = """

            Additional Work Notes:
            \(trimmedAdditionalWork)

            """
        } else {
            additionalWorkSection = "\n"
        }

        emailBody = """
        Dear Customer,

        Please find attached the Trip Completion Report for the service performed on \(trip.formattedServiceDate).

        Report: \(trip.reportNumber)
        Technician: \(trip.technicianName)
        Total: \(CurrencyFormatter.shared.format(trip.grandTotal))
        \(additionalWorkSection)
        If you have any questions about this report, please don't hesitate to reach out.

        Best regards,
        \(trip.companyName)
        """
    }
}
