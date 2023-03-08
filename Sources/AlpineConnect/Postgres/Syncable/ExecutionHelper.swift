//
//  ExecutionHelper.swift
//  
//
//  Created by mkv on 3/8/23.
//

import PostgresClientKit

public protocol ExecutionHelper {
    static func performWork(in connection: Connection) throws
}

