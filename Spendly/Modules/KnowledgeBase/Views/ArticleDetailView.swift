import SwiftUI
import UIKit
import SpendlyCore

// MARK: - UIKit Share Sheet Representable

private struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ArticleDetailView: View {

    let article: KBArticle
    @Bindable var viewModel: KnowledgeBaseViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var newNoteText: String = ""
    @State private var showShareSheet: Bool = false
    @State private var showNoteEditor: Bool = false

    var body: some View {
        NavigationStack {  // ArticleDetailView is presented as a sheet — NavigationStack is correct here
            ZStack {
                SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        titleSection
                        actionBar
                        dataInsightsSection
                        articleContentSection
                        technicianTipsSection
                        privateNotesSection
                    }
                    .padding(.bottom, SpendlySpacing.xxxl * 2)
                }
            }
            .navigationTitle("Knowledge Base")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: SpendlyIcon.close.systemName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            viewModel.toggleBookmark(for: article.id)
                        } label: {
                            Label(
                                article.isBookmarked ? "Remove Bookmark" : "Bookmark",
                                systemImage: article.isBookmarked ? "bookmark.fill" : SpendlyIcon.bookmark.systemName
                            )
                        }
                        Button {
                            showShareSheet = true
                        } label: {
                            Label("Share", systemImage: SpendlyIcon.share.systemName)
                        }
                        Button {
                            printArticle()
                        } label: {
                            Label("Print PDF", systemImage: "printer")
                        }
                    } label: {
                        Image(systemName: SpendlyIcon.moreVert.systemName)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                let shareText = "\(article.title)\n\n\(article.summary)\n\n\(article.content)"
                ActivityViewController(activityItems: [shareText])
            }
        }
    }

    // MARK: - Print

    private func printArticle() {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo.printInfo()
        printInfo.jobName = article.title
        printInfo.outputType = .general
        printController.printInfo = printInfo

        let formatter = UIMarkupTextPrintFormatter(markupText: buildPrintHTML())
        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        printController.printFormatter = formatter

        printController.present(animated: true)
    }

    private func buildPrintHTML() -> String {
        let tagsHTML = article.tags.map { "<span style='background:#e0e7ff;padding:2px 8px;border-radius:4px;font-size:12px;margin-right:4px;'>\($0)</span>" }.joined()
        return """
        <html><head><style>
        body { font-family: -apple-system, Helvetica, Arial, sans-serif; line-height: 1.6; color: #1a1a1a; }
        h1 { font-size: 22px; margin-bottom: 4px; }
        .meta { font-size: 13px; color: #666; margin-bottom: 16px; }
        .content { font-size: 15px; white-space: pre-wrap; }
        .tags { margin-top: 20px; }
        </style></head><body>
        <h1>\(article.title)</h1>
        <div class='meta'>By \(article.authorName) &middot; \(article.formattedDate) &middot; \(article.readTimeLabel) &middot; \(article.category.rawValue)</div>
        <div class='content'>\(article.content)</div>
        <div class='tags'>\(tagsHTML)</div>
        </body></html>
        """
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            SPBadge(article.category.rawValue, style: article.category.color)

            Text(article.title)
                .font(SpendlyFont.title())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: SpendlySpacing.lg) {
                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text("Updated \(article.formattedDate)")
                        .font(SpendlyFont.caption())
                }
                .foregroundStyle(SpendlyColors.secondary)

                HStack(spacing: SpendlySpacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                    Text(article.readTimeLabel)
                        .font(SpendlyFont.caption())
                }
                .foregroundStyle(SpendlyColors.secondary)
            }

            // Author
            HStack(spacing: SpendlySpacing.sm) {
                ZStack {
                    Circle()
                        .fill(SpendlyColors.primary.opacity(0.12))
                        .frame(width: 28, height: 28)
                    Text(article.authorInitials)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(SpendlyColors.primary)
                }
                Text(article.authorName)
                    .font(SpendlyFont.caption())
                    .fontWeight(.medium)
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpendlySpacing.sm) {
                actionButton(icon: "arrow.down.circle", label: "Save Offline")
                actionButton(icon: SpendlyIcon.share.systemName, label: "Share") {
                    showShareSheet = true
                }
                actionButton(icon: "printer", label: "Print PDF") {
                    printArticle()
                }
                actionButton(
                    icon: article.isBookmarked ? "bookmark.fill" : SpendlyIcon.bookmark.systemName,
                    label: article.isBookmarked ? "Bookmarked" : "Bookmark"
                ) {
                    viewModel.toggleBookmark(for: article.id)
                }
            }
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.md)
        }
        .background(SpendlyColors.surface(for: colorScheme))
    }

    private func actionButton(icon: String, label: String, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(SpendlyFont.caption())
                    .fontWeight(.medium)
            }
            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.sm + 2)
            .background(
                colorScheme == .dark
                    ? SpendlyColors.secondary.opacity(0.15)
                    : SpendlyColors.backgroundLight
            )
            .clipShape(Capsule())
        }
    }

    // MARK: - Data Insights

    private var dataInsightsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Text("PAST DATA INSIGHTS")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .tracking(0.8)
                Spacer()
                SPBadge("Last 12 Months", style: .info)
            }

            HStack(spacing: SpendlySpacing.md) {
                insightCard(
                    label: "Total Views",
                    value: "\(article.viewCount)",
                    trend: "+12%",
                    trendUp: true
                )
                insightCard(
                    label: "Avg. Read Time",
                    value: "\(article.readTimeMinutes)m",
                    trend: "-8%",
                    trendUp: false
                )
            }
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
        .padding(.top, SpendlySpacing.sm)
    }

    private func insightCard(label: String, value: String, trend: String, trendUp: Bool) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text(label)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
            Text(value)
                .font(SpendlyFont.title())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .monospacedDigit()
            HStack(spacing: SpendlySpacing.xs) {
                Image(systemName: trendUp ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 10, weight: .bold))
                Text(trend + " vs LY")
                    .font(SpendlyFont.caption())
            }
            .foregroundStyle(trendUp ? SpendlyColors.error : SpendlyColors.success)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(SpendlySpacing.md)
        .background(
            colorScheme == .dark
                ? SpendlyColors.secondary.opacity(0.08)
                : SpendlyColors.backgroundLight
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
    }

    // MARK: - Article Content

    private var articleContentSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("ARTICLE CONTENT")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(SpendlyColors.secondary)
                .tracking(0.8)

            // Render simple markdown-like content
            ForEach(parseContentSections(article.content), id: \.self) { section in
                if section.hasPrefix("## ") {
                    Text(section.replacingOccurrences(of: "## ", with: ""))
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .padding(.top, SpendlySpacing.sm)
                } else if section.hasPrefix("### ") {
                    Text(section.replacingOccurrences(of: "### ", with: ""))
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .padding(.top, SpendlySpacing.xs)
                } else if section.hasPrefix("**") && section.hasSuffix("**") {
                    Text(section.replacingOccurrences(of: "**", with: ""))
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                } else if section.hasPrefix("- [ ]") || section.hasPrefix("- [x]") {
                    let checked = section.hasPrefix("- [x]")
                    let text = section
                        .replacingOccurrences(of: "- [ ] ", with: "")
                        .replacingOccurrences(of: "- [x] ", with: "")
                    HStack(alignment: .top, spacing: SpendlySpacing.sm) {
                        Image(systemName: checked ? "checkmark.square.fill" : "square")
                            .font(.system(size: 14))
                            .foregroundStyle(checked ? SpendlyColors.success : SpendlyColors.secondary)
                        Text(text)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                } else if !section.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(section)
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // Tags
            if !article.tags.isEmpty {
                SPDivider()
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("TAGS")
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(SpendlyColors.secondary)
                        .tracking(0.8)
                    FlowLayout(spacing: SpendlySpacing.sm) {
                        ForEach(article.tags, id: \.self) { tag in
                            Text(tag)
                                .font(SpendlyFont.caption())
                                .fontWeight(.medium)
                                .foregroundStyle(SpendlyColors.info)
                                .padding(.horizontal, SpendlySpacing.md)
                                .padding(.vertical, SpendlySpacing.xs)
                                .background(SpendlyColors.info.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
        .padding(.top, SpendlySpacing.sm)
    }

    private func parseContentSections(_ content: String) -> [String] {
        content.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    // MARK: - Technician Tips

    private var technicianTipsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: "lightbulb")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpendlyColors.info)
                Text("TECHNICIAN TIPS")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .foregroundStyle(SpendlyColors.info)
                    .tracking(0.8)
            }

            VStack(spacing: SpendlySpacing.md) {
                tipBubble(
                    initials: article.authorInitials,
                    name: article.authorName,
                    role: "Author",
                    tip: "Always verify terminal connections for tightness before assuming equipment is dead. Many reported failures are just loose wires."
                )

                if article.category == .troubleshooting {
                    tipBubble(
                        initials: "AM",
                        name: "Anita M.",
                        role: "Expert Level",
                        tip: "If the thermal overload is tripped, let it cool for 30 mins before condemning. Use a wet rag to speed up cooling."
                    )
                }
            }
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.info.opacity(colorScheme == .dark ? 0.08 : 0.05))
        .padding(.top, SpendlySpacing.sm)
    }

    private func tipBubble(initials: String, name: String, role: String, tip: String) -> some View {
        HStack(alignment: .top, spacing: SpendlySpacing.sm) {
            ZStack {
                Circle()
                    .fill(SpendlyColors.info.opacity(0.15))
                    .frame(width: 32, height: 32)
                Text(initials)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(SpendlyColors.info)
            }

            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                HStack(spacing: SpendlySpacing.xs) {
                    Text(name)
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text(role)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }
                Text("\"\(tip)\"")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - Private Notes

    private var privateNotesSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(SpendlyColors.accent)
                Text("PRIVATE NOTES")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .tracking(0.8)
                Spacer()
                Text("Only visible to you")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            // Add note input
            VStack(spacing: SpendlySpacing.sm) {
                HStack(alignment: .top, spacing: SpendlySpacing.sm) {
                    TextField("Add a private note...", text: $newNoteText, axis: .vertical)
                        .font(SpendlyFont.body())
                        .lineLimit(1...4)
                        .padding(SpendlySpacing.md)
                        .background(
                            colorScheme == .dark
                                ? SpendlyColors.secondary.opacity(0.1)
                                : SpendlyColors.backgroundLight
                        )
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))

                    if !newNoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button {
                            let trimmed = newNoteText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            viewModel.addNote(to: article.id, content: trimmed)
                            newNoteText = ""
                        } label: {
                            Image(systemName: SpendlyIcon.send.systemName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(SpendlyColors.primary)
                                .clipShape(Circle())
                        }
                    }
                }
            }

            // Existing notes
            if article.privateNotes.isEmpty {
                HStack {
                    Image(systemName: "note.text")
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                    Text("No private notes yet. Add your first note above.")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .padding(.vertical, SpendlySpacing.md)
            } else {
                ForEach(article.privateNotes) { note in
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        HStack {
                            Text(note.formattedDate)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                            Spacer()
                            Button {
                                viewModel.deleteNote(from: article.id, noteID: note.id)
                            } label: {
                                Image(systemName: SpendlyIcon.delete.systemName)
                                    .font(.system(size: 12))
                                    .foregroundStyle(SpendlyColors.error.opacity(0.6))
                            }
                        }
                        Text(note.content)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(SpendlySpacing.md)
                    .background(
                        SpendlyColors.accent.opacity(colorScheme == .dark ? 0.08 : 0.05)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                }
            }
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
        .padding(.top, SpendlySpacing.sm)
    }
}

// MARK: - Flow Layout (for tags)

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(subviews[index].sizeThatFits(.unspecified))
            )
        }
    }

    private struct LayoutResult {
        var size: CGSize
        var positions: [CGPoint]
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> LayoutResult {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            rowHeight = max(rowHeight, size.height)
            currentX += size.width + spacing
            maxX = max(maxX, currentX - spacing)
        }

        return LayoutResult(
            size: CGSize(width: maxX, height: currentY + rowHeight),
            positions: positions
        )
    }
}

// MARK: - Preview

#Preview("Article Detail - Light") {
    ArticleDetailView(
        article: KnowledgeBaseMockData.articles[0],
        viewModel: KnowledgeBaseViewModel()
    )
    .preferredColorScheme(.light)
}

#Preview("Article Detail - Dark") {
    ArticleDetailView(
        article: KnowledgeBaseMockData.articles[0],
        viewModel: KnowledgeBaseViewModel()
    )
    .preferredColorScheme(.dark)
}
