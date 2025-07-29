//
//  ResizableHeaderScrollView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 29/07/25.
//
import SwiftUI

/// A SwiftUI view that provides a scrollable view with a resizable header that adjusts its height based on scroll position.
/// The header can be sticky and optionally ignores the top safe area.
///
/// - Parameters:
///   - Header: The type of the header view, conforming to `View`.
///   - Content: The type of the content view, conforming to `View`.
@available(iOS 18, *)
public struct ResizableHeaderScrollView<Header, Content>: View where Header: View, Content: View {
    
    /// The minimum height of the header when fully collapsed.
    /// This value defines the smallest size the header can take during scrolling.
    private var minimumHeight: CGFloat
    
    /// The maximum height of the header when fully expanded.
    /// This value defines the largest size the header can take when not scrolled.
    private var maximumHeight: CGFloat
    
    /// A boolean indicating whether the view ignores the top safe area.
    /// When `true`, the header extends into the top safe area; otherwise, it respects the safe area insets.
    /// Defaults to `false`.
    private var ignoresSafeAreaTop: Bool
    
    /// A boolean indicating whether the header remains sticky during scrolling.
    /// When `true`, the header stays pinned at the top when scrolling past its minimum height.
    /// Defaults to `false`.
    private var isSticky: Bool
    
    /// A view builder closure that provides the header view, taking the scroll progress and safe area insets as parameters.
    /// - Parameters:
    ///   - progress: A value between 0 and 1 indicating the scroll progress, where 0 is fully expanded and 1 is fully collapsed.
    ///   - safeArea: The safe area insets of the parent view, adjusted based on `ignoresSafeAreaTop`.
    /// - Returns: A view of type `Header` to be used as the scrollable header.
    var header: (CGFloat, EdgeInsets) -> Header
    
    /// A view builder closure that provides the content view of the scrollable area.
    /// - Returns: A view of type `Content` to be displayed in the scrollable body.
    var content: () -> Content
    
    /// Initializes a `ResizableHeaderScrollView` with specified height constraints, header behavior, and content views.
    /// - Parameters:
    ///   - minimumHeight: The minimum height of the header when fully collapsed.
    ///   - maximumHeight: The maximum height of the header when fully expanded.
    ///   - ignoresSafeAreaTop: A boolean indicating whether the view ignores the top safe area. Defaults to `false`.
    ///   - isSticky: A boolean indicating whether the header remains pinned at the top during scrolling. Defaults to `false`.
    ///   - header: A view builder closure that provides the header view, taking scroll progress and safe area insets as parameters.
    ///   - content: A view builder closure that provides the scrollable content view.
    ///   - offsetY: The initial vertical scroll offset for tracking the scroll position.
    public init(
        minimumHeight: CGFloat,
        maximumHeight: CGFloat,
        ignoresSafeAreaTop: Bool = false,
        isSticky: Bool = false,
        @ViewBuilder header: @escaping (CGFloat, EdgeInsets) -> Header,
        @ViewBuilder content: @escaping () -> Content,
    ) {
        self.minimumHeight = minimumHeight
        self.maximumHeight = maximumHeight
        self.ignoresSafeAreaTop = ignoresSafeAreaTop
        self.isSticky = isSticky
        self.header = header
        self.content = content
    }
    
    /// The current vertical scroll offset, tracked as a state variable.
    /// This value is updated as the user scrolls and is used to calculate the header's size and position.
    @State private var offsetY: CGFloat = 0
    
    /// The main view composition, defining the scrollable content and resizable header.
    public var body: some View {
        GeometryReader { geometry in
            /// The safe area insets, adjusted based on `ignoresSafeAreaTop`.
            let safeArea = ignoresSafeAreaTop ? geometry.safeAreaInsets : .init()
            
            ScrollView(.vertical) {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Section {
                        /// The scrollable content provided by the `content` closure.
                        content()
                    } header: {
                        GeometryReader { _ in
                            /// The scroll progress, clamped between 0 (fully expanded) and 1 (fully collapsed).
                            let progress: CGFloat = min(max(offsetY / (maximumHeight - minimumHeight), 0), 1)
                            
                            /// The calculated height of the header based on scroll progress and safe area.
                            let resizedHeight = (maximumHeight + safeArea.top) - (maximumHeight - minimumHeight) * progress
                            
                            header(progress, safeArea)
                                .frame(height: resizedHeight, alignment: .bottom)
                                .offset(y: isSticky ? (offsetY < 0 ? offsetY : 0) : 0)
                        }
                        /// The header's frame, including the maximum height and safe area offset.
                        .frame(height: maximumHeight + safeArea.top)
                    }
                }
            }
            /// Configures the scroll view to ignore the top safe area if `ignoresSafeAreaTop` is `true`.
            .ignoresSafeArea(.container, edges: ignoresSafeAreaTop ? [.top] : [])
            /// Tracks changes in scroll geometry to update the `offsetY` state.
            .onScrollGeometryChange(for: CGFloat.self) {
                $0.contentOffset.y + $0.contentInsets.top
            } action: { oldValue, newValue in
                offsetY = newValue
            }
        }
    }
}
