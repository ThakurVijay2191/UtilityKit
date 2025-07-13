//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Apple on 22/06/25.
//

import SwiftUI

/// A custom SwiftUI view that displays a circular button which morphs into a full-screen modal.
/// The button animates from its original position into a full-screen cover, showing either the label or content based on state.
public struct MorphingButton<Label: View, Content: View>: View {
    
    /// Controls whether the full-screen modal is presented.
    @Binding var isMenusPresented: Bool
    
    /// The background color used for both the button and the full-screen container.
    var backgroundColor: Color
    
    /// The view used as the circular button's label.
    @ViewBuilder var label: () -> Label
    
    /// The content to display in the full-screen modal once it morphs.
    @ViewBuilder var content: () -> Content
    
    public init(
        isMenusPresented: Binding<Bool>,
        backgroundColor: Color,
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content,
    ) {
        self._isMenusPresented = isMenusPresented
        self.backgroundColor = backgroundColor
        self.label = label
        self.content = content
    }
    
    /// Tracks whether to animate and show the full content or keep showing the label inside full-screen.
    @State private var animateContent: Bool = false
    
    /// Stores the global position and size of the button for transition animation.
    @State private var viewPosition: CGRect = .zero
    
    public var body: some View {
        label()
            .background(backgroundColor)
            .clipShape(.circle)
            .contentShape(.circle)
            /// Captures the frame of the button in global space.
            .onGeometryChange(for: CGRect.self, of: {
                $0.frame(in: .global)
            }, action: { newValue in
                viewPosition = newValue
            })
        
            .opacity(isMenusPresented ? 0 : 1)
        
            /// Tap toggles the full-screen presentation.
            .onTapGesture {
                toggleFullScreenCover(false, status: true)
            }
        
            /// Displays the full-screen modal.
            .fullScreenCover(isPresented: $isMenusPresented) {
                ZStack(alignment: .topLeading) {
                    
                    /// Shows animated content or the label depending on animation state.
                    if animateContent {
                        content()
                            .transition(.blurReplace)
                    } else {
                        label()
                            .transition(.blurReplace)
                    }
                }
                .geometryGroup()
                
                /// Applies corner radius to the full-screen view.
                .clipShape(.rect(cornerRadius: 30, style: .continuous))
                
                /// Adds background color to full-screen modal.
                .background {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(backgroundColor)
                }
                
                /// Adds padding when content is fully expanded.
                .padding(animateContent ? 15 : 0)
                .padding(animateContent ? 5 : 0)
                
                /// Expands to full screen when content is active, otherwise aligns to original button position.
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: animateContent ? .bottom : .topLeading
                )
                
                /// Morph transition from button location to fullscreen.
                .offset(
                    x: animateContent ? 0 : viewPosition.minX,
                    y: animateContent ? 0 : viewPosition.minY
                )
                .ignoresSafeArea(animateContent ? [] : .all)
                
                /// Dismisses modal on tap outside if content is shown.
                .background {
                    Rectangle()
                        .fill(.black.opacity(animateContent ? 0.05 : 0))
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.snappy(duration: 0.35, extraBounce: 0.1), completionCriteria: .removed) {
                                animateContent = false
                            } completion: {
                                toggleFullScreenCover(false, status: false)
                            }
                        }
                }
                
                /// Delays and animates content morph after modal appears.
                .task {
                    try? await Task.sleep(for: .seconds(0.05))
                    withAnimation(.snappy(duration: 0.35, extraBounce: 0.1)) {
                        animateContent = true
                    }
                }
            }
    }
    
    /// Toggles the full-screen cover with optional animation.
    /// - Parameters:
    ///   - withAnimation: Whether the change should animate.
    ///   - status: Whether the modal should be shown or hidden.
    private func toggleFullScreenCover(_ withAnimation: Bool, status: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = !withAnimation
        withTransaction(transaction) {
            isMenusPresented = status
        }
    }
}

