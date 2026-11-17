import Foundation

/// Абстракция над сетью: в тестах подменяется заглушкой.
/// Тип `nonisolated`, поэтому сеть и декодирование JSON не выполняются на main actor.
nonisolated protocol HTTPClient: Sendable {
    func get<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T
}

nonisolated struct URLSessionHTTPClient: HTTPClient {

    private let session: URLSession
    private let timeout: TimeInterval

    init(session: URLSession = .shared, timeout: TimeInterval = 15) {
        self.session = session
        self.timeout = timeout
    }

    func get<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.timeoutInterval = timeout

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}
