import SwiftUI

// MARK: - Color Hex Initializer

public extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Spendly Color Palettes

public enum SpendlyColors {

    // MARK: Blueprint Precision (Operational Screens)

    public static let primary = Color(hex: "#19355c")
    public static let accent = Color(hex: "#f97316")
    public static let secondary = Color(hex: "#64748B")
    public static let backgroundLight = Color(hex: "#f6f7f8")
    public static let backgroundDark = Color(hex: "#13181f")
    public static let surfaceLight = Color(hex: "#FFFFFF")
    public static let surfaceDark = Color(hex: "#1e293b")
    public static let success = Color(hex: "#10b981")
    public static let warning = Color(hex: "#f59e0b")
    public static let error = Color(hex: "#ef4444")
    public static let info = Color(hex: "#3b82f6")

    // MARK: Aeon Financial (Billing / Analytics Screens)

    public static let aeonPrimary = Color(hex: "#000e24")
    public static let aeonSecondary = Color(hex: "#47607E")
    public static let aeonAccent = Color(hex: "#70D8C8")
    public static let aeonBackground = Color(hex: "#F0F3FF")
    public static let aeonSurface = Color(hex: "#101B30")

    // MARK: Adaptive helpers

    /// Returns the appropriate background for the current color scheme.
    public static func background(for scheme: ColorScheme) -> Color {
        scheme == .dark ? backgroundDark : backgroundLight
    }

    /// Returns the appropriate surface for the current color scheme.
    public static func surface(for scheme: ColorScheme) -> Color {
        scheme == .dark ? surfaceDark : surfaceLight
    }

    /// Foreground text that contrasts with the current scheme.
    public static func foreground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? .white : primary
    }

    /// Secondary foreground text.
    public static func secondaryForeground(for scheme: ColorScheme) -> Color {
        scheme == .dark ? Color.white.opacity(0.7) : secondary
    }
}
