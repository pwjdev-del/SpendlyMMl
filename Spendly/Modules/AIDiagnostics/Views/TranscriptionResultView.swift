import SwiftUI
import SpendlyCore

struct TranscriptionResultView: View {
    @Bindable var viewModel: AIDiagnosticsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpendlySpacing.lg) {

                    // MARK: - Confidence
                    HStack {
                        Text("Overall Confidence")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Spacer()
                        Text("\(Int(viewModel.overallConfidence * 100))%")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.success)
                    }
                    .padding(SpendlySpacing.md)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                    // MARK: - Original Transcription
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        HStack {
                            Text("Original (\(viewModel.detectedLanguage))")
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Spacer()
                        }
                        Text(viewModel.originalTranscription)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                    .padding(SpendlySpacing.md)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                    // MARK: - Translated / Edited Transcription
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        HStack {
                            Text("Translation (\(viewModel.targetLanguage))")
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Spacer()
                            if !viewModel.isEditingTranscription {
                                Button {
                                    viewModel.startEditingTranscription()
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                        .font(SpendlyFont.caption())
                                }
                            }
                        }

                        if viewModel.isEditingTranscription {
                            TextEditor(text: $viewModel.editedTranscription)
                                .frame(minHeight: 100)
                                .font(SpendlyFont.body())
                                .overlay(
                                    RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                                        .stroke(SpendlyColors.primary, lineWidth: 1)
                                )
                            HStack {
                                Button("Cancel") {
                                    viewModel.cancelTranscriptionEdit()
                                }
                                .buttonStyle(.bordered)
                                Spacer()
                                Button("Save") {
                                    viewModel.saveTranscriptionEdit()
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(SpendlyColors.primary)
                            }
                        } else {
                            Text(viewModel.translatedTranscription)
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        }
                    }
                    .padding(SpendlySpacing.md)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                    // MARK: - Extracted Items
                    if !viewModel.extractedItems.isEmpty {
                        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                            Text("AI Extracted Items")
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            ForEach(viewModel.extractedItems) { item in
                                HStack(spacing: SpendlySpacing.sm) {
                                    Image(systemName: item.isAccepted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(item.isAccepted ? SpendlyColors.success : SpendlyColors.secondary)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.text)
                                            .font(SpendlyFont.body())
                                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                        HStack(spacing: SpendlySpacing.xs) {
                                            SPBadge(item.category.rawValue, style: item.category.badgeStyle)
                                            Text("\(Int(item.confidence * 100))%")
                                                .font(SpendlyFont.caption())
                                                .foregroundStyle(SpendlyColors.secondary)
                                        }
                                    }

                                    Spacer()

                                    Button {
                                        viewModel.toggleItemAcceptance(itemID: item.id)
                                    } label: {
                                        Image(systemName: item.isAccepted ? "xmark" : "plus")
                                            .font(.caption)
                                            .foregroundStyle(SpendlyColors.secondary)
                                    }
                                }
                                .padding(SpendlySpacing.sm)
                                .background(SpendlyColors.background(for: colorScheme))
                                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                            }
                        }
                        .padding(SpendlySpacing.md)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))
                    }
                }
                .padding(SpendlySpacing.md)
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationTitle("Transcription Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("New Session") {
                        viewModel.resetSession()
                        dismiss()
                    }
                }
            }
        }
    }
}
