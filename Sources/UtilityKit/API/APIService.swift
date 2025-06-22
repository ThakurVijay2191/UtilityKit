//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation
import Combine

/// A singleton service responsible for managing API requests, responses, and authentication flows.
///
/// `APIService` provides a modern, scalable, and configurable abstraction for making HTTP
/// requests. It supports both async/await and Combine-based request patterns, and includes
/// built-in handling for authentication, token refresh, response decoding, and error reporting.
///
/// This service is intended to be configured once at app launch using an `APIConfig` object,
/// and used throughout the app via `APIService.shared`.
public final class APIService {
    
    /// The shared singleton instance of `APIService`.
    ///
    /// Marked as `nonisolated(unsafe)` to allow safe use across concurrency domains.
    nonisolated(unsafe) public static let shared = APIService()

    /// Private initializer to enforce singleton usage.
    private init() {}

    // MARK: - Configuration

    /// The configuration used to define base URL, headers, and authentication behavior.
    ///
    /// This must be set before performing any requests. Attempting to request without configuring
    /// will throw `APIError.notConfigured`.
    public var config: APIConfig!

    /// Configures the `APIService` with a given `APIConfig` object.
    ///
    /// - Parameter config: The configuration defining network behavior, base URL, and token refresh.
    public func configure(_ config: APIConfig) {
        self.config = config
    }

    /// A collection of Combine cancellables used to retain subscriptions (if needed).
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Request (Async/Await)

    /// Performs a typed API request using Swift's async/await.
    ///
    /// - Parameters:
    ///   - endpoint: An object conforming to `APIEndpoint`, describing the request.
    ///   - responseType: The expected `Decodable` model type.
    /// - Returns: A decoded response of the specified type.
    /// - Throws: An `APIError` if the request fails, decoding fails, or auth errors occur.
    public func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        guard config != nil else { throw APIError.notConfigured }
        return try await performRequest(endpoint: endpoint, responseType: responseType, retryOn401: true)
    }

    // MARK: - Public Request (Combine)

    /// Performs a typed API request using Combine and returns a publisher.
    ///
    /// - Parameters:
    ///   - endpoint: An object conforming to `APIEndpoint`.
    ///   - responseType: The expected `Decodable` model type.
    /// - Returns: A publisher emitting either a decoded response or an `APIError`.
    public func requestPublisher<T: Decodable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type
    ) async -> AnyPublisher<T, APIError> {
        do {
            let request = try await buildRequest(for: endpoint)

            return URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { result in
                    guard let response = result.response as? HTTPURLResponse else {
                        throw APIError.invalidResponse
                    }

                    switch response.statusCode {
                    case 200..<300:
                        return result.data
                    case 401:
                        throw APIError.unauthorized
                    case 403:
                        throw APIError.forbidden
                    default:
                        throw APIError.invalidResponse
                    }
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { error in
                    if let apiError = error as? APIError {
                        return apiError
                    } else if error is DecodingError {
                        return .decodingFailed
                    } else {
                        return .requestFailed(error)
                    }
                }
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()

        } catch {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
    }

    // MARK: - Internal Request Logic

    /// Internal function to build and execute a request, with optional retry on 401 (Unauthorized).
    ///
    /// - Parameters:
    ///   - endpoint: The endpoint to request.
    ///   - responseType: The expected `Decodable` model.
    ///   - retryOn401: Whether to retry the request after a token refresh.
    /// - Returns: A decoded instance of the specified type.
    /// - Throws: An `APIError` on failure.
    public func performRequest<T: Decodable>(
        endpoint: APIEndpoint,
        responseType: T.Type,
        retryOn401: Bool
    ) async throws -> T {
        let request = try await buildRequest(for: endpoint)

        if config.loggingEnabled {
            debugPrint("➡️ Request: \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if config.loggingEnabled {
            debugPrint("⬅️ Response [\(httpResponse.statusCode)] for \(request.url?.absoluteString ?? "")")
        }

        switch httpResponse.statusCode {
        case 200..<300:
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingFailed
            }

        case 401 where endpoint.requiresAuth && retryOn401:
            try await refreshAccessToken()
            return try await performRequest(endpoint: endpoint, responseType: responseType, retryOn401: false)

        case 401:
            if config.shouldAutoLogoutOn401 {
                NotificationCenter.default.post(name: .userSessionExpired, object: nil)
            }
            throw APIError.unauthorized

        case 403:
            throw APIError.forbidden

        default:
            throw APIError.invalidResponse
        }
    }

    // MARK: - Build URLRequest

    /// Builds a fully formed `URLRequest` from a given endpoint.
    ///
    /// This function merges base URL, path, query items, method, headers, body,
    /// and handles attaching authentication tokens if required.
    ///
    /// - Parameter endpoint: The endpoint describing the request.
    /// - Returns: A ready-to-use `URLRequest`.
    /// - Throws: `APIError.invalidURL` or `APIError.notConfigured`.
    private func buildRequest(for endpoint: APIEndpoint) async throws -> URLRequest {
        guard let config else { throw APIError.notConfigured }
        guard var components = URLComponents(string: config.baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        components.queryItems = endpoint.queryItems
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        // Merge headers: config + endpoint + auth
        var headers = config.defaultHeaders
        endpoint.headers?.forEach { headers[$0.key] = $0.value }

        if endpoint.requiresAuth, let token = TokenStorage.shared.accessToken {
            headers["Authorization"] = "Bearer \(token)"
        }

        request.allHTTPHeaderFields = headers

        return request
    }

    // MARK: - Token Refresh Logic

    /// Attempts to refresh the access token using the configured refresh handler.
    ///
    /// If the refresh is successful, new tokens are stored and the original request is retried.
    /// If the refresh fails, a session expiration notification is posted and the user
    /// should be logged out.
    ///
    /// - Throws: `APIError.tokenRefreshFailed` on failure.
    private func refreshAccessToken() async throws {
        guard
            let refreshToken = TokenStorage.shared.refreshToken,
            let handler = config.refreshHandler
        else {
            throw APIError.tokenRefreshFailed
        }

        let endpoint = handler.endpointBuilder(refreshToken)
        let request = try await buildRequest(for: endpoint)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            NotificationCenter.default.post(name: .userSessionExpired, object: nil)
            throw APIError.tokenRefreshFailed
        }

        do {
            let tokens = try handler.responseParser(data)
            TokenStorage.shared.accessToken = tokens.accessToken
            TokenStorage.shared.refreshToken = tokens.refreshToken
        } catch {
            NotificationCenter.default.post(name: .userSessionExpired, object: nil)
            throw APIError.tokenRefreshFailed
        }
    }
}



