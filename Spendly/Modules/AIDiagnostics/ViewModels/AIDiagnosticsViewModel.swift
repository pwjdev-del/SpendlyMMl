import SwiftUI
import Combine
import SpendlyCore

// MARK: - AIDiagnosticsViewModel

@Observable
final class AIDiagnosticsViewModel {

    // MARK: - Recording State

    var recordingState: RecordingState = .idle
    var sessionSeconds: TimeInterval = 0
    var isLiveTranslationOn: Bool = true
    var isCodeSwitchingActive: Bool = false
    var sessionID: String = "#VD-9421"

    // MARK: - Language

    var detectedLanguage: String = "Spanish"
    var targetLanguage: String = "English"
    var supportedLanguages: [SupportedLanguage] = AIDiagnosticsMockData.supportedLanguages

    // MARK: - Transcription

    var originalTranscription: String = ""
    var translatedTranscription: String = ""
    var transcriptionSegments: [TranscriptionSegmentDisplay] = []
    var editedTranscription: String = ""
    var isEditingTranscription: Bool = false

    // MARK: - AI Extraction Results

    var extractedItems: [ExtractedItem] = []
    var categoryMapping: IssueCategoryMapping?
    var overallConfidence: Double = 0.0

    // MARK: - Waveform

    var waveformAmplitudes: [CGFloat] = AIDiagnosticsMockData.waveformAmplitudes
    var currentWaveformPhase: Double = 0

    // MARK: - Machine Selection

    var machineTemplates: [MachineTemplate] = AIDiagnosticsMockData.mockMachineTemplates
    var selectedMachineIndex: Int = 0

    var selectedMachine: MachineTemplate {
        guard machineTemplates.indices.contains(selectedMachineIndex) else {
            return machineTemplates.first ?? MachineTemplate(name: "Unknown", serialNumber: "N/A", model: "N/A")
        }
        return machineTemplates[selectedMachineIndex]
    }

    // MARK: - Wizard State

    var currentWizardStep: DiagnosticWizardStep = .systemSelection
    var systemTypes: [SystemType] = AIDiagnosticsMockData.systemTypes
    var selectedSystemType: SystemType?
    var components: [ComponentOption] = AIDiagnosticsMockData.electricalComponents
    var selectedComponent: ComponentOption?
    var symptomChips: [SymptomChip] = AIDiagnosticsMockData.symptomChips
    var detailDescription: String = ""
    var selectedUrgency: UrgencyLevel = .standard

    // MARK: - Photo Upload

    var uploadedPhotoCount: Int = 2
    let maxPhotos: Int = 5

    // MARK: - Navigation

    var showTranscriptionResult: Bool = false
    var showDiagnosticWizard: Bool = false
    var showLanguagePicker: Bool = false
    var showReportSubmitted: Bool = false

    // MARK: - Timer Publisher

    private var timerCancellable: AnyCancellable?
    private var waveformCancellable: AnyCancellable?

    // MARK: - Init

    init() {
        selectedSystemType = systemTypes.first
        selectedComponent = components.first
    }

    // MARK: - Recording Controls

