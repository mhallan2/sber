import Foundation
@testable import Lab01UIKit

final class InMemoryKeyValueStore: KeyValueStore {

    private var storage: [String: Any] = [:]

    func value<T>(forKey key: StorageKey) -> T? {
        storage[key.rawValue] as? T
    }

    func setValue<T>(_ value: T?, forKey key: StorageKey) {
        guard let value else {
            storage[key.rawValue] = nil
            return
        }
        storage[key.rawValue] = value
    }

    func removeValue(forKey key: StorageKey) {
        storage[key.rawValue] = nil
    }
}

final class InMemorySecureStore: SecureStore {

    private var storage: [String: String] = [:]
    var shouldFailOnSave = false

    func string(for key: SecureKey) -> String? {
        storage[key.rawValue]
    }

    func save(_ value: String, for key: SecureKey) throws {
        if shouldFailOnSave { throw KeychainError.encodingFailed }
        storage[key.rawValue] = value
    }

    func delete(_ key: SecureKey) throws {
        storage[key.rawValue] = nil
    }
}
