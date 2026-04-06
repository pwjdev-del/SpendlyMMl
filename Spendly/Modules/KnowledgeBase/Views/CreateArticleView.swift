import SwiftUI
import UniformTypeIdentifiers
import SpendlyCore

struct CreateArticleView: View {
    @Bindable var viewModel: KnowledgeBaseViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedCategory: KBCategory = .commonRepairs
    @State private var tagsText: String = ""
    @State private var attachments: [KBAttachment] = []
    @State private var showFileImporter: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpendlySpacing.md) {

                    // Title
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("Title")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        TextField("Article title", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }

                    // Category
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("Category")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(KBCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Content
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("Content")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendlyRadius.large)
                                    .stroke(SpendlyColors.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }

                    // Tags
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        Text("Tags (comma separated)")
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        TextField("tag1, tag2, tag3", text: $tagsText)
                            .textFieldStyle(.roundedBorder)
                    }

                    // MARK: File Attachments
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        HStack {
                            Text("Attachments")
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Spacer()
                            Button {
                                showFileImporter = true
                            } label: {
                                HStack(spacing: SpendlySpacing.xs) {
                                    Image(systemName: "paperclip")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Add File")
                                        .font(SpendlyFont.caption())
                                        .fontWeight(.semibold)
                                }
                                .foregroundStyle(SpendlyColors.primary)
                            }
                        }

                        if attachments.isEmpty {
                            HStack(spacing: SpendlySpacing.sm) {
                                Image(systemName: "doc.badge.plus")
                                    .font(.system(size: 16))
                                    .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                                Text("No files attached. Tap \"Add File\" to attach documents, images, or PDFs.")
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                            }
                            .padding(SpendlySpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                                    .strokeBorder(SpendlyColors.secondary.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [6]))
                            )
                        } else {
                            VStack(spacing: SpendlySpacing.xs) {
                                ForEach(attachments) { attachment in
                                    HStack(spacing: SpendlySpacing.sm) {
                                        Image(systemName: iconForFile(attachment.fileName))
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(SpendlyColors.info)
                                            .frame(width: 28)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(attachment.fileName)
                                                .font(SpendlyFont.bodyMedium())
                                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                                .lineLimit(1)
                                            if !attachment.fileSize.isEmpty {
                                                Text(attachment.fileSize)
                                                    .font(SpendlyFont.caption())
                                                    .foregroundStyle(SpendlyColors.secondary)
                                            }
                                        }

                                        Spacer()

                                        Button {
                                            attachments.removeAll(where: { $0.id == attachment.id })
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 18))
                                                .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                                        }
                                    }
                                    .padding(SpendlySpacing.sm)
                                    .background(
                                        colorScheme == .dark
                                            ? SpendlyColors.secondary.opacity(0.1)
                                            : SpendlyColors.backgroundLight
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                                }
                            }
                        }
                    }
                }
                .padding(SpendlySpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SpendlyColors.background(for: colorScheme))
            .navigationTitle("New Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publish") {
                        let tags = tagsText
                            .split(separator: ",")
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                            .filter { !$0.isEmpty }
                        viewModel.publishArticle(
                            title: title,
                            category: selectedCategory,
                            content: content,
                            tags: tags,
                            attachments: attachments
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.item],
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    for url in urls {
                        let name = url.lastPathComponent
                        // Attempt to read file size
                        var sizeLabel = ""
                        if url.startAccessingSecurityScopedResource() {
                            defer { url.stopAccessingSecurityScopedResource() }
                            if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
                               let bytes = attrs[.size] as? Int64 {
                                sizeLabel = ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
                            }
                        }
                        let attachment = KBAttachment(fileName: name, fileSize: sizeLabel)
                        attachments.append(attachment)
                    }
                case .failure:
                    break
                }
            }
        }
    }

    // MARK: - Helpers

    private func iconForFile(_ name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf":                          return "doc.richtext"
        case "doc", "docx":                  return "doc.text"
        case "xls", "xlsx", "csv":           return "tablecells"
        case "png", "jpg", "jpeg", "heic":   return "photo"
        case "mp4", "mov":                   return "film"
        default:                             return "doc"
        }
    }
}
