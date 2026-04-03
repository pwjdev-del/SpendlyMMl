import SwiftUI
import SpendlyCore

struct CreateArticleView: View {
    @Bindable var viewModel: KnowledgeBaseViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedCategory: KBCategory = .commonRepairs
    @State private var tagsText: String = ""

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
                }
                .padding(SpendlySpacing.md)
            }
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
                            tags: tags
                        )
                        dismiss()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}
