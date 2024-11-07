//
//  ExecutionHelper.swift
//  
//
//  Created by mkv on 3/8/23.
//

import CoreData
//import PostgresClientKit

public protocol ExecutionHelper {
    
    static var syncManager: SyncManager { get }
    
    static func performWork(with postgresManager: PostgresManager, in context: NSManagedObjectContext) async throws
}
