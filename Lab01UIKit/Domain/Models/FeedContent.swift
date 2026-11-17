import Foundation

/// Результат двух запросов: пользователи (оранжевая секция) и посты (зелёная).
nonisolated struct FeedContent: Sendable {
    let users: [User]
    let posts: [Post]
}
