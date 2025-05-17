//
//  SkeletonShimmer 2.swift
//  UtilityKit
//
//  Created by Vijay Thakur on 17/05/25.
//

import SwiftUI

@available(iOS 17.0, *)
public struct SkeletonShimmer<S: Shape>: View {
    public var shape: S
    public var color: Color
    public init(_ shape: S, _ color: Color = .gray.opacity(0.3)) {
        self.shape = shape
        self.color = color
    }
    
    @State public var isAnimating: Bool = false
    public var body: some View {
        shape
            .fill(color)
            .overlay {
                GeometryReader{
                    let size = $0.size
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
    
    public var rotation: Double {
        return 5
    }
    
    public var animation: Animation {
        .easeInOut(duration: 1.5).repeatForever(autoreverses: false)
    }
}
