//
//  NetworkManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation
import PostgresClientKit

public class NetworkManager {
    
    static public let shared = NetworkManager()
    static public let sharedWithNoTimeout = NetworkManager(noTimeout: true)
    
    public var pool: ConnectionPool?
    
    public init(noTimeout: Bool = true) {
        let ci = LoginConnectionInfo.shared
        
        var connectionPoolConfiguration = ConnectionPoolConfiguration()
        connectionPoolConfiguration.maximumConnections = 10
        connectionPoolConfiguration.maximumPendingRequests = noTimeout ? nil : 60
        connectionPoolConfiguration.pendingRequestTimeout = noTimeout ? nil : 180
        connectionPoolConfiguration.allocatedConnectionTimeout = noTimeout ? nil : 240
        connectionPoolConfiguration.dispatchQueue = DispatchQueue.global()
        connectionPoolConfiguration.metricsResetWhenLogged = false
        
        var configuration = PostgresClientKit.ConnectionConfiguration()
        configuration.host = ci.host
        configuration.database = ci.database
        configuration.user = ci.user
        configuration.credential = .scramSHA256(password: ci.password)
        configuration.applicationName = ci.application
        
        pool = ConnectionPool(connectionPoolConfiguration: connectionPoolConfiguration, connectionConfiguration: configuration)
    }
}
