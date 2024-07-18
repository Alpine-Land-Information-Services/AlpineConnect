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
    
    init(_ info: PostgresInfo, credentials: CredentialsData) {
        
        var connectionPoolConfiguration = ConnectionPoolConfiguration()
        connectionPoolConfiguration.maximumConnections = 10
        connectionPoolConfiguration.maximumPendingRequests = nil
        connectionPoolConfiguration.pendingRequestTimeout = info.timeout
        connectionPoolConfiguration.allocatedConnectionTimeout = info.timeout
        connectionPoolConfiguration.dispatchQueue = DispatchQueue.global()
        connectionPoolConfiguration.metricsResetWhenLogged = false
        connectionPoolConfiguration.metricsLoggingInterval = nil

        var configuration = PostgresClientKit.ConnectionConfiguration()
        configuration.host = info.host
        configuration.database = info.databaseName
        configuration.user = credentials.email
        configuration.credential = .scramSHA256(password: credentials.password)
        configuration.applicationName = info.databaseName
        
        pool = ConnectionPool(connectionPoolConfiguration: connectionPoolConfiguration, connectionConfiguration: configuration)
    }
}
