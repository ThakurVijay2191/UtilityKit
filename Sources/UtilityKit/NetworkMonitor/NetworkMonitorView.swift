//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 20/05/25.
//

import SwiftUI

struct NetworkMonitorView<MainContent: View>: View {
    @ViewBuilder var content: MainContent
    @State private var networkMonitor: NetworkMonitor = .init()
    var body: some View {
        content
            .environment(\.isNetworkConnected, networkMonitor.isConnected)
            .environment(\.connectionType, networkMonitor.connectionType)
    }
}
