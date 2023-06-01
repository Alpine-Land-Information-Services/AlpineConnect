//
//  Exporter.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/26/23.
//

import CoreData
import AlpineCore
import PostgresClientKit

class ExporterTest {
    
    var objectType: NSManagedObject.Type
    
    init(for objectType: NSManagedObject.Type) {
        self.objectType = objectType
    }
    
    deinit {
        print("Releasing Exporter for \(objectType.entityName)")
    }
    
    func export(with connection: Connection, in context: NSManagedObjectContext) throws {
        let batchFetcher = CDBatchFetcher(for: objectType.entityName, using: NSPredicate(format: "a_changed = TRUE"), with: 10)
        try context.performAndWait {
            while let objects = try batchFetcher.fetchObjectBatch(in: context) as? [any Exportable] {
                try export(objects)
            }
        }
    }
}

private extension ExporterTest {
    
    func export(_ objects: [NSManagedObject]) throws {
//        for object in objects {
//            object.observeDeallocation()
//        }
    }
}


class Exporter {

    var objectType: any Exportable.Type
    weak var syncManager: SyncManager!

    init(for objectType: any Exportable.Type, using syncManager: SyncManager) {
        self.objectType = objectType
        self.syncManager = syncManager
    }

    deinit {
        print("Releasing Exporter for \(objectType.entityName)")
    }

    func export(with connection: Connection, in context: NSManagedObjectContext) throws {
        var totalObjectsCount = 0
        try context.performAndWait {
            totalObjectsCount = try objectType.getCount(using: objectType.exportPredicate, in: context)
        }
        syncManager.tracker.makeRecord(name: objectType.displayName, type: .export, recordCount: totalObjectsCount)

        guard totalObjectsCount > 0 else {
            return
        }

        let batchFetcher = CDBatchFetcher(for: objectType.entityName, using: NSPredicate(format: "a_changed = TRUE"), with: 10)
        var objects: [any Exportable]? = []

        repeat {
            try context.performAndWait {
                objects = try batchFetcher.fetchObjectBatch(in: context) as? [any Exportable]
                objects?.forEach { $0.observeDeallocation() }
                if let objects = objects {
                    try export(objects, with: connection)
                }
//                try context.save()
                try context.persistentSave()
            }
        } while objects != nil

        defer { syncManager.currentQuery = "" }

        objectType.additionalActionsAfterExport()
        syncManager.tracker.endRecordSync()
    }
    
//    func export(with connection: Connection, in context: NSManagedObjectContext) throws {
//        var totalObjectsCount = 0
//        try context.performAndWait {
//            totalObjectsCount = try objectType.getCount(using: objectType.exportPredicate, in: context)
//        }
//        syncManager.tracker.makeRecord(name: objectType.displayName, type: .export, recordCount: totalObjectsCount)
//
//        guard totalObjectsCount > 0 else {
//            return
//        }
//
//        let batchFetcher = CDBatchFetcher(for: objectType.entityName, using: objectType.exportPredicate, with: objectType.exportBatchSize)
//        try context.performAndWait {
//            while let objects = try batchFetcher.fetchObjectBatch(in: context) as? [any Exportable] {
//                objects.forEach { $0.observeDeallocation() }
//                try export(objects, with: connection)
//                try context.persistentSave()
//            }
//        }
//
//        defer { syncManager.currentQuery = "" }
//
//        objectType.additionalActionsAfterExport()
//        syncManager.tracker.endRecordSync()
//    }
}





private extension Exporter {

    func export(_ objects: [any Exportable], with connection: Connection) throws {
        for query in objectType.getInsertQueries(for: objects) {
            try execute(query, with: connection)
        }
//        
//        print("Exported")
//        sleep(1)
        syncManager.tracker.progressUpdate(adding: Double(objects.count))
        modifyAfterExport(objects)
    }
    
    func modifyAfterExport(_ objects: [any Exportable]) {
        for object in objects {
            object.setValue(false, forKey: "a_changed")
        }
    }

    func execute(_ query: String, with connection: Connection) throws {
        let statement = try connection.prepareStatement(text: query)
        defer {statement.close()}

        syncManager.currentQuery = query
        try statement.execute()
        try connection.commitTransaction()
    }
}