    func startRecording() {
        recordingState = .recording
        sessionSeconds = 0
        originalTranscription = ""
        translatedTranscription = ""
        transcriptionSegments = []
        extractedItems = []
        categoryMapping = nil

        startSessionTimer()
        startWaveformAnimation()

        // Simulate transcription arriving after 4 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
            self?.simulateTranscriptionReceived()
        }
    }

    func stopRecording() {
        recordingState = .processing

        timerCancellable?.cancel()
        timerCancellable = nil

        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.simulateAIExtraction()
            self?.recordingState = .completed
            self?.waveformCancellable?.cancel()
            self?.waveformCancellable = nil
        }
    }

    func resetSession() {
        recordingState = .idle
        sessionSeconds = 0
        originalTranscription = ""
        translatedTranscription = ""
        transcriptionSegments = []
        extractedItems = []
        categoryMapping = nil
        overallConfidence = 0.0
        editedTranscription = ""
        isEditingTranscription = false
        isCodeSwitchingActive = false
        showTranscriptionResult = false

        timerCancellable?.cancel()
        waveformCancellable?.cancel()
    }

    // MARK: - Session Timer

    private func startSessionTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.recordingState == .recording else { return }
                self.sessionSeconds += 1
            }
    }

    // MARK: - Waveform Animation

    private func startWaveformAnimation() {
        waveformCancellable = Timer.publish(every: 0.15, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.recordingState == .recording else { return }
                self.currentWaveformPhase += 0.3
                // Randomize amplitudes slightly for a live feel
                for i in self.waveformAmplitudes.indices {
                    let base = AIDiagnosticsMockData.waveformAmplitudes[i]
                    let variance = CGFloat.random(in: -0.15...0.15)
                    self.waveformAmplitudes[i] = max(0.1, min(1.0, base + variance))
                }
            }
    }

    // MARK: - Simulated AI

    private func simulateTranscriptionReceived() {
        guard recordingState == .recording else { return }

        if isCodeSwitchingActive {
            transcriptionSegments = AIDiagnosticsMockData.mockCodeSwitchSegments
            originalTranscription = AIDiagnosticsMockData.mockCodeSwitchOriginal
            translatedTranscription = AIDiagnosticsMockData.mockCodeSwitchStandardized
            detectedLanguage = "Mixed (EN/HI)"
        } else {
            transcriptionSegments = AIDiagnosticsMockData.mockSegments
            originalTranscription = AIDiagnosticsMockData.mockOriginalText
            translatedTranscription = AIDiagnosticsMockData.mockTranslatedText
            detectedLanguage = "Spanish"
        }

        editedTranscription = translatedTranscription
    }

    private func simulateAIExtraction() {
        extractedItems = AIDiagnosticsMockData.mockExtractedItems
        categoryMapping = AIDiagnosticsMockData.mockCategoryMapping
        overallConfidence = 0.92
        showTranscriptionResult = true
    }

    // MARK: - Language Selection

    func selectLanguage(_ language: SupportedLanguage) {
        detectedLanguage = language.name
        showLanguagePicker = false
    }

    // MARK: - Extracted Item Actions

    func toggleItemAcceptance(itemID: UUID) {
        guard let idx = extractedItems.firstIndex(where: { $0.id == itemID }) else { return }
        extractedItems[idx].isAccepted.toggle()
    }

    func removeExtractedItem(itemID: UUID) {
        extractedItems.removeAll { $0.id == itemID }
    }

    // MARK: - Transcription Editing

    func startEditingTranscription() {
        isEditingTranscription = true
        editedTranscription = translatedTranscription
    }

    func saveTranscriptionEdit() {
        translatedTranscription = editedTranscription
        isEditingTranscription = false
    }

    func cancelTranscriptionEdit() {
        editedTranscription = translatedTranscription
        isEditingTranscription = false
    }

    // MARK: - Wizard Navigation

    func nextWizardStep() {
        guard let nextStep = DiagnosticWizardStep(rawValue: currentWizardStep.rawValue + 1) else { return }
        currentWizardStep = nextStep
    }

    func previousWizardStep() {
        guard let prevStep = DiagnosticWizardStep(rawValue: currentWizardStep.rawValue - 1) else { return }
        currentWizardStep = prevStep
    }

    func selectSystemType(_ type: SystemType) {
        selectedSystemType = type
        // Update available components based on system type
        switch type.name {
        case "Electrical & Programming":
            components = AIDiagnosticsMockData.electricalComponents
        case "Mechanical & Hardware":
            components = AIDiagnosticsMockData.mechanicalComponents
        case "Pneumatic System":
            components = AIDiagnosticsMockData.pneumaticComponents
        default:
            components = AIDiagnosticsMockData.electricalComponents
        }
        selectedComponent = components.first
    }

    func toggleSymptomChip(chipID: UUID) {
        guard let idx = symptomChips.firstIndex(where: { $0.id == chipID }) else { return }
        symptomChips[idx].isSelected.toggle()
    }

    // MARK: - Code Switching

    func toggleCodeSwitching() {
        isCodeSwitchingActive.toggle()
    }

    // MARK: - Submit Report

    func submitDiagnosticReport() {
        showReportSubmitted = true

        // Reset after delay for demo
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showReportSubmitted = false
        }
    }

    // MARK: - Timer Formatting

    var formattedSessionTime: String {
        let minutes = Int(sessionSeconds) / 60
        let seconds = Int(sessionSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Computed

    var acceptedItems: [ExtractedItem] {
        extractedItems.filter(\.isAccepted)
    }

    var symptoms: [ExtractedItem] {
        extractedItems.filter { $0.category == .symptom }
    }

    var actions: [ExtractedItem] {
        extractedItems.filter { $0.category == .action }
    }

    var parts: [ExtractedItem] {
        extractedItems.filter { $0.category == .part }
    }

    var selectedSymptomNames: [String] {
        symptomChips.filter(\.isSelected).map(\.name)
    }

    var wizardProgress: Double {
        Double(currentWizardStep.rawValue + 1) / Double(DiagnosticWizardStep.allCases.count)
    }

    var canProceedWizard: Bool {
        switch currentWizardStep {
        case .systemSelection:    return selectedSystemType != nil
        case .componentSelection: return selectedComponent != nil
        case .symptoms:           return symptomChips.contains(where: \.isSelected)
        case .evidence:           return true
        case .impact:             return true
        }
    }

    // MARK: - Cleanup

    func cleanup() {
        timerCancellable?.cancel()
        waveformCancellable?.cancel()
    }
}
