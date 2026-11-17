import Foundation

protocol SessionCleaning: AnyObject {
    /// Полностью очищает локальные данные пользователя.
    func clearAllLocalData() throws
}

/// Единственное место, знающее, что именно надо стереть при выходе.
/// Раньше список ключей дублировался в двух контроллерах.
final class SessionCleaner: SessionCleaning {

    private let secureStore: SecureStore
    private let keyValueStore: KeyValueStore

    init(secureStore: SecureStore, keyValueStore: KeyValueStore) {
        self.secureStore = secureStore
        self.keyValueStore = keyValueStore
    }

    func clearAllLocalData() throws {
        // Сначала Keychain: если он не очистился, остальное не трогаем,
        // чтобы не получить «логин есть, пароля нет».
        try secureStore.delete(.password)

        keyValueStore.removeValue(forKey: .username)
        keyValueStore.removeValue(forKey: .legacyPassword)
        keyValueStore.removeValue(forKey: .likedPostIds)
        keyValueStore.removeValue(forKey: .isAscendingSort)
    }
}
