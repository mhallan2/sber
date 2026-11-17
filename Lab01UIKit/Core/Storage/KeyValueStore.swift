import Foundation

protocol KeyValueStore: AnyObject {
    func value<T>(forKey key: StorageKey) -> T?
    /// `nil` удаляет значение.
    func setValue<T>(_ value: T?, forKey key: StorageKey)
    func removeValue(forKey key: StorageKey)
}

final class UserDefaultsStore: KeyValueStore {

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func value<T>(forKey key: StorageKey) -> T? {
        defaults.object(forKey: key.rawValue) as? T
    }

    func setValue<T>(_ value: T?, forKey key: StorageKey) {
        guard let value else {
            removeValue(forKey: key)
            return
        }
        defaults.set(value, forKey: key.rawValue)
    }

    func removeValue(forKey key: StorageKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
}
