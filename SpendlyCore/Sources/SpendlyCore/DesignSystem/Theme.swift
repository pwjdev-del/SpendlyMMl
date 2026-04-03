import SwiftUI

// MARK: - Theme

public enum SpendlyTheme {
    case blueprint
    case aeon

    public var primaryColor: Color {
        switch self {
        case .blueprint: return SpendlyColors.primary
        case .aeon:      return SpendlyColors.aeonPrimary
        }
    }

    public var accentColor: Color {
        switch self {
        case .blueprint: return SpendlyColors.accent
        case .aeon:      return SpendlyColors.aeonAccent
        }
    }

    public var secondaryColor: Color {
        switch self {
        case .blueprint: return SpendlyColors.secondary
        case .aeon:      return SpendlyColors.aeonSecondary
        }
    }

    public func backgroundColor(for scheme: ColorScheme) -> Color {
        switch self {
        case .blueprint:
            return scheme == .dark ? SpendlyColors.backgroundDark : SpendlyColors.backgroundLight
        case .aeon:
            return scheme == .dark ? SpendlyColors.aeonSurface : SpendlyColors.aeonBackground
        }
    }

    public func surfaceColor(for scheme: ColorScheme) -> Color {
        switch self {
        case .blueprint:
            return scheme == .dark ? SpendlyColors.surfaceDark : SpendlyColors.surfaceLight
        case .aeon:
            return scheme == .dark ? SpendlyColors.aeonPrimary : .white
        }
    }

    public func foregroundColor(for scheme: ColorScheme) -> Color {
        switch self {
        case .blueprint:
            return scheme == .dark ? .white : SpendlyColors.primary
        case .aeon:
            return scheme == .dark ? .white : SpendlyColors.aeonPrimary
        }
    }
}

// MARK: - CornerStyle + Design System Radius
// FontChoice and CornerStyle are defined in Models/Enums.swift.
// This extension bridges CornerStyle to SpendlyRadius tokens.

public extension CornerStyle {
    var designRadius: CGFloat {
        switch self {
        case .square:       return SpendlyRadius.small
        case .rounded:      return SpendlyRadius.medium
        case .extraRounded: return SpendlyRadius.xl
        }
    }
}

// MARK: - Branding Configuration

@Observable
public final class BrandingConfiguration {
    public var customPrimaryColor: Color?
    public var customSecondaryColor: Color?
    public var customLogoURL: String?
    public var fontChoice: FontChoice
    public var cornerStyle: CornerStyle

    public init(
        customPrimaryColor: Color? = nil,
        customSecondaryColor: Color? = nil,
        customLogoURL: String? = nil,
        fontChoice: FontChoice = .sansSerif,
        cornerStyle: CornerStyle = .rounded
    ) {
        self.customPrimaryColor = customPrimaryColor
        self.customSecondaryColor = customSecondaryColor
        self.customLogoURL = customLogoURL
        self.fontChoice = fontChoice
        self.cornerStyle = cornerStyle
    }
}

// MARK: - Environment Keys

private struct SpendlyThemeKey: EnvironmentKey {
    static let defaultValue: SpendlyTheme = .blueprint
}

private struct BrandingConfigurationKey: EnvironmentKey {
    static let defaultValue: BrandingConfiguration = BrandingConfiguration()
}

public extension EnvironmentValues {
    var spendlyTheme: SpendlyTheme {
        get { self[SpendlyThemeKey.self] }
        set { self[SpendlyThemeKey.self] = newValue }
    }

    var brandingConfiguration: BrandingConfiguration {
        get { self[BrandingConfigurationKey.self] }
        set { self[BrandingConfigurationKey.self] = newValue }
    }
}

public extension View {
    func spendlyTheme(_ theme: SpendlyTheme) -> some View {
        environment(\.spendlyTheme, theme)
    }

    func brandingConfiguration(_ config: BrandingConfiguration) -> some View {
        environment(\.brandingConfiguration, config)
    }
}
