import SwiftUI
import PhotosUI
import SpendlyCore

// MARK: - Service Image

struct ServiceImage: Identifiable {
    let id: UUID
    var name: String
    var image: UIImage?

    init(id: UUID = UUID(), name: String, image: UIImage? = nil) {
        self.id = id
        self.name = name
        self.image = image
    }
}

// MARK: - Currency Display Format

enum CurrencyDisplayFormat: String, CaseIterable, Identifiable {
    case symbolFirst = "$1,234.56 (Symbol First)"
    case codeFirst = "USD 1,234.56 (Code First)"
    case symbolLast = "1.234,56 \u{20AC} (EU Standard)"

    var id: String { rawValue }
}

// MARK: - Currency Option

enum CurrencyOption: String, CaseIterable, Identifiable {
    case usd = "USD ($)"
    case eur = "EUR (\u{20AC})"
    case gbp = "GBP (\u{00A3})"
    case inr = "INR (\u{20B9})"
    case jpy = "JPY (\u{00A5})"
    case aud = "AUD ($)"
    case cad = "CAD ($)"

    var id: String { rawValue }
}

// MARK: - ViewModel

@Observable
final class WhiteLabelBrandingViewModel {

    // MARK: - Branding Appearance

    var primaryColor: Color = Color(hex: "#3b82f6")
    var secondaryColor: Color = Color(hex: "#64748b")
    var selectedFont: FontChoice = .sansSerif
    var selectedCornerStyle: CornerStyle = .rounded

    // MARK: - Image Upload State

    var companyLogoImage: UIImage?
    var loginHeroImage: UIImage?
    var appIconImage: UIImage?
    var serviceImages: [ServiceImage] = []

    var showLogoPhotoPicker = false
    var showHeroPhotoPicker = false
    var showAppIconPhotoPicker = false
    var showServiceImagePicker = false

    var logoPhotoItem: PhotosPickerItem?
    var heroPhotoItem: PhotosPickerItem?
    var appIconPhotoItem: PhotosPickerItem?
    var servicePhotoItem: PhotosPickerItem?

    // MARK: - Finance / Currency Settings

    var selectedCurrency: String = CurrencyOption.usd.rawValue
    var globalTaxRate: String = "0.00"
    var selectedDisplayFormat: String = CurrencyDisplayFormat.symbolFirst.rawValue
    var allowRegionalOverrides: Bool = false

    // MARK: - UI State

    var isSaving: Bool = false
    var showSaveConfirmation: Bool = false
    var showResetAlert: Bool = false

    // MARK: - Computed

    var cornerRadius: CGFloat {
        selectedCornerStyle.designRadius
    }

    var previewFont: Font {
        switch selectedFont {
        case .sansSerif: return .system(.body, design: .default)
        case .serif:     return .system(.body, design: .serif)
        case .mono:      return .system(.body, design: .monospaced)
        }
    }

    var previewHeadingFont: Font {
        switch selectedFont {
        case .sansSerif: return .system(.title3, design: .default, weight: .bold)
        case .serif:     return .system(.title3, design: .serif, weight: .bold)
        case .mono:      return .system(.title3, design: .monospaced, weight: .bold)
        }
    }

    // MARK: - Actions

    func saveChanges() {
        isSaving = true
        // Simulate network save
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isSaving = false
            self?.showSaveConfirmation = true
        }
    }

    func resetToDefaults() {
        primaryColor = Color(hex: "#3b82f6")
        secondaryColor = Color(hex: "#64748b")
        selectedFont = .sansSerif
        selectedCornerStyle = .rounded
        companyLogoImage = nil
        loginHeroImage = nil
        appIconImage = nil
        serviceImages = []
        selectedCurrency = CurrencyOption.usd.rawValue
        globalTaxRate = "0.00"
        selectedDisplayFormat = CurrencyDisplayFormat.symbolFirst.rawValue
        allowRegionalOverrides = false
    }

    func removeServiceImage(_ image: ServiceImage) {
        serviceImages.removeAll { $0.id == image.id }
    }

    // MARK: - Photo Loading

    func loadLogoImage() async {
        guard let item = logoPhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            await MainActor.run {
                companyLogoImage = uiImage
            }
        }
    }

    func loadHeroImage() async {
        guard let item = heroPhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            await MainActor.run {
                loginHeroImage = uiImage
            }
        }
    }

    func loadAppIconImage() async {
        guard let item = appIconPhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            await MainActor.run {
                appIconImage = uiImage
            }
        }
    }

    func loadServiceImage() async {
        guard let item = servicePhotoItem else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            await MainActor.run {
                let newImage = ServiceImage(name: "Service \(serviceImages.count + 1)", image: uiImage)
                serviceImages.append(newImage)
            }
        }
    }
}
