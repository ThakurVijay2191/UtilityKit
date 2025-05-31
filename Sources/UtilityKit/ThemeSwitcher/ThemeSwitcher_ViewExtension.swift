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
}

