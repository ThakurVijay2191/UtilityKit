//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Vijay Thakur on 17/05/25.
//

import Foundation

@available(iOS 17.0, *)
/// An enum representing possible errors that can occur during the Sign In with Apple process.
public enum SignInWithAppleError: Error, CustomStringConvertible {
    /// The user cancelled the sign-in attempt.
    case cancelled
    
    /// The sign-in attempt failed with a specific error message.
    /// - Parameter message: A description of the failure reason.
    case failed(String)
    
    /// The identity token is missing, typically due to a failed token retrieval.
    case missingIdentityToken
    
    /// The provided credentials are invalid or incomplete.
    case invalidCredentials
    
    /// An error occurred while interacting with the keychain.
    /// - Parameter message: A description of the keychain error.
    case keychainError(String)
    
    /// An unknown error occurred during the sign-in attempt.
    /// - Parameter error: The underlying error.
    case unknown(Error)
    
    /// A human-readable description of the error, suitable for logging or displaying to the user.
    public var description: String {
        switch self {
        case .cancelled:
            return "Sign in was cancelled by the user."
        case .failed(let message):
            return "Sign in failed: \(message)"
        case .missingIdentityToken:
            return "Missing identity token."
        case .invalidCredentials:
            return "Invalid credentials."
        case .keychainError(let message):
            return "Keychain error: \(message)"
        case .unknown(let error):
            return "Unknown error occurred: \(error.localizedDescription)"
        }
    }
}
