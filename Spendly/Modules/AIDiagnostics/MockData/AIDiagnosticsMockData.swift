import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Supported Language

struct SupportedLanguage: Identifiable, Hashable {
    let id: String
    var name: String
    var nativeName: String
    var code: String

    init(id: String = UUID().uuidString, name: String, nativeName: String, code: String) {
        self.id = id
        self.name = name
        self.nativeName = nativeName
        self.code = code
    }
}

// MARK: - Transcription Segment Display

struct TranscriptionSegmentDisplay: Identifiable {
    let id: UUID
    var text: String
    var language: String
    var startTime: Double
    var endTime: Double
    var isCodeSwitch: Bool

    init(
        id: UUID = UUID(),
        text: String,
        language: String,
        startTime: Double,
        endTime: Double,
        isCodeSwitch: Bool = false
    ) {
        self.id = id
        self.text = text
        self.language = language
        self.startTime = startTime
        self.endTime = endTime
        self.isCodeSwitch = isCodeSwitch
    }
}

// MARK: - Extracted Item

struct ExtractedItem: Identifiable {
    let id: UUID
    var text: String
    var category: ExtractedItemCategory
    var confidence: Double
    var isAccepted: Bool
    var icon: String

    init(
        id: UUID = UUID(),
        text: String,
        category: ExtractedItemCategory,
        confidence: Double,
        isAccepted: Bool = true,
        icon: String = "circle.fill"
    ) {
        self.id = id
        self.text = text
        self.category = category
        self.confidence = confidence
        self.isAccepted = isAccepted
        self.icon = icon
    }
}

enum ExtractedItemCategory: String, CaseIterable {
    case symptom = "Symptom"
    case action = "Action Taken"
    case part = "Part Mentioned"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .symptom: return .error
        case .action:  return .info
        case .part:    return .warning
        }
    }

    var icon: String {
        switch self {
        case .symptom: return "exclamationmark.triangle.fill"
        case .action:  return "wrench.and.screwdriver.fill"
        case .part:    return "gearshape.2.fill"
        }
    }

    var color: Color {
        switch self {
        case .symptom: return SpendlyColors.error
        case .action:  return SpendlyColors.info
        case .part:    return SpendlyColors.warning
        }
    }
}

// MARK: - Issue Category Mapping

struct IssueCategoryMapping: Identifiable {
    let id: UUID
    var system: String
    var systemIcon: String
    var assembly: String
    var assemblyIcon: String
    var symptom: String
    var symptomIcon: String
    var confidence: Double

    init(
        id: UUID = UUID(),
        system: String,
        systemIcon: String,
        assembly: String,
        assemblyIcon: String,
        symptom: String,
        symptomIcon: String,
        confidence: Double
    ) {
        self.id = id
        self.system = system
        self.systemIcon = systemIcon
        self.assembly = assembly
        self.assemblyIcon = assemblyIcon
        self.symptom = symptom
        self.symptomIcon = symptomIcon
        self.confidence = confidence
    }
}

// MARK: - Urgency Level

enum UrgencyLevel: String, CaseIterable, Identifiable {
    case minor = "Minor"
    case standard = "Standard"
    case urgent = "Urgent"
    case shutdown = "Shutdown"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .minor:    return "info.circle.fill"
        case .standard: return "exclamationmark.triangle.fill"
        case .urgent:   return "exclamationmark.octagon.fill"
        case .shutdown: return "bolt.slash.fill"
        }
    }

    var color: Color {
        switch self {
        case .minor:    return SpendlyColors.success
        case .standard: return SpendlyColors.warning
        case .urgent:   return SpendlyColors.error
        case .shutdown: return Color(hex: "#1e293b")
        }
    }

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .minor:    return .success
        case .standard: return .warning
        case .urgent:   return .error
        case .shutdown: return .neutral
        }
    }
}

// MARK: - Machine Template

struct MachineTemplate: Identifiable {
    let id: UUID
    var name: String
    var serialNumber: String
    var model: String
    var iconName: String

    init(
        id: UUID = UUID(),
        name: String,
        serialNumber: String,
        model: String,
        iconName: String = "gearshape.2"
    ) {
        self.id = id
        self.name = name
        self.serialNumber = serialNumber
        self.model = model
        self.iconName = iconName
    }
}

// MARK: - Diagnostic Wizard Step

enum DiagnosticWizardStep: Int, CaseIterable {
    case systemSelection = 0
    case componentSelection = 1
    case symptoms = 2
    case evidence = 3
    case impact = 4

    var title: String {
        switch self {
        case .systemSelection:    return "What system is affected?"
        case .componentSelection: return "Select Assembly/Component"
        case .symptoms:           return "Specific Symptoms"
        case .evidence:           return "Additional Evidence"
        case .impact:             return "Impact Level"
        }
    }
}

