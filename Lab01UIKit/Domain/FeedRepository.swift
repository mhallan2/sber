import Foundation

nonisolated protocol FeedRepository: Sendable {
    func loadFeed() async throws -> FeedContent
}

/// Два параллельных запроса. Если один упал, второй автоматически отменяется.
nonisolated struct DefaultFeedRepository: FeedRepository {

    private let client: HTTPClient

    init(client: HTTPClient = URLSessionHTTPClient()) {
        self.client = client
    }

    func loadFeed() async throws -> FeedContent {
        async let users: [User] = client.get(.users)
        async let posts: [Post] = client.get(.posts)

        return try await FeedContent(users: users, posts: posts)
    }
}
