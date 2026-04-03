import SwiftUI
import SpendlyCore

public struct CustomerTabRouter: View {
    @State private var selectedTab = 0
    @Environment(AuthState.self) private var authState
    @State private var showLogoutConfirmation = false

    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                CustomerPortalRootView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            logoutButton
                        }
                    }
            }
            .tabItem { Label("Dashboard", systemImage: "person.crop.square") }
            .tag(0)

            NavigationStack {
                MachineVaultRootView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            logoutButton
                        }
                    }
            }
            .tabItem { Label("Machines", systemImage: "gearshape.2") }
            .tag(1)

            NavigationStack {
                TicketManagementRootView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            logoutButton
                        }
                    }
            }
            .tabItem { Label("Incidents", systemImage: "ticket") }
            .tag(2)

            NavigationStack {
                TripReportRootView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            logoutButton
                        }
                    }
            }
            .tabItem { Label("Documents", systemImage: "doc.richtext") }
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
    CustomerTabRouter()
        .environment(AuthState())
}
