import SwiftUI
import SwiftData
import SpendlyCore

@main
struct SpendlyApp: App {
    @State private var authViewModel = AuthState()
    @State private var brandingConfig = BrandingConfiguration()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environment(authViewModel)
                .environment(brandingConfig)
        }
        .modelContainer(SpendlyDataContainer.shared.container)
    }
}
