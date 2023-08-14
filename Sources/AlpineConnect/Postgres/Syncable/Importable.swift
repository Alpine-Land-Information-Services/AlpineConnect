//
//  Importable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/17/23.
//

import CoreData
import AlpineCore
import PostgresClientKit

public protocol Importable: Syncable {
    
    static var pgTableName: String { get }
    static var selectQuery: String { get }
    static var shallCountRecords: Bool { get }
    
    static func needUpdate(in context: NSManagedObjectContext) -> Bool
    static func processPGResult(cursor: Cursor, in context: NSManagedObjectContext) throws
}

public extension Importable {
    static var importable: Importable.Type {
        self as Importable.Type
    }
}

public extension Importable {
    
    static func needUpdate(in context: NSManagedObjectContext) -> Bool {
        true
    }
    
    static var shallCountRecords: Bool { true }
}

public extension Importable {
    
    static func sync(with connection: Connection, in context: NSManagedObjectContext) -> Bool {
        guard Self.needUpdate(in: context) else {
            syncManager.tracker.makeRecord(name: Self.displayName, type: .import, recordCount: 0)
            return true
        }

        let text = Self.selectQuery
        var result = false
        
        defer { syncManager.currentQuery = "" }
        do {
            syncManager.currentQuery = text
            if shallCountRecords {
                let recCount = try getRecordsCount(query: text, connection: connection)
                syncManager.tracker.makeRecord(name: Self.displayName, type: .import, recordCount: recCount)
                
                guard recCount != 0 else { return true }
            }
            else {
                print("---------------->>> \(Self.entityName)")
            }
                        
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            try Self.processPGResult(cursor: cursor, in: context)
            try context.persistentSave()
            
            syncManager.tracker.endRecordSync()
            result = true
            
        } catch {
            AppControl.makeError(onAction: "\(Self.entityName) Import", error: error, customDescription: syncManager.currentQuery)
        }
        
        return result
    }
    
    static func getRecordsCount(query: String, connection: Connection) throws -> Int {
        let c_text = "select count(*) from (\(query)) as temp"
        let c_statement = try connection.prepareStatement(text: c_text)
        defer { c_statement.close() }
        let c_cursor = try c_statement.execute()
        defer { c_cursor.close() }
        var recCount: Int = 0
        for row in c_cursor {
            recCount = try row.get().columns[0].int()
        }
        print("---------------->>> \(Self.entityName): \(recCount)")
        
        return recCount
    }
    
    static func loop(with cursor: Cursor, actions: (_ row: Result<Row, Error>) throws -> ()) throws {
        for row in cursor {
            syncManager.tracker.progressUpdate()
            try actions(row)
        }
    }
}
