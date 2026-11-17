
import Foundation

final class APIService {

    static let shared = APIService()

    // MARK: - Initialization

    private init() {}

    // MARK: - API Endpoints

    func fetchUsers() async throws -> [User] {
        let url = URL(
            string: "https://jsonplaceholder.typicode.com/users"
        )!

        return try await fetch(url: url)
    }

    func fetchPosts() async throws -> [Post] {
        let url = URL(
            string: "https://jsonplaceholder.typicode.com/posts"
        )!

        return try await fetch(url: url)
    }

    // MARK: - HTTP Requests and Decoding

    private func fetch<T: Decodable>(
        url: URL
    ) async throws -> T {

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Network Errors

enum NetworkError: LocalizedError {
    case invalidResponse
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Сервер вернул некорректный ответ."

        case .httpError(let statusCode):
            return "Ошибка сервера. HTTP-код: \(statusCode)."
        }
    }
}
