//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 01/08/25.
//

import SwiftUI

/// A customizable glass-like expandable menu that transitions between a label and full content view with animation.
///
/// `ExpandableGlassMenu` is a glass-effect container that expands from a compact `Label` view to a full-size `Content` view,
/// based on the `progress` value. The appearance uses a glass effect, scaling, and blur transitions to deliver a smooth UI interaction.
///
/// Example usage:
/// ```swift
/// ExpandableGlassMenu(alignment: .bottomTrailing, progress: progress) {
///     VStack {
///         Button("Item 1") { }
///         Button("Item 2") { }
///     }
/// } label: {
///     Image(systemName: "plus")
///         .resizable()
///         .frame(width: 20, height: 20)
/// }
/// ```
///
/// - Important: This view requires iOS 26.0 or later.
///
/// - Parameters:
///   - alignment: The anchor point for the menu expansion (e.g., `.bottomTrailing`, `.topLeading`, etc.).
///   - progress: A normalized value (0 to 1) representing the expansion state. `0` = collapsed, `1` = fully expanded.
///   - labelSize: The size of the label view (defaults to 55x55).
///   - cornerRadius: The corner radius of the menu container (defaults to 30).
///   - content: A closure that returns the view shown when the menu is expanded.
///   - label: A closure that returns the view shown when the menu is collapsed.
@available(iOS 26.0, *)
public struct ExpandableGlassMenu<Content: View, Label: View>: View, @MainActor Animatable {

    private var alignment: Alignment
    private var progress: CGFloat
    private var labelSize: CGSize
    private var cornerRadius: CGFloat
    private var content: Content
    private var label: Label

    /// Initializes a new `ExpandableGlassMenu` with the given parameters.
    public init(
        alignment: Alignment,
        progress: CGFloat,
        labelSize: CGSize = .init(width: 55, height: 55),
        cornerRadius: CGFloat = 30,
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.alignment = alignment
        self.progress = progress
        self.labelSize = labelSize
        self.cornerRadius = cornerRadius
        self.content = content()
        self.label = label()
    }

    @State private var contentSize: CGSize = .zero

    /// Supports animation by interpolating the `progress` value.
    public var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    /// The view hierarchy that defines the layout and visual effects for the expandable menu.
    public var body: some View {
        GlassEffectContainer {
            let widthDiff = contentSize.width - labelSize.width
            let heightDiff = contentSize.height - labelSize.height

            let rWidth = widthDiff * contentOpacity
            let rHeight = heightDiff * contentOpacity

            ZStack(alignment: alignment) {
                content
                    .compositingGroup()
                    .scaleEffect(contentScale)
                    .blur(radius: 14 * blurProgress)
                    .opacity(contentOpacity)
                    .onGeometryChange(for: CGSize.self) {
                        $0.size
                    } action: { newValue in
                        contentSize = newValue
                    }
                    .fixedSize()
                    .frame(
                        width: labelSize.width + rWidth,
                        height: labelSize.height + rHeight
                    )

                label
                    .compositingGroup()
                    .blur(radius: 14 * blurProgress)
                    .opacity(1 - labelOpacity)
                    .frame(width: labelSize.width, height: labelSize.height)
            }
            .compositingGroup()
            .clipShape(.rect(cornerRadius: cornerRadius))
            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
        }
        .scaleEffect(
            x: 1 - (blurProgress * 0.35),
            y: 1 + (blurProgress * 0.45),
            anchor: scaleAnchor
        )
        .offset(y: offset * blurProgress)
    }

    /// The opacity of the label view, fading out as the menu expands.
    private var labelOpacity: CGFloat {
        min(progress / 0.35, 1)
    }

    /// The opacity of the content view, fading in as the menu expands.
    private var contentOpacity: CGFloat {
        max(progress - 0.35, 0) / 0.65
    }

    /// Calculates the scaling factor applied to the content as it transitions.
    private var contentScale: CGFloat {
        let minAspectScale = min(labelSize.width / contentSize.width, labelSize.height / contentSize.height)
        return minAspectScale + (1 - minAspectScale) * progress
    }

    /// Calculates the amount of blur based on progress, used for both label and content.
    private var blurProgress: CGFloat {
        progress > 0.5 ? (1 - progress) / 0.5 : progress / 0.5
    }

    /// Determines vertical offset based on alignment, used to animate the container.
    private var offset: CGFloat {
        switch alignment {
        case .bottom, .bottomLeading, .bottomTrailing: return -75
        case .top, .topLeading, .topTrailing: return 75
        default: return 0.0
        }
    }

    /// Determines the anchor point for scaling based on the alignment.
    private var scaleAnchor: UnitPoint {
        switch alignment {
        case .bottomLeading: return .bottomLeading
        case .bottom: return .bottom
        case .bottomTrailing: return .bottomTrailing
        case .topLeading: return .topLeading
        case .top: return .top
        case .topTrailing: return .topTrailing
        case .leading: return .leading
        case .trailing: return .trailing
        default: return .center
        }
    }
}

