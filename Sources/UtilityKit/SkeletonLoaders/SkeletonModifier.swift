//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Vijay Thakur on 17/05/25.
//

import SwiftUI

extension View {
    func skeleton(isRedacted: Bool)-> some View {
        self
            .modifier(SkeletonShimmerModifier(isRedacted: isRedacted))
    }
}

fileprivate struct SkeletonShimmerModifier: ViewModifier {
    var isRedacted: Bool
    @State private var isAnimating: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    func body(content: Content) -> some View {
        content
            .redacted(reason: isRedacted ? .placeholder : [])
            .overlay {
                if isRedacted{
                    GeometryReader{
                        let size = $0.size
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
    
    var rotation: Double {
        return 5
    }
    
    var animation: Animation {
        .easeInOut(duration: 1.5).repeatForever(autoreverses: false)
    }
}

struct SampleView: View {
    var body: some View {
        Rectangle()
            .fill(.red)
            .frame(height: 400)
            .skeleton(isRedacted: true)
            .padding(20)
    }
}

#Preview {
    SampleView()
}
