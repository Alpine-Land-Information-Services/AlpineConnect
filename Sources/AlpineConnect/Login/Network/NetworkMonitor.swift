//
//  NetworkMonitor.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import Foundation
import Network

public class NetworkMonitor {
    
    static public let shared = NetworkMonitor()
    
    public var connected = false

    public func start() {
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.connected = true
            }
            else {
                self.connected = false
            }
        }
    }
}
