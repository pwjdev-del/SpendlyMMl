import Foundation

public class CurrencyFormatter {
    public static let shared = CurrencyFormatter()

    private let formatter: NumberFormatter

    public init(locale: Locale = .current, currencyCode: String? = nil) {
        formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        if let code = currencyCode {
            formatter.currencyCode = code
        }
    }

    /// Formats a Double as a localized currency string.
    /// - Parameters:
    ///   - amount: The amount to format
    ///   - currencyCode: Optional override for currency code (e.g., "USD", "INR", "EUR")
    /// - Returns: A formatted currency string (e.g., "$1,234.56")
    public func format(_ amount: Double, currencyCode: String? = nil) -> String {
        if let code = currencyCode {
            let customFormatter = NumberFormatter()
            customFormatter.numberStyle = .currency
            customFormatter.currencyCode = code
            customFormatter.locale = formatter.locale
            return customFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        }
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    /// Formats a Double as a compact currency string for display in cards/lists.
    /// - Parameters:
    ///   - amount: The amount to format
    ///   - currencyCode: Optional currency code
    /// - Returns: A compact string (e.g., "$1.2K", "$3.5M")
    public func formatCompact(_ amount: Double, currencyCode: String? = nil) -> String {
        let code = currencyCode ?? formatter.currencyCode ?? "USD"
        let symbol = currencySymbol(for: code)

        switch abs(amount) {
        case 1_000_000_000...:
            return "\(symbol)\(String(format: "%.1f", amount / 1_000_000_000))B"
        case 1_000_000...:
            return "\(symbol)\(String(format: "%.1f", amount / 1_000_000))M"
        case 1_000...:
            return "\(symbol)\(String(format: "%.1f", amount / 1_000))K"
        default:
            return format(amount, currencyCode: currencyCode)
        }
    }

    /// Returns the currency symbol for a given currency code.
    public func currencySymbol(for code: String) -> String {
        let locale = NSLocale(localeIdentifier: code)
        return locale.displayName(forKey: .currencySymbol, value: code) ?? code
    }

    /// Parses a currency string back into a Double.
    /// - Parameter string: The formatted currency string
    /// - Returns: The numeric value, or nil if parsing fails
    public func parse(_ string: String) -> Double? {
        return formatter.number(from: string)?.doubleValue
    }
}
