//
//  RefreshTokenHandler.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation

public struct RefreshTokenHandler {
    public let endpointBuilder: (_ refreshToken: String) -> APIEndpoint
    public let responseParser: (_ data: Data) throws -> (accessToken: String, refreshToken: String)

    public init(
        endpointBuilder: @escaping (_ refreshToken: String) -> APIEndpoint,
        responseParser: @escaping (_ data: Data) throws -> (accessToken: String, refreshToken: String)
    ) {
        self.endpointBuilder = endpointBuilder
        self.responseParser = responseParser
    }
}
