import Foundation

// MARK: - API Errors

public enum APIError: Error, LocalizedError {
    case notFound
    case unauthorized
    case serverError(String)
    case decodingError
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case .notFound:
            return "Resource not found"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError:
            return "Failed to decode response"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - API Client

public class APIClient {
    public static let shared = APIClient()

    /// The organization ID for tenant isolation. All queries filter by this.
    public var currentOrgID: UUID?

    private init() {}

    /// Fetches a list of records from Supabase.
    /// Currently returns an empty array -- will be replaced with real Supabase queries.
    /// Every fetch automatically filters by orgID for tenant isolation.
    public func fetch<T: Codable & Sendable>(
        from table: String,
        filters: [String: Any] = [:]
    ) async throws -> [T] {
        guard currentOrgID != nil else {
            throw APIError.unauthorized
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Mock: return empty array
        // Real implementation will query SpendlySupabase.shared.client
        // and automatically add .eq("org_id", currentOrgID) for tenant isolation
        return []
    }

    /// Fetches a single record by ID.
    /// Currently returns nil -- will be replaced with real Supabase queries.
    public func fetchOne<T: Codable & Sendable>(
        from table: String,
        id: UUID
    ) async throws -> T? {
        guard currentOrgID != nil else {
            throw APIError.unauthorized
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Mock: return nil
        return nil
    }

    /// Creates a new record in Supabase.
    /// Currently returns the input unchanged -- will be replaced with real Supabase insert.
    public func create<T: Codable & Sendable>(
        in table: String,
        record: T
    ) async throws -> T {
        guard currentOrgID != nil else {
            throw APIError.unauthorized
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Mock: return the record as-is
        return record
    }

    /// Updates an existing record in Supabase.
    /// Currently returns the input unchanged -- will be replaced with real Supabase update.
    public func update<T: Codable & Sendable>(
        in table: String,
        id: UUID,
        record: T
    ) async throws -> T {
        guard currentOrgID != nil else {
            throw APIError.unauthorized
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Mock: return the record as-is
        return record
    }

    /// Deletes a record by ID from Supabase.
    /// Currently a no-op -- will be replaced with real Supabase delete.
    public func delete(
        from table: String,
        id: UUID
    ) async throws {
        guard currentOrgID != nil else {
            throw APIError.unauthorized
        }

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)

        // Mock: no-op
    }
}
