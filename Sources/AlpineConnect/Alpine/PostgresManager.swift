//
//  PostgresManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 12/7/23.
//

import Foundation
import PostgresNIO

public class PostgresManager {
    
    private let client: PostgresClient
    //        let logger = Logger(label: "com.alpineconnect.postgres")
    
    init(_ info: PostgresInfo, credentials: CredentialsData) async throws {
     
        let config = PostgresClient.Configuration(
            host: info.host,
            port: 5432,
            username: credentials.email,
            password: credentials.password,
            database: info.databaseName,
            tls: .disable
        )
        
        self.client = PostgresClient(configuration: config)
        
        await runAndCancel(client: client)
    }
    
    func runAndCancel(client: PostgresClient) async {
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask {
                await client.run()
            }
//            taskGroup.cancelAll()
        }
    }

    public func querySequence(_ sql: String, bindValues: [Encodable] = []) async throws -> PostgresRowSequence {
        var bindings = PostgresBindings()
        
        try bindValues.forEach { value in
            switch value {
            case let intValue as Int:
                bindings.append(intValue)
            case let stringValue as String:
                bindings.append(stringValue)
            case let doubleValue as Double:
                bindings.append(doubleValue)
            case let uuidValue as UUID:
                bindings.append(uuidValue)
            case let dateValue as Date:
                bindings.append(dateValue)
            default:
                throw NSError(domain: "Unsupported bind value type", code: 0, userInfo: nil)
            }
        }
        
        let query = PostgresQuery(unsafeSQL: sql, binds: bindings)

        return try await client.query(query, logger: nil)
    }
    
    public func queryRows(_ sql: String, bindValues: [Encodable] = []) async throws -> [PostgresRow] {
        return try await querySequence(sql, bindValues: bindValues).collect()
    }
    
 
}


//public class PostgresManager {
//
//    private let eventLoopGroup: EventLoopGroup
//    private let configuration: PostgresConnection.Configuration
//    private let logger: Logger
//    private var connectionIDCounter: Int = 0
//    
//    init(_ info: PostgresInfo, credentials: CredentialsData) {
//        // Инициализация группы событий для асинхронных задач
//        self.eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
//        
//        // Инициализация логгера
//        self.logger = Logger(label: "com.alpineconnect.postgres")
//        
//        configuration = PostgresConnection.Configuration(
//            host: info.host,
////            port: 5432  // стандартный порт для PostgreSQL
//            username: credentials.email,
//            password: credentials.password,
//            database: info.databaseName,
//            tls: .disable
//        )
//    }
//    
//    deinit {
//        try? eventLoopGroup.syncShutdownGracefully()
//    }
//    
//    func getConnection() async throws -> PostgresConnection {
//        // Увеличиваем счетчик для уникального ID
//        connectionIDCounter += 1
//        let connectionID = connectionIDCounter
//        
//        // Создаём и возвращаем новое подключение с уникальным ID и логгером
//        return try await PostgresConnection.connect(
//            on: eventLoopGroup.next(),
//            configuration: configuration,
//            id: connectionID,
//            logger: logger
//        )
//    }
//}

//public class PostgresManager {
//    
//    public var pool: ConnectionPool?
//    
//    init(_ info: PostgresInfo, credentials: CredentialsData) {
//        
//        var connectionPoolConfiguration = ConnectionPoolConfiguration()
//        connectionPoolConfiguration.maximumConnections = 10
//        connectionPoolConfiguration.maximumPendingRequests = nil
//        connectionPoolConfiguration.pendingRequestTimeout = info.timeout
//        connectionPoolConfiguration.allocatedConnectionTimeout = info.timeout
//        connectionPoolConfiguration.dispatchQueue = DispatchQueue.global()
//        connectionPoolConfiguration.metricsResetWhenLogged = false
//        connectionPoolConfiguration.metricsLoggingInterval = nil
//
//        var configuration = PostgresClientKit.ConnectionConfiguration()
//        configuration.host = info.host
//        configuration.database = info.databaseName
//        configuration.user = credentials.email
//        configuration.credential = .scramSHA256(password: credentials.password)
//        configuration.applicationName = info.databaseName
//        
//        pool = ConnectionPool(connectionPoolConfiguration: connectionPoolConfiguration, connectionConfiguration: configuration)
//    }
//}
//
