//
//  KeychainService.swift
//  Lab01UIKit
//
//  Created by Елизавета on 17.11.2026.
//


import Foundation
import Security

final class KeychainService {

    static let shared = KeychainService()

    private let service = "Lab01UIKit"
    private let account = "registeredPassword"

    // MARK: - Initialization

    private init() {}

    // MARK: - Password Storage

    func savePassword(_ password: String) -> Bool {
        guard let data = password.data(using: .utf8) else {
            return false
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String:
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        if status == errSecSuccess {
            return true
        }

        if status != errSecItemNotFound {
            return false
        }

        var newItem = query
        newItem.merge(attributes) { _, new in new }

        let addStatus = SecItemAdd(
            newItem as CFDictionary,
            nil
        )

        return addStatus == errSecSuccess
    }

    func getPassword() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: CFTypeRef?

        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result
        )

        guard status == errSecSuccess,
              let data = result as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func deletePassword() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess ||
               status == errSecItemNotFound
    }
}
