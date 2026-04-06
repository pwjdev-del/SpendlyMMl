import Foundation
import SwiftData

public class SpendlyDataContainer {
    public static let shared = SpendlyDataContainer()
    public let container: ModelContainer

    private init() {
        let schema = Schema([
            SPUser.self,
            Organization.self,
            Customer.self,
            Machine.self,
            AssetTransfer.self,
            CustodyLog.self,
            ServiceTrip.self,
            Estimate.self,
            EstimateItem.self,
            Invoice.self,
            InvoiceItem.self,
            Expense.self,
            Ticket.self,
            TicketStatusHistory.self,
            MachineIncident.self,
            IncidentCategory.self,
            IncidentTemplate.self,
            AuditReport.self,
            AuditSection.self,
            Article.self,
            ArticleNote.self,
            ChatRoom.self,
            ChatMessage.self,
            ScheduleEvent.self,
            TimesheetEntry.self,
            SPNotification.self,
            Subscription.self,
            SubscriptionModule.self,
            UserSettings.self,
            OrgBranding.self,
            Territory.self,
            ComparisonGroup.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // If the persistent store is corrupted or a migration fails, fall back
            // to an in-memory container so the app can still launch without crashing.
            print("[SpendlyDataContainer] Failed to create persistent ModelContainer: \(error.localizedDescription). Falling back to in-memory store.")
            let fallbackConfig = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                container = try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                // This should never happen with an in-memory store, but if it does
                // we have no choice but to terminate — SwiftData schema itself is invalid.
                fatalError("[SpendlyDataContainer] Failed to create even in-memory ModelContainer: \(error.localizedDescription)")
            }
        }
    }
}
