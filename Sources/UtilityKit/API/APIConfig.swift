//
//  APIConfig.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation

/// A configuration model that defines key parameters for network operations.
///
/// `APIConfig` is a centralized structure used to define the base URL, default headers,
/// logging behavior, token refresh logic, and other critical flags required to drive the API layer.
///
/// This struct is typically injected into a networking service or API client to provide
/// consistent configuration across all requests.
public struct APIConfig {
    
    /// The root URL for all API requests.
    ///
    /// This value should include the scheme (e.g., `https://`) and domain.
    /// Example: `https://api.example.com`
    public var baseURL: String

    /// Default HTTP headers that will be applied to every request unless overridden.
    ///
    /// Use this to specify commonly required headers like `Content-Type`, `Accept`,
    /// or custom authorization tokens.
    public var defaultHeaders: [String: String] = [:]

    /// A flag indicating whether HTTP requests and responses should be logged.
    ///
    /// When enabled, request and response details are printed to the console.
    /// This is particularly useful for debugging and development builds.
    public var loggingEnabled: Bool = true

    /// A flag indicating whether the application should automatically log out the user
    /// when a `401 Unauthorized` response is received.
    ///
    /// When enabled, a 401 response will trigger the logout logic, helping ensure
    /// the user's session remains secure.
    public var shouldAutoLogoutOn401: Bool = true

    /// An optional closure or handler responsible for refreshing authentication tokens.
    ///
    /// If provided, this handler will be invoked when a token refresh is needed,
    /// typically after receiving a `401 Unauthorized` response. This supports
    /// seamless token renewal without interrupting the user experience.
    public var refreshHandler: RefreshTokenHandler?

    /// Initializes a new `APIConfig` with optional customization.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for the API.
    ///   - defaultHeaders: Common HTTP headers applied to all requests (default: empty dictionary).
    ///   - loggingEnabled: Whether to enable request/response logging (default: `true`).
    ///   - shouldAutoLogoutOn401: Whether to auto-logout on `401 Unauthorized` (default: `true`).
    ///   - refreshHandler: A handler to refresh authentication tokens (default: `nil`).
    public init(baseURL: String,
                defaultHeaders: [String: String] = [:],
                loggingEnabled: Bool = true,
                shouldAutoLogoutOn401: Bool = true,
                refreshHandler: RefreshTokenHandler? = nil) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.loggingEnabled = loggingEnabled
        self.shouldAutoLogoutOn401 = shouldAutoLogoutOn401
        self.refreshHandler = refreshHandler
    }
}