// MARK: - System Type

struct SystemType: Identifiable, Hashable {
    let id: UUID
    var name: String
    var icon: String

    init(id: UUID = UUID(), name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

// MARK: - Component Option

struct ComponentOption: Identifiable, Hashable {
    let id: UUID
    var name: String
    var detail: String

    init(id: UUID = UUID(), name: String, detail: String) {
        self.id = id
        self.name = name
        self.detail = detail
    }
}

// MARK: - Symptom Chip

struct SymptomChip: Identifiable {
    let id: UUID
    var name: String
    var isSelected: Bool

    init(id: UUID = UUID(), name: String, isSelected: Bool = false) {
        self.id = id
        self.name = name
        self.isSelected = isSelected
    }
}

// MARK: - Recording State

enum RecordingState: Equatable {
    case idle
    case recording
    case processing
    case completed
    case error(String)
}

// MARK: - Mock Data

enum AIDiagnosticsMockData {

    // MARK: Languages

    static let supportedLanguages: [SupportedLanguage] = [
        SupportedLanguage(name: "English",   nativeName: "English",    code: "en"),
        SupportedLanguage(name: "Spanish",   nativeName: "Espanol",    code: "es"),
        SupportedLanguage(name: "Hindi",     nativeName: "Hindi",      code: "hi"),
        SupportedLanguage(name: "Bengali",   nativeName: "Bangla",     code: "bn"),
        SupportedLanguage(name: "Gujarati",  nativeName: "Gujarati",   code: "gu"),
        SupportedLanguage(name: "Tamil",     nativeName: "Tamil",      code: "ta"),
        SupportedLanguage(name: "Telugu",    nativeName: "Telugu",     code: "te"),
        SupportedLanguage(name: "Kannada",   nativeName: "Kannada",    code: "kn"),
        SupportedLanguage(name: "Malayalam", nativeName: "Malayalam",  code: "ml"),
        SupportedLanguage(name: "Marathi",   nativeName: "Marathi",    code: "mr"),
        SupportedLanguage(name: "Punjabi",   nativeName: "Punjabi",    code: "pa"),
        SupportedLanguage(name: "Urdu",      nativeName: "Urdu",       code: "ur"),
        SupportedLanguage(name: "Odia",      nativeName: "Odia",       code: "or"),
        SupportedLanguage(name: "Assamese",  nativeName: "Assamese",   code: "as"),
        SupportedLanguage(name: "Maithili",  nativeName: "Maithili",   code: "mai"),
        SupportedLanguage(name: "French",    nativeName: "Francais",   code: "fr"),
        SupportedLanguage(name: "German",    nativeName: "Deutsch",    code: "de"),
    ]

    // MARK: Mock Transcription Segments

    static let mockSegments: [TranscriptionSegmentDisplay] = [
        TranscriptionSegmentDisplay(
            text: "El sistema electrico parece estar fallando cuando la temperatura sube.",
            language: "Spanish",
            startTime: 0.0,
            endTime: 4.2
        ),
        TranscriptionSegmentDisplay(
            text: "El panel de control no envia la senal de arranque al motor de combustion.",
            language: "Spanish",
            startTime: 4.3,
            endTime: 8.6
        ),
    ]

    static let mockCodeSwitchSegments: [TranscriptionSegmentDisplay] = [
        TranscriptionSegmentDisplay(
            text: "The motor makes a strange noise, sounds like",
            language: "English",
            startTime: 0.0,
            endTime: 2.8,
            isCodeSwitch: false
        ),
        TranscriptionSegmentDisplay(
            text: "ghar-ghar",
            language: "Hindi",
            startTime: 2.8,
            endTime: 3.5,
            isCodeSwitch: true
        ),
        TranscriptionSegmentDisplay(
            text: "when starting.",
            language: "English",
            startTime: 3.5,
            endTime: 4.6,
            isCodeSwitch: false
        ),
    ]

    // MARK: Mock Translations

    static let mockOriginalText = "El sistema electrico parece estar fallando cuando la temperatura sube. El panel de control no envia la senal de arranque al motor de combustion."

    static let mockTranslatedText = "The electrical system appears to be failing when the temperature rises. The control panel is not sending the start signal to the combustion engine."

    static let mockCodeSwitchOriginal = "The motor makes a strange noise, sounds like ghar-ghar when starting."

    static let mockCodeSwitchStandardized = "Symptom: Abnormal mechanical noise (grinding) during startup."

    // MARK: Extracted Items

    static let mockExtractedItems: [ExtractedItem] = [
        ExtractedItem(
            text: "Electrical system failing at high temperature",
            category: .symptom,
            confidence: 0.94,
            icon: "exclamationmark.triangle.fill"
        ),
        ExtractedItem(
            text: "Control panel start signal failure",
            category: .symptom,
            confidence: 0.91,
            icon: "exclamationmark.triangle.fill"
        ),
        ExtractedItem(
            text: "Abnormal grinding noise during startup",
            category: .symptom,
            confidence: 0.88,
            icon: "exclamationmark.triangle.fill"
        ),
        ExtractedItem(
            text: "Visual inspection of wiring harness",
            category: .action,
            confidence: 0.82,
            icon: "wrench.and.screwdriver.fill"
        ),
        ExtractedItem(
            text: "Tested motor relay switch",
            category: .action,
            confidence: 0.79,
            icon: "wrench.and.screwdriver.fill"
        ),
        ExtractedItem(
            text: "Control Panel Module (CPM-400)",
            category: .part,
            confidence: 0.96,
            icon: "gearshape.2.fill"
        ),
        ExtractedItem(
            text: "Combustion Engine Starter Relay",
            category: .part,
            confidence: 0.87,
            icon: "gearshape.2.fill"
        ),
        ExtractedItem(
            text: "Thermal Fuse Assembly",
            category: .part,
            confidence: 0.73,
            icon: "gearshape.2.fill"
        ),
    ]

    // MARK: Issue Category Mapping

    static let mockCategoryMapping = IssueCategoryMapping(
        system: "Electrical",
        systemIcon: "bolt.fill",
        assembly: "Control Logic",
        assemblyIcon: "cpu",
        symptom: "Start Failure",
        symptomIcon: "exclamationmark.triangle.fill",
        confidence: 0.92
    )

    // MARK: Machine Templates

    static let mockMachineTemplates: [MachineTemplate] = [
        MachineTemplate(name: "Excavator PX-400", serialNumber: "98234-A", model: "PX-400", iconName: "truck.box.fill"),
        MachineTemplate(name: "Excavator PX-400", serialNumber: "98235-B", model: "PX-400", iconName: "truck.box.fill"),
        MachineTemplate(name: "Loader LT-20",     serialNumber: "11092-X", model: "LT-20",  iconName: "shippingbox.fill"),
        MachineTemplate(name: "Compressor AC-50",  serialNumber: "44781-C", model: "AC-50",  iconName: "fan.fill"),
    ]

    // MARK: System Types

    static let systemTypes: [SystemType] = [
        SystemType(name: "Electrical & Programming", icon: "bolt.fill"),
        SystemType(name: "Mechanical & Hardware",    icon: "gearshape.fill"),
        SystemType(name: "Pneumatic System",         icon: "wind"),
    ]

    // MARK: Components

    static let electricalComponents: [ComponentOption] = [
        ComponentOption(name: "Servo & Drive Faults",    detail: "Motor errors, amplifier alarms, or positioning issues"),
        ComponentOption(name: "Control Logic & Software", detail: "PLC errors, HMI freezing, or sequence logic failures"),
        ComponentOption(name: "Safety Circuits",          detail: "E-Stop resets, light curtains, or safety relay faults"),
    ]

    static let mechanicalComponents: [ComponentOption] = [
        ComponentOption(name: "Bearings & Shafts",   detail: "Vibration, noise, or alignment problems"),
        ComponentOption(name: "Hydraulic System",     detail: "Leaks, pressure loss, or valve failures"),
        ComponentOption(name: "Structural Integrity", detail: "Frame cracks, welds, or mounting issues"),
    ]

    static let pneumaticComponents: [ComponentOption] = [
        ComponentOption(name: "Air Compressor",  detail: "Pressure drops, cycling issues, or moisture"),
        ComponentOption(name: "Valve Assembly",   detail: "Sticking, leaking, or solenoid failures"),
        ComponentOption(name: "Cylinder & Seals", detail: "Drift, slow response, or seal wear"),
    ]

    // MARK: Symptom Chips

    static let symptomChips: [SymptomChip] = [
        SymptomChip(name: "Overcurrent Alarm"),
        SymptomChip(name: "Communication Loss", isSelected: true),
        SymptomChip(name: "Encoder Feedback Error"),
        SymptomChip(name: "Thermal Overload"),
        SymptomChip(name: "Intermittent Shutdown"),
        SymptomChip(name: "Abnormal Vibration"),
        SymptomChip(name: "Error Code Displayed"),
        SymptomChip(name: "Unusual Noise"),
    ]

    // MARK: Waveform Amplitudes

    static let waveformAmplitudes: [CGFloat] = [
        0.2, 0.4, 0.6, 0.3, 0.8, 0.95, 0.5, 0.7, 0.35, 0.9, 0.55, 0.25,
        0.65, 0.45, 0.85, 0.3, 0.7, 0.5, 0.4, 0.75, 0.6, 0.2, 0.5, 0.8,
        0.35, 0.55, 0.9, 0.4, 0.7, 0.25, 0.6, 0.85, 0.45, 0.3, 0.65, 0.5,
    ]
}
