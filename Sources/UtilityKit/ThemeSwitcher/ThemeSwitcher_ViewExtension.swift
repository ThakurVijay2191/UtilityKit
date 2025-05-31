//
//  File.swift
//  UtilityKit
//
//  Created by Apple on 01/06/25.
//

import SwiftUI

/// Applies a dynamic theme-switching modifier to the view.
///
/// Use this method to attach a `ThemeSwitcherModifier` to your SwiftUI view hierarchy.
/// This enables runtime theme switching (e.g., between light and dark modes) based on
/// a persistent Boolean flag, typically stored using `@AppStorage`.
///
/// This modifier is useful for implementing user-controlled themes across the entire app,
/// and can be driven from a toggle or settings screen.
///
/// ```swift
/// @AppStorage("isDarkMode") private var isDarkModeEnabled: Bool = false
///
/// var body: some View {
///     ContentView()
///         .themeSwitch(toggleTheme: $isDarkModeEnabled)
/// }
/// ```
///
/// - Parameters:
///   - toggleTheme: A `Binding<Bool>` to control whether the dark theme is enabled. Use `@AppStorage` to persist this value.
///   - config: An optional `ThemeConfig` struct that defines additional behavior for theme customization. Defaults to `ThemeConfig()`.
/// - Returns: A view modified with `ThemeSwitcherModifier`, enabling theme toggling.
///
/// - SeeAlso: `ThemeSwitcherModifier`, `ThemeConfig`, `@AppStorage`
public extension View {
    @ViewBuilder
    func themeSwitch(toggleTheme: Binding<Bool>, config: ThemeConfig = ThemeConfig()) -> some View {
        self.modifier(
            ThemeSwitcherModifier(toggleTheme: toggleTheme, config: config)
        )
    }
    
    /// Captures the view’s frame and exposes it using a `PreferenceKey` callback.
    ///
    /// This modifier uses `GeometryReader` to obtain the current view’s frame in global coordinates,
    /// then passes that `CGRect` to the supplied closure whenever the frame changes.
    ///
    /// - Parameter value: A closure called with the view’s current frame (`CGRect`) whenever it changes.
    ///
    /// ### Example
    /// ```swift
    /// Text("Track my frame")
    ///     .rect { frame in
    ///         print("Frame: \(frame)")
    ///     }
    /// ```
    ///
    /// - SeeAlso: `RectKey`
    @ViewBuilder
    func rect(value: @escaping (CGRect) -> Void) -> some View {
        self
            .overlay {
                GeometryReader {
                    Color.clear
                        .preference(key: RectKey.self, value: $0.frame(in: .global))
                        .onPreferenceChange(RectKey.self, perform: value)
                }
            }
    }
}

