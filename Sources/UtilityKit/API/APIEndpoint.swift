//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation

public protocol APIEndpoint {
    var path: String { get }
    var method: String { get }
    var headers: [String: String]? { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Data? { get }
    var requiresAuth: Bool { get }
}
