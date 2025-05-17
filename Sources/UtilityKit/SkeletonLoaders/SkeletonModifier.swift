//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Vijay Thakur on 17/05/25.
//

import SwiftUI

@available(iOS 17.0, *)
/// A SwiftUI View extension that adds a skeleton loading shimmer effect for redacted views.
public extension View {
    /// Applies a skeleton shimmer effect to the view when the given condition is true.
    /// - Parameter isRedacted: A Boolean value indicating whether the view should be redacted with a shimmer effect.
    /// - Returns: A view with a shimmering skeleton effect if `isRedacted` is true.
    func skeleton(_ isRedacted: Bool) -> some View {
        self
            .modifier(SkeletonShimmerModifier(isRedacted))
    }
}

@available(iOS 17.0, *)
/// A custom ViewModifier for adding a skeleton shimmer effect to any SwiftUI view.
fileprivate struct SkeletonShimmerModifier: ViewModifier {
    private var isRedacted: Bool
    init(_ isRedacted: Bool) {
        self.isRedacted = isRedacted
    }
    @State private var isAnimating: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    /// Builds the modified view with the skeleton shimmer effect if `isRedacted` is true.
    /// - Parameter content: The original content view.
    /// - Returns: A view with an animated shimmer overlay when redacted.
    func body(content: Content) -> some View {
        content
            .redacted(reason: isRedacted ? .placeholder : [])
            .overlay {
                if isRedacted{
                    GeometryReader { geometry in
                        let size = geometry.size
                        let skeletonWidth = size.width / 2
                        let blurRadius = max(skeletonWidth / 2, 30)
                        let blurDiameter = blurRadius * 2
                        let minX = -(skeletonWidth + blurDiameter)
                        let maxX = size.width + skeletonWidth + blurDiameter
                        Rectangle()
                            .fill(colorScheme == .dark ? .white : .black)
                            .frame(width: skeletonWidth, height: size.height * 2)
                            .frame(height: size.height)
                            .blur(radius: blurRadius)
                            .rotationEffect(.init(degrees: rotation))
                            .offset(x: isAnimating ? maxX : minX)
                    }
                    .mask {
                        content
                            .redacted(reason: .placeholder)
                    }
                    .blendMode(.softLight)
                    .task {
                        guard !isAnimating else { return }
                        withAnimation(animation) {
                            isAnimating = true
                        }
                    }
                    .onDisappear {
                        isAnimating = false
                    }
                    .transaction {
                        if $0.animation != animation {
                            $0.animation = .none
                        }
                    }
                }
            }
    }
    
    /// The fixed rotation angle for the shimmer effect.
    var rotation: Double {
        return 5
    }
    
    /// The animation used for the shimmer effect.
    var animation: Animation {
        .easeInOut(duration: 1.5).repeatForever(autoreverses: false)
    }
}
