import SwiftUI
import SpendlyCore

public struct OEMTabRouter: View {
    @State private var selectedTab = 0
    @State private var sidebarSelection: Int? = 0
    @Environment(AuthState.self) private var authState
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

    // MARK: - iPad (Sidebar)

    private var iPadLayout: some View {
        NavigationSplitView {
            List(selection: $sidebarSelection) {
                Section("Main") {
                    Label("Dashboard", systemImage: "square.grid.2x2").tag(0)
                    Label("Trips", systemImage: "briefcase").tag(1)
                    Label("Approvals", systemImage: "checkmark.circle").tag(2)
                    Label("Machines", systemImage: "gearshape.2").tag(3)
                }

                Section("Modules") {
                    Label("Customers", systemImage: "person.crop.rectangle").tag(10)
                    Label("Estimates", systemImage: "doc.text").tag(11)
                    Label("Invoicing", systemImage: "doc.plaintext").tag(12)
                    Label("Parts & Inventory", systemImage: "shippingbox").tag(17)
                    Label("Knowledge Base", systemImage: "books.vertical").tag(13)
                    Label("Customer Feedback", systemImage: "star.bubble").tag(18)
                    Label("Team Chat", systemImage: "message").tag(14)
                    Label("Analytics", systemImage: "chart.xyaxis.line").tag(15)
                    Label("Resources", systemImage: "person.2").tag(16)
                }

                Section("Account") {
                    Label("Settings", systemImage: "gearshape").tag(20)
                    Label("Notifications", systemImage: "bell").tag(21)
                }
            }
            .navigationTitle("Spendly")
            .listStyle(.sidebar)
            .tint(SpendlyColors.primary)
            .safeAreaInset(edge: .bottom) {
                iPadSignOutButton
            }
        } detail: {
            NavigationStack {
                iPadDetailView
            }
        }
        .tint(SpendlyColors.primary)
    }

    @ViewBuilder
    private var iPadDetailView: some View {
        switch sidebarSelection ?? 0 {
        case 0:  ManagerDashboardRootView()
        case 1:  JobExecutionRootView()
        case 2:  ClientApprovalRootView()
        case 3:  MachineVaultRootView()
        case 10: CustomerProfileRootView()
        case 11: EstimateBuilderRootView()
        case 12: InvoicingBillingRootView()
        case 13: KnowledgeBaseRootView()
        case 14: TeamChatRootView()
        case 15: AnalyticsDashboardsRootView()
        case 16: ResourceManagementRootView()
        case 17: PartsInventoryRootView()
        case 18: CustomerFeedbackRootView()
        case 20: SettingsNotificationsRootView()
        case 21: PushNotificationsRootView()
        default: ManagerDashboardRootView()
        }
    }

    @State private var showLogoutConfirmationIPad = false

    private var iPadSignOutButton: some View {
        Button(role: .destructive) {
            showLogoutConfirmationIPad = true
        } label: {
            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                .foregroundStyle(SpendlyColors.error)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.vertical, 12)
        }
        .alert("Sign Out", isPresented: $showLogoutConfirmationIPad) {
            Button("Sign Out", role: .destructive) { authState.logout() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
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
                    PartsInventoryRootView()
                } label: {
                    Label("Parts & Inventory", systemImage: "shippingbox")
                }

                NavigationLink {
                    KnowledgeBaseRootView()
                } label: {
                    Label("Knowledge Base", systemImage: "books.vertical")
                }

                NavigationLink {
                    CustomerFeedbackRootView()
                } label: {
                    Label("Customer Feedback", systemImage: "star.bubble")
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
