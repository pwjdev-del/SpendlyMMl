import Foundation

// MARK: - AI Service Protocol

public protocol AIServiceProtocol {
    func transcribeAudio(data: Data, language: String?) async throws -> TranscriptionResult
    func extractSymptoms(from text: String) async throws -> DiagnosticExtraction
    func categorizeIssue(description: String) async throws -> IssueCategory
    func translateText(_ text: String, to language: String) async throws -> String
    func generateReportNarrative(from tripData: ServiceTripSummary) async throws -> String
}

// MARK: - Transcription Result

public struct TranscriptionResult: Codable, Sendable {
    public var text: String
    public var detectedLanguage: String
    public var confidence: Double
    public var segments: [TranscriptionSegment]

    public init(
        text: String,
        detectedLanguage: String,
        confidence: Double,
        segments: [TranscriptionSegment] = []
    ) {
        self.text = text
        self.detectedLanguage = detectedLanguage
        self.confidence = confidence
        self.segments = segments
    }
}

// MARK: - Transcription Segment

public struct TranscriptionSegment: Codable, Sendable {
    public var text: String
    public var language: String
    public var startTime: Double
    public var endTime: Double

    public init(
        text: String,
        language: String,
        startTime: Double,
        endTime: Double
    ) {
        self.text = text
        self.language = language
        self.startTime = startTime
        self.endTime = endTime
    }
}

// MARK: - Diagnostic Extraction

public struct DiagnosticExtraction: Codable, Sendable {
    public var symptoms: [String]
    public var actionsTaken: [String]
    public var partsMentioned: [String]
    public var suggestedCategory: String
    public var confidence: Double

    public init(
        symptoms: [String],
        actionsTaken: [String],
        partsMentioned: [String],
        suggestedCategory: String,
        confidence: Double
    ) {
        self.symptoms = symptoms
        self.actionsTaken = actionsTaken
        self.partsMentioned = partsMentioned
        self.suggestedCategory = suggestedCategory
        self.confidence = confidence
    }
}

// MARK: - Issue Category

public struct IssueCategory: Codable, Sendable {
    public var primary: String
    public var subCategory: String?
    public var confidence: Double

    public init(
        primary: String,
        subCategory: String? = nil,
        confidence: Double
    ) {
        self.primary = primary
        self.subCategory = subCategory
        self.confidence = confidence
    }
}

// MARK: - Service Trip Summary

public struct ServiceTripSummary: Codable, Sendable {
    public var technicianName: String
    public var customerName: String
    public var machineName: String
    public var tasksCompleted: [String]
    public var hoursWorked: Double
    public var partsUsed: [String]

    public init(
        technicianName: String,
        customerName: String,
        machineName: String,
        tasksCompleted: [String],
        hoursWorked: Double,
        partsUsed: [String]
    ) {
        self.technicianName = technicianName
        self.customerName = customerName
        self.machineName = machineName
        self.tasksCompleted = tasksCompleted
        self.hoursWorked = hoursWorked
        self.partsUsed = partsUsed
    }
}
