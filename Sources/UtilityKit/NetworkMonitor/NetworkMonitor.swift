//
//  NetworkMonitor.swift
//  UtilityKit
//
//  Created by Apple on 31/05/25.
//

import Network
import Foundation

/// A class that monitors the device's network connectivity status in real time.
///
/// `NetworkMonitor` uses `NWPathMonitor` to observe changes in network connectivity
/// and updates a `NetworkStatus` model accordingly. This class is annotated with
/// `@Observable`, allowing SwiftUI views to reactively bind to its network status.
///
/// ```swift
/// let monitor = NetworkMonitor()
/// monitor.startMonitoring()
/// ```
///
/// You can bind to the `networkStatus` property to observe connectivity changes:
///
/// ```swift
/// @StateObject private var monitor = NetworkMonitor()
///
/// var body: some View {
///     Text(monitor.networkStatus.isConnected == true ? "Online" : "Offline")
/// }
/// ```
///
/// - Note: Make sure to call `stopMonitoring()` when the object is no longer needed.
@Observable
public class NetworkMonitor: @unchecked Sendable {
    
    /// The current network status as monitored by the system.
    ///
    /// This value is updated automatically whenever the network path changes.
    public var networkStatus: NetworkStatus = .init(isConnected: nil, connectionType: nil)
    
    /// A private serial dispatch queue used by the network monitor.
    private var queue = DispatchQueue(label: "com.utilityKit.networkMonitor")
    
    /// The underlying `NWPathMonitor` instance from Apple's Network framework.
    private var monitor = NWPathMonitor()
    
    /// Creates and starts a new `NetworkMonitor` instance.
    ///
    /// Upon initialization, monitoring begins immediately to track changes in connectivity.
    init() {
        startMonitoring()
    }
    
    /// Begins monitoring the network path for changes.
    ///
    /// This sets a `pathUpdateHandler` on the monitor which updates the
    /// `networkStatus` property on the main actor whenever the path status changes.
    public func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.networkStatus.isConnected = path.status == .satisfied
                
                let types: [NWInterface.InterfaceType] = [.wifi, .cellular, .loopback, .wiredEthernet, .other]
                if let type = types.first(where: { path.usesInterfaceType($0) }) {
                    self.networkStatus.connectionType = type
                } else {
                    self.networkStatus.connectionType = nil
                }
            }
        }
        
        monitor.start(queue: queue)
    }
    
    /// Stops monitoring the network path and releases system resources.
    public func stopMonitoring() {
        monitor.cancel()
    }
}
