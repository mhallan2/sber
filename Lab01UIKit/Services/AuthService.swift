//
//  Authservice.swift
//  Lab01UIKit
//
//  Created by Елизавета on 17.11.2026.
//


import Foundation

final class AuthService {

    static let shared = AuthService()

    private let usernameKey = "registeredUsername"
    private let oldPasswordKey = "registeredPassword"

    // MARK: - Initialization

    private init() {}

    // MARK: - Account Status

    var hasRegisteredUser: Bool {
        let username = UserDefaults.standard.string(
            forKey: usernameKey
        )

        let password = KeychainService.shared.getPassword()

        return username != nil && password != nil
    }

    // MARK: - Registration and Sign-In

    func register(
        username: String,
        password: String
    ) -> Bool {
        
        let saved = KeychainService.shared.savePassword(password)

        guard saved else {
            return false
        }

        UserDefaults.standard.set(
            username,
            forKey: usernameKey
        )

        return true
    }

    func login(
        username: String,
        password: String
    ) -> Bool {
        let savedUsername = UserDefaults.standard.string(
            forKey: usernameKey
        )

        let savedPassword = KeychainService.shared.getPassword()

        return username == savedUsername &&
               password == savedPassword &&
               savedUsername != nil &&
               savedPassword != nil
    }

    // MARK: - Sign-Out and Credential Removal

    func logout() -> Bool {
        let deleted = KeychainService.shared.deletePassword()

        guard deleted else {
            return false
        }

        UserDefaults.standard.removeObject(
            forKey: usernameKey
        )

        UserDefaults.standard.removeObject(
            forKey: oldPasswordKey
        )

        return true
    }
}
