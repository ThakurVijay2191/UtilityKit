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
    @ObservedObject private var networkMonitor: NetworkMonitor
    
    public init(networkMonitor: NetworkMonitor,@ViewBuilder _ content: @escaping ()->MainContent) {
        self.networkMonitor = networkMonitor
        self.content = content
    }
    public var body: some View {
        content()
            .environment(\.isNetworkConnected, networkMonitor.isConnected)
            .environment(\.connectionType, networkMonitor.connectionType)
    }
}
