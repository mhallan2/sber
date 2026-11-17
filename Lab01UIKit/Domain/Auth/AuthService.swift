import Foundation

nonisolated enum AuthError: LocalizedError {
    case emptyCredentials
    case invalidCredentials
    case storageFailure

    var errorDescription: String? {
        switch self {
        case .emptyCredentials: return L10n.Auth.emptyCredentials
        case .invalidCredentials: return L10n.Auth.invalidCredentials
        case .storageFailure: return L10n.Auth.storageFailure
        }
    }
}

protocol AuthServicing: AnyObject {
    var hasRegisteredUser: Bool { get }
    func register(username: String, password: String) throws
    func login(username: String, password: String) throws
    /// Удаляет старую небезопасную копию пароля из UserDefaults (миграция).
    func removeLegacyCredentials()
}

/// Регистрация и вход по локально сохранённым данным: логин — в UserDefaults, пароль — в Keychain.
/// Очистка данных при выходе вынесена в `SessionCleaner`.
final class AuthService: AuthServicing {

    private let keyValueStore: KeyValueStore
    private let secureStore: SecureStore

    init(keyValueStore: KeyValueStore, secureStore: SecureStore) {
        self.keyValueStore = keyValueStore
        self.secureStore = secureStore
    }

    var hasRegisteredUser: Bool {
        storedUsername != nil && secureStore.string(for: .password) != nil
    }

    func register(username: String, password: String) throws {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthError.emptyCredentials
        }

        do {
            try secureStore.save(password, for: .password)
        } catch {
            throw AuthError.storageFailure
        }
        keyValueStore.setValue(username, forKey: .username)
    }

    func login(username: String, password: String) throws {
        guard !username.isEmpty, !password.isEmpty else {
            throw AuthError.emptyCredentials
        }

        guard let savedUsername = storedUsername,
              let savedPassword = secureStore.string(for: .password),
              username == savedUsername,
              password == savedPassword else {
            throw AuthError.invalidCredentials
        }
    }

    func removeLegacyCredentials() {
        keyValueStore.removeValue(forKey: .legacyPassword)
    }

    private var storedUsername: String? {
        keyValueStore.value(forKey: .username)
    }
}
