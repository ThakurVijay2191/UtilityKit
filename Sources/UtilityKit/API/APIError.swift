//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation

public enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed
    case unauthorized
    case forbidden
    case sessionExpired
    case tokenRefreshFailed
    case noInternet
    case notConfigured
    case custom(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL: return "The URL is invalid."
        case .requestFailed(let error): return "Request failed: \(error.localizedDescription)"
        case .invalidResponse: return "Invalid response from server."
        case .decodingFailed: return "Failed to decode server response."
        case .unauthorized: return "You're not authorized. Please log in again."
        case .forbidden: return "Access is forbidden."
        case .sessionExpired: return "Session expired. Please log in again."
        case .tokenRefreshFailed: return "Failed to refresh session."
        case .noInternet: return "No internet connection."
        case .notConfigured: return "No api configuration found."
        case .custom(let message): return message
        }
    }
}
