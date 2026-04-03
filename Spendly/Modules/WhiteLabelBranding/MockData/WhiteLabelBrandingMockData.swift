import SwiftUI
import SpendlyCore

// MARK: - Mock Data

enum WhiteLabelBrandingMockData {

    /// A pre-populated ViewModel for previews and development.
    static func makeViewModel() -> WhiteLabelBrandingViewModel {
        let vm = WhiteLabelBrandingViewModel()
        vm.primaryColor = Color(hex: "#3b82f6")
        vm.secondaryColor = Color(hex: "#64748b")
        vm.selectedFont = .sansSerif
        vm.selectedCornerStyle = .rounded
        vm.selectedCurrency = CurrencyOption.usd.rawValue
        vm.globalTaxRate = "8.25"
        vm.selectedDisplayFormat = CurrencyDisplayFormat.symbolFirst.rawValue
        vm.allowRegionalOverrides = false
        vm.serviceImages = sampleServiceImages
        return vm
    }

    /// Sample service images (without actual UIImage data for previews).
    static let sampleServiceImages: [ServiceImage] = [
        ServiceImage(name: "Plumbing"),
        ServiceImage(name: "Electrical"),
    ]

    /// All available currency options as display strings.
    static let currencyOptions: [String] = CurrencyOption.allCases.map(\.rawValue)

    /// All available display format options as display strings.
    static let displayFormatOptions: [String] = CurrencyDisplayFormat.allCases.map(\.rawValue)

    /// Sample OrgBranding model instance.
    static let sampleOrgBranding = OrgBranding(
        logoURL: nil,
        primaryColor: "#3b82f6",
        secondaryColor: "#64748b",
        accentColor: "#f97316",
        fontName: "sans-serif",
        tagline: "Field Service Excellence"
    )
}
