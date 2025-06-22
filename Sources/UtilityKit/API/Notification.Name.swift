//
//  APIConfig.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 18/06/25.
//

import Foundation

/// An extension of `Notification.Name` that defines custom notification identifiers
/// used across the app for system-wide event broadcasting.
extension Notification.Name {
    
    /// A notification posted when the user's session has expired.
    ///
    /// This is typically triggered when a request returns a `401 Unauthorized` status
    /// and token refresh fails or is not available. Observers of this notification
    /// should respond by logging out the user and presenting the login screen.
    ///
    /// Example usage:
    /// ```swift
    /// NotificationCenter.default.post(name: .userSessionExpired, object: nil)
    ///
    /// NotificationCenter.default.addObserver(forName: .userSessionExpired, object: nil, queue: .main) { _ in
    ///     // Handle logout flow
    /// }
    /// ```
    static let userSessionExpired = Notification.Name("userSessionExpired")
}

