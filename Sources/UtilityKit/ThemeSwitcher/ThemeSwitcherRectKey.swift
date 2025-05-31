//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Apple on 01/06/25.
//

import SwiftUI

/// A `PreferenceKey` used to propagate a `CGRect` value up the view hierarchy.
///
/// `RectKey` is commonly used in conjunction with a custom view modifier to capture
/// the frame of a view and pass it to a parent for layout or animation purposes.
///
/// This key is designed for single-view frame reporting. If multiple values are provided,
/// the most recent value replaces the previous one.
///
/// Example usage:
/// ```swift
/// extension View {
///     func rect(onChange: @escaping (CGRect) -> Void) -> some View {
///         self
///             .background(
///                 GeometryReader { geometry in
///                     Color.clear
///                         .preference(key: RectKey.self, value: geometry.frame(in: .global))
///                 }
///             )
///             .onPreferenceChange(RectKey.self, perform: onChange)
///     }
/// }
/// ```
///
/// - SeeAlso: `PreferenceKey`, `GeometryReader`
public struct RectKey: @preconcurrency PreferenceKey {

    /// The default value for the preference key, set to `.zero`.
    @MainActor
    public static let defaultValue: CGRect = .zero

    /// Combines multiple values into one. In this implementation, the most recent value replaces the previous one.
    ///
    /// - Parameters:
    ///   - value: The current accumulated value.
    ///   - nextValue: A closure returning the next value to be combined.
    public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
