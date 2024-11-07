//
//  Importable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/17/23.
//
import CoreData
import AlpineCore
import PostgresNIO

public protocol Importable: Syncable {
    
    static var pgTableName: String { get }
    static var selectQuery: String { get }
    static var shallCountRecords: Bool { get }
    
    static func needUpdate(in context: NSManagedObjectContext) -> Bool
    static func processPGResult(rows: PostgresRowSequence, in context: NSManagedObjectContext) async throws
    static func cleanObsoleteData(in context: NSManagedObjectContext) -> Bool
}

public extension Importable {
    static var importable: Importable.Type {
        self as Importable.Type
    }
}

public extension Importable {
    
    static var shallCountRecords: Bool { true }
    
    static func needUpdate(in context: NSManagedObjectContext) -> Bool {
        true
    }
    
    static func cleanObsoleteData(in context: NSManagedObjectContext) -> Bool {
        return false
    }
}

public extension Importable {
    
    static func sync(using postgresManager: PostgresManager, in context: NSManagedObjectContext) async throws {
        guard Self.needUpdate(in: context) else {
            syncManager.tracker.makeRecord(name: Self.displayName, type: .import, recordCount: 0)
            return
        }

        let text = Self.selectQuery
        syncManager.currentQuery = text

        if shallCountRecords {
            let recCount = try await getRecordsCount(query: text, using: postgresManager)
            syncManager.tracker.makeRecord(name: Self.displayName, type: .import, recordCount: recCount)
            guard recCount != 0 else { return }
        } else {
            print("-- import  >>>  \(Self.entityName)")
        }

        let rows = try await postgresManager.querySequence(text)
        try await Self.processPGResult(rows: rows, in: context)
        try context.persistentSave()
        
        syncManager.tracker.endRecordSync()
    }
    
    static func getRecordsCount(query: String, using postgresManager: PostgresManager) async throws -> Int {
        let countQuery = "SELECT count(*) FROM (\(query)) as temp"
        let rows = try await postgresManager.querySequence(countQuery)
        
        if let firstRow = try await rows.first(where: { _ in true }) {
            return try firstRow.decode(Int.self)
        }
        return 0
    }
    
    static func loop(rows: [PostgresRow], actions: (_ row: PostgresRow) throws -> ()) throws {
        for row in rows {
            syncManager.tracker.progressUpdate()
            try actions(row)
        }
    }
}
