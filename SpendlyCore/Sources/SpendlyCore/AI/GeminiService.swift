import Foundation

/// Mock implementation of AIServiceProtocol using Gemini 2.0 Flash.
/// Returns realistic data matching the Mamata packaging machine domain.
/// Will be replaced with real Gemini API calls once the API key is configured.
public class GeminiService: AIServiceProtocol {
    public static let shared = GeminiService()

    public init() {}

    public func transcribeAudio(data: Data, language: String?) async throws -> TranscriptionResult {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 1_500_000_000)

        return TranscriptionResult(
            text: "The electrical system appears to be failing when the temperature rises above normal operating range. The control board assembly shows intermittent faults.",
            detectedLanguage: language ?? "en",
            confidence: 0.94,
            segments: [
                TranscriptionSegment(
                    text: "The electrical system appears to be failing when the temperature rises above normal operating range.",
                    language: language ?? "en",
                    startTime: 0.0,
                    endTime: 4.8
                ),
                TranscriptionSegment(
                    text: "The control board assembly shows intermittent faults.",
                    language: language ?? "en",
                    startTime: 5.0,
                    endTime: 8.2
                )
            ]
        )
    }

    public func extractSymptoms(from text: String) async throws -> DiagnosticExtraction {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        return DiagnosticExtraction(
            symptoms: [
                "Intermittent electrical faults",
                "Temperature-related failures",
                "Control board malfunction above operating range"
            ],
            actionsTaken: [
                "Inspected control board",
                "Checked wiring connections",
                "Measured temperature readings at multiple points"
            ],
            partsMentioned: [
                "Control Board Assembly",
                "Temperature Sensor",
                "Wiring Harness"
            ],
            suggestedCategory: "Electrical",
            confidence: 0.89
        )
    }

    public func categorizeIssue(description: String) async throws -> IssueCategory {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 800_000_000)

        return IssueCategory(
            primary: "Electrical",
            subCategory: "Control Board Assembly",
            confidence: 0.92
        )
    }

    public func translateText(_ text: String, to language: String) async throws -> String {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Mock: return the same text
        // Real implementation will use Gemini for translation
        return text
    }

    public func generateReportNarrative(from tripData: ServiceTripSummary) async throws -> String {
        // Simulate processing delay
        try await Task.sleep(nanoseconds: 1_200_000_000)

        return """
        Service Report: On-site visit to \(tripData.customerName) for maintenance of \(tripData.machineName). \
        Technician \(tripData.technicianName) completed \(tripData.tasksCompleted.count) task(s) over \
        \(String(format: "%.1f", tripData.hoursWorked)) hours. \
        Tasks performed included \(tripData.tasksCompleted.joined(separator: ", ")). \
        Parts utilized during the service: \(tripData.partsUsed.joined(separator: ", ")). \
        The machine was restored to full operational status following the completion of all scheduled maintenance procedures. \
        A follow-up inspection is recommended within 30 days to verify continued performance stability.
        """
    }
}
