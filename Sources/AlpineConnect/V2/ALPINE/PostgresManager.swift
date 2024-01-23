//
//  PostgresManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation
import PostgresClientKit

public class PostgresManager {
    
    public var pool: ConnectionPool?
    
    init(_ info: PostgresInfo, credentials: CredentialsData, dbName: String) {
        
        var connectionPoolConfiguration = ConnectionPoolConfiguration()
        connectionPoolConfiguration.maximumConnections = 10
        connectionPoolConfiguration.maximumPendingRequests = nil
        connectionPoolConfiguration.pendingRequestTimeout = info.timeout
        connectionPoolConfiguration.allocatedConnectionTimeout = info.timeout
        connectionPoolConfiguration.dispatchQueue = DispatchQueue.global()
        connectionPoolConfiguration.metricsResetWhenLogged = false

        var configuration = PostgresClientKit.ConnectionConfiguration()
        configuration.host = info.host
        configuration.database = dbName
        configuration.user = credentials.email
        configuration.credential = .scramSHA256(password: credentials.password)
        configuration.applicationName = dbName
        
        pool = ConnectionPool(connectionPoolConfiguration: connectionPoolConfiguration, connectionConfiguration: configuration)
    }
}
