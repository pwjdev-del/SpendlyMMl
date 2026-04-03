import SwiftUI

public enum SpendlyRadius {
    /// 4pt
    public static let small: CGFloat = 4
    /// 8pt
    public static let medium: CGFloat = 8
    /// 12pt
    public static let large: CGFloat = 12
    /// 16pt
    public static let xl: CGFloat = 16
    /// Use with `.clipShape(Capsule())` for pill shapes
    public static let pill: CGFloat = .infinity
}
