//
//  TrackingManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/6/22.
//

import Foundation
import PostgresClientKit

public struct ConnectionInfo {
    var host: String = "alpine-database-1.cz1ugaicrz33.us-west-1.rds.amazonaws.com"
    var database: String = "iOS_maintenance"
    var user = "postgres"
    var password = "i$mppWMB$I7Y4XoD"
}

public class TrackingManager {
    
    static let shared = TrackingManager()
    static let sharedWithNoTimeout = TrackingManager(noTimeout: true)
    var pool: ConnectionPool?
    
    init(noTimeout: Bool = false) {
        let ci = ConnectionInfo()
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
        configuration.credential = .md5Password(password: ci.password)
        configuration.applicationName = "AlpineConnect"
        pool = ConnectionPool(
                   connectionPoolConfiguration: connectionPoolConfiguration,
                   connectionConfiguration: configuration)
    }
}
