import Foundation

// https://jsonplaceholder.typicode.com/posts
nonisolated struct Post: Decodable, Identifiable, Hashable, Sendable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
