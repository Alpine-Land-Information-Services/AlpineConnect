//
//  Exportable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/17/23.
//

import CoreData
import PostgresClientKit

public protocol Exportable: Syncable {
    
    static func insertQuery(for objects: [Self], in context: NSManagedObjectContext) -> String
    static func getAllExportable(in context: NSManagedObjectContext) -> [Self]
    static func modifyExportable(_ objects: [Self])
    static func additionalActionsAfterExport()
}

public extension Exportable {
    static var exportable: any Exportable.Type {
        return self as any Exportable.Type
    }
}

public extension Exportable {
    
    static func export(with connection: Connection, in context: NSManagedObjectContext) -> Bool {
        let objects = Self.getAllExportable(in: context)
        SyncTracker.shared.makeRecord(name: Self.entityDisplayName, type: .export, recordCount: objects.count)

        guard objects.count > 0 else {
            return true
        }

        let query = Self.insertQuery(for: objects, in: context)
        var result = false

        do {
            print(query)

            let statement = try connection.prepareStatement(text: query)
            defer { statement.close() }
            let cursor = try statement.execute()
            defer { cursor.close() }

            Self.modifyExportable(objects)
            Self.additionalActionsAfterExport()
            try context.save()

            SyncTracker.shared.endRecordSync()
            result = true

        } catch {
            AppControl.makeError(onAction: "\(Self.entityName) Export", error: error)
        }

        return result
    }
    
    static func getAllExportable(in context: NSManagedObjectContext) -> [Self] {
        Self.findObjects(by: NSPredicate(format: "changed = true"), in: context) as? [Self] ?? []
    }
    
    static func modifyExportable(_ objects: [Self]) {
        for object in objects {
            object.setValue(false, forKey: "changed")
        }
    }
    
    static func additionalActionsAfterExport() {}
}
