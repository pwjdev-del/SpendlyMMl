import Foundation
import SwiftUI
import SpendlyCore

// MARK: - Sort Option

enum KBSortOption: String, CaseIterable {
    case newest       = "Newest First"
    case oldest       = "Oldest First"
    case mostViewed   = "Most Viewed"
    case titleAZ      = "Title (A-Z)"
}

// MARK: - ViewModel

@Observable
final class KnowledgeBaseViewModel {

    // MARK: Data
    var allArticles: [KBArticle] = KnowledgeBaseMockData.articles
    var faqItems: [KBFAQItem] = KnowledgeBaseMockData.faqItems
    var recentlyViewedIDs: [UUID] = []

    // MARK: UI State
    var searchText: String = ""
    var selectedCategory: KBCategory? = nil
    var sortOption: KBSortOption = .newest
    var showArticleDetail: Bool = false
    var selectedArticle: KBArticle? = nil
    var showCreateArticle: Bool = false
    var expandedFAQID: UUID? = nil

    // MARK: - Computed: Filtered Articles

    var filteredArticles: [KBArticle] {
        var result = allArticles.filter { $0.status == .published }

        // Category filter
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }

        // Search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { article in
                article.title.lowercased().contains(query) ||
                article.summary.lowercased().contains(query) ||
                article.category.rawValue.lowercased().contains(query) ||
                article.tags.contains(where: { $0.lowercased().contains(query) }) ||
                article.authorName.lowercased().contains(query)
            }
        }

        // Sort
        switch sortOption {
        case .newest:
            result.sort { $0.updatedAt > $1.updatedAt }
        case .oldest:
            result.sort { $0.updatedAt < $1.updatedAt }
        case .mostViewed:
            result.sort { $0.viewCount > $1.viewCount }
        case .titleAZ:
            result.sort { $0.title < $1.title }
        }

        return result
    }

    // MARK: - Computed: Recommended (first 2 by view count, simulating active assignment relevance)

    var recommendedArticles: [KBArticle] {
        allArticles
            .filter { $0.status == .published }
            .sorted { $0.viewCount > $1.viewCount }
            .prefix(2)
            .map { $0 }
    }

    // MARK: - Computed: Trending (top 3 most viewed)

    var trendingArticles: [KBArticle] {
        allArticles
            .filter { $0.status == .published }
            .sorted { $0.viewCount > $1.viewCount }
            .prefix(3)
            .map { $0 }
    }

    // MARK: - Computed: Recently Viewed

    var recentlyViewedArticles: [KBArticle] {
        recentlyViewedIDs.compactMap { id in
            allArticles.first(where: { $0.id == id })
        }
    }

    // MARK: - Summary Stats

    var totalArticles: Int { allArticles.filter { $0.status == .published }.count }

    var totalViews: Int {
        allArticles.reduce(0) { $0 + $1.viewCount }
    }

    func articleCount(for category: KBCategory) -> Int {
        allArticles.filter { $0.category == category && $0.status == .published }.count
    }

    // MARK: - Actions

    func selectArticle(_ article: KBArticle) {
        selectedArticle = article
        showArticleDetail = true

        // Track recently viewed
        recentlyViewedIDs.removeAll(where: { $0 == article.id })
        recentlyViewedIDs.insert(article.id, at: 0)
        if recentlyViewedIDs.count > 10 {
            recentlyViewedIDs = Array(recentlyViewedIDs.prefix(10))
        }
    }

    func toggleBookmark(for articleID: UUID) {
        if let index = allArticles.firstIndex(where: { $0.id == articleID }) {
            allArticles[index].isBookmarked.toggle()
        }
        // Update selectedArticle if it matches
        if selectedArticle?.id == articleID {
            selectedArticle?.isBookmarked.toggle()
        }
    }

    func addNote(to articleID: UUID, content: String) {
        let note = KBNote(content: content)
        if let index = allArticles.firstIndex(where: { $0.id == articleID }) {
            allArticles[index].privateNotes.insert(note, at: 0)
        }
        if selectedArticle?.id == articleID {
            selectedArticle?.privateNotes.insert(note, at: 0)
        }
    }

    func deleteNote(from articleID: UUID, noteID: UUID) {
        if let index = allArticles.firstIndex(where: { $0.id == articleID }) {
            allArticles[index].privateNotes.removeAll(where: { $0.id == noteID })
        }
        if selectedArticle?.id == articleID {
            selectedArticle?.privateNotes.removeAll(where: { $0.id == noteID })
        }
    }

    func selectCategory(_ category: KBCategory?) {
        withAnimation(.easeInOut(duration: 0.25)) {
            if selectedCategory == category {
                selectedCategory = nil
            } else {
                selectedCategory = category
            }
        }
    }

    func toggleFAQ(_ id: UUID) {
        withAnimation(.easeInOut(duration: 0.2)) {
            expandedFAQID = expandedFAQID == id ? nil : id
        }
    }

    // MARK: - Create Article

    func publishArticle(title: String, category: KBCategory, content: String, tags: [String]) {
        let article = KBArticle(
            id: UUID(),
            title: title,
            summary: String(content.prefix(120)),
            content: content,
            category: category,
            authorName: "Current User",
            authorInitials: "CU",
            readTimeMinutes: max(1, content.split(separator: " ").count / 200),
            viewCount: 0,
            createdAt: Date(),
            updatedAt: Date(),
            status: .published,
            tags: tags,
            isBookmarked: false,
            privateNotes: []
        )
        allArticles.insert(article, at: 0)
    }
}
