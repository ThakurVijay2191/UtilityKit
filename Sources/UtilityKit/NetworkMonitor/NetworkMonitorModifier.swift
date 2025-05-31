//
//  NetworkMonitorModifier.swift
//  UtilityKit
//
//  Created by Apple on 31/05/25.
//

import SwiftUI

/// A view modifier that injects a `NetworkStatus` object into the SwiftUI environment.
///
/// Use `NetworkMonitorModifier` to provide real-time network status updates to
/// any view hierarchy via the `@Environment(\.networkStatus)` property wrapper.
///
/// This modifier initializes a `NetworkMonitor` and automatically injects its
/// `networkStatus` into the environment, enabling reactive UI updates based
/// on connectivity changes.
///
/// ```swift
/// ContentView()
///     .modifier(NetworkMonitorModifier())
/// ```
///
/// Then in any child view:
///
/// ```swift
/// @Environment(\.networkStatus) private var networkStatus
/// ```
///
/// - SeeAlso: `EnvironmentValues.networkStatus`, `NetworkMonitor`, `NetworkStatus`
public struct NetworkMonitorModifier: ViewModifier {
    
    /// A state object that observes network status changes.
    @State private var networkMonitor: NetworkMonitor = .init()
    
    /// Modifies the content view by injecting the current network status into the environment.
    ///
    /// - Parameter content: The original view content.
    /// - Returns: A view with the `networkStatus` injected into its environment.
    public func body(content: Content) -> some View {
        content
            .environment(\.networkStatus, networkMonitor.networkStatus)
    }
}

