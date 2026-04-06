import SwiftUI
import SpendlyCore

public struct AdminTabRouter: View {
    @State private var selectedTab = 0
    @State private var sidebarSelection: Int? = 0
    @Environment(AuthState.self) private var authState
    @State private var showLogoutConfirmation = false
    @Environment(\.horizontalSizeClass) private var sizeClass

    public var body: some View {
        if sizeClass == .regular {
            iPadLayout
        } else {
            iPhoneLayout
        }
    }

    // MARK: - iPhone (Tab Bar)

    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                AnalyticsDashboardsRootView()
                    .toolbar { ToolbarItem(placement: .topBarTrailing) { logoutButton } }
            }
            .tabItem { Label("Dashboard", systemImage: "chart.xyaxis.line") }
            .tag(0)

            NavigationStack {
                WhiteLabelBrandingRootView()
                    .toolbar { ToolbarItem(placement: .topBarTrailing) { logoutButton } }
            }
            .tabItem { Label("Branding", systemImage: "paintbrush") }
            .tag(1)

            NavigationStack {
                OrgPermissionsRootView()
                    .toolbar { ToolbarItem(placement: .topBarTrailing) { logoutButton } }
            }
            .tabItem { Label("Users", systemImage: "person.3") }
            .tag(2)

            NavigationStack {
                SettingsNotificationsRootView()
                    .toolbar { ToolbarItem(placement: .topBarTrailing) { logoutButton } }
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
            .tag(3)
        }
        .tint(SpendlyColors.primary)
        .alert("Sign Out", isPresented: $showLogoutConfirmation) {
            Button("Sign Out", role: .destructive) { authState.logout() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }

    // MARK: - iPad (Sidebar)

    private var iPadLayout: some View {
        NavigationSplitView {
            List(selection: $sidebarSelection) {
                Section("Admin") {
                    Label("Dashboard", systemImage: "chart.xyaxis.line").tag(0)
                    Label("Branding", systemImage: "paintbrush").tag(1)
                    Label("Users", systemImage: "person.3").tag(2)
                    Label("Settings", systemImage: "gearshape").tag(3)
                }
            }
            .navigationTitle("Admin")
            .listStyle(.sidebar)
            .tint(SpendlyColors.primary)
            .safeAreaInset(edge: .bottom) {
                Button(role: .destructive) {
                    showLogoutConfirmation = true
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(SpendlyColors.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                }
            }
        } detail: {
            NavigationStack {
                switch sidebarSelection ?? 0 {
                case 0:  AnalyticsDashboardsRootView()
                case 1:  WhiteLabelBrandingRootView()
                case 2:  OrgPermissionsRootView()
                case 3:  SettingsNotificationsRootView()
                default: AnalyticsDashboardsRootView()
                }
            }
        }
        .tint(SpendlyColors.primary)
        .alert("Sign Out", isPresented: $showLogoutConfirmation) {
            Button("Sign Out", role: .destructive) { authState.logout() }
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
