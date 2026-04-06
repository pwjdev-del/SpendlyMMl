import SwiftUI
import AVFoundation
import PhotosUI
import Combine
import SpendlyCore

// MARK: - PhotoCaptureView

struct PhotoCaptureView: View {

    @Bindable var viewModel: JobExecutionViewModel
    let jobID: UUID

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: PhotoTab = .before
    @State private var captionText: String = ""
    @State private var showCamera: Bool = false
    @State private var showVoiceRecorder: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    // Video recording state
    @State private var isRecordingVideo: Bool = false
    @State private var videoRecordingSeconds: TimeInterval = 0
    @State private var videoTimerCancellable: AnyCancellable?

    enum PhotoTab: String, CaseIterable {
        case before = "Before"
        case after = "After"
    }

    private var currentJob: JobDisplayModel? {
        viewModel.jobs.first { $0.id == jobID }
    }

    private var beforePhotos: [PhotoCaptureItem] {
        currentJob?.photos.filter(\.isBefore) ?? []
    }

    private var afterPhotos: [PhotoCaptureItem] {
        currentJob?.photos.filter { !$0.isBefore } ?? []
    }

    private var displayedPhotos: [PhotoCaptureItem] {
        selectedTab == .before ? beforePhotos : afterPhotos
    }

    private var voiceNotes: [VoiceNote] {
        currentJob?.voiceNotes ?? []
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                photoTabSelector

                ScrollView {
                    VStack(spacing: SpendlySpacing.xl) {
                        // Photo grid
                        photoGrid

                        // Voice notes section
                        if !voiceNotes.isEmpty {
                            voiceNotesSection
                        }

                        // Caption input
                        captionInput

                        // Capture button
                        captureButton
                    }
                    .padding(SpendlySpacing.lg)
                }
                .background(SpendlyColors.background(for: colorScheme))
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationTitle("Job Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.primary)
                }
            }
            .sheet(isPresented: $showVoiceRecorder) {
                VoiceNoteRecorderView(viewModel: viewModel, jobID: jobID)
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await loadPhoto(from: newItem)
                }
            }
        }
    }

    // MARK: - Tab Selector

    private var photoTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(PhotoTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: SpendlySpacing.sm) {
                        HStack(spacing: SpendlySpacing.sm) {
                            Text(tab.rawValue)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(
                                    selectedTab == tab
                                        ? SpendlyColors.primary
                                        : SpendlyColors.secondary
                                )

                            let count = tab == .before ? beforePhotos.count : afterPhotos.count
                            if count > 0 {
                                Text("\(count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(width: 18, height: 18)
                                    .background(SpendlyColors.primary)
                                    .clipShape(Circle())
                            }
                        }

                        Rectangle()
                            .fill(selectedTab == tab ? SpendlyColors.primary : .clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.top, SpendlySpacing.sm)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Photo Grid

    private var photoGrid: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            Text("\(selectedTab.rawValue) Photos")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            if displayedPhotos.isEmpty {
                emptyPhotoState
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: SpendlySpacing.md),
                        GridItem(.flexible(), spacing: SpendlySpacing.md)
                    ],
                    spacing: SpendlySpacing.md
                ) {
                    ForEach(displayedPhotos) { photo in
                        photoThumbnail(photo: photo)
                    }
                }
            }
        }
    }

    private var emptyPhotoState: some View {
        VStack(spacing: SpendlySpacing.lg) {
            Image(systemName: "camera.badge.ellipsis")
                .font(.system(size: 40))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))

            Text("No \(selectedTab.rawValue.lowercased()) photos yet")
                .font(SpendlyFont.body())
                .foregroundStyle(SpendlyColors.secondary)

            Text("Tap the capture button below to add photos")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SpendlySpacing.xxxl)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                .strokeBorder(
                    SpendlyColors.secondary.opacity(0.15),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
        )
    }

    private func photoThumbnail(photo: PhotoCaptureItem) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            ZStack(alignment: .topTrailing) {
                // Show actual image if available, otherwise placeholder SF Symbol
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(SpendlyColors.primary.opacity(0.08))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        Group {
                            if let data = photo.imageData,
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                VStack(spacing: SpendlySpacing.xs) {
                                    Image(systemName: photo.placeholderIcon)
                                        .font(.system(size: 28))
                                        .foregroundStyle(SpendlyColors.primary.opacity(0.6))
                                    Text(timeLabel(for: photo.timestamp))
                                        .font(.system(size: 9, weight: .medium))
                                        .foregroundStyle(SpendlyColors.secondary)
                                }
                            }
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                // Delete button
                Button {
                    viewModel.removePhoto(from: jobID, photoID: photo.id)
                } label: {
                    Image(systemName: SpendlyIcon.close.systemName)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(SpendlySpacing.xs)

                // Offline badge
                if viewModel.isOffline {
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 8, weight: .bold))
                            Text("PENDING")
                                .font(.system(size: 8, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, SpendlySpacing.sm)
                        .padding(.vertical, 2)
                        .background(SpendlyColors.warning)
                        .clipShape(Capsule())
                        .padding(SpendlySpacing.sm)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                }
            }

            // Caption
            if !photo.caption.isEmpty {
                Text(photo.caption)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .lineLimit(2)
            }
        }
    }

    private func timeLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    // MARK: - Caption Input

    private var captionInput: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text("Photo Caption (optional)")
                .font(SpendlyFont.caption())
                .fontWeight(.semibold)
                .foregroundStyle(SpendlyColors.secondary)

            TextField("Add a description for this photo...", text: $captionText)
                .font(SpendlyFont.body())
                .padding(SpendlySpacing.md)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .strokeBorder(SpendlyColors.secondary.opacity(0.15), lineWidth: 1)
                )
        }
    }

    // MARK: - Voice Notes Section

    private var voiceNotesSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Image(systemName: SpendlyIcon.mic.systemName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(SpendlyColors.primary)

                Text("Voice Notes")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Spacer()

                Text("\(voiceNotes.count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(SpendlyColors.primary)
                    .clipShape(Circle())
            }

            VStack(spacing: SpendlySpacing.sm) {
                ForEach(voiceNotes) { note in
                    voiceNoteRow(note: note)
                }
            }
        }
    }

    @State private var playingNoteID: UUID?
    @State private var notePlayer: AVAudioPlayer?

    private func voiceNoteRow(note: VoiceNote) -> some View {
        HStack(spacing: SpendlySpacing.md) {
            // Play button
            Button {
                toggleNotePlayback(note: note)
            } label: {
                Image(systemName: playingNoteID == note.id ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(SpendlyColors.primary)
            }

            // Info
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text("Voice Note")
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(note.formattedDuration)
                        .font(SpendlyFont.caption())

                    Text("--")
                        .font(SpendlyFont.caption())

                    Text(timeLabel(for: note.createdAt))
                        .font(SpendlyFont.caption())
                }
                .foregroundStyle(SpendlyColors.secondary)
            }

            Spacer()

            // Delete button
            Button {
                if playingNoteID == note.id {
                    notePlayer?.stop()
                    notePlayer = nil
                    playingNoteID = nil
                }
                viewModel.removeVoiceNote(from: jobID, voiceNoteID: note.id)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(SpendlyColors.error.opacity(0.7))
                    .frame(width: 32, height: 32)
                    .background(SpendlyColors.error.opacity(0.08))
                    .clipShape(Circle())
            }
        }
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .strokeBorder(SpendlyColors.secondary.opacity(0.1), lineWidth: 1)
        )
    }

    private func toggleNotePlayback(note: VoiceNote) {
        if playingNoteID == note.id {
            notePlayer?.stop()
            notePlayer = nil
            playingNoteID = nil
            return
        }

        guard let url = note.fileURL else { return }

        notePlayer?.stop()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            notePlayer = try AVAudioPlayer(contentsOf: url)
            notePlayer?.play()
            playingNoteID = note.id
        } catch {
            playingNoteID = nil
        }
    }

    // MARK: - Capture Button

    private var captureButton: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Primary capture button using PhotosPicker
            PhotosPicker(
                selection: $selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: SpendlyIcon.camera.systemName)
                        .font(.system(size: 18, weight: .semibold))
                    Text("Capture \(selectedTab.rawValue) Photo")
                        .font(SpendlyFont.bodySemibold())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundStyle(.white)
                .background(SpendlyColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            }

            // Voice note button
            Button { showVoiceRecorder = true } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: SpendlyIcon.mic.systemName)
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add Voice Note")
                        .font(SpendlyFont.bodySemibold())
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .foregroundStyle(SpendlyColors.primary)
                .background(.clear)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                        .strokeBorder(SpendlyColors.primary.opacity(0.3), lineWidth: 1.5)
                )
            }

            // Video record button
            Button {
                if isRecordingVideo {
                    stopVideoRecording()
                } else {
                    startVideoRecording()
                }
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: isRecordingVideo ? "stop.fill" : "video.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text(isRecordingVideo ? "Stop Video" : "Record Video")
                        .font(SpendlyFont.caption())
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .foregroundStyle(isRecordingVideo ? .white : SpendlyColors.secondary)
                .background(isRecordingVideo ? SpendlyColors.error : .clear)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                .overlay(
                    isRecordingVideo
                        ? nil
                        : RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                            .strokeBorder(SpendlyColors.secondary.opacity(0.2), lineWidth: 1)
                )
            }

            // Video recording indicator
            if isRecordingVideo {
                videoRecordingIndicator
            }
        }
    }

    // MARK: - Video Recording Indicator

    private var videoRecordingIndicator: some View {
        HStack(spacing: SpendlySpacing.md) {
            Circle()
                .fill(SpendlyColors.error)
                .frame(width: 10, height: 10)

            Text("REC")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(SpendlyColors.error)

            Text(formattedRecordingTime(videoRecordingSeconds))
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Spacer()

            Button {
                stopVideoRecording()
            } label: {
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 14))
                    Text("Stop & Save")
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, SpendlySpacing.md)
                .padding(.vertical, SpendlySpacing.sm)
                .background(SpendlyColors.error)
                .clipShape(Capsule())
            }
        }
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.error.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium)
                .strokeBorder(SpendlyColors.error.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Helper Methods

    private func formattedRecordingTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self) {
            let photo = PhotoCaptureItem(
                caption: captionText,
                isBefore: selectedTab == .before,
                timestamp: Date(),
                imageData: data,
                placeholderIcon: "photo.on.rectangle.angled"
            )
            viewModel.addPhoto(to: jobID, photo: photo)
            captionText = ""
            selectedPhotoItem = nil
        }
    }

    private func startVideoRecording() {
        isRecordingVideo = true
        videoRecordingSeconds = 0
        videoTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if self.isRecordingVideo {
                    self.videoRecordingSeconds += 1
                }
            }
    }

    private func stopVideoRecording() {
        isRecordingVideo = false
        videoTimerCancellable?.cancel()
        videoTimerCancellable = nil

        // Store as a mock video entry with a video icon placeholder
        let photo = PhotoCaptureItem(
            caption: captionText.isEmpty ? "Video (\(formattedRecordingTime(videoRecordingSeconds)))" : captionText,
            isBefore: selectedTab == .before,
            timestamp: Date(),
            imageData: nil,
            placeholderIcon: "video.fill"
        )
        viewModel.addPhoto(to: jobID, photo: photo)
        captionText = ""
        videoRecordingSeconds = 0
    }
}

// MARK: - Preview

#Preview {
    let vm = JobExecutionViewModel()
    PhotoCaptureView(viewModel: vm, jobID: JobExecutionMockData.jobs[1].id)
}
