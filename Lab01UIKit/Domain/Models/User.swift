import Foundation

// https://jsonplaceholder.typicode.com/users
nonisolated struct User: Decodable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let username: String
    let email: String
}
