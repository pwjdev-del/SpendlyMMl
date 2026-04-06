import SwiftUI
import SpendlyCore

public struct CustomerTabRouter: View {
    @State private var selectedTab = 0
    @State private var sidebarSelection: Int? = 0
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Environment(AuthState.self) private var authState
    @State private var showLogoutConfirmation = false

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
            NavigationStack { CustomerPortalRootView() }
                .tabItem { Label("Dashboard", systemImage: "person.crop.square") }
                .tag(0)

            NavigationStack { MachineVaultRootView() }
                .tabItem { Label("Machines", systemImage: "gearshape.2") }
                .tag(1)

            NavigationStack { TicketManagementRootView() }
                .tabItem { Label("Incidents", systemImage: "ticket") }
                .tag(2)

            NavigationStack { TripReportRootView() }
                .tabItem { Label("Documents", systemImage: "doc.richtext") }
                .tag(3)

            NavigationStack { CustomerMoreMenuView() }
                .tabItem { Label("More", systemImage: "ellipsis") }
                .tag(4)
        }
        .tint(SpendlyColors.primary)
    }

    // MARK: - iPad (Sidebar)

    private var iPadLayout: some View {
        NavigationSplitView {
            List(selection: $sidebarSelection) {
                Section("Main") {
                    Label("Dashboard", systemImage: "person.crop.square").tag(0)
                    Label("Machines", systemImage: "gearshape.2").tag(1)
                    Label("Incidents", systemImage: "ticket").tag(2)
                    Label("Documents", systemImage: "doc.richtext").tag(3)
                }

                Section("Account") {
                    Label("Settings", systemImage: "gearshape").tag(10)
                    Label("Notifications", systemImage: "bell").tag(11)
                }
            }
            .navigationTitle("Spendly")
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
                case 0:  CustomerPortalRootView()
                case 1:  MachineVaultRootView()
                case 2:  TicketManagementRootView()
                case 3:  TripReportRootView()
                case 10: SettingsNotificationsRootView()
                case 11: PushNotificationsRootView()
                default: CustomerPortalRootView()
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
}

// MARK: - CustomerMoreMenuView

public struct CustomerMoreMenuView: View {
    @Environment(AuthState.self) private var authState
    @State private var showLogoutConfirmation = false

    public var body: some View {
        List {
            Section("Account") {
                NavigationLink {
                    SettingsNotificationsRootView()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }

                NavigationLink {
                    PushNotificationsRootView()
                } label: {
                    Label("Notifications", systemImage: "bell")
                }

                Button(role: .destructive) {
                    showLogoutConfirmation = true
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(SpendlyColors.error)
                }
            }
        }
        .navigationTitle("More")
        .alert("Sign Out", isPresented: $showLogoutConfirmation) {
            Button("Sign Out", role: .destructive) {
                authState.logout()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
    }
}

#Preview {
    CustomerTabRouter()
        .environment(AuthState())
}
