//
//  PostgresInfo.swift
//  
//
//  Created by Vladislav on 7/19/24.
//

import Foundation

public struct PostgresInfo {
    
    var timeout: Int?
    var port: Int
    var host: String
    var dbNames: DBNames
    var databaseType: DatabaseType
    var databaseName: String {
        dbNames.getName(from: databaseType)
    }
    var postgresSSLServerName: String?
    
    public init(host: String, port: Int, databaseType: DatabaseType? = nil, dbNames: DBNames, timeout: Int?, postgresSSLServerName: String? = nil) {
        self.host = host
        self.databaseType = databaseType ?? .production
        self.timeout = timeout
        self.dbNames = dbNames
        self.port = port
        self.postgresSSLServerName = postgresSSLServerName
    }
}
