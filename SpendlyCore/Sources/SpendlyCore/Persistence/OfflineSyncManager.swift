import Foundation
import SwiftUI
import SwiftData

@Observable
public class OfflineSyncManager {
    /// Whether the device is currently online (from NetworkMonitor)
    public var isOnline: Bool = true

    /// Number of records pending sync
    public var pendingCount: Int = 0

    /// Whether a sync operation is currently in progress
    public var isSyncing: Bool = false

    /// Last successful sync timestamp
    public var lastSyncedAt: Date?

    /// Error message from last sync attempt
    public var lastSyncError: String?

    private let networkMonitor: NetworkMonitor

    public init(networkMonitor: NetworkMonitor = NetworkMonitor()) {
        self.networkMonitor = networkMonitor
        self.isOnline = networkMonitor.isConnected
    }

    /// Syncs all pending records to Supabase.
    /// Currently stubbed -- the actual upload is a no-op but status tracking works.
    public func syncPendingRecords() async {
        guard isOnline else {
            lastSyncError = "No network connection"
            return
        }

        guard !isSyncing else { return }

        isSyncing = true
        lastSyncError = nil

        // Simulate sync delay
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        // Stub: In the real implementation, this would:
        // 1. Query all @Model types with syncStatus == .pending
        // 2. Upload each to Supabase via APIClient
        // 3. Mark each as .synced on success
        // 4. Mark as .failed on error

        // For now, just reset the pending count
        pendingCount = 0
        lastSyncedAt = Date()
        isSyncing = false
    }

    /// Marks a specific record as synced by ID.
    /// In the real implementation, this updates syncStatus on the SwiftData model.
    public func markAsSynced(_ id: UUID) {
        // Stub: In the real implementation, this would find the record
        // across all model types and set syncStatus = .synced
        if pendingCount > 0 {
            pendingCount -= 1
        }
    }

    /// Increments the pending count when a new record is created offline.
    public func markAsPending(_ id: UUID) {
        pendingCount += 1
    }

    /// Updates the online status from the network monitor.
    public func updateConnectionStatus() {
        isOnline = networkMonitor.isConnected
    }
}
