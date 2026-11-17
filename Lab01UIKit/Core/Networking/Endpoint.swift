import Foundation

/// Описание адреса API. Все URL живут здесь, а не размазаны по сервисам.
nonisolated struct Endpoint: Sendable {
    let path: String

    private static let baseURL: URL = {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com") else {
            preconditionFailure("Invalid base URL")
        }
        return url
    }()

    var url: URL { Self.baseURL.appendingPathComponent(path) }

    static let users = Endpoint(path: "users")
    static let posts = Endpoint(path: "posts")
}
