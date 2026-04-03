import SwiftUI
import SpendlyCore

public struct AdminTabRouter: View {
    @State private var selectedTab = 0
    @Environment(AuthState.self) private var authState
    @State private var showLogoutConfirmation = false

    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                AnalyticsDashboardsRootView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            logoutButton
                        }
                    }
            }
            .tabItem { Label("Dashboard", systemImage: "chart.xyaxis.line") }
            .tag(0)

            NavigationStack {
                WhiteLabelBrandingRootView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            logoutButton
                        }
                    }
            }
            .tabItem { Label("Branding", systemImage: "paintbrush") }
            .tag(1)

            NavigationStack {
                OrgPermissionsRootView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            logoutButton
                        }
                    }
            }
            .tabItem { Label("Users", systemImage: "person.3") }
            .tag(2)

            NavigationStack {
                SettingsNotificationsRootView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            logoutButton
                        }
                    }
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(3)
        }
        .tint(SpendlyColors.primary)
        .alert("Sign Out", isPresented: $showLogoutConfirmation) {
            Button("Sign Out", role: .destructive) {
                authState.logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    private var logoutButton: some View {
        Button {
            showLogoutConfirmation = true
        } label: {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .foregroundStyle(SpendlyColors.error)
        }
    }
}

#Preview {
    AdminTabRouter()
        .environment(AuthState())
}
