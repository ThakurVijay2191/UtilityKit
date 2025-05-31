//
//  File.swift
//  UtilityKit
//
//  Created by Apple on 31/05/25.
//

import SwiftUI

/// Applies a network monitoring modifier to the view conditionally.
///
/// Use this method to inject the current `NetworkStatus` into the environment,
/// enabling SwiftUI views to observe network connectivity in real time. The
/// `NetworkMonitorModifier` is applied only when `isEnabled` is `true`.
///
/// ```swift
/// ContentView()
///     .networkMonitor() // Enabled by default
///
/// ContentView()
///     .networkMonitor(false) // Skips applying the modifier
/// ```
///
/// This is especially useful for enabling or disabling monitoring
/// based on build configuration, feature flags, or user settings.
///
/// - Parameter isEnabled: A Boolean value that determines whether to apply the modifier. Defaults to `true`.
/// - Returns: A view that conditionally applies the `NetworkMonitorModifier`.
///
/// - SeeAlso: `NetworkMonitorModifier`, `NetworkStatus`, `EnvironmentValues.networkStatus`
public extension View {
    /// Conditionally applies the `NetworkMonitorModifier` to the view.
    ///
    /// - Parameter isEnabled: A flag that determines whether monitoring should be enabled.
    ///                        Defaults to `true`.
    @ViewBuilder
    func networkMonitor(_ isEnabled: Bool = true) -> some View {
        if isEnabled {
            self
                .modifier(NetworkMonitorModifier())
        } else {
            self
        }
    }
}

