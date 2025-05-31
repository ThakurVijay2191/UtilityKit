//
//  NetworkStatus.swift
//  UtilityKit
//
//  Created by Apple on 31/05/25.
//

import Network

/// A value that describes the current network connectivity state.
///
/// `NetworkStatus` provides information about whether the device is connected to a network,
/// and if so, what type of network interface is being used (e.g., Wi-Fi, cellular).
///
/// This type is used in conjunction with `NetworkMonitor` and the SwiftUI environment
/// to allow views to reactively respond to network changes.
///
/// ```swift
/// if networkStatus.isConnected == true {
///     Text("Connected via \(networkStatus.connectionType?.debugDescription ?? "Unknown")")
/// } else {
///     Text("Offline")
/// }
/// ```
///
/// - SeeAlso: `NWInterface.InterfaceType`, `NetworkMonitor`, `EnvironmentValues.networkStatus`
public struct NetworkStatus {
    
    /// A Boolean value indicating whether the device is connected to the network.
    ///
    /// This value is `true` if a valid connection exists, `false` if explicitly offline,
    /// or `nil` if the connection state is unknown or has not yet been determined.
    public var isConnected: Bool?
    
    /// The type of network interface currently being used, such as Wi-Fi or cellular.
    ///
    /// This value is `nil` if no interface is active or if it cannot be determined.
    /// Use this to tailor behavior or UI based on the connection type.
    public var connectionType: NWInterface.InterfaceType?
}
