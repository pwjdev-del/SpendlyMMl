import SwiftUI
import SpendlyCore

// MARK: - Mock Data

enum SettingsNotificationsMockData {

    /// A pre-populated ViewModel for previews and development.
    static func makeViewModel() -> SettingsNotificationsViewModel {
        let vm = SettingsNotificationsViewModel()
        vm.statusUpdatesEnabled = true
        vm.newAssignmentsEnabled = true
        vm.messagesEnabled = true
        vm.scheduleChangesEnabled = false
        vm.pushNotificationsEnabled = true
        vm.emailAlertsEnabled = false
        vm.smsRemindersEnabled = true
        vm.biometricLoginEnabled = true
        vm.darkModePreference = DarkModePreference.system.rawValue
        vm.selectedLanguage = LanguageOption.english.rawValue
        vm.selectedDialect = DialectOption.usEnglish.rawValue
        vm.selectedMeasurementUnit = MeasurementUnitOption.imperial.rawValue
        vm.geminiAPIKey = "AIzaSyB1234567890abcdef"
        vm.isAPIKeyValid = true
        vm.defaultEstimationHours = "2.0"
        vm.autoEstimateEnabled = true
        vm.estimationBuffer = "15"
        vm.defaultCurrency = "USD ($)"
        vm.globalTaxRate = "8.25"
        vm.allowRegionalOverrides = true
        vm.regionalTaxEntries = sampleRegionalTaxEntries
        return vm
    }

    /// Sample regional tax entries for previews.
    static let sampleRegionalTaxEntries: [RegionalTaxEntry] = [
        RegionalTaxEntry(regionName: "California", taxRate: "7.25", currencyCode: "USD"),
        RegionalTaxEntry(regionName: "Texas", taxRate: "6.25", currencyCode: "USD"),
        RegionalTaxEntry(regionName: "Ontario", taxRate: "13.00", currencyCode: "CAD"),
    ]

    /// All available language options as display strings.
    static let languageOptions: [String] = LanguageOption.allCases.map(\.rawValue)

    /// All available dialect options as display strings.
    static let dialectOptions: [String] = DialectOption.allCases.map(\.rawValue)

    /// All available dark mode options as display strings.
    static let darkModeOptions: [String] = DarkModePreference.allCases.map(\.rawValue)

    /// All available measurement unit options as display strings.
    static let measurementOptions: [String] = MeasurementUnitOption.allCases.map(\.rawValue)

    /// Currency options for regional tax manager.
    static let currencyOptions: [String] = [
        "USD ($)", "EUR (\u{20AC})", "GBP (\u{00A3})", "CAD ($)",
        "AUD ($)", "INR (\u{20B9})", "JPY (\u{00A5})"
    ]

    /// Sample user profile for settings header.
    static let sampleUserName = "Johnathan Miller"
    static let sampleUserRole = "Senior HVAC Technician"
    static let sampleEmployeeID = "#FSP-8829"
    static let sampleAppVersion = "4.2.0"
}
