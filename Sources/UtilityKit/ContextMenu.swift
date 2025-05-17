//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Vijay Thakur on 17/05/25.
//

import SwiftUI

@available(iOS 17.0, *)
public struct ContextMenu<Content: View, Preview: View>: View{
    private var content: Content
    private var preview: Preview
    private var menu: UIMenu
    public init(@ViewBuilder content: @escaping ()->Content, @ViewBuilder preview: @escaping ()->Preview, @ViewBuilder menu: @escaping ()->UIMenu) {
        self.content = content()
        self.preview = preview()
        self.menu = menu()
    }
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
fileprivate struct ContextMenuHelper<Content: View, Preview: View>: UIViewRepresentable{
    var content: Content
    var preview: Preview
    var actions: UIMenu
    init(content: Content, preview: Preview, actions: UIMenu) {
        self.content = content
        self.preview = preview
        self.actions = actions
    }
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

    func updateUIView(_ uiView: UIView, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UIContextMenuInteractionDelegate {
        var parent: ContextMenuHelper
        init(parent: ContextMenuHelper) {
            self.parent = parent
        }


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
