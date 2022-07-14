//
//  NetworkMonitor.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import Foundation
import Network

public class NetworkMonitor: ObservableObject {
    
    static public let shared = NetworkMonitor()
    
    @Published public var connected = false
    public var action: (() -> Void)?

    public func start() {
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.connected = true
                if let action = self.action {
                    action()
                }
            }
            else {
                self.connected = false
            }
        }
    }
}
