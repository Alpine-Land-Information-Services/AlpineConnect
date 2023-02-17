//
//  NetworkMonitor.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/6/22.
//

import Foundation
import Network
import SwiftUI
import AlpineUI

public class NetworkMonitor: ObservableObject {
    
    static public let shared = NetworkMonitor()
    
    public enum ConnectionType: String {
        case offline
        case wifi
        case cellular
    }
    
    @Published public var connectionType = ConnectionType.offline
    @Published public var connected = false
    
    public func start() {
        let monitor = NWPathMonitor()
        monitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if path.isExpensive {
                    self.changeConnectionType(.cellular)
                }
                else {
                    self.changeConnectionType(.wifi)
                }
                DispatchQueue.main.async {
                    self.connected = true
                }
            }
            else {
                DispatchQueue.main.async {
                    self.connected = false
                }
                self.changeConnectionType(.offline)
            }
        }
    }
    
    func changeConnectionType(_ type: ConnectionType) {
        DispatchQueue.main.async {
            self.connectionType = type
        }
    }
    
    public func checkConnection() -> Bool {
        if connected {
            return true
        }
        AppControl.noConnectionAlert()
        
        return false
    }
}
