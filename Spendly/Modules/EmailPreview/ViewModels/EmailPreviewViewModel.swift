import Foundation
import SwiftUI
import SpendlyCore

// MARK: - EmailPreviewViewModel

@Observable
final class EmailPreviewViewModel {

    // MARK: State

    var email: EmailPreviewDisplayModel = EmailPreviewMockData.sampleEmail
    var sendState: EmailSendState = .idle
    var showPreviewSheet: Bool = true
    var showSuccessScreen: Bool = false

    // MARK: Computed

    var isSending: Bool {
        sendState == .sending
    }

    var primaryRecipients: [EmailPreviewRecipient] {
        email.recipients.filter { $0.role.isPrimary }
    }

    var ccRecipients: [EmailPreviewRecipient] {
        email.recipients.filter { !$0.role.isPrimary }
    }

    var recipientSummary: String {
        let names = email.recipients.map { "\($0.role.rawValue): \($0.name)" }
        return names.joined(separator: ", ")
    }

    // MARK: Actions

    func sendEmail() {
        guard !isSending else { return }
        sendState = .sending

        // Simulate network send
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            let sentTo = self.email.recipients.map(\.name)
            self.sendState = .success(sentTo: sentTo)
            self.showPreviewSheet = false
            self.showSuccessScreen = true
        }
    }

    func goBackToEdit() {
        showPreviewSheet = false
    }

    func resetToPreview() {
        sendState = .idle
        showPreviewSheet = true
        showSuccessScreen = false
    }

    func backToSchedule() {
        showSuccessScreen = false
        showPreviewSheet = false
    }

    func viewSentReport() {
        // Placeholder for navigating to sent report
        backToSchedule()
    }

    func startNewJob() {
        // Placeholder for navigating to new job creation
        backToSchedule()
    }

    func loadEmail(_ email: EmailPreviewDisplayModel) {
        self.email = email
        self.sendState = .idle
        self.showPreviewSheet = true
        self.showSuccessScreen = false
    }
}
