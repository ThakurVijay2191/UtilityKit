//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 20/05/25.
//

import SwiftUI

public struct NetworkMonitorView<MainContent: View>: View {
    @ViewBuilder public var content: MainContent
    @State public var networkMonitor: NetworkMonitor = .init()
    public var body: some View {
        content
            .environment(\.isNetworkConnected, networkMonitor.isConnected)
            .environment(\.connectionType, networkMonitor.connectionType)
    }
}
