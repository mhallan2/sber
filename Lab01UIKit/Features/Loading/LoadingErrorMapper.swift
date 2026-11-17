import Foundation

nonisolated struct LoadingErrorInfo: Sendable {
    let message: String
    let iconName: String
}

/// Превращает ошибку в текст и SF Symbol. Раньше это жило прямо в контроллере.
nonisolated enum LoadingErrorMapper {

    static func map(_ error: Error) -> LoadingErrorInfo {
        LoadingErrorInfo(
            message: L10n.Loading.failed(reason: reason(for: error)),
            iconName: iconName(for: error)
        )
    }

    static func reason(for error: Error) -> String {
        guard let urlError = error as? URLError else {
            return error.localizedDescription
        }

        switch urlError.code {
        case .notConnectedToInternet: return L10n.Loading.offline
        case .timedOut: return L10n.Loading.timedOut
        case .cannotFindHost: return L10n.Loading.hostNotFound
        case .cannotConnectToHost: return L10n.Loading.cannotConnect
        default: return urlError.localizedDescription
        }
    }

    static func iconName(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet: return "wifi.slash"
            case .timedOut: return "clock.badge.exclamationmark"
            case .cannotFindHost, .cannotConnectToHost: return "network.slash"
            default: return "exclamationmark.triangle"
            }
        }

        if error is DecodingError {
            return "doc.text.magnifyingglass"
        }

        return "exclamationmark.triangle"
    }
}
