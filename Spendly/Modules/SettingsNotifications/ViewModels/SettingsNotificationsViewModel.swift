import SwiftUI
import SpendlyCore

// MARK: - Dark Mode Preference

enum DarkModePreference: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }
}

// MARK: - Language Option

enum LanguageOption: String, CaseIterable, Identifiable {
    case english = "English"
    case spanish = "Spanish"
    case french = "French"
    case german = "German"
    case portuguese = "Portuguese"
    case japanese = "Japanese"
    case mandarin = "Mandarin Chinese"
    case arabic = "Arabic"
    case hindi = "Hindi"

    var id: String { rawValue }
}

// MARK: - Dialect Option

enum DialectOption: String, CaseIterable, Identifiable {
    case usEnglish = "US English"
    case ukEnglish = "UK English"
    case auEnglish = "AU English"
    case latamSpanish = "Latin American Spanish"
    case castilianSpanish = "Castilian Spanish"
    case canadianFrench = "Canadian French"
    case europeanFrench = "European French"
    case brazilianPortuguese = "Brazilian Portuguese"
    case europeanPortuguese = "European Portuguese"

    var id: String { rawValue }
}

// MARK: - Measurement Unit

enum MeasurementUnitOption: String, CaseIterable, Identifiable {
    case imperial = "Imperial"
    case metric = "Metric"

    var id: String { rawValue }
}

// MARK: - Regional Tax Entry

struct RegionalTaxEntry: Identifiable {
    let id: UUID
    var regionName: String
    var taxRate: String
    var currencyCode: String

    init(
        id: UUID = UUID(),
        regionName: String,
        taxRate: String = "0.00",
        currencyCode: String = "USD"
    ) {
        self.id = id
        self.regionName = regionName
        self.taxRate = taxRate
        self.currencyCode = currencyCode
    }
}

// MARK: - ViewModel

@Observable
final class SettingsNotificationsViewModel {

    // MARK: - Notification Preferences (Work Orders)

    var statusUpdatesEnabled: Bool = true
    var newAssignmentsEnabled: Bool = true

    // MARK: - Notification Preferences (Communication)

    var messagesEnabled: Bool = true
    var scheduleChangesEnabled: Bool = false

    // MARK: - General Notification Channels

    var pushNotificationsEnabled: Bool = true
    var emailAlertsEnabled: Bool = false
    var smsRemindersEnabled: Bool = true

    // MARK: - Security

    @ObservationIgnored
    @AppStorage("biometricEnabled") var biometricLoginEnabled: Bool = false

    // MARK: - App Preferences

    @ObservationIgnored
    @AppStorage("darkModePreference") var darkModePreference: String = DarkModePreference.system.rawValue
    var selectedLanguage: String = LanguageOption.english.rawValue
    var selectedDialect: String = DialectOption.usEnglish.rawValue
    var selectedMeasurementUnit: String = MeasurementUnitOption.imperial.rawValue

    // MARK: - API Key Management

    var geminiAPIKey: String = ""
    var isAPIKeyVisible: Bool = false
    var isAPIKeyValid: Bool = false

    // MARK: - Task Estimation Settings

    var defaultEstimationHours: String = "2.0"
    var autoEstimateEnabled: Bool = true
    var estimationBuffer: String = "15"

    // MARK: - Regional Tax & Currency

    var defaultCurrency: String = "USD ($)"
    var globalTaxRate: String = "0.00"
    var regionalTaxEntries: [RegionalTaxEntry] = []
    var allowRegionalOverrides: Bool = false

    // MARK: - UI State

    var isSaving: Bool = false
    var showSaveConfirmation: Bool = false
    var showResetAlert: Bool = false
    var activeSheet: SettingsSheet?

    // MARK: - Sheet Navigation

    enum SettingsSheet: Identifiable {
        case notifications
        case general
        case apiKeys
        case taskEstimation
        case regionalTax

        var id: String {
            switch self {
            case .notifications: return "notifications"
            case .general: return "general"
            case .apiKeys: return "apiKeys"
            case .taskEstimation: return "taskEstimation"
            case .regionalTax: return "regionalTax"
            }
        }
    }

    // MARK: - Computed

    var darkModeColorScheme: ColorScheme? {
        switch DarkModePreference(rawValue: darkModePreference) {
        case .light: return .light
        case .dark: return .dark
        default: return nil
        }
    }

    var maskedAPIKey: String {
        guard !geminiAPIKey.isEmpty else { return "" }
        if geminiAPIKey.count <= 8 {
            return String(repeating: "*", count: geminiAPIKey.count)
        }
        let prefix = String(geminiAPIKey.prefix(4))
        let suffix = String(geminiAPIKey.suffix(4))
        let masked = String(repeating: "*", count: geminiAPIKey.count - 8)
        return prefix + masked + suffix
    }

    var notificationSummary: String {
        let count = [
            statusUpdatesEnabled,
            newAssignmentsEnabled,
            messagesEnabled,
            scheduleChangesEnabled
        ].filter { $0 }.count
        return "\(count) of 4 enabled"
    }

    // MARK: - Actions

    func saveNotificationPreferences() {
        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.isSaving = false
            self?.showSaveConfirmation = true
        }
    }

    func saveGeneralSettings() {
        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.isSaving = false
            self?.showSaveConfirmation = true
        }
    }

    func validateAPIKey() {
        guard !geminiAPIKey.isEmpty else {
            isAPIKeyValid = false
            return
        }
        // Simulate validation
        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isSaving = false
            self?.isAPIKeyValid = (self?.geminiAPIKey.count ?? 0) >= 10
        }
    }

    func addRegionalTaxEntry() {
        let entry = RegionalTaxEntry(regionName: "New Region")
        regionalTaxEntries.append(entry)
    }

    func removeRegionalTaxEntry(_ entry: RegionalTaxEntry) {
        regionalTaxEntries.removeAll { $0.id == entry.id }
    }

    func resetToDefaults() {
        statusUpdatesEnabled = true
        newAssignmentsEnabled = true
        messagesEnabled = true
        scheduleChangesEnabled = false
        pushNotificationsEnabled = true
        emailAlertsEnabled = false
        smsRemindersEnabled = true
        biometricLoginEnabled = false
        darkModePreference = DarkModePreference.system.rawValue
        selectedLanguage = LanguageOption.english.rawValue
        selectedDialect = DialectOption.usEnglish.rawValue
        selectedMeasurementUnit = MeasurementUnitOption.imperial.rawValue
        geminiAPIKey = ""
        isAPIKeyVisible = false
        isAPIKeyValid = false
        defaultEstimationHours = "2.0"
        autoEstimateEnabled = true
        estimationBuffer = "15"
        defaultCurrency = "USD ($)"
        globalTaxRate = "0.00"
        regionalTaxEntries = []
        allowRegionalOverrides = false
    }
}
