//
//  NetworkManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 6/23/22.
//

import Foundation
import PostgresClientKit

public class NetworkManager {
    
    static public var shared = NetworkManager()
    
    public var pool: ConnectionPool?
    
    public init(noTimeout: Bool = true, database: String? = nil) {
        let info = LoginConnectionInfo.shared
        let userManager = UserManager.shared
        
        var connectionPoolConfiguration = ConnectionPoolConfiguration()
        connectionPoolConfiguration.maximumConnections = 10
        connectionPoolConfiguration.maximumPendingRequests = noTimeout ? nil : 60
        connectionPoolConfiguration.pendingRequestTimeout = noTimeout ? nil : 180
        connectionPoolConfiguration.allocatedConnectionTimeout = noTimeout ? nil : 240
        connectionPoolConfiguration.dispatchQueue = DispatchQueue.global()
        connectionPoolConfiguration.metricsResetWhenLogged = false
        
        var configuration = PostgresClientKit.ConnectionConfiguration()
        configuration.host = info.host
        configuration.database = database ?? info.database
        configuration.user = userManager.userName
        configuration.credential = .scramSHA256(password: userManager.password)
        configuration.applicationName = info.appDBName
        
        pool = ConnectionPool(connectionPoolConfiguration: connectionPoolConfiguration, connectionConfiguration: configuration)
    }
    
    static func update() {
        self.shared = NetworkManager()
    }
}
