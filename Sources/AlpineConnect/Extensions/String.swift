//
//  String.swift
//  
//
//  Created by mkv on 5/9/23.
//

import Foundation

public func escapeForSql(_ string: String) -> String {
    let str = string.replacingOccurrences(of: "'", with: "''")
//    str = str.replacingOccurrences(of: "\"", with: "\\\"")
    return str
}
