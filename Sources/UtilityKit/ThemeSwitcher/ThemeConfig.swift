//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Apple on 01/06/25.
//

import SwiftUI

/// A configuration structure for customizing the appearance and behavior of the theme switcher UI.
///
/// `ThemeConfig` allows fine-grained control over the icon used to toggle themes,
/// its layout, padding, size, and color. This configuration is typically passed to
/// the `themeSwitch(toggleTheme:config:)` view extension or directly into
/// a `ThemeSwitcherModifier`.
///
/// Example usage:
///
/// ```swift
/// let config = ThemeConfig(
///     sourceAlignment: .topTrailing,
///     lightModeImage: "sun.max.fill",
///     darkModeImage: "moon.fill",
///     iconLightModeColor: .yellow,
///     iconDarkModeColor: .gray
/// )
///
/// ContentView()
///     .themeSwitch(toggleTheme: $isDarkMode, config: config)
/// ```
///
/// - SeeAlso: `themeSwitch(toggleTheme:config:)`, `ThemeSwitcherModifier`
public struct ThemeConfig {

    // MARK: - Properties

    /// The alignment of the theme toggle icon within its container.
    public var sourceAlignment: Alignment

    /// The image name to be displayed when the app is in light mode.
    public var lightModeImage: String

    /// The image name to be displayed when the app is in dark mode.
    public var darkModeImage: String

    /// Indicates whether the icon is an SF Symbol or a custom image asset.
    public var isSymbolImage: Bool

    /// The color of the icon when in light mode.
    public var iconLightModeColor: Color

    /// The color of the icon when in dark mode.
    public var iconDarkModeColor: Color

    /// The size of the icon image.
    public var iconSize: CGFloat

    /// The size of the button container around the icon.
    public var buttonSize: CGFloat

    /// The offset to apply to the entire theme toggle icon.
    public var sourceOffset: CGSize

    /// Padding to apply to the leading edge of the theme toggle source view.
    public var sourcePaddingLeading: CGFloat

    /// Padding to apply to the trailing edge of the theme toggle source view.
    public var sourcePaddingTrailing: CGFloat

    /// Padding to apply to the top edge of the theme toggle source view.
    public var sourcePaddingTop: CGFloat

    /// Padding to apply to the bottom edge of the theme toggle source view.
    public var sourcePaddingBottom: CGFloat

    // MARK: - Initializer

    /// Initializes a new `ThemeConfig` with optional customization values.
    ///
    /// - Parameters:
    ///   - sourceAlignment: The position of the toggle icon (default: `.topLeading`).
    ///   - lightModeImage: The icon for light mode (default: `"moon.fill"`).
    ///   - darkModeImage: The icon for dark mode (default: `"sun.max.fill"`).
    ///   - isSymbolImage: Whether the icon is an SF Symbol (default: `true`).
    ///   - iconLightModeColor: Color for light mode icon (default: `.black`).
    ///   - iconDarkModeColor: Color for dark mode icon (default: `.white`).
    ///   - iconSize: Size of the theme icon (default: `16`).
    ///   - buttonSize: Size of the button container (default: `40`).
    ///   - sourceOffset: Offset for the icon (default: `.zero`).
    ///   - sourcePaddingLeading: Padding on the leading edge (default: `0`).
    ///   - sourcePaddingTrailing: Padding on the trailing edge (default: `0`).
    ///   - sourcePaddingTop: Padding on the top edge (default: `0`).
    ///   - sourcePaddingBottom: Padding on the bottom edge (default: `0`).
    public init(
        sourceAlignment: Alignment = .topLeading,
        lightModeImage: String = "moon.fill",
        darkModeImage: String = "sun.max.fill",
        isSymbolImage: Bool = true,
        iconLightModeColor: Color = .black,
        iconDarkModeColor: Color = .white,
        iconSize: CGFloat = 16,
        buttonSize: CGFloat = 40,
        sourceOffset: CGSize = .zero,
        sourcePaddingLeading: CGFloat = 0,
        sourcePaddingTrailing: CGFloat = 0,
        sourcePaddingTop: CGFloat = 0,
        sourcePaddingBottom: CGFloat = 0
    ) {
        self.sourceAlignment = sourceAlignment
        self.lightModeImage = lightModeImage
        self.darkModeImage = darkModeImage
        self.isSymbolImage = isSymbolImage
        self.iconLightModeColor = iconLightModeColor
        self.iconDarkModeColor = iconDarkModeColor
        self.iconSize = iconSize
        self.buttonSize = buttonSize
        self.sourceOffset = sourceOffset
        self.sourcePaddingLeading = sourcePaddingLeading
        self.sourcePaddingTrailing = sourcePaddingTrailing
        self.sourcePaddingTop = sourcePaddingTop
        self.sourcePaddingBottom = sourcePaddingBottom
    }

    // MARK: - Internal Computed Property

    /// Returns the opposing alignment used for internal positioning (e.g., button animations).
    var widthAlignment: Alignment {
        if sourceAlignment == .topTrailing {
            return .bottomLeading
        } else if sourceAlignment == .topLeading {
            return .bottomTrailing
        } else if sourceAlignment == .bottomLeading {
            return .topTrailing
        } else {
            return .topLeading
        }
    }
}

