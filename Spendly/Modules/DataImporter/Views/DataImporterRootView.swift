import SwiftUI
import SpendlyCore

// MARK: - DataImporterRootView

public struct DataImporterRootView: View {
    @State private var viewModel = DataImporterViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        ZStack(alignment: .bottom) {
            SPScreenWrapper {
                VStack(spacing: SpendlySpacing.lg) {
                    // MARK: - Page Header
                    pageHeader

                    // MARK: - Entity Selection
                    entitySelectionSection

                    // MARK: - File Upload Zone
                    fileUploadSection

                    // MARK: - Validation Preview
                    if viewModel.hasFileAttached {
                        validationPreviewSection
                    }

                    // MARK: - Import Footer (Progress + Action)
                    if viewModel.hasFileAttached {
                        importActionSection
                    }

                    // MARK: - Import Complete
                    if viewModel.showImportComplete {
                        importCompleteSection
                    }

                    // MARK: - Bottom spacer for tab bar
                    Spacer().frame(height: SpendlySpacing.xxxl)
                }
            }

            // MARK: - Tab Bar
            SPTabBar(
                tabs: viewModel.tabItems,
                selectedIndex: $viewModel.selectedTabIndex
            )
        }
    }

    // MARK: - Page Header

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text("Data Importer")
                        .font(SpendlyFont.largeTitle())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Text("Upload data ledgers to synchronize your core entities.")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        .lineSpacing(2)
                }

                Spacer()
            }

            // Download CSV Template button
            SPButton("Download CSV Template", icon: "arrow.down.doc", style: .secondary) {
                viewModel.downloadTemplate()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Entity Selection Section

    private var entitySelectionSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            sectionLabel("1. SELECT TARGET ENTITY")

            ForEach(ImportEntityType.allCases) { entity in
                entityRadioTile(entity)
            }
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(cardBorderColor, lineWidth: 1)
        )
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(SpendlyColors.accent)
                .frame(width: 3)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: SpendlyRadius.large,
                        bottomLeadingRadius: SpendlyRadius.large
                    )
                )
        }
    }

    private func entityRadioTile(_ entity: ImportEntityType) -> some View {
        let isSelected = viewModel.selectedEntity == entity

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectEntity(entity)
            }
        } label: {
            HStack(spacing: SpendlySpacing.md) {
                // Radio indicator
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? SpendlyColors.accent : SpendlyColors.secondary.opacity(0.4),
                            lineWidth: 2
                        )
                        .frame(width: 20, height: 20)

                    if isSelected {
                        Circle()
                            .fill(SpendlyColors.accent)
                            .frame(width: 10, height: 10)
                    }
                }

                Image(systemName: entity.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? SpendlyColors.accent : SpendlyColors.secondary)
                    .frame(width: 24)

                Text(entity.rawValue)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(
                        isSelected
                            ? SpendlyColors.foreground(for: colorScheme)
                            : SpendlyColors.secondaryForeground(for: colorScheme)
                    )

                Spacer()
            }
            .padding(SpendlySpacing.lg)
            .background(
                isSelected
                    ? SpendlyColors.accent.opacity(0.08)
                    : SpendlyColors.background(for: colorScheme)
            )
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .strokeBorder(
                        isSelected ? SpendlyColors.accent : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - File Upload Section

    private var fileUploadSection: some View {
        VStack(spacing: 0) {
            if let fileName = viewModel.attachedFileName, viewModel.hasFileAttached {
                // File attached state
                HStack(spacing: SpendlySpacing.md) {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(SpendlyColors.success)

                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text(fileName)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        Text("CSV File - Ready")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.success)
                    }

                    Spacer()

                    Button {
                        viewModel.resetImport()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                    }
                }
                .padding(SpendlySpacing.lg)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                        .strokeBorder(SpendlyColors.success.opacity(0.3), lineWidth: 1.5)
                )
            } else {
                // Upload zone (dashed border)
                Button {
                    viewModel.simulateFileAttach()
                } label: {
                    VStack(spacing: SpendlySpacing.lg) {
                        ZStack {
                            Circle()
                                .fill(SpendlyColors.accent.opacity(0.12))
                                .frame(width: 56, height: 56)

                            Image(systemName: "doc.badge.arrow.up")
                                .font(.system(size: 24))
                                .foregroundStyle(SpendlyColors.accent)
                        }

                        VStack(spacing: SpendlySpacing.xs) {
                            Text("Drop Architectural Ledger")
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            Text("Accepts .CSV, .XLSX, or .JSON up to 50MB")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        }

                        Text("Browse Files")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, SpendlySpacing.xxl)
                            .padding(.vertical, SpendlySpacing.sm)
                            .background(SpendlyColors.primary)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.xxxl)
                    .background(
                        RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                            )
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.3))
                    )
                    .background(
                        SpendlyColors.surface(for: colorScheme).opacity(0.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(SpendlySpacing.xs)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.xl, style: .continuous)
                        .strokeBorder(cardBorderColor, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Validation Preview Section

    private var validationPreviewSection: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                HStack {
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        sectionLabel("2. VALIDATION PREVIEW")

                        HStack(spacing: SpendlySpacing.xs) {
                            Text("Pre-processing:")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                            Text("\(viewModel.totalRecordCount) records found")
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                                .foregroundStyle(SpendlyColors.accent)
                        }
                    }

                    Spacer()

                    SPBadge("Ready to Import", style: .success)
                }
            }
            .padding(SpendlySpacing.lg)

            SPDivider()

            // Table Header
            tableHeaderRow

            SPDivider()

            // Table Rows
            ForEach(viewModel.records) { record in
                tableRow(record: record)
                SPDivider()
            }
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(cardBorderColor, lineWidth: 1)
        )
    }

    private var tableHeaderRow: some View {
        HStack(spacing: 0) {
            tableHeaderCell("Status", width: 52)
            tableHeaderCell("Serial ID", flex: true)
            tableHeaderCell("Model", flex: true)
            tableHeaderCell("Site Location", flex: true)
        }
        .padding(.vertical, SpendlySpacing.sm)
        .background(SpendlyColors.background(for: colorScheme))
    }

    private func tableHeaderCell(_ title: String, width: CGFloat? = nil, flex: Bool = false) -> some View {
        Text(title)
            .font(SpendlyFont.caption())
            .fontWeight(.bold)
            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            .frame(maxWidth: flex ? .infinity : width, alignment: .leading)
            .padding(.horizontal, SpendlySpacing.md)
    }

    private func tableRow(record: ImportRecord) -> some View {
        HStack(spacing: 0) {
            // Status icon
            Image(systemName: record.status.icon)
                .font(.system(size: 16))
                .foregroundStyle(record.status == .valid ? SpendlyColors.success : SpendlyColors.error)
                .frame(width: 52, alignment: .leading)
                .padding(.horizontal, SpendlySpacing.md)

            // Serial ID
            Text(record.serialID)
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, SpendlySpacing.md)

            // Model
            Text(record.model)
                .font(SpendlyFont.bodyMedium())
                .foregroundStyle(
                    record.isModelMissing
                        ? SpendlyColors.error
                        : SpendlyColors.foreground(for: colorScheme)
                )
                .italic(record.isModelMissing)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, SpendlySpacing.md)

            // Site Location
            Text(record.siteLocation)
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, SpendlySpacing.md)
        }
        .padding(.vertical, SpendlySpacing.md)
        .background(
            record.status == .warning
                ? SpendlyColors.error.opacity(0.04)
                : Color.clear
        )
    }

    // MARK: - Import Action Section

    private var importActionSection: some View {
        VStack(spacing: SpendlySpacing.lg) {
            // Progress label row
            HStack {
                Text("IMPORT PROGRESS")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.8))

                Spacer()

                Text("\(viewModel.progressPercentage)%")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.8))
                    .monospacedDigit()
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.15))
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(SpendlyColors.accent)
                        .frame(
                            width: geo.size.width * viewModel.importProgress,
                            height: 6
                        )
                        .animation(.easeInOut(duration: 0.3), value: viewModel.importProgress)
                }
            }
            .frame(height: 6)

            // Warning count + Start Import
            HStack {
                if viewModel.warningCount > 0 && !viewModel.showImportComplete {
                    Text("Review the \(viewModel.warningCount) warning\(viewModel.warningCount == 1 ? "" : "s") detected before final submission.")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(.white.opacity(0.6))
                } else if viewModel.showImportComplete {
                    Text("Import completed successfully.")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                if !viewModel.showImportComplete {
                    Button {
                        Task {
                            await viewModel.startImport()
                        }
                    } label: {
                        HStack(spacing: SpendlySpacing.sm) {
                            if viewModel.isImporting {
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(0.8)
                            }

                            Text(viewModel.isImporting ? "Importing..." : "Start Import")
                                .font(SpendlyFont.bodySemibold())
                                .fontWeight(.heavy)
                                .textCase(.uppercase)
                                .tracking(-0.3)

                            if !viewModel.isImporting {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 14))
                            }
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, SpendlySpacing.xl)
                        .padding(.vertical, SpendlySpacing.md)
                        .background(SpendlyColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    }
                    .disabled(viewModel.isImporting)
                    .opacity(viewModel.isImporting ? 0.7 : 1.0)
                }
            }
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.primary)
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: - Import Complete Section

    private var importCompleteSection: some View {
        VStack(spacing: SpendlySpacing.lg) {
            ZStack {
                Circle()
                    .fill(SpendlyColors.success.opacity(0.12))
                    .frame(width: 64, height: 64)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(SpendlyColors.success)
            }

            VStack(spacing: SpendlySpacing.xs) {
                Text("Import Complete")
                    .font(SpendlyFont.title())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text("\(viewModel.validCount) records imported successfully. \(viewModel.warningCount) warning\(viewModel.warningCount == 1 ? "" : "s") skipped.")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .multilineTextAlignment(.center)
            }

            SPButton("Start New Import", icon: "arrow.counterclockwise", style: .secondary) {
                withAnimation {
                    viewModel.resetImport()
                }
            }
        }
        .padding(SpendlySpacing.xxl)
        .frame(maxWidth: .infinity)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(SpendlyColors.success.opacity(0.3), lineWidth: 1.5)
        )
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(SpendlyFont.caption())
            .fontWeight(.bold)
            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            .tracking(1.2)
    }

    private var cardBorderColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.08)
            : Color(hex: "#e5e7eb")
    }
}

// MARK: - Preview

#Preview("Light") {
    DataImporterRootView()
}

#Preview("Dark") {
    DataImporterRootView()
        .preferredColorScheme(.dark)
}
