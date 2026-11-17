import Foundation

nonisolated enum NetworkError: LocalizedError {
    case invalidResponse
    case httpError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return L10n.Network.invalidResponse
        case .httpError(let statusCode):
            return L10n.Network.httpError(statusCode)
        }
    }
}
