//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation

/// A comprehensive enumeration of possible networking errors returned by the API layer.
///
/// `APIError` conforms to both `Error` and `LocalizedError`, allowing it to be used
/// in standard Swift error handling as well as user-facing error messaging.
///
/// Each case represents a specific failure scenario that may occur during
/// network communication, request construction, or response parsing.
public enum APIError: Error, LocalizedError {

    /// Indicates that the URL provided for the request is malformed or invalid.
    case invalidURL

    /// Indicates a failure during the URL session request.
    ///
    /// - Parameter error: The underlying error returned by `URLSession` or a related layer.
    case requestFailed(Error)

    /// Indicates that the response received was not valid or did not meet expected criteria.
    ///
    /// This may include unexpected status codes, empty data, or missing headers.
    case invalidResponse

    /// Indicates that the response could not be decoded into the expected model type.
    ///
    /// Typically caused by mismatched JSON structure or incorrect decoding logic.
    case decodingFailed

    /// Indicates that the request was made without proper authorization.
    ///
    /// Often corresponds to a `401 Unauthorized` HTTP response.
    case unauthorized

    /// Indicates that access to the resource is forbidden.
    ///
    /// Often corresponds to a `403 Forbidden` HTTP response.
    case forbidden

    /// Indicates that the user’s session has expired and a re-login is required.
    ///
    /// Useful for triggering logout or token refresh workflows.
    case sessionExpired

    /// Indicates that an attempt to refresh the authentication token has failed.
    ///
    /// Typically used in scenarios where automatic token renewal is implemented.
    case tokenRefreshFailed

    /// Indicates that the device is not connected to the internet.
    ///
    /// Can be used to provide offline messaging or retry mechanisms.
    case noInternet

    /// Indicates that the API configuration was missing or improperly initialized.
    ///
    /// Useful for early-stage validation of networking setup.
    case notConfigured

    /// A custom, developer-defined error with an associated message.
    ///
    /// - Parameter message: A user-friendly or developer-specified error string.
    case custom(String)

    /// A localized description of the error, suitable for display in UI alerts or logs.
    ///
    /// This computed property provides a human-readable explanation for each error case,
    /// and integrates seamlessly with Swift’s `LocalizedError` protocol.
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server."
        case .decodingFailed:
            return "Failed to decode server response."
        case .unauthorized:
            return "You're not authorized. Please log in again."
        case .forbidden:
            return "Access is forbidden."
        case .sessionExpired:
            return "Session expired. Please log in again."
        case .tokenRefreshFailed:
            return "Failed to refresh session."
        case .noInternet:
            return "No internet connection."
        case .notConfigured:
            return "No API configuration found."
        case .custom(let message):
            return message
        }
    }
}
