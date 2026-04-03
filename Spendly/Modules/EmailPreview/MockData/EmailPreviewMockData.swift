import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Email Preview Display Model

struct EmailPreviewDisplayModel: Identifiable {
    let id: UUID
    var subject: String
    var fromAddress: String
    var reportNumber: String
    var customerName: String
    var recipients: [EmailPreviewRecipient]
    var bodyGreeting: String
    var bodyText: String
    var workSummary: String
    var closingText: String
    var senderName: String
    var senderTeam: String
    var attachment: EmailAttachment
    var serviceDate: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: serviceDate)
    }
}

// MARK: - Email Preview Recipient

struct EmailPreviewRecipient: Identifiable {
    let id: UUID
    var name: String
    var role: RecipientRole

    enum RecipientRole: String {
        case requestor = "Requestor"
        case signatory = "Signatory"
        case cc = "CC"

        var icon: String {
            switch self {
            case .requestor: return "person"
            case .signatory: return "signature"
            case .cc:        return "person.2"
            }
        }

        var isPrimary: Bool {
            switch self {
            case .requestor, .signatory: return true
            case .cc: return false
            }
        }
    }
}

// MARK: - Email Attachment

struct EmailAttachment: Identifiable {
    let id: UUID
    var fileName: String
    var fileSize: String
    var fileType: AttachmentType

    enum AttachmentType {
        case pdf
        case image
        case document

        var icon: String {
            switch self {
            case .pdf:      return "doc.richtext"
            case .image:    return "photo"
            case .document: return "doc.text"
            }
        }

        var tintColor: Color {
            switch self {
            case .pdf:      return SpendlyColors.error
            case .image:    return SpendlyColors.info
            case .document: return SpendlyColors.primary
            }
        }
    }
}

// MARK: - Send State

enum EmailSendState: Equatable {
    case idle
    case sending
    case success(sentTo: [String])
    case failed(message: String)
}

// MARK: - Mock Data

enum EmailPreviewMockData {

    static let sampleEmail = EmailPreviewDisplayModel(
        id: UUID(),
        subject: "Trip Completion Report: Global Logistics Hub - TCR-2024-089",
        fromAddress: "service@fieldtech.com",
        reportNumber: "TCR-2024-089",
        customerName: "Global Logistics Hub",
        recipients: [
            EmailPreviewRecipient(
                id: UUID(),
                name: "John Doe",
                role: .requestor
            ),
            EmailPreviewRecipient(
                id: UUID(),
                name: "Jane Smith",
                role: .signatory
            ),
            EmailPreviewRecipient(
                id: UUID(),
                name: "Operations Team",
                role: .cc
            )
        ],
        bodyGreeting: "Dear John,",
        bodyText: "We are pleased to inform you that the requested service at Global Logistics Hub has been completed. Please find the detailed Trip Completion Report (TCR-2024-089) attached for your review and records.",
        workSummary: "Completed preventive maintenance on Zone 4 conveyor systems, replaced primary drive belts, and calibrated alignment sensors. System test successful.",
        closingText: "If you have any questions regarding the details of this report, please contact our support team.",
        senderName: "Field Service Team",
        senderTeam: "Field Service Pro",
        attachment: EmailAttachment(
            id: UUID(),
            fileName: "TCR-2024-089.pdf",
            fileSize: "2.4 MB",
            fileType: .pdf
        ),
        serviceDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    )

    static let sampleEmail2 = EmailPreviewDisplayModel(
        id: UUID(),
        subject: "Trip Completion Report: Metro Health Systems - TCR-2024-090",
        fromAddress: "service@fieldtech.com",
        reportNumber: "TCR-2024-090",
        customerName: "Metro Health Systems",
        recipients: [
            EmailPreviewRecipient(
                id: UUID(),
                name: "Dr. Sarah Lee",
                role: .requestor
            ),
            EmailPreviewRecipient(
                id: UUID(),
                name: "Admin Office",
                role: .signatory
            )
        ],
        bodyGreeting: "Dear Dr. Lee,",
        bodyText: "We are pleased to inform you that the requested generator maintenance at Metro Health Systems has been completed. Please find the detailed Trip Completion Report (TCR-2024-090) attached for your review and records.",
        workSummary: "Annual generator maintenance complete. Replaced batteries, performed full coolant flush, and load tested transfer switch. All systems passed.",
        closingText: "If you have any questions regarding the details of this report, please contact our support team.",
        senderName: "Field Service Team",
        senderTeam: "Field Service Pro",
        attachment: EmailAttachment(
            id: UUID(),
            fileName: "TCR-2024-090.pdf",
            fileSize: "3.1 MB",
            fileType: .pdf
        ),
        serviceDate: Calendar.current.date(byAdding: .day, value: -2, to: Date())!
    )
}
