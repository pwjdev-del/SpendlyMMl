import SwiftUI
import SpendlyCore

/// Real-time preview card showing how the current branding settings will look
/// in the live application. Mirrors the Stitch "Live Preview" section.
struct BrandingPreviewCard: View {

    let primaryColor: Color
    let secondaryColor: Color
    let cornerRadius: CGFloat
    let headingFont: Font
    let bodyFont: Font
    let logoImage: UIImage?

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            sectionLabel

            SPCard(elevation: .medium) {
                VStack(spacing: SpendlySpacing.md) {
                    logoPlaceholder
                    headingText
                    descriptionText
                    primaryButton
                    secondaryButton
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .animation(.easeInOut(duration: 0.2), value: cornerRadius)
            .animation(.easeInOut(duration: 0.2), value: primaryColor)
            .animation(.easeInOut(duration: 0.2), value: secondaryColor)
        }
    }

    // MARK: - Subviews

    private var sectionLabel: some View {
        Text("LIVE PREVIEW")
            .font(SpendlyFont.caption())
            .fontWeight(.semibold)
            .foregroundStyle(SpendlyColors.secondary)
            .tracking(1.2)
    }

    private var logoPlaceholder: some View {
        Group {
            if let logoImage {
                Image(uiImage: logoImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                    .strokeBorder(
                        SpendlyColors.secondary.opacity(0.3),
                        style: StrokeStyle(lineWidth: 1.5, dash: [4, 3])
                    )
                    .frame(width: 48, height: 48)
                    .background(
                        SpendlyColors.surface(for: colorScheme).opacity(0.5)
                    )
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var headingText: some View {
        Text("Main App Heading")
            .font(headingFont)
            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            .frame(maxWidth: .infinity)
    }

    private var descriptionText: some View {
        Text("This is how your company branding will appear to your field technicians.")
            .font(bodyFont)
            .foregroundStyle(SpendlyColors.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    private var primaryButton: some View {
        Text("Action Button")
            .font(bodyFont)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.md)
            .padding(.horizontal, SpendlySpacing.lg)
            .background(primaryColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: primaryColor.opacity(0.25), radius: 4, y: 2)
    }

    private var secondaryButton: some View {
        Text("Secondary Action")
            .font(bodyFont)
            .fontWeight(.medium)
            .foregroundStyle(secondaryColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendlySpacing.sm)
            .padding(.horizontal, SpendlySpacing.lg)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(secondaryColor, lineWidth: 1.5)
            )
    }
}

// MARK: - Preview

#Preview("Default State") {
    ScrollView {
        BrandingPreviewCard(
            primaryColor: Color(hex: "#3b82f6"),
            secondaryColor: Color(hex: "#64748b"),
            cornerRadius: SpendlyRadius.medium,
            headingFont: .system(.title3, design: .default, weight: .bold),
            bodyFont: .system(.body, design: .default),
            logoImage: nil
        )
        .padding()
    }
    .background(SpendlyColors.backgroundLight)
}

#Preview("Custom Branding") {
    ScrollView {
        BrandingPreviewCard(
            primaryColor: Color(hex: "#19355c"),
            secondaryColor: Color(hex: "#f97316"),
            cornerRadius: SpendlyRadius.xl,
            headingFont: .system(.title3, design: .serif, weight: .bold),
            bodyFont: .system(.body, design: .serif),
            logoImage: nil
        )
        .padding()
    }
    .background(SpendlyColors.backgroundLight)
}

#Preview("Dark Mode") {
    ScrollView {
        BrandingPreviewCard(
            primaryColor: Color(hex: "#3b82f6"),
            secondaryColor: Color(hex: "#64748b"),
            cornerRadius: SpendlyRadius.medium,
            headingFont: .system(.title3, design: .default, weight: .bold),
            bodyFont: .system(.body, design: .default),
            logoImage: nil
        )
        .padding()
    }
    .background(SpendlyColors.backgroundDark)
    .preferredColorScheme(.dark)
}
