import SwiftUI

// MARK: - Font Registration

public enum SpendlyFontRegistrar {
    /// Call once at app launch (e.g. in your App init) to register bundled Inter & Manrope fonts.
    public static func registerFonts() {
        let fontNames = [
            "Inter-Regular",
            "Inter-Medium",
            "Inter-SemiBold",
            "Inter-Bold",
            "Manrope-Regular",
            "Manrope-Medium",
            "Manrope-SemiBold",
            "Manrope-Bold",
            "Manrope-ExtraBold"
        ]
        for name in fontNames {
            registerFont(named: name)
        }
    }

    private static func registerFont(named name: String) {
        let extensions = ["ttf", "otf"]
        // Search in the main bundle first, then fall back to the package bundle.
        let bundles: [Bundle] = [
            .main,
            Bundle(for: BundleToken.self)
        ]
        for bundle in bundles {
            for ext in extensions {
                if let url = bundle.url(forResource: name, withExtension: ext) {
                    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
                    return
                }
            }
        }
    }
}

// Private class used to locate the package bundle.
private final class BundleToken {
}

// MARK: - Spendly Font

public enum SpendlyFont {

    // MARK: Inter variants

    /// Caption — Inter Regular 12pt
    public static func caption() -> Font {
        .custom("Inter-Regular", size: 12)
    }

    /// Body — Inter Regular 14pt
    public static func body() -> Font {
        .custom("Inter-Regular", size: 14)
    }

    /// Body Medium — Inter Medium 14pt
    public static func bodyMedium() -> Font {
        .custom("Inter-Medium", size: 14)
    }

    /// Body Semibold — Inter SemiBold 14pt
    public static func bodySemibold() -> Font {
        .custom("Inter-SemiBold", size: 14)
    }

    /// Headline — Inter SemiBold 16pt
    public static func headline() -> Font {
        .custom("Inter-SemiBold", size: 16)
    }

    /// Title — Inter Bold 20pt
    public static func title() -> Font {
        .custom("Inter-Bold", size: 20)
    }

    /// Large Title — Inter Bold 24pt
    public static func largeTitle() -> Font {
        .custom("Inter-Bold", size: 24)
    }

    // MARK: Manrope variants (Aeon Financial)

    /// Financial Headline — Manrope Bold 20pt
    public static func financialHeadline() -> Font {
        .custom("Manrope-Bold", size: 20)
    }

    /// Financial Title — Manrope ExtraBold 28pt
    public static func financialTitle() -> Font {
        .custom("Manrope-ExtraBold", size: 28)
    }

    // MARK: Tabular Numbers

    /// Tabular Numbers — Inter Medium 14pt, monospaced digit
    public static func tabularNumbers() -> Font {
        .custom("Inter-Medium", size: 14)
            .monospacedDigit()
    }
}
