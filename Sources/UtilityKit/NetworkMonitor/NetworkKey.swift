//
//  NetworkKey.swift
//  UtilityKit
//
//  Created by Apple on 31/05/25.
//

import SwiftUI

/// A key for accessing the network status value in the environment.
///
/// Use `NetworkKey` to inject or retrieve a `NetworkStatus` value
/// from the SwiftUI environment. This key enables the custom
/// `EnvironmentValues.networkStatus` property to function properly.
///
/// This key provides a default value of `NetworkStatus(isConnected: nil, connectionType: nil)`,
/// which represents an unknown or undefined network state.
///
/// - SeeAlso: `NetworkStatus`, `EnvironmentValues.networkStatus`
public struct NetworkKey: @preconcurrency EnvironmentKey {
    /// The default value used when no explicit `NetworkStatus` is set in the environment.
    ///
    /// This value initializes `isConnected` and `connectionType` to `nil`,
    /// representing an unknown or uninitialized network condition.
    @MainActor
    public static let defaultValue: NetworkStatus = .init(isConnected: nil, connectionType: nil)
}
