//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation

public struct Endpoint: APIEndpoint {
    public var path: String
    public var method: String = "GET"
    public var headers: [String: String]? = nil
    public var queryItems: [URLQueryItem]? = nil
    public var body: Data? = nil
    public var requiresAuth: Bool = true

    public init(_ path: String) {
        self.path = path
    }

    public func post(body: Encodable) -> Endpoint {
        var copy = self
        copy.method = "POST"
        copy.body = try? JSONEncoder().encode(body)
        return copy
    }

    public func get() -> Endpoint {
        var copy = self
        copy.method = "GET"
        return copy
    }

    public func set(headers: [String: String]) -> Endpoint {
        var copy = self
        copy.headers = headers
        return copy
    }

    public func auth(_ required: Bool) -> Endpoint {
        var copy = self
        copy.requiresAuth = required
        return copy
    }

    public func query(_ items: [URLQueryItem]) -> Endpoint {
        var copy = self
        copy.queryItems = items
        return copy
    }
}

