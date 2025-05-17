//
//  SkeletonShimmer 2.swift
//  UtilityKit
//
//  Created by Vijay Thakur on 17/05/25.
//

import SwiftUI

@available(iOS 17.0, *)
/// A SwiftUI view that provides a customizable skeleton shimmer effect for any shape.
public struct SkeletonShimmer<S: Shape>: View {
    /// The shape to use for the skeleton shimmer.
    public var shape: S
    /// The base color of the skeleton.
    public var color: Color
    
    /// Initializes a new SkeletonShimmer view.
    /// - Parameters:
    ///   - shape: The shape to use for the skeleton effect (e.g., Circle, Rectangle).
    ///   - color: The base color for the skeleton shimmer. Defaults to a light gray.
    public init(_ shape: S, _ color: Color = .gray.opacity(0.3)) {
        self.shape = shape
        self.color = color
    }
    
    /// State to track the animation status.
    @State public var isAnimating: Bool = false
    
    /// The main body of the SkeletonShimmer view, which applies the shimmer effect to the specified shape.
    public var body: some View {
        shape
            .fill(color)
            .overlay {
                GeometryReader { geometry in
                    let size = geometry.size
                    let skeletonWidth = size.width / 2
                    let blurRadius = max(skeletonWidth / 2, 30)
                    let blurDiameter = blurRadius * 2
                    let minX = -(skeletonWidth + blurDiameter)
                    let maxX = size.width + skeletonWidth + blurDiameter
                    Rectangle()
                        .fill(.gray)
                        .frame(width: skeletonWidth, height: size.height * 2)
                        .frame(height: size.height)
                        .blur(radius: blurRadius)
                        .rotationEffect(.init(degrees: rotation))
                        .blendMode(.softLight)
                        .offset(x: isAnimating ? maxX : minX)
                }
            }
            .clipShape(shape)
            .compositingGroup()
            .onAppear {
                // Start the shimmer animation when the view appears
                guard !isAnimating else { return }
                withAnimation(animation) {
                    isAnimating = true
                }
            }
            .onDisappear {
                // Stop the shimmer animation when the view disappears
                isAnimating = false
            }
            .transaction {
                if $0.animation != animation {
                    $0.animation = .none
                }
            }
    }
    
    /// The fixed rotation angle for the shimmer effect.
    public var rotation: Double {
        return 5
    }
    
    /// The animation used for the shimmer effect.
    public var animation: Animation {
        .easeInOut(duration: 1.5).repeatForever(autoreverses: false)
    }
}
