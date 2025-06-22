//
//  RefreshTokenHandler.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation

/// A utility struct that encapsulates the logic required to refresh authentication tokens.
///
/// `RefreshTokenHandler` defines how to construct a token refresh request (`endpointBuilder`)
/// and how to parse the response (`responseParser`). This struct enables `APIService` to
/// generically perform token renewal without hard-coding endpoint details.
///
/// You typically inject this into `APIConfig` to support automatic retry on 401 Unauthorized responses.
public struct RefreshTokenHandler {
    
    /// A closure that constructs the `APIEndpoint` used to refresh the authentication token.
    ///
    /// This function takes the existing refresh token as input and returns a fully configured
    /// `APIEndpoint` object to be used in the refresh request.
    ///
    /// Example:
    /// ```swift
    /// endpointBuilder: { refreshToken in
    ///     Endpoint("/auth/refresh")
    ///         .post(body: ["refresh_token": refreshToken])
    ///         .auth(false)
    /// }
    /// ```
    public let endpointBuilder: (_ refreshToken: String) -> APIEndpoint

    /// A closure that parses the response `Data` from the refresh token endpoint.
    ///
    /// This function should decode the response payload and extract both the new
    /// access and refresh tokens. If decoding fails or response is invalid,
    /// it should throw an appropriate error.
    ///
    /// Example:
    /// ```swift
    /// responseParser: { data in
    ///     let tokens = try JSONDecoder().decode(TokenResponse.self, from: data)
    ///     return (tokens.accessToken, tokens.refreshToken)
    /// }
    /// ```
    public let responseParser: (_ data: Data) throws -> (accessToken: String, refreshToken: String)

    /// Creates a new instance of `RefreshTokenHandler`.
    ///
    /// - Parameters:
    ///   - endpointBuilder: A closure that builds the token refresh endpoint.
    ///   - responseParser: A closure that parses the response and extracts tokens.
    public init(
        endpointBuilder: @escaping (_ refreshToken: String) -> APIEndpoint,
        responseParser: @escaping (_ data: Data) throws -> (accessToken: String, refreshToken: String)
    ) {
        self.endpointBuilder = endpointBuilder
        self.responseParser = responseParser
    }
}
