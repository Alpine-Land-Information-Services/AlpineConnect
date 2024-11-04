//
//  PostgresManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation
import PostgresClientKit
import NIO
import NIOSSL

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

        let sslContext = try! NIOSSLContext(
            configuration: .makeClientConfiguration(certificateVerification: .none))
        
        let factory = try! DefaultConnectionFactory(eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1))
        factory.host = info.host
        factory.port = info.port
        factory.ssl = false
        factory.database = info.databaseName
        factory.sslContext = sslContext
        factory.sslServerName = info.postgresSSLServerName
        
        
        pool = ConnectionPool(
            connectionPoolConfiguration: connectionPoolConfiguration,
            connectionFactory: factory,
            user: credentials.email,
            credential: .md5Password(password: credentials.password),
            connectionDelegate: nil
        )
    }
    
    
}
