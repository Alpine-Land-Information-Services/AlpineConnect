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
    
    static var isSavedIndependently: Bool { get }
    
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
    }
}
