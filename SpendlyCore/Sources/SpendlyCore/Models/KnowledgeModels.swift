import Foundation
import SwiftData

// MARK: - Article (Knowledge Base)

@Model
public class Article {
    public var id: UUID
    public var orgID: UUID
    public var authorID: UUID
    public var title: String
    public var content: String
    public var category: String?
    public var tags: [String]
    public var status: ArticleStatus
    public var viewCount: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        authorID: UUID = UUID(),
        title: String = "",
        content: String = "",
        category: String? = nil,
        tags: [String] = [],
        status: ArticleStatus = .draft,
        viewCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.authorID = authorID
        self.title = title
        self.content = content
        self.category = category
        self.tags = tags
        self.status = status
        self.viewCount = viewCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.syncStatus = syncStatus
    }
}

// MARK: - Article Note

@Model
public class ArticleNote {
    public var id: UUID
    public var orgID: UUID
    public var articleID: UUID
    public var authorID: UUID
    public var content: String
    public var createdAt: Date
    public var syncStatus: SyncStatus

    public init(
        id: UUID = UUID(),
        orgID: UUID = UUID(),
        articleID: UUID = UUID(),
        authorID: UUID = UUID(),
        content: String = "",
        createdAt: Date = Date(),
        syncStatus: SyncStatus = .synced
    ) {
        self.id = id
        self.orgID = orgID
        self.articleID = articleID
        self.authorID = authorID
        self.content = content
        self.createdAt = createdAt
        self.syncStatus = syncStatus
    }
}
