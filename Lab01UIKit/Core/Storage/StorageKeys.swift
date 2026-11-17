import Foundation

/// Все ключи локального хранилища — в одном месте (раньше строки были разбросаны по четырём файлам).
enum StorageKey: String {
    case username = "registeredUsername"
    /// Старая небезопасная копия пароля. Только для миграции: удаляется при запуске.
    case legacyPassword = "registeredPassword"
    case likedPostIds
    case isAscendingSort
}

/// Ключи Keychain. Значение совпадает со старым, чтобы не потерять уже сохранённый пароль.
enum SecureKey: String {
    case password = "registeredPassword"
}
