//
//  APIConfig.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//


public struct APIConfig {
    public var baseURL: String
    public var defaultHeaders: [String: String] = [:]
    public var loggingEnabled: Bool = true
    public var shouldAutoLogoutOn401: Bool = true

    public init(baseURL: String,
                defaultHeaders: [String: String] = [:],
                loggingEnabled: Bool = true,
                shouldAutoLogoutOn401: Bool = true) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.loggingEnabled = loggingEnabled
        self.shouldAutoLogoutOn401 = shouldAutoLogoutOn401
    }
}