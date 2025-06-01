//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Apple on 01/06/25.
//

import SwiftUI

/// A `ViewModifier` that applies a dark/light theme toggle with animated circular mask transition and configurable icon.
///
/// `ThemeSwitcherModifier` is responsible for rendering a theme toggle button (usually at a corner of the screen)
/// and animating the transition between themes with a smooth radial mask effect. It can be fully customized via the `ThemeConfig`
/// to control alignment, icon appearance, sizing, and padding.
///
/// This modifier is not used directly. Instead, apply it via the `.themeSwitch(toggleTheme:config:)` view extension:
///
/// ```swift
/// @AppStorage("isDarkMode") var isDarkMode: Bool = false
///
/// ContentView()
///     .themeSwitch(toggleTheme: $isDarkMode)
/// ```
///
/// - Note: This modifier performs image-based transitions using snapshots of the current and next themes, and overlays them using `GeometryReader`.
/// - Important: The modifier disables the theme toggle button during animation to prevent overlap or glitches.
/// - SeeAlso: `ThemeConfig`, `themeSwitch(toggleTheme:config:)`
public struct ThemeSwitcherModifier: ViewModifier {

    // MARK: - Properties

    /// The binding that determines whether dark mode is active.
    @Binding var activateDarkMode: Bool

    /// Configuration for customizing the toggle button appearance and layout.
    var config: ThemeConfig

    /// Stores and observes the persistent dark mode state using `@AppStorage`.
    @AppStorage("toggleDarkMode")
    private var toggleDarkMode: Bool = false

    /// The frame of the toggle button, used to position the mask animation.
    @State private var buttonRect: CGRect = .zero

    /// The screenshot of the new theme after toggle.
    @State private var currentImage: UIImage?

    /// The screenshot of the previous theme before toggle.
    @State private var previousImage: UIImage?

    /// A flag to control the progress of the mask animation.
    @State private var maskAnimation: Bool = false

    // MARK: - View Modifier Body

    public func body(content: Content) -> some View {
        content
            // Step 1: Create snapshot images
            .createImages(
                toggleDarkMode: toggleDarkMode,
                currentImage: $currentImage,
                previousImage: $previousImage,
                activateDarkMode: $activateDarkMode
            )

            // Step 2: Perform animated masking transition
            .overlay {
                GeometryReader { geometry in
                    let size = geometry.size
                    if let previousImage, let currentImage {
                        ZStack {
                            Image(uiImage: previousImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.width, height: size.height)

                            Image(uiImage: currentImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.width, height: size.height)
                                .mask(alignment: .topLeading) {
                                    Circle()
                                        .frame(
                                            width: buttonRect.width * (maskAnimation ? 80 : 1),
                                            height: buttonRect.height * (maskAnimation ? 80 : 1),
                                            alignment: config.widthAlignment
                                        )
                                        .frame(width: buttonRect.width, height: buttonRect.height)
                                        .offset(x: buttonRect.minX, y: buttonRect.minY)
                                        .ignoresSafeArea()
                                }
                        }
                        .task {
                            guard !maskAnimation else { return }
                            withAnimation(.easeInOut(duration: 0.9), completionCriteria: .logicallyComplete) {
                                maskAnimation = true
                            } completion: {
                                self.currentImage = nil
                                self.previousImage = nil
                                self.maskAnimation = false
                            }
                        }
                    }
                }
                .mask {
                    Rectangle()
                        .overlay(alignment: .topLeading) {
                            Circle()
                                .frame(width: buttonRect.width, height: buttonRect.height)
                                .offset(x: buttonRect.minX, y: buttonRect.minY)
                                .blendMode(.destinationOut)
                        }
                }
                .ignoresSafeArea()
            }

            // Step 3: Render the theme toggle button
            .overlay(alignment: config.sourceAlignment) {
                Button {
                    toggleDarkMode.toggle()
                } label: {
                    image
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: config.iconSize, height: config.iconSize)
                        .foregroundStyle(toggleDarkMode ? config.iconDarkModeColor : config.iconLightModeColor)
                        .frame(width: config.buttonSize, height: config.buttonSize)
                }
                .rect {
                    buttonRect = $0
                }
                .padding(.leading, config.sourcePaddingLeading)
                .padding(.trailing, config.sourcePaddingTrailing)
                .padding(.top, config.sourcePaddingTop)
                .padding(.bottom, config.sourcePaddingBottom)
                .offset(config.sourceOffset)
                .ignoresSafeArea()
                .disabled(currentImage != nil || previousImage != nil || maskAnimation)
            }
    }

    // MARK: - Private Helper

    /// Resolves the appropriate icon to display based on the current theme and configuration.
    private var image: Image {
        if config.isSymbolImage {
            Image(systemName: toggleDarkMode ? config.darkModeImage : config.lightModeImage)
        } else {
            Image(toggleDarkMode ? config.darkModeImage : config.lightModeImage)
        }
    }
}

