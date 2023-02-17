//
//  Syncable.swift
//  AlpineConnect
//
//  Created by mkv on 2/6/23.
//

import CoreData
import PostgresClientKit

public protocol Syncable: NSManagedObject {
    
    static var pgTableName: String { get }
    static var pgSelectText: String { get }
    static var countRecords: Bool { get }
    
    static func needUpdate() -> Bool
    static func processPGResult(cursor: Cursor) throws
}

public extension Syncable {
    static var type: Syncable.Type {
        return self as Syncable.Type
    }
}

public extension Syncable {
    static func needUpdate() -> Bool {
        true
    }
    
    static var countRecords: Bool {
        true
    }
}

public extension Syncable {
    
    static func sync(with connection: Connection, in context: NSManagedObjectContext) -> Bool {
        guard Self.needUpdate() else {
            SyncTracker.shared.makeRecord(name: Self.entityName, recordCount: 0)
            return true
        }

        let text = Self.pgSelectText
        var result = false
        
        do {
            if Self.countRecords {
                let recCount = try getRecordsCount(query: text, connection: connection)
                SyncTracker.shared.makeRecord(name: Self.entityName, recordCount: recCount)
                
                guard recCount != 0 else { return true }
            }
            else {
                print("---------------->>> \(Self.entityName)")
            }
            
            print(text)
            
            let statement = try connection.prepareStatement(text: text)
            defer { statement.close() }
            let cursor = try statement.execute()
            defer { cursor.close() }
            
            try Self.processPGResult(cursor: cursor)
            try context.save()
            
            SyncTracker.shared.endRecordSync()
            result = true
            
        } catch {
            AppControl.makeError(onAction: "\(Self.entityName) Import", error: error)
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
            SyncTracker.shared.progressUpdate()
            try actions(row)
        }
    }
}
