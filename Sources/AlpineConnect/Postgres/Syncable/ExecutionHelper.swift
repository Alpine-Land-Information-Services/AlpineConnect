//
//  ExecutionHelper.swift
//  
//
//  Created by mkv on 3/8/23.
//

import CoreData
import PostgresClientKit

public protocol ExecutionHelper {
    
    static var syncManager: SyncManager { get }
    
    static func performWork(with connection: Connection, in context: NSManagedObjectContext) throws
}

