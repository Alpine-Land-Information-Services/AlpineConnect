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
    static public var sharedWithTimeOut = NetworkManager(noTimeout: false)
    
    public var pool: ConnectionPool?
    
    public init(noTimeout: Bool = true, database: String? = nil) {
        let info = LoginConnectionInfo.shared
        let userManager = UserManager.shared
        
        var connectionPoolConfiguration = ConnectionPoolConfiguration()
        connectionPoolConfiguration.maximumConnections = 10
        connectionPoolConfiguration.maximumPendingRequests = noTimeout ? nil : 2
        connectionPoolConfiguration.pendingRequestTimeout = noTimeout ? nil : 10
        connectionPoolConfiguration.allocatedConnectionTimeout = noTimeout ? nil : 10
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
        self.sharedWithTimeOut = NetworkManager(noTimeout: false)
    }
}


