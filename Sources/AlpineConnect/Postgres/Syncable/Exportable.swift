//
//  Exportable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/17/23.
//

import CoreData
import PostgresClientKit

public protocol Exportable: Syncable {
        
    static var exportBatchSize: Int { get }
    static var exportPredicate: NSPredicate { get }
    
    static var isSavedIndependently : Bool { get }
    
    static func getInsertQueries(for objects: [any Exportable]) -> [String]
    static func modifyAfterExport(_ objects: [any Exportable])
    static func additionalActionsAfterExport()
    
    func checkMissingRequirements() -> Bool
}

public extension Exportable {
    
    static var exportable: any Exportable.Type {
        self as any Exportable.Type
    }
    
    static var exportBatchSize: Int {
        10
    }
    
    static var isSavedIndependently: Bool {
        false
    }
    
    static var exportPredicate: NSPredicate {
        NSPredicate(format: "a_changed = true")
    }
}

public extension Exportable {
    
    static func convert<Object: Exportable>(from objects: [any Exportable]) -> [Object] {
        objects.compactMap({$0 as? Object})
    }
    
    static func modifyAfterExport(_ objects: [any Exportable]) {
        for object in objects {
            object.setValue(false, forKey: "a_changed")
        }
    }
    
    static func additionalActionsAfterExport() {}
}

public extension Exportable {
    
    static func getAllExportable(in context: NSManagedObjectContext) -> [Self] {
        Self.findObjects(by: NSPredicate(format: "a_changed = true"), in: context) as? [Self] ?? []
//        var objects = [Self]()
//        do {
//            try Self.deleteAllLocal(in: context)
//            objects =
//        }
//        catch {
//            AppControl.makeError(onAction: "Local Objects Delete", error: error)
//        }
//        return objects
    }
}

//public extension Exportable {
//
//    func export(with connection: Connection, in context: NSManagedObjectContext) throws {
//
//        let objects = Object.getAllExportable(in: context)
//        syncManager.tracker.makeRecord(name: Object.displayName, type: .export, recordCount: objects.count)
//        let totalObjectsCount = Object.getCount(for: nil, in: context)
//
//        guard objects.count > 0 else {
//            return true
//        }
//
//        var result = false
//        defer { syncManager.currentQuery = "" }
//
//        do {
//
//
//            Self.additionalActionsAfterExport()
//
//            syncManager.tracker.endRecordSync()
//            result = true
//
//        } catch {
//            AppControl.makeError(onAction: "\(Object.entityName) Export", error: error, customDescription: syncManager.currentQuery)
//        }
//
//        return result
//    }
//}
//
//private extension Exportable {
//
//    static func export(_ objects: [Object], with connection: Connection, in context: NSManagedObjectContext) throws {
//        for query in Self.getInsertQueries(for: objects, in: context) {
//            try execute(query, with: connection)
//        }
//
//        let obj = type(of: objects.first!)
//
//        Self.modifyExportable(type(of: Self))
//    }
//
//    static func execute(_ query: String, with connection: Connection) throws {
//        let statement = try connection.prepareStatement(text: query)
//        defer { statement.close() }
//
//        print(query)
//        syncManager.currentQuery = query
//
//        try statement.execute()
//    }
//}
