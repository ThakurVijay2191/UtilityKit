//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation
import Security

/// A singleton class responsible for securely storing and retrieving authentication tokens using the iOS Keychain.
///
/// `TokenStorage` acts as a central access point for authentication credentials such as
/// `accessToken` and `refreshToken`. It ensures these sensitive values are stored securely
/// using the system Keychain, which provides encryption and protection against unauthorized access.
///
/// This class exposes the same public API (`accessToken` and `refreshToken`) as its UserDefaults-based
/// version to maintain backward compatibility. It is `Sendable` and safe to use across concurrency domains.
public final class TokenStorage: Sendable {
    
    /// The shared singleton instance of `TokenStorage`.
    static let shared = TokenStorage()
    
    /// Private initializer to enforce singleton usage.
    private init() {}

    // MARK: - Keychain Keys

    /// Key used to identify the access token entry in the Keychain.
    private let accessTokenKey = "accessToken"

    /// Key used to identify the refresh token entry in the Keychain.
    private let refreshTokenKey = "refreshToken"

    // MARK: - Public API

    /// The access token used for authenticated API requests.
    ///
    /// This value is securely persisted in the Keychain. Setting it to `nil` will remove it.
    var accessToken: String? {
        get { getToken(forKey: accessTokenKey) }
        set { setToken(newValue, forKey: accessTokenKey) }
    }

    /// The refresh token used to obtain a new access token upon expiration.
    ///
    /// This value is securely persisted in the Keychain. Setting it to `nil` will remove it.
    var refreshToken: String? {
        get { getToken(forKey: refreshTokenKey) }
        set { setToken(newValue, forKey: refreshTokenKey) }
    }

    // MARK: - Keychain Helpers

    /// Stores a token value in the Keychain, or deletes it if `nil`.
    ///
    /// - Parameters:
    ///   - token: The token string to store. If `nil`, the key will be removed from Keychain.
    ///   - key: The key under which the token will be stored.
    private func setToken(_ token: String?, forKey key: String) {
        guard let token = token else {
            deleteToken(forKey: key)
            return
        }

        let data = Data(token.utf8)

        // First, delete any existing value to avoid duplication
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add the new token
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    /// Retrieves a token value from the Keychain for a given key.
    ///
    /// - Parameter key: The key associated with the stored token.
    /// - Returns: The token string if found, or `nil` if not present.
    private func getToken(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : true,
            kSecMatchLimit as String  : kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess, let data = result as? Data {
            return String(data: data, encoding: .utf8)
        }

        return nil
    }

    /// Deletes a token entry from the Keychain for a given key.
    ///
    /// - Parameter key: The key of the token to be removed.
    private func deleteToken(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

