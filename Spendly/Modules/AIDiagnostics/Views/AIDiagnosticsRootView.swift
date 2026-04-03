import SwiftUI
import SpendlyCore

// MARK: - AIDiagnosticsRootView

public struct AIDiagnosticsRootView: View {
    @State private var viewModel = AIDiagnosticsViewModel()
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            ZStack {
                SpendlyColors.background(for: colorScheme)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    headerSection

                    // Main Content
                    ScrollView {
                        VStack(spacing: SpendlySpacing.lg) {
                            sessionProgressBar
                            voiceEntryPoint
                            transcriptionArea
                            waveformVisualizer
                        }
                        .padding(.horizontal, SpendlySpacing.lg)
                        .padding(.top, SpendlySpacing.sm)
                        .padding(.bottom, 100)
                    }
                }

                // Floating mic button
                VStack {
                    Spacer()
                    floatingMicButton
                        .padding(.bottom, SpendlySpacing.xl)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showTranscriptionResult) {
                TranscriptionResultView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showDiagnosticWizard) {
                DiagnosticWizardView(viewModel: viewModel)
            }
            .onDisappear {
                viewModel.cleanup()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: SpendlySpacing.md) {
            Button {
                dismiss()
            } label: {
                Image(systemName: SpendlyIcon.arrowBack.systemName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Voice Diagnostic")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Text("Session ID: \(viewModel.sessionID)")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            Spacer()

            Button {
                viewModel.showDiagnosticWizard = true
            } label: {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .frame(width: 40, height: 40)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
            }

            Button {
                // Settings placeholder
            } label: {
                Image(systemName: SpendlyIcon.settings.systemName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .frame(width: 40, height: 40)
                    .background(SpendlyColors.surface(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Session Progress Bar

    private var sessionProgressBar: some View {
        SPCard {
            VStack(spacing: SpendlySpacing.md) {
                HStack {
                    // Live indicator
                    HStack(spacing: SpendlySpacing.sm) {
                        if viewModel.recordingState == .recording {
                            Circle()
                                .fill(SpendlyColors.error)
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .fill(SpendlyColors.error.opacity(0.4))
                                        .frame(width: 18, height: 18)
                                        .scaleEffect(viewModel.recordingState == .recording ? 1.3 : 1.0)
                                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.recordingState)
                                )
                        } else {
                            Circle()
                                .fill(SpendlyColors.secondary.opacity(0.3))
                                .frame(width: 10, height: 10)
                        }

                        Text(viewModel.recordingState == .recording
                             ? "Session Live: \(viewModel.formattedSessionTime)"
                             : viewModel.recordingState == .completed ? "Session Complete" : "Ready to Record")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }

                    Spacer()

                    // AI Active badge
                    if viewModel.recordingState == .recording || viewModel.recordingState == .processing {
                        aiBadge
                    }
                }

                // Code-Switching Toggle
                if viewModel.recordingState == .recording {
                    HStack {
                        Spacer()
                        Button {
                            viewModel.toggleCodeSwitching()
                        } label: {
                            HStack(spacing: SpendlySpacing.xs) {
                                Image(systemName: "globe")
                                    .font(.system(size: 12, weight: .semibold))
                                Text(viewModel.isCodeSwitchingActive ? "Code-Switching Active" : "Code-Switching Off")
                                    .font(SpendlyFont.caption())
                                    .fontWeight(.bold)
                                    .textCase(.uppercase)
                            }
                            .padding(.horizontal, SpendlySpacing.sm)
                            .padding(.vertical, SpendlySpacing.xs)
                            .foregroundStyle(viewModel.isCodeSwitchingActive ? SpendlyColors.info : SpendlyColors.secondary)
                            .background(
                                viewModel.isCodeSwitchingActive
                                    ? SpendlyColors.info.opacity(0.12)
                                    : SpendlyColors.secondary.opacity(0.08)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendlyRadius.small)
                                    .strokeBorder(
                                        viewModel.isCodeSwitchingActive
                                            ? SpendlyColors.info.opacity(0.3)
                                            : SpendlyColors.secondary.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                        }
                    }
                }

                // Progress bar
                SPProgressBar(
                    progress: viewModel.recordingState == .recording ? 0.72 : (viewModel.recordingState == .completed ? 1.0 : 0.0),
                    height: 6
                )
            }
        }
    }

    // MARK: - AI Badge

    private var aiBadge: some View {
        HStack(spacing: SpendlySpacing.xs) {
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .bold))
            Text("AI Active")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
        }
        .padding(.horizontal, SpendlySpacing.sm)
        .padding(.vertical, SpendlySpacing.xs)
        .foregroundStyle(SpendlyColors.info)
        .background(SpendlyColors.info.opacity(0.12))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(SpendlyColors.info.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Voice Entry Point

    @ViewBuilder
    private var voiceEntryPoint: some View {
        if viewModel.recordingState == .idle {
            SPCard(elevation: .medium) {
                VStack(spacing: SpendlySpacing.lg) {
                    // Mic icon
                    ZStack {
                        Circle()
                            .fill(SpendlyColors.primary)
                            .frame(width: 64, height: 64)
                            .shadow(color: SpendlyColors.primary.opacity(0.3), radius: 12, y: 4)

                        Image(systemName: SpendlyIcon.mic.systemName)
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(.white)
                    }

                    VStack(spacing: SpendlySpacing.sm) {
                        Text("Voice Diagnostics")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                        Text("Describe the issue in your own words. Our AI will automatically categorize the system and components for you.")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300)
                    }

                    // Machine selector
                    SPSelect(
                        "Target Machine",
                        options: viewModel.machineTemplates.map { "\($0.name) (SN: \($0.serialNumber))" },
                        selection: .constant("\(viewModel.selectedMachine.name) (SN: \(viewModel.selectedMachine.serialNumber))")
                    )

                    SPButton("Start Voice Assistant", icon: "sparkles", style: .primary) {
                        viewModel.startRecording()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpendlySpacing.md)
            }
            .background(
                RoundedRectangle(cornerRadius: SpendlyRadius.large)
                    .fill(SpendlyColors.primary.opacity(0.04))
            )
        }
    }

    // MARK: - Transcription Area

    @ViewBuilder
    private var transcriptionArea: some View {
        if !viewModel.originalTranscription.isEmpty {
            VStack(spacing: SpendlySpacing.lg) {
                // Original Speech Card
                originalSpeechCard

                // AI Translation Card
                aiTranslationCard
            }
        }
    }

    private var originalSpeechCard: some View {
        SPCard {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                HStack {
                    // Language badge
                    detectedLanguageBadge

                    Spacer()

                    // Listen to original button
                    Button {
                        // Playback placeholder
                    } label: {
                        HStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 14))
                            Text("Listen")
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                                .textCase(.uppercase)
                        }
                        .padding(.horizontal, SpendlySpacing.sm)
                        .padding(.vertical, SpendlySpacing.xs)
                        .foregroundStyle(SpendlyColors.primary)
                        .background(SpendlyColors.primary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small))
                    }
                }

                // Transcription text with code-switch highlighting
                if viewModel.isCodeSwitchingActive {
                    codeSwitchText
                } else {
                    Text("\"\(viewModel.originalTranscription)\"")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .italic()
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .lineSpacing(4)
                }
            }
        }
    }

    private var detectedLanguageBadge: some View {
        Button {
            viewModel.showLanguagePicker = true
        } label: {
            HStack(spacing: SpendlySpacing.xs) {
                Text("Detected: \(viewModel.detectedLanguage)")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .bold))
            }
            .padding(.horizontal, SpendlySpacing.md)
            .padding(.vertical, SpendlySpacing.sm)
            .foregroundStyle(.white)
            .background(SpendlyColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small))
        }
        .sheet(isPresented: $viewModel.showLanguagePicker) {
            languagePickerSheet
        }
    }

    private var codeSwitchText: some View {
        HStack(spacing: 0) {
            ForEach(viewModel.transcriptionSegments) { segment in
                if segment.isCodeSwitch {
                    Text(segment.text)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(SpendlyColors.primary)
                        .underline(true, pattern: .dot)
                } else {
                    Text(segment.text + " ")
                        .font(.system(size: 18, weight: .medium))
                        .italic()
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }
        }
        .lineSpacing(4)
    }

    // MARK: - AI Translation Card

    private var aiTranslationCard: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            // Header
            HStack {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(SpendlyColors.info)
                    Text("AI Translation & Mapping")
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .foregroundStyle(SpendlyColors.info)
                }

                Spacer()

                // Live translation toggle
                HStack(spacing: SpendlySpacing.xs) {
                    Text("Live Translation")
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(SpendlyColors.secondary)
                        .textCase(.uppercase)

                    Toggle("", isOn: $viewModel.isLiveTranslationOn)
                        .labelsHidden()
                        .tint(SpendlyColors.primary)
                        .scaleEffect(0.8)
                }
            }

            // Translated text
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                Rectangle()
                    .fill(SpendlyColors.primary)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .overlay(alignment: .leading) {
                        HStack(alignment: .top) {
                            Rectangle()
                                .fill(SpendlyColors.primary)
                                .frame(width: 2)

                            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                                if viewModel.isEditingTranscription {
                                    TextEditor(text: $viewModel.editedTranscription)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                        .frame(minHeight: 80)
                                        .padding(SpendlySpacing.sm)
                                        .background(SpendlyColors.surface(for: colorScheme).opacity(0.5))
                                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small))

                                    HStack {
                                        SPButton("Save", icon: "checkmark", style: .primary) {
                                            viewModel.saveTranscriptionEdit()
                                        }
                                        SPButton("Cancel", style: .ghost) {
                                            viewModel.cancelTranscriptionEdit()
                                        }
                                    }
                                } else {
                                    Text("\"\(viewModel.translatedTranscription)\"")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme).opacity(0.85))
                                        .lineSpacing(4)

                                    Button {
                                        viewModel.startEditingTranscription()
                                    } label: {
                                        HStack(spacing: SpendlySpacing.xs) {
                                            Image(systemName: "pencil")
                                                .font(.system(size: 10))
                                            Text("Edit Translation")
                                                .font(SpendlyFont.caption())
                                                .fontWeight(.semibold)
                                        }
                                        .foregroundStyle(SpendlyColors.primary)
                                    }
                                }
                            }
                        }
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)

            // Category mapping cards
            if let mapping = viewModel.categoryMapping {
                categoryMappingGrid(mapping)
            }
        }
        .padding(SpendlySpacing.lg)
        .background(colorScheme == .dark ? SpendlyColors.surfaceDark : Color(hex: "#0f172a"))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    private func categoryMappingGrid(_ mapping: IssueCategoryMapping) -> some View {
        HStack(spacing: SpendlySpacing.sm) {
            mappingCell(label: "System", value: mapping.system, icon: mapping.systemIcon, iconColor: SpendlyColors.info)
            mappingCell(label: "Assembly", value: mapping.assembly, icon: mapping.assemblyIcon, iconColor: SpendlyColors.info)
            mappingCell(label: "Symptom", value: mapping.symptom, icon: mapping.symptomIcon, iconColor: SpendlyColors.warning)
        }
    }

    private func mappingCell(label: String, value: String, icon: String, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(label)
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .textCase(.uppercase)
                .foregroundStyle(.white.opacity(0.4))

            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(iconColor)
                Text(value)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpendlySpacing.md)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Waveform Visualizer

    @ViewBuilder
    private var waveformVisualizer: some View {
        if viewModel.recordingState == .recording || viewModel.recordingState == .processing {
            SPCard {
                HStack(spacing: 3) {
                    ForEach(Array(viewModel.waveformAmplitudes.enumerated()), id: \.offset) { index, amplitude in
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(
                                SpendlyColors.primary.opacity(0.2 + (Double(amplitude) * 0.8))
                            )
                            .frame(width: 3, height: max(4, amplitude * 48))
                            .animation(
                                .easeInOut(duration: 0.15),
                                value: amplitude
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
        }
    }

    // MARK: - Floating Mic Button

    private var floatingMicButton: some View {
        Button {
            switch viewModel.recordingState {
            case .idle:
                viewModel.startRecording()
            case .recording:
                viewModel.stopRecording()
            case .completed:
                viewModel.showTranscriptionResult = true
            default:
                break
            }
        } label: {
            ZStack {
                Circle()
                    .fill(micButtonColor)
                    .frame(width: 64, height: 64)
                    .shadow(color: micButtonColor.opacity(0.4), radius: 12, y: 4)

                if viewModel.recordingState == .processing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: micButtonIcon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
        }
        .disabled(viewModel.recordingState == .processing)
    }

    private var micButtonColor: Color {
        switch viewModel.recordingState {
        case .idle:       return SpendlyColors.primary
        case .recording:  return SpendlyColors.error
        case .processing: return SpendlyColors.secondary
        case .completed:  return SpendlyColors.success
        case .error:      return SpendlyColors.error
        }
    }

    private var micButtonIcon: String {
        switch viewModel.recordingState {
        case .idle:       return SpendlyIcon.mic.systemName
        case .recording:  return SpendlyIcon.stop.systemName
        case .completed:  return "checkmark"
        default:          return SpendlyIcon.mic.systemName
        }
    }

    // MARK: - Language Picker Sheet

    private var languagePickerSheet: some View {
        NavigationStack {
            List(viewModel.supportedLanguages) { language in
                Button {
                    viewModel.selectLanguage(language)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(language.name)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text(language.nativeName)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }

                        Spacer()

                        if language.name == viewModel.detectedLanguage {
                            Image(systemName: "checkmark")
                                .foregroundStyle(SpendlyColors.primary)
                                .fontWeight(.bold)
                        }
                    }
                    .padding(.vertical, SpendlySpacing.xs)
                }
            }
            .navigationTitle("Select Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        viewModel.showLanguagePicker = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Preview

#Preview {
    AIDiagnosticsRootView()
}
