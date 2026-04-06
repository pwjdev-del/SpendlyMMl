import SwiftUI
import AVFoundation
import SpendlyCore

// MARK: - VoiceNoteRecorderView

struct VoiceNoteRecorderView: View {

    @Bindable var viewModel: JobExecutionViewModel
    let jobID: UUID

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var recorder: AVAudioRecorder?
    @State private var player: AVAudioPlayer?
    @State private var isRecording: Bool = false
    @State private var hasRecording: Bool = false
    @State private var isPlaying: Bool = false
    @State private var elapsedSeconds: TimeInterval = 0
    @State private var recordingURL: URL?
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var permissionDenied: Bool = false

    // Waveform animation bars
    @State private var waveformLevels: [CGFloat] = Array(repeating: 0.1, count: 24)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer()

                // Status label
                statusLabel

                // Timer display
                timerDisplay
                    .padding(.top, SpendlySpacing.md)

                // Waveform visualization
                waveformView
                    .padding(.top, SpendlySpacing.xxl)

                Spacer()

                // Controls
                controlButtons
                    .padding(.bottom, SpendlySpacing.xxl)

                // Save / Cancel bar
                if hasRecording && !isRecording {
                    actionBar
                        .padding(.bottom, SpendlySpacing.lg)
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .background(SpendlyColors.background(for: colorScheme))
            .navigationTitle("Voice Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        stopAndCleanup()
                        dismiss()
                    }
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.secondary)
                }
            }
            .alert("Microphone Access Required", isPresented: $permissionDenied) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Spendly needs microphone access to record voice notes. Please enable it in Settings.")
            }
            .onDisappear {
                stopAndCleanup()
            }
        }
    }

    // MARK: - Status Label

    private var statusLabel: some View {
        Text(statusText)
            .font(SpendlyFont.bodySemibold())
            .foregroundStyle(statusColor)
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.sm)
            .background(statusColor.opacity(0.1))
            .clipShape(Capsule())
    }

    private var statusText: String {
        if isRecording { return "Recording..." }
        if isPlaying { return "Playing" }
        if hasRecording { return "Recording Complete" }
        return "Ready to Record"
    }

    private var statusColor: Color {
        if isRecording { return SpendlyColors.error }
        if isPlaying { return SpendlyColors.primary }
        if hasRecording { return SpendlyColors.success }
        return SpendlyColors.secondary
    }

    // MARK: - Timer Display

    private var timerDisplay: some View {
        let displaySeconds = hasRecording && !isRecording ? recordingDuration : elapsedSeconds
        let minutes = Int(displaySeconds) / 60
        let seconds = Int(displaySeconds) % 60

        return Text(String(format: "%02d:%02d", minutes, seconds))
            .font(.system(size: 56, weight: .light, design: .monospaced))
            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.15), value: displaySeconds)
    }

    // MARK: - Waveform Visualization

    private var waveformView: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(0..<waveformLevels.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(waveformBarColor(at: index))
                    .frame(width: 6, height: waveformLevels[index] * 60)
                    .animation(
                        .easeInOut(duration: 0.15).delay(Double(index) * 0.01),
                        value: waveformLevels[index]
                    )
            }
        }
        .frame(height: 64)
        .padding(.horizontal, SpendlySpacing.lg)
    }

    private func waveformBarColor(at index: Int) -> Color {
        if isRecording {
            return SpendlyColors.error.opacity(0.6 + Double(waveformLevels[index]) * 0.4)
        }
        if isPlaying {
            return SpendlyColors.primary.opacity(0.5 + Double(waveformLevels[index]) * 0.5)
        }
        return SpendlyColors.secondary.opacity(0.2)
    }

    // MARK: - Control Buttons

    private var controlButtons: some View {
        HStack(spacing: SpendlySpacing.xxxl) {
            // Re-record button (visible after recording)
            if hasRecording && !isRecording {
                Button {
                    resetRecording()
                } label: {
                    VStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 22, weight: .semibold))
                            .frame(width: 52, height: 52)
                            .foregroundStyle(SpendlyColors.secondary)
                            .background(SpendlyColors.surface(for: colorScheme))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1.5)
                            )

                        Text("Re-record")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }

            // Main record / stop button
            Button {
                if isRecording {
                    stopRecording()
                } else if !hasRecording {
                    requestPermissionAndRecord()
                }
            } label: {
                ZStack {
                    // Outer ring
                    Circle()
                        .strokeBorder(
                            isRecording ? SpendlyColors.error.opacity(0.3) : SpendlyColors.error.opacity(0.15),
                            lineWidth: 4
                        )
                        .frame(width: 84, height: 84)

                    // Pulsing background when recording
                    if isRecording {
                        Circle()
                            .fill(SpendlyColors.error.opacity(0.1))
                            .frame(width: 84, height: 84)
                    }

                    // Inner button
                    if isRecording {
                        // Stop icon (rounded square)
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(SpendlyColors.error)
                            .frame(width: 28, height: 28)
                    } else {
                        // Record circle
                        Circle()
                            .fill(SpendlyColors.error)
                            .frame(width: 64, height: 64)

                        Image(systemName: SpendlyIcon.mic.systemName)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .disabled(hasRecording && !isRecording)
            .opacity(hasRecording && !isRecording ? 0.3 : 1)

            // Play / Pause button (visible after recording)
            if hasRecording && !isRecording {
                Button {
                    if isPlaying {
                        stopPlayback()
                    } else {
                        startPlayback()
                    }
                } label: {
                    VStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .frame(width: 52, height: 52)
                            .foregroundStyle(.white)
                            .background(SpendlyColors.primary)
                            .clipShape(Circle())

                        Text(isPlaying ? "Stop" : "Play")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Action Bar (Save / Cancel)

    private var actionBar: some View {
        HStack(spacing: SpendlySpacing.md) {
            // Discard button
            Button {
                stopAndCleanup()
                dismiss()
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Discard")
                        .font(SpendlyFont.bodySemibold())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(SpendlyColors.error)
                .background(SpendlyColors.error.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                        .strokeBorder(SpendlyColors.error.opacity(0.2), lineWidth: 1)
                )
            }

            // Save button
            Button {
                saveVoiceNote()
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                    Text("Save Note")
                        .font(SpendlyFont.bodySemibold())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(.white)
                .background(SpendlyColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            }
        }
    }

    // MARK: - Recording Logic

    private func requestPermissionAndRecord() {
        AVAudioApplication.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    startRecording()
                } else {
                    permissionDenied = true
                }
            }
        }
    }

    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            return
        }

        let fileName = "voice_note_\(UUID().uuidString).m4a"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        recordingURL = fileURL

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: fileURL, settings: settings)
            recorder?.isMeteringEnabled = true
            recorder?.record()

            isRecording = true
            hasRecording = false
            elapsedSeconds = 0

            // Start timer for elapsed time and waveform updates
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                DispatchQueue.main.async {
                    elapsedSeconds += 0.1
                    updateWaveform()
                }
            }
        } catch {
            return
        }
    }

    private func stopRecording() {
        recorder?.stop()
        isRecording = false
        hasRecording = true
        recordingDuration = elapsedSeconds

        timer?.invalidate()
        timer = nil

        // Reset waveform to idle
        withAnimation(.easeOut(duration: 0.3)) {
            waveformLevels = Array(repeating: 0.1, count: waveformLevels.count)
        }
    }

    private func resetRecording() {
        stopPlayback()

        // Delete old file
        if let url = recordingURL {
            try? FileManager.default.removeItem(at: url)
        }

        recordingURL = nil
        hasRecording = false
        elapsedSeconds = 0
        recordingDuration = 0

        withAnimation(.easeOut(duration: 0.3)) {
            waveformLevels = Array(repeating: 0.1, count: waveformLevels.count)
        }
    }

    private func updateWaveform() {
        guard let recorder, isRecording else { return }
        recorder.updateMeters()

        let power = recorder.averagePower(forChannel: 0)
        // Normalize: power ranges from -160 to 0 dB, map to 0.1...1.0
        let normalized = max(0.1, CGFloat((power + 50) / 50))

        withAnimation(.easeInOut(duration: 0.1)) {
            waveformLevels.removeFirst()
            waveformLevels.append(min(1.0, normalized))
        }
    }

    // MARK: - Playback Logic

    private func startPlayback() {
        guard let url = recordingURL else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            isPlaying = true

            // Animate waveform during playback
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                DispatchQueue.main.async {
                    if let player, player.isPlaying {
                        // Simulate waveform with randomized levels
                        withAnimation(.easeInOut(duration: 0.1)) {
                            waveformLevels = waveformLevels.map { _ in
                                CGFloat.random(in: 0.15...0.85)
                            }
                        }
                    } else {
                        stopPlayback()
                    }
                }
            }
        } catch {
            return
        }
    }

    private func stopPlayback() {
        player?.stop()
        player = nil
        isPlaying = false

        timer?.invalidate()
        timer = nil

        withAnimation(.easeOut(duration: 0.3)) {
            waveformLevels = Array(repeating: 0.1, count: waveformLevels.count)
        }
    }

    // MARK: - Save & Cleanup

    private func saveVoiceNote() {
        stopPlayback()

        let voiceNote = VoiceNote(
            duration: recordingDuration,
            fileURL: recordingURL,
            createdAt: Date()
        )
        viewModel.addVoiceNote(to: jobID, voiceNote: voiceNote)
        dismiss()
    }

    private func stopAndCleanup() {
        timer?.invalidate()
        timer = nil
        recorder?.stop()
        recorder = nil
        player?.stop()
        player = nil
    }
}

// MARK: - Preview

#Preview {
    let vm = JobExecutionViewModel()
    VoiceNoteRecorderView(viewModel: vm, jobID: JobExecutionMockData.jobs[1].id)
}
