//
//  TrackingManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 4/6/22.
//

import Foundation
import PostgresNIO
//import PostgresClientKit

public struct TrackerConnectionInfo {
    
    static var shared = TrackerConnectionInfo()
    
    var host: String = "alpine-database-1.cz1ugaicrz33.us-west-1.rds.amazonaws.com"
    var database: String = "iOS_maintenance"
    var user = "ios_maintenance"
    var password = ""
}


public class TrackingManager {
    
    private let client: PostgresClient
    //        let logger = Logger(label: "com.alpineconnect.postgres")
    private init(client: PostgresClient) {
        self.client = client
    }

    public static func createInstance() async throws -> TrackingManager {
        let credentials = TrackerConnectionInfo.shared
        
        let config = PostgresClient.Configuration(
            host: credentials.host,
            port: 5432,
            username: credentials.user,
            password: credentials.password,
            database: credentials.database,
            tls: .disable
        )

        let client = PostgresClient(configuration: config)
        
        await withTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask {
                await client.run()
            }
        }
        return TrackingManager(client: client)
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
