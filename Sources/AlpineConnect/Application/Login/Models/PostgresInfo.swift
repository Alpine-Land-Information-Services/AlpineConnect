//
//  PostgresInfo.swift
//  
//
//  Created by Vladislav on 7/19/24.
//

import Foundation

public struct PostgresInfo {
    
    var timeout: Int?
    var host: String
    var dbNames: DBNames
    var databaseType: DatabaseType
    var databaseName: String {
        dbNames.getName(from: databaseType)
    }
    
    public init(host: String, databaseType: DatabaseType? = nil, dbNames: DBNames, timeout: Int?) {
        self.host = host
        self.databaseType = databaseType ?? .production
        self.timeout = timeout
        self.dbNames = dbNames
    }
}
