//
//  SwiftUIView.swift
//  UtilityKit
//
//  Created by Jagdeep Singh on 20/05/25.
//

import SwiftUI
import Network

public extension EnvironmentValues {
    @Entry var isNetworkConnected: Bool?
    @Entry var connectionType: NWInterface.InterfaceType?
    
}

public class NetworkMonitor: ObservableObject, @unchecked Sendable{
    @Published var isConnected: Bool?
    @Published var connectionType: NWInterface.InterfaceType?
    
    private var queue = DispatchQueue(label: "Monitor")
    private var monitor = NWPathMonitor()
    
    init() {
        startMonitoring()
    }
    
    private func startMonitoring(){
        monitor.pathUpdateHandler = { path in
            Task { @MainActor [weak self] in
                self?.isConnected = (path.status == .satisfied)
                let types: [NWInterface.InterfaceType] = [.wifi, .cellular, .wiredEthernet, .loopback]
                if let type = types.first(where: { path.usesInterfaceType($0)}){
                    self?.connectionType = type
                }else {
                    self?.connectionType = nil
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    public func stopMonitoring(){
        monitor.cancel()
    }
}
