import SwiftUI
import PhotosUI
import SpendlyCore

// MARK: - WhiteLabelBrandingRootView

public struct WhiteLabelBrandingRootView: View {

    @State private var viewModel = WhiteLabelBrandingViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            header
            scrollContent
        }
        .background(SpendlyColors.background(for: colorScheme).ignoresSafeArea())
        .alert("Settings Saved", isPresented: $viewModel.showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your branding settings have been saved successfully.")
        }
        .alert("Reset to Defaults?", isPresented: $viewModel.showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetToDefaults()
            }
        } message: {
            Text("This will reset all branding settings to their platform defaults. This action cannot be undone.")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("White Label Branding")
                .font(SpendlyFont.title())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Spacer()

            SPButton("Save Changes", style: .primary, isLoading: viewModel.isSaving) {
                viewModel.saveChanges()
            }
            .frame(width: 150)
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Scroll Content

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: SpendlySpacing.xxl) {
                livePreviewSection
                assetManagementSection
                brandingSettingsSection
                Divider()
                    .padding(.horizontal, SpendlySpacing.lg)
                currencySection
                resetSection
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.top, SpendlySpacing.lg)
            .padding(.bottom, SpendlySpacing.xxxl)
        }
    }

    // MARK: - Live Preview Section

    private var livePreviewSection: some View {
        BrandingPreviewCard(
            primaryColor: viewModel.primaryColor,
            secondaryColor: viewModel.secondaryColor,
            cornerRadius: viewModel.cornerRadius,
            headingFont: viewModel.previewHeadingFont,
            bodyFont: viewModel.previewFont,
            logoImage: viewModel.companyLogoImage
        )
    }

    // MARK: - Asset Management Section

    private var assetManagementSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            HStack {
                Text("ASSET MANAGEMENT")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .tracking(1.2)

                Spacer()

                SPBadge("IMAGE LIBRARY", style: .info)
            }

            appIconAndHeroRow
            serviceImageGallerySection
        }
    }

    // MARK: - App Icon & Login Hero Row

    private var appIconAndHeroRow: some View {
        HStack(alignment: .top, spacing: SpendlySpacing.lg) {
            // Main App Icon
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Main App Icon")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                PhotosPicker(selection: $viewModel.appIconPhotoItem, matching: .images) {
                    imageUploadBox(
                        image: viewModel.appIconImage,
                        hint: "1024x1024px"
                    )
                    .aspectRatio(1, contentMode: .fit)
                }
                .onChange(of: viewModel.appIconPhotoItem) {
                    Task { await viewModel.loadAppIconImage() }
                }
            }
            .frame(maxWidth: .infinity)

            // Login Hero
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Login Hero")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                PhotosPicker(selection: $viewModel.heroPhotoItem, matching: .images) {
                    imageUploadBox(
                        image: viewModel.loginHeroImage,
                        hint: "16:9 Aspect"
                    )
                    .aspectRatio(1, contentMode: .fit)
                }
                .onChange(of: viewModel.heroPhotoItem) {
                    Task { await viewModel.loadHeroImage() }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Service Image Gallery

    private var serviceImageGallerySection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Text("Service Image Gallery")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                PhotosPicker(selection: $viewModel.servicePhotoItem, matching: .images) {
                    Text("+ Add New")
                        .font(SpendlyFont.caption())
                        .fontWeight(.semibold)
                        .foregroundStyle(SpendlyColors.primary)
                }
                .onChange(of: viewModel.servicePhotoItem) {
                    Task { await viewModel.loadServiceImage() }
                }
            }

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: SpendlySpacing.md),
                    GridItem(.flexible(), spacing: SpendlySpacing.md),
                    GridItem(.flexible(), spacing: SpendlySpacing.md),
                ],
                spacing: SpendlySpacing.md
            ) {
                ForEach(viewModel.serviceImages) { serviceImage in
                    serviceImageThumbnail(serviceImage)
                }

                // Add placeholder
                addImagePlaceholder
            }
        }
    }

    private func serviceImageThumbnail(_ serviceImage: ServiceImage) -> some View {
        ZStack(alignment: .bottom) {
            if let uiImage = serviceImage.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
            } else {
                Rectangle()
                    .fill(SpendlyColors.secondary.opacity(0.1))
                    .aspectRatio(1, contentMode: .fill)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                    }
            }

            // Name overlay
            Text(serviceImage.name)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 2)
                .padding(.horizontal, 4)
                .background(.black.opacity(0.6))

            // Delete button overlay
            VStack {
                HStack {
                    Spacer()
                    Button {
                        viewModel.removeServiceImage(serviceImage)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                            .shadow(radius: 2)
                    }
                    .padding(4)
                }
                Spacer()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
        )
    }

    private var addImagePlaceholder: some View {
        PhotosPicker(selection: $viewModel.servicePhotoItem, matching: .images) {
            RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                .strokeBorder(
                    SpendlyColors.secondary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [5, 3])
                )
                .aspectRatio(1, contentMode: .fit)
                .background(
                    SpendlyColors.surface(for: colorScheme).opacity(0.5)
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
                )
                .overlay {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .light))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                }
        }
    }

    // MARK: - Branding Settings Section

    private var brandingSettingsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
            companyLogoUpload
            colorPickersSection
            fontSelectionSection
            cornerRoundnessSection
        }
    }

    // MARK: - Company Logo Upload (#11)

    private var companyLogoUpload: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("Company Logo (Dashboard/Invoices)")
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            PhotosPicker(selection: $viewModel.logoPhotoItem, matching: .images) {
                Group {
                    if let logo = viewModel.companyLogoImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: logo)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 128)
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))

                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(SpendlyColors.primary)
                                .background(Circle().fill(.white))
                                .padding(SpendlySpacing.sm)
                        }
                    } else {
                        uploadDropzone
                    }
                }
            }
            .onChange(of: viewModel.logoPhotoItem) {
                Task { await viewModel.loadLogoImage() }
            }
        }
    }

    private var uploadDropzone: some View {
        VStack(spacing: SpendlySpacing.md) {
            Image(systemName: "icloud.and.arrow.up")
                .font(.system(size: 28))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.5))

            VStack(spacing: SpendlySpacing.xs) {
                Text("Click to upload")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.secondary)
                + Text(" or drag and drop")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondary)

                Text("PNG or JPG (Recommended 512x512px)")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 128)
        .background(SpendlyColors.surface(for: colorScheme).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(
                    SpendlyColors.secondary.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                )
        )
    }

    // MARK: - Color Pickers (#14, #15)

    private var colorPickersSection: some View {
        HStack(alignment: .top, spacing: SpendlySpacing.lg) {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Primary Color")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                ColorPicker("", selection: $viewModel.primaryColor, supportsOpacity: false)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Text("Secondary Color")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                ColorPicker("", selection: $viewModel.secondaryColor, supportsOpacity: false)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Font Selection (#16)

    private var fontSelectionSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("Typography Font")
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            HStack(spacing: SpendlySpacing.sm) {
                ForEach(FontChoice.allCases, id: \.self) { font in
                    fontOptionButton(font)
                }
            }
        }
    }

    private func fontOptionButton(_ font: FontChoice) -> some View {
        let isSelected = viewModel.selectedFont == font
        let label: String = {
            switch font {
            case .sansSerif: return "Sans Serif"
            case .serif:     return "Serif"
            case .mono:      return "Mono"
            }
        }()
        let designFont: Font = {
            switch font {
            case .sansSerif: return .system(.subheadline, design: .default)
            case .serif:     return .system(.subheadline, design: .serif)
            case .mono:      return .system(.subheadline, design: .monospaced)
            }
        }()

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.selectedFont = font
            }
        } label: {
            Text(label)
                .font(designFont)
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpendlySpacing.md)
                .background(
                    isSelected
                        ? SpendlyColors.primary.opacity(0.08)
                        : SpendlyColors.surface(for: colorScheme)
                )
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .strokeBorder(
                            isSelected ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.2),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .foregroundStyle(
                    isSelected
                        ? SpendlyColors.primary
                        : SpendlyColors.foreground(for: colorScheme)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Corner Roundness (#17)

    private var cornerRoundnessSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("Element Roundness")
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            HStack(spacing: SpendlySpacing.sm) {
                ForEach(CornerStyle.allCases, id: \.self) { style in
                    cornerOptionButton(style)
                }
            }
        }
    }

    private func cornerOptionButton(_ style: CornerStyle) -> some View {
        let isSelected = viewModel.selectedCornerStyle == style
        let label: String = {
            switch style {
            case .square:       return "Square"
            case .rounded:      return "Rounded"
            case .extraRounded: return "Extra"
            }
        }()
        let shapeRadius: CGFloat = {
            switch style {
            case .square:       return 0
            case .rounded:      return SpendlyRadius.medium
            case .extraRounded: return SpendlyRadius.xl + 8
            }
        }()

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.selectedCornerStyle = style
            }
        } label: {
            Text(label)
                .font(SpendlyFont.caption())
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpendlySpacing.md)
                .background(
                    isSelected
                        ? SpendlyColors.primary.opacity(0.08)
                        : SpendlyColors.surface(for: colorScheme)
                )
                .clipShape(RoundedRectangle(cornerRadius: shapeRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: shapeRadius, style: .continuous)
                        .strokeBorder(
                            isSelected ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.2),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
                .foregroundStyle(
                    isSelected
                        ? SpendlyColors.primary
                        : SpendlyColors.foreground(for: colorScheme)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Currency Section (#19-22)

    private var currencySection: some View {
        CurrencySettingsView(viewModel: viewModel)
    }

    // MARK: - Reset Defaults (#23)

    private var resetSection: some View {
        Button {
            viewModel.showResetAlert = true
        } label: {
            Text("RESET TO PLATFORM DEFAULTS")
                .font(SpendlyFont.caption())
                .fontWeight(.medium)
                .foregroundStyle(SpendlyColors.secondary.opacity(0.6))
                .tracking(2)
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpendlySpacing.lg)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Image Upload Box Helper

    private func imageUploadBox(image: UIImage?, hint: String) -> some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            } else {
                VStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "photo")
                        .font(.system(size: 24))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.5))

                    Text(hint)
                        .font(.system(size: 10))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(SpendlyColors.surface(for: colorScheme).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .strokeBorder(
                            SpendlyColors.secondary.opacity(0.3),
                            style: StrokeStyle(lineWidth: 2, dash: [5, 3])
                        )
                )
            }
        }
    }
}

// MARK: - Previews

#Preview("White Label Branding") {
    WhiteLabelBrandingRootView()
}

#Preview("Dark Mode") {
    WhiteLabelBrandingRootView()
        .preferredColorScheme(.dark)
}