/// A collection of view utilities to assist with capturing geometry and UI snapshots.
///
/// These extensions are typically used in support of view transitions or dynamic theming.
///
/// - Note: These are marked `fileprivate` to restrict usage to the defining file.
///         If broader access is required, consider making them `internal` or `public`.

fileprivate extension View {
    /// Creates snapshot images of the root view before and after toggling dark mode.
    ///
    /// This is used to visually animate the transition between light and dark appearance
    /// using masked view overlays. The function captures two screenshots — one before the theme switch
    /// and one after — and assigns them to the respective bindings.
    ///
    /// - Parameters:
    ///   - toggleDarkMode: The new theme state (`true` for dark, `false` for light).
    ///   - currentImage: A binding to store the screenshot *after* the theme switch.
    ///   - previousImage: A binding to store the screenshot *before* the theme switch.
    ///   - activateDarkMode: A binding that toggles the app's dark mode activation.
    ///
    /// - Important: This method relies on `UIApplication.shared` and the root view controller
    ///              to capture the top-level view. Ensure the view hierarchy is fully rendered.
    ///
    /// ### Example Usage
    /// ```swift
    /// myView.createImages(
    ///     toggleDarkMode: isDark,
    ///     currentImage: $current,
    ///     previousImage: $previous,
    ///     activateDarkMode: $darkMode
    /// )
    /// ```
    ///
    /// - Note: This operation is asynchronous and introduces a small delay (`0.01s`) to allow rendering.
    @MainActor
    @ViewBuilder
    func createImages(
        toggleDarkMode: Bool,
        currentImage: Binding<UIImage?>,
        previousImage: Binding<UIImage?>,
        activateDarkMode: Binding<Bool>
    ) -> some View {
        self
            .onChange(of: toggleDarkMode) { oldValue, newValue in
                Task {
                    guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?
                            .windows.first(where: { $0.isKeyWindow }),
                          let rootView = window.rootViewController?.view
                    else { return }

                    let frameSize = rootView.frame.size

                    // Overlay snapshot before dark mode switch
                    let imageView = UIImageView()
                    imageView.frame = window.bounds
                    imageView.image = rootView.image(frameSize)
                    imageView.contentMode = .scaleAspectFit
                    window.addSubview(imageView)

                    // Step 1: Capture previous image before toggle
                    activateDarkMode.wrappedValue = !newValue
                    try await Task.sleep(for: .milliseconds(100))
                    previousImage.wrappedValue = rootView.image(frameSize)

                    // Step 2: Toggle dark mode ON/OFF
                    activateDarkMode.wrappedValue = newValue
                    try await Task.sleep(for: .milliseconds(150)) // Ensure UI has updated

                    // Step 3: Capture new image after toggle
                    currentImage.wrappedValue = rootView.image(frameSize)

                    // Step 4: Clean up the temporary image overlay
                    imageView.removeFromSuperview()
                }
            }
    }

}
