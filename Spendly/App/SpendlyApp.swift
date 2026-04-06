import SwiftUI
import SwiftData
import SpendlyCore

@main
struct SpendlyApp: App {
    @State private var authViewModel = AuthState()
    @State private var brandingConfig = BrandingConfiguration()
    @AppStorage("darkModePreference") private var darkModePreference: String = "System"

    private var preferredColorScheme: ColorScheme? {
        switch darkModePreference {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environment(authViewModel)
                .environment(brandingConfig)
                .preferredColorScheme(preferredColorScheme)
                .onAppear {
                    authViewModel.restoreRememberedSessionIfNeeded()
                }
        }
        .modelContainer(SpendlyDataContainer.shared.container)
    }
}
