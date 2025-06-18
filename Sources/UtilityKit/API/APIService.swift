//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation
import Combine

public final class APIService{
    nonisolated(unsafe) public static let shared = APIService()
    private init() {}

    // MARK: - Configuration
    public var config: APIConfig!

    public func configure(_ config: APIConfig) {
        self.config = config
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Request (Async)

    public func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        guard config != nil else { throw APIError.notConfigured }
        return try await performRequest(endpoint: endpoint, responseType: responseType, retryOn401: true)
    }

    // MARK: - Public Request (Combine)

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
        request.httpMethod = endpoint.method
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



