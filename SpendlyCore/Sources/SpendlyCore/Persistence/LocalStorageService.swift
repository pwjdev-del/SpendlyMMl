import Foundation

/// Simple JSON-based persistence service that reads/writes Codable arrays
/// to the app's documents directory. Designed for lightweight offline storage
/// of display-model data (not a replacement for SwiftData or a real database).
public final class LocalStorageService: Sendable {

    public static let shared = LocalStorageService()

    private let directory: URL

    public init(directory: URL? = nil) {
        if let directory {
            self.directory = directory
        } else {
            self.directory = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("SpendlyLocalStorage", isDirectory: true)
        }

        // Ensure the directory exists
        try? FileManager.default.createDirectory(
            at: self.directory,
            withIntermediateDirectories: true
        )
    }

    // MARK: - Public API

    /// Saves a Codable array to a JSON file keyed by `key`.
    public func save<T: Codable>(_ items: [T], forKey key: String) {
        let url = fileURL(for: key)
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(items)
            try data.write(to: url, options: .atomic)
        } catch {
            print("[LocalStorageService] Failed to save \(key): \(error.localizedDescription)")
        }
    }

    /// Loads a Codable array from the JSON file keyed by `key`.
    /// Returns `nil` if the file doesn't exist or can't be decoded.
    public func load<T: Codable>(forKey key: String) -> [T]? {
        let url = fileURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([T].self, from: data)
        } catch {
            print("[LocalStorageService] Failed to load \(key): \(error.localizedDescription)")
            return nil
        }
    }

    /// Removes the persisted file for the given key.
    public func remove(forKey key: String) {
        let url = fileURL(for: key)
        try? FileManager.default.removeItem(at: url)
    }

    /// Returns true if a persisted file exists for the given key.
    public func exists(forKey key: String) -> Bool {
        FileManager.default.fileExists(atPath: fileURL(for: key).path)
    }

    // MARK: - Private

    private func fileURL(for key: String) -> URL {
        directory.appendingPathComponent("\(key).json")
    }
}
