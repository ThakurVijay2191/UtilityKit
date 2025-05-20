//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 20/05/25.
//

import SwiftUI

@available(iOS 17.0, *)
public struct NetworkMonitorView<MainContent: View>: View {
    private var content: ()->MainContent
    @State private var networkMonitor: NetworkMonitor = .init()
    
    public init(@ViewBuilder _ content: @escaping ()->MainContent) {
        self.content = content
    }
    public var body: some View {
        content()
            .environment(\.isNetworkConnected, networkMonitor.isConnected)
            .environment(\.connectionType, networkMonitor.connectionType)
    }
}
