//
//  NetworkTracker.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/27/23.
//

import SwiftUI

struct NetworkMonitorModifier: ViewModifier {
    
    var network = NetworkMonitor.shared
    
    var connectAction: (() -> ())?
    var disconnectAction: (() -> ())?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: network.connected) { _, connected in
                switch connected {
                case true:
                    TokenManager.checkToken()
                    if let connectAction {
                        connectAction()
                    }
                case false:
                    if let disconnectAction {
                        disconnectAction()
                    }
                }
            }
    }
}

extension View {
    
    public func networkMonitor(connectAction: (() -> ())? = nil, disconnectAction: (() -> ())? = nil) -> some View {
        self
            .modifier(NetworkMonitorModifier(connectAction: connectAction, disconnectAction: disconnectAction))
    }
}
