import Foundation

public class StorageService {
    public static let shared = StorageService()

    private init() {}

    /// Uploads image data to Supabase Storage.
    /// Currently returns a mock URL -- will be replaced with real Supabase storage upload.
    /// - Parameters:
    ///   - data: The image data to upload
    ///   - path: The storage path (e.g., "receipts/expense-123.jpg")
    /// - Returns: The public URL of the uploaded image
    public func uploadImage(_ data: Data, path: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Mock: return a fake URL based on the path
        let mockURL = "https://ocgscikxbnetmipxpjvq.supabase.co/storage/v1/object/public/images/\(path)"
        return mockURL
    }

    /// Downloads image data from a URL.
    /// Currently returns empty data -- will be replaced with real download.
    /// - Parameter url: The URL string to download from
    /// - Returns: The downloaded image data
    public func downloadImage(from url: String) async throws -> Data {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_000_000_000)

        // Mock: return empty data
        // Real implementation will use URLSession or Supabase storage client
        return Data()
    }
}
