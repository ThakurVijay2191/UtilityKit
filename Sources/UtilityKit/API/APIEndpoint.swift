//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation

/// A protocol that defines the contract for representing a single API endpoint.
///
/// `APIEndpoint` encapsulates all the essential components required to construct
/// and execute an HTTP request. It serves as a standardized, type-safe interface
/// for describing endpoints in modular and scalable network layers.
///
/// Conforming to this protocol allows networking clients to build and execute
/// requests without coupling to specific API details.
public protocol APIEndpoint {
    
    /// The relative path component of the URL for the endpoint.
    ///
    /// This path is appended to the base URL defined in your `APIConfig`.
    ///
    /// Example: `"/v1/users/me"` or `"/auth/login"`
    var path: String { get }

    /// The HTTP method used to perform the request.
    ///
    /// Defines the type of operation being performed—such as `.get`, `.post`, or `.delete`.
    /// Strong typing via `HTTPMethod` helps eliminate invalid method declarations and
    /// improves readability across your networking layer.
    var method: HTTPMethod { get }

    /// Additional HTTP headers to include with the request.
    ///
    /// These headers supplement or override any default headers specified in the `APIConfig`.
    /// Use this for specifying custom headers like content type, authorization tokens, or
    /// client-specific metadata.
    ///
    /// Example: `["Content-Type": "application/json"]`
    var headers: [String: String]? { get }

    /// Query parameters to be appended to the URL.
    ///
    /// These are useful for `GET` requests or endpoints that require key-value filtering
    /// or pagination information in the URL.
    ///
    /// Example: `[URLQueryItem(name: "page", value: "1")]`
    var queryItems: [URLQueryItem]? { get }

    /// The HTTP body payload to send with the request.
    ///
    /// Typically applies to `POST`, `PUT`, or `PATCH` requests. This should contain the
    /// request payload encoded as `Data`, such as JSON or form data.
    ///
    /// Example: `try? JSONEncoder().encode(userPayload)`
    var body: Data? { get }

    /// Indicates whether this endpoint requires an authenticated user session.
    ///
    /// When `true`, the networking layer should attach an authorization token
    /// or perform a token refresh if needed. Used to gate access to protected resources.
    var requiresAuth: Bool { get }
}
