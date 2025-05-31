//
//  File.swift
//  UtilityKit
//
//  Created by Apple on 31/05/25.
//

import SwiftUI

/// A value that indicates the current network status from the environment.
///
/// Use this property to read or write the current `NetworkStatus` value from the
/// SwiftUI `EnvironmentValues`. You can use this to conditionally update UI based
/// on whether the device is online, offline, or in a limited connectivity state.
///
/// ```swift
/// @Environment(\.networkStatus) private var networkStatus
/// ```
///
/// - SeeAlso: `NetworkKey`, `NetworkStatus`
public extension EnvironmentValues {
    /// The current network status for the environment.
    ///
    /// This value reflects the network connectivity as defined by the custom
    /// `NetworkStatus` type and provided via the `NetworkKey`.
    var networkStatus: NetworkStatus {
        get { self[NetworkKey.self] }
        set { self[NetworkKey.self] = newValue }
    }
}
