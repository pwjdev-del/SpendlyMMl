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
        container = try! ModelContainer(for: schema, configurations: [config])
    }
}
