//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Vijay Thakur on 17/05/25.
//

import SwiftUI

@available(iOS 17.0, *)
/// A SwiftUI view that provides a context menu with both a preview and actions, similar to the native iOS context menu.
public struct ContextMenu<Content: View, Preview: View>: View{
    private var content: Content
    private var preview: Preview
    private var menu: UIMenu
    
    /// Initializes a new ContextMenu view.
    /// - Parameters:
    ///   - content: The main content view that triggers the context menu.
    ///   - preview: The preview view displayed when the context menu is activated.
    ///   - menu: The UIMenu providing the list of actions available in the context menu.
    public init(@ViewBuilder content: @escaping ()->Content, @ViewBuilder preview: @escaping ()->Preview, @ViewBuilder menu: @escaping ()->UIMenu) {
        self.content = content()
        self.preview = preview()
        self.menu = menu()
    }
    
    /// The body of the ContextMenu, which overlays the provided content with the context menu interaction.
    public var body: some View {
        ZStack {
            content
                .hidden()
                .overlay {
                    ContextMenuHelper(content: content, preview: preview, actions: menu)
                }

        }
    }
}

@available(iOS 17.0, *)
/// A helper UIViewRepresentable that connects SwiftUI views to UIKit context menu functionality.
fileprivate struct ContextMenuHelper<Content: View, Preview: View>: UIViewRepresentable{
    var content: Content
    var preview: Preview
    var actions: UIMenu
    
    /// Initializes a new ContextMenuHelper instance.
    /// - Parameters:
    ///   - content: The main content view wrapped in a UIHostingController.
    ///   - preview: The preview view displayed when the context menu is activated.
    ///   - actions: The UIMenu providing the list of actions available in the context menu.
    init(content: Content, preview: Preview, actions: UIMenu) {
        self.content = content
        self.preview = preview
        self.actions = actions
    }
    
    /// Creates the underlying UIKit UIView with the context menu interaction.
    /// - Parameter context: The context for the UIViewRepresentable.
    /// - Returns: A UIView containing the hosted SwiftUI content and context menu interaction.
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        let hostView = UIHostingController(rootView: content)
        hostView.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            hostView.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostView.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostView.view.heightAnchor.constraint(equalTo: view.heightAnchor),
        ]
        view.addSubview(hostView.view)
        view.addConstraints(constraints)
        let interaction = UIContextMenuInteraction(delegate: context.coordinator)
        view.addInteraction(interaction)
        return view
    }

    /// Updates the UIView when the SwiftUI view state changes.
    /// - Parameters:
    ///   - uiView: The existing UIView instance.
    ///   - context: The context for the UIViewRepresentable.
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates required for this basic implementation.
    }

    /// Creates the coordinator for managing context menu interactions.
    /// - Returns: A Coordinator instance to handle context menu actions.
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    /// Coordinator for handling context menu interactions.
    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var parent: ContextMenuHelper
        init(parent: ContextMenuHelper) {
            self.parent = parent
        }

        /// Provides the context menu configuration, including the preview and actions.
        /// - Parameters:
        ///   - interaction: The context menu interaction requesting a configuration.
        ///   - location: The location of the interaction within the view.
        /// - Returns: A UIContextMenuConfiguration for the context menu.
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            return UIContextMenuConfiguration(identifier: nil) {
                let previewView = self.parent.preview
                let hostingController = UIHostingController(rootView: previewView)

                // Make the background clear to avoid the white square
                hostingController.view.backgroundColor = .clear
                // Set preferred content size to match the SwiftUI view's size
                hostingController.preferredContentSize = (hostingController.view.intrinsicContentSize)
                hostingController.view.clipsToBounds = false
                hostingController.view.layer.masksToBounds = false
                return hostingController
            } actionProvider: { items in
                return self.parent.actions
            }
        }
    }
}
