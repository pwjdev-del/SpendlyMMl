import SwiftUI
import SpendlyCore

public struct OEMTabRouter: View {
    @State private var selectedTab = 0
    @Environment(AuthState.self) private var authState

    public var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { ManagerDashboardRootView() }
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2") }
                .tag(0)

            NavigationStack { JobExecutionRootView() }
                .tabItem { Label("Trips", systemImage: "briefcase") }
                .tag(1)

            NavigationStack { ClientApprovalRootView() }
                .tabItem { Label("Approvals", systemImage: "checkmark.circle") }
                .tag(2)

            NavigationStack { MachineVaultRootView() }
                .tabItem { Label("Machines", systemImage: "gearshape.2") }
                .tag(3)

            NavigationStack { MoreMenuView() }
                .tabItem { Label("More", systemImage: "ellipsis") }
                .tag(4)
        }
        .tint(SpendlyColors.primary)
    }
}

// MARK: - MoreMenuView

public struct MoreMenuView: View {
    @Environment(AuthState.self) private var authState
    @State private var showLogoutConfirmation = false

    public var body: some View {
        List {
            Section("Modules") {
                NavigationLink {
                    CustomerProfileRootView()
                } label: {
                    Label("Customers", systemImage: "person.crop.rectangle")
                }

                NavigationLink {
                    EstimateBuilderRootView()
                } label: {
                    Label("Estimates", systemImage: "doc.text")
                }

                NavigationLink {
                    InvoicingBillingRootView()
                } label: {
                    Label("Invoicing", systemImage: "doc.plaintext")
                }

                NavigationLink {
                    KnowledgeBaseRootView()
                } label: {
                    Label("Knowledge Base", systemImage: "books.vertical")
                }

                NavigationLink {
                    TeamChatRootView()
                } label: {
                    Label("Team Chat", systemImage: "message")
                }

                NavigationLink {
                    AnalyticsDashboardsRootView()
                } label: {
                    Label("Analytics", systemImage: "chart.xyaxis.line")
                }

                NavigationLink {
                    ResourceManagementRootView()
                } label: {
                    Label("Resources", systemImage: "person.2")
                }
            }

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
    OEMTabRouter()
        .environment(AuthState())
}
