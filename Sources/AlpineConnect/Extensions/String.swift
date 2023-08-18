//
//  String.swift
//  AlpineConnect
//
//  Created by mkv on 5/9/23.
//

import Foundation

public func escapeForSql(_ string: String) -> String {
    let str = string.replacingOccurrences(of: "'", with: "''")
    return str
}

public extension String {
    
    var postgresEscaped: String {
        return replacingOccurrences(of: "'", with: "''")
    }
}
