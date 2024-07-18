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
import AlpineCore

@Observable
public class NetworkMonitor {
    
    @available(*, deprecated, message: "Use AlpineCore NetworkTracker")
    static public let shared = NetworkMonitor()
    
    public enum ConnectionType: String {
        case offline
        case wifi
        case cellular
    }
    
    public var connectionType = ConnectionType.offline
    
    public var connected = false
    
    public static var serverURL = "https://alpinebackyard20220722084741.azurewebsites.net/"
    public static var storageURL = "https://alpine-storage.azurewebsites.net"
    
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

    func canConnectToWebsite(_ website: String = "www.alpine-lis.com", completion: @escaping (Bool) -> Void) {
        let host = NWEndpoint.Host(website)
        let connection = NWConnection(host: host, port: .http, using: .tcp)
        
        connection.stateUpdateHandler = { connection in
            switch connection {
            case .ready:
                completion(true)
            case .waiting(let error):
                print("\(error)")
            case .failed(let error):
                print("\(error)")
            default:
                break
            }
        }
        
        connection.start(queue: .global())
        
        let deadline = DispatchTime.now() + .seconds(10)
        DispatchQueue.global().asyncAfter(deadline: deadline) {
            connection.cancel()
            completion(false)
        }
    }
    
    func canConnectToServer(_ server: String = Login.serverURL, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: server) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion((200...299).contains(httpResponse.statusCode))
            } else {
                completion(false)
            }
        }
        task.resume()
    }
    
    public func canConnectToServer(_ server: String = serverURL) async -> Bool {
        guard connected else { return false }
        
        return await withCheckedContinuation { continuation in
            canConnectToServer { connection in
                continuation.resume(returning: connection)
            }
        }
    }
}

public extension NetworkMonitor {
    
    func connectedAction(action: () -> Void) {
        guard connected else {
            Core.makeSimpleAlert(title: "Offline", message: "Network connection is required for this action.")
            return
        }
        
        action()
    }
}
