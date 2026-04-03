import SwiftUI
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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab selector
                photoTabSelector

                ScrollView {
                    VStack(spacing: SpendlySpacing.xl) {
                        // Photo grid
                        photoGrid

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
                // Placeholder image
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(SpendlyColors.primary.opacity(0.08))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        VStack(spacing: SpendlySpacing.xs) {
                            Image(systemName: "photo")
                                .font(.system(size: 24))
                                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                            Text(timeLabel(for: photo.timestamp))
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                    )

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

    // MARK: - Capture Button

    private var captureButton: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Primary capture button
            Button {
                let photo = PhotoCaptureItem(
                    caption: captionText,
                    isBefore: selectedTab == .before,
                    timestamp: Date()
                )
                viewModel.addPhoto(to: jobID, photo: photo)
                captionText = ""
            } label: {
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
            Button {} label: {
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

            // Video thumbnail placeholder
            Button {} label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Record Video")
                        .font(SpendlyFont.caption())
                        .fontWeight(.semibold)
                }
                .foregroundStyle(SpendlyColors.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let vm = JobExecutionViewModel()
    PhotoCaptureView(viewModel: vm, jobID: JobExecutionMockData.jobs[1].id)
}
