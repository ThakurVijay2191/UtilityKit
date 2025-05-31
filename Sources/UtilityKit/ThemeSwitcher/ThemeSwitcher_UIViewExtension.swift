//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Apple on 01/06/25.
//

import SwiftUI

/// Captures a snapshot of the current view hierarchy as a `UIImage`.
///
/// This method renders the view’s current visual content into a `UIImage` of the specified size.
///
/// The rendering is done using `UIGraphicsImageRenderer`, which supports high-resolution output
/// and correct context scaling on Retina displays.
///
/// - Important: The method uses `drawHierarchy(in:afterScreenUpdates:)`
///   which includes all subviews, transforms, and visual effects (e.g., shadows, blurs, etc.).
///
/// - Parameter size: The size of the image to render. This should typically match
///   or scale proportionally to the view’s current bounds.
/// - Returns: A `UIImage` snapshot of the view’s visual hierarchy.
///
/// ### Example
/// ```swift
/// let image = myView.image(CGSize(width: 200, height: 200))
/// UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
/// ```
extension UIView {
    /// Renders the view hierarchy as a `UIImage` with the given size.
    ///
    /// - Parameter size: The size of the output image.
    /// - Returns: A `UIImage` representing the rendered view hierarchy.
    func image(_ size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            drawHierarchy(in: .init(origin: .zero, size: size), afterScreenUpdates: true)
        }
    }
}
