//
//  TrackingManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/6/22.
//

import Foundation
import PostgresClientKit
import NIO
import NIOSSL

public struct TrackerConnectionInfo {
    
    static var shared = TrackerConnectionInfo()
    
    var host: String = "alpine-database-1.cz1ugaicrz33.us-west-1.rds.amazonaws.com"
    var port = 5432
    var database: String = "iOS_maintenance"
    var user = "ios_maintenance"
    var password = ""
    let postgresSSLServerName: String? = nil
}

public class TrackingManager {
    
    static public let shared = TrackingManager()
    
    public var pool: ConnectionPool?
   
    
    public init() {
        let environment = TrackerConnectionInfo.shared
        
        var connectionPoolConfiguration = ConnectionPoolConfiguration()
        connectionPoolConfiguration.maximumConnections = 10
        connectionPoolConfiguration.maximumPendingRequests = 60
        connectionPoolConfiguration.pendingRequestTimeout = nil
        connectionPoolConfiguration.allocatedConnectionTimeout = nil
        connectionPoolConfiguration.dispatchQueue = DispatchQueue.global()
        connectionPoolConfiguration.metricsResetWhenLogged = false
        
        let sslContext = try! NIOSSLContext(
            configuration: .makeClientConfiguration(certificateVerification: .none))
        
        let factory = try! DefaultConnectionFactory(eventLoopGroup: MultiThreadedEventLoopGroup(numberOfThreads: 1))
        factory.host = environment.host
        factory.port = environment.port
        factory.ssl = false
        factory.database = environment.database
        factory.sslContext = sslContext
        factory.sslServerName = environment.postgresSSLServerName
        
        pool = ConnectionPool(
            connectionPoolConfiguration: connectionPoolConfiguration,
            connectionFactory: factory,
            user: environment.user,
            credential: .md5Password(password: environment.password),
            connectionDelegate: nil
        )
    }
}
