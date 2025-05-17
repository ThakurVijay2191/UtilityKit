//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Vijay Thakur on 17/05/25.
//

import Foundation

@available(iOS 17.0, *)
/// A utility class for securely storing, reading, and deleting sensitive data in the iOS Keychain.
public class KeychainItem {
    /// The keychain service identifier, used to group related keychain items.
    private let service: String
    /// The account identifier, representing the unique key for the stored value.
    private let account: String
    
    /// Initializes a new KeychainItem instance.
    /// - Parameters:
    ///   - service: The keychain service name, used to identify a group of related keychain items.
    ///   - account: The account name, used as the unique key for storing the item.
    public init(service: String, account: String) {
        self.service = service
        self.account = account
    }
    
    /// Saves a string value to the keychain.
    /// - Parameter value: The string value to store.
    /// - Throws: An error if the item cannot be stored.
    public func save(_ value: String) throws {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw SignInWithAppleError.keychainError("Failed to store item: \(status)")
        }
    }
    
    /// Reads a string value from the keychain.
    /// - Returns: The stored string value.
    /// - Throws: An error if the item cannot be found or decoded.
    public func read() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, let data = item as? Data, let value = String(data: data, encoding: .utf8) {
            return value
        } else {
            throw SignInWithAppleError.keychainError("Failed to read item: \(status)")
        }
    }
    
    /// Deletes a keychain item.
    /// - Throws: An error if the item cannot be deleted or is not found.
    public func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw SignInWithAppleError.keychainError("Failed to delete item: \(status)")
        }
    }
}
