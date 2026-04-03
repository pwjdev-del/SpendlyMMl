import SwiftUI
import SwiftData
import Foundation

// MARK: - MockDataProvider Protocol

public protocol MockDataProvider {
    associatedtype ModelType
    static var samples: [ModelType] { get }
    static var single: ModelType { get }
}
