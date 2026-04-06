import SwiftUI
import SpendlyCore

public struct KnowledgeBaseRootView: View {

    @State private var viewModel = KnowledgeBaseViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        ZStack {
            SpendlyTheme.blueprint.backgroundColor(for: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: SpendlySpacing.lg) {
                    headerSection
                    searchSection
                    categoriesGrid
                    recommendedSection
                    trendingSection
                    recentlyViewedSection
                    faqSection
                }
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.top, SpendlySpacing.sm)
                .padding(.bottom, SpendlySpacing.xxxl * 2)
            }
        }
        .sheet(item: $viewModel.selectedArticle) { article in
            ArticleDetailView(
                article: article,
                viewModel: viewModel
            )
        }
        .sheet(isPresented: $viewModel.showCreateArticle) {
            CreateArticleView(viewModel: viewModel)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text("Knowledge Base")
                    .font(SpendlyFont.largeTitle())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text("Find solutions, guides, and expert knowledge")
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }

            Spacer()

            Button {
                viewModel.showCreateArticle = true
            } label: {
                Image(systemName: SpendlyIcon.addCircle.systemName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(SpendlyColors.primary)
            }
        }
        .padding(.top, SpendlySpacing.sm)
    }

    // MARK: - Search

    private var searchSection: some View {
        VStack(spacing: SpendlySpacing.sm) {
            SPSearchBar(searchText: $viewModel.searchText)

            // Category filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpendlySpacing.sm) {
                    categoryChip(label: "All", isSelected: viewModel.selectedCategory == nil) {
                        viewModel.selectCategory(nil)
                    }
                    ForEach(KBCategory.allCases) { category in
                        categoryChip(
                            label: category.rawValue,
                            isSelected: viewModel.selectedCategory == category
                        ) {
                            viewModel.selectCategory(category)
                        }
                    }
                }
            }

            // Sort control
            HStack {
                Text("\(viewModel.filteredArticles.count) article\(viewModel.filteredArticles.count == 1 ? "" : "s")")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)

                Spacer()

                Menu {
                    ForEach(KBSortOption.allCases, id: \.self) { option in
                        Button {
                            viewModel.sortOption = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                if viewModel.sortOption == option {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 11))
                        Text(viewModel.sortOption.rawValue)
                            .font(SpendlyFont.caption())
                    }
                    .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
    }

    private func categoryChip(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(isSelected ? .white : SpendlyColors.foreground(for: colorScheme))
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.vertical, SpendlySpacing.sm)
                .background(isSelected ? SpendlyColors.primary : SpendlyColors.surface(for: colorScheme))
                .clipShape(Capsule())
        }
    }

    // MARK: - Categories Grid

    private var categoriesGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: SpendlySpacing.md),
                GridItem(.flexible(), spacing: SpendlySpacing.md)
            ],
            spacing: SpendlySpacing.md
        ) {
            ForEach(KBCategory.allCases) { category in
                categoryCard(category)
                    .onTapGesture {
                        viewModel.selectCategory(category)
                    }
            }
        }
    }

    private func categoryCard(_ category: KBCategory) -> some View {
        VStack(spacing: SpendlySpacing.sm) {
            ZStack {
                Circle()
                    .fill(Color(hex: category.backgroundHex).opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: category.icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color(hex: category.backgroundHex))
            }

            Text(category.rawValue)
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(viewModel.articleCount(for: category)) articles")
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SpendlySpacing.lg)
        .padding(.horizontal, SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: - Recommended Section

    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Text("Recommended for You")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SpendlySpacing.lg) {
                    ForEach(viewModel.recommendedArticles) { article in
                        recommendedCard(article)
                            .onTapGesture {
                                viewModel.selectArticle(article)
                            }
                    }
                }
            }
        }
    }

    private func recommendedCard(_ article: KBArticle) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image placeholder
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: article.category.backgroundHex).opacity(0.3),
                        Color(hex: article.category.backgroundHex).opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image(systemName: article.category.icon)
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(Color(hex: article.category.backgroundHex).opacity(0.6))
            }
            .frame(height: 120)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: SpendlyRadius.large,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: SpendlyRadius.large
                )
            )

            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                SPBadge(article.category.rawValue, style: article.category.color)

                Text(article.title)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .lineLimit(2)

                Text(article.summary)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
                    .lineLimit(2)
            }
            .padding(SpendlySpacing.md)
        }
        .frame(width: 240)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: - Trending Section

    private var trendingSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            Text("Trending Articles")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            VStack(spacing: SpendlySpacing.sm) {
                ForEach(viewModel.trendingArticles) { article in
                    trendingRow(article)
                        .onTapGesture {
                            viewModel.selectArticle(article)
                        }
                }
            }
        }
    }

    private func trendingRow(_ article: KBArticle) -> some View {
        HStack(spacing: SpendlySpacing.md) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .fill(SpendlyColors.secondary.opacity(0.08))
                    .frame(width: 40, height: 40)
                Image(systemName: "doc.text")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(SpendlyColors.secondary.opacity(0.6))
            }

            // Text
            VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                Text(article.title)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .lineLimit(1)
                Text(article.summary)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: SpendlyIcon.chevronRight.systemName)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
        }
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }

    // MARK: - Recently Viewed Section

    @ViewBuilder
    private var recentlyViewedSection: some View {
        if !viewModel.recentlyViewedArticles.isEmpty {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                HStack {
                    Image(systemName: SpendlyIcon.history.systemName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(SpendlyColors.secondary)
                    Text("Recently Viewed")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }

                VStack(spacing: SpendlySpacing.sm) {
                    ForEach(viewModel.recentlyViewedArticles.prefix(3)) { article in
                        HStack(spacing: SpendlySpacing.md) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: article.category.backgroundHex).opacity(0.12))
                                    .frame(width: 36, height: 36)
                                Image(systemName: article.category.icon)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color(hex: article.category.backgroundHex))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(article.title)
                                    .font(SpendlyFont.bodyMedium())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                    .lineLimit(1)
                                Text(article.readTimeLabel)
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                            }

                            Spacer()

                            Image(systemName: SpendlyIcon.chevronRight.systemName)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                        }
                        .padding(SpendlySpacing.md)
                        .background(SpendlyColors.surface(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                        .onTapGesture {
                            viewModel.selectArticle(article)
                        }
                    }
                }
            }
        }
    }

    // MARK: - FAQ Section

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SpendlyColors.info)
                Text("Frequently Asked Questions")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            VStack(spacing: SpendlySpacing.sm) {
                ForEach(viewModel.faqItems) { faq in
                    faqRow(faq)
                }
            }
        }
    }

    private func faqRow(_ faq: KBFAQItem) -> some View {
        let isExpanded = viewModel.expandedFAQID == faq.id

        return VStack(alignment: .leading, spacing: 0) {
            Button {
                viewModel.toggleFAQ(faq.id)
            } label: {
                HStack {
                    Text(faq.question)
                        .font(SpendlyFont.bodyMedium())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .padding(SpendlySpacing.lg)
            }

            if isExpanded {
                SPDivider()
                Text(faq.answer)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .padding(SpendlySpacing.lg)
                    .padding(.top, 0)
            }
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
    }
}

// MARK: - Preview

#Preview("Knowledge Base - Light") {
    KnowledgeBaseRootView()
        .preferredColorScheme(.light)
}

#Preview("Knowledge Base - Dark") {
    KnowledgeBaseRootView()
        .preferredColorScheme(.dark)
}
