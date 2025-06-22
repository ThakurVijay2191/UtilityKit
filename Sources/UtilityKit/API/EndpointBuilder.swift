//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation

/// A concrete implementation of `APIEndpoint` that provides a flexible, fluent interface
/// for constructing HTTP endpoint definitions.
///
/// `Endpoint` simplifies the creation and configuration of network requests by
/// allowing developers to declaratively build endpoints using method chaining.
///
/// Example usage:
/// ```swift
/// let endpoint = Endpoint("/users/profile")
///     .get()
///     .auth(true)
///     .query([URLQueryItem(name: "id", value: "123")])
/// ```
public struct Endpoint: APIEndpoint {
    
    // MARK: - APIEndpoint Conformance

    /// The path component of the URL, relative to the base URL.
    public var path: String

    /// The HTTP method for the request. Defaults to `.get`.
    public var method: HTTPMethod = .get

    /// Optional headers specific to this endpoint.
    public var headers: [String: String]? = nil

    /// Optional query parameters to be appended to the URL.
    public var queryItems: [URLQueryItem]? = nil

    /// Optional HTTP body data, typically JSON.
    public var body: Data? = nil

    /// Indicates whether the endpoint requires authorization. Defaults to `true`.
    public var requiresAuth: Bool = true

    // MARK: - Initializer

    /// Initializes an `Endpoint` with a relative path.
    ///
    /// - Parameter path: The path component to be appended to the base URL.
    public init(_ path: String) {
        self.path = path
    }

    // MARK: - Builder Methods

    /// Sets the HTTP method to `POST` and encodes the provided body.
    ///
    /// - Parameter body: A value conforming to `Encodable` that will be JSON-encoded.
    /// - Returns: A new `Endpoint` instance with `.post` method and encoded body.
    public func post(body: Encodable) -> Endpoint {
        var copy = self
        copy.method = .post
        copy.body = try? JSONEncoder().encode(body)
        return copy
    }

    /// Sets the HTTP method to `PUT` and encodes the provided body if present.
    ///
    /// - Parameter body: An optional `Encodable` object to send in the request body.
    /// - Returns: A new `Endpoint` instance with `.put` method and optional body.
    public func put(body: Encodable?) -> Endpoint {
        var copy = self
        copy.method = .put
        if let body {
            copy.body = try? JSONEncoder().encode(body)
        }
        return copy
    }

    /// Sets the HTTP method to `GET`.
    ///
    /// - Returns: A new `Endpoint` instance configured for a `GET` request.
    public func get() -> Endpoint {
        var copy = self
        copy.method = .get
        return copy
    }

    /// Sets custom headers for the request.
    ///
    /// - Parameter headers: A dictionary of header fields.
    /// - Returns: A new `Endpoint` instance with the specified headers.
    public func set(headers: [String: String]) -> Endpoint {
        var copy = self
        copy.headers = headers
        return copy
    }

    /// Toggles whether the request requires authorization.
    ///
    /// - Parameter required: A boolean indicating whether auth is required.
    /// - Returns: A new `Endpoint` instance with the updated auth requirement.
    public func auth(_ required: Bool) -> Endpoint {
        var copy = self
        copy.requiresAuth = required
        return copy
    }

    /// Adds query parameters to the endpoint.
    ///
    /// - Parameter items: An array of `URLQueryItem` values.
    /// - Returns: A new `Endpoint` instance with the specified query items.
    public func query(_ items: [URLQueryItem]) -> Endpoint {
        var copy = self
        copy.queryItems = items
        return copy
    }
}


