import Foundation
import Network

@Observable
public class NetworkMonitor {
    public var isConnected: Bool = true

    private let monitor = NWPathMonitor()

    public init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: DispatchQueue(label: "com.spendly.NetworkMonitor"))
    }

    deinit {
        monitor.cancel()
    }
}
