//
//  Exporter.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/26/23.
//

import CoreData
import AlpineCore
import PostgresClientKit

class Exporter {
    
    var objectType: any Exportable.Type
    var syncManager: SyncManager
    
    init(for objectType: any Exportable.Type, using syncManager: SyncManager) {
        self.objectType = objectType
        self.syncManager = syncManager
    }
    
    func export(with connection: Connection, in context: NSManagedObjectContext) throws {
        let totalObjectsCount = try objectType.getCount(using: objectType.exportPredicate, in: context)
        syncManager.tracker.makeRecord(name: objectType.displayName, type: .export, recordCount: totalObjectsCount)

        guard totalObjectsCount > 0 else {
            return
        }

        let batchFetcher = CDBatchFetcher(for: objectType.entityName, using: objectType.exportPredicate, with: objectType.exportBatchSize, in: context)
        while let objects = try batchFetcher.fetchObjectBatch() as? [any Exportable] {
            try export(objects, with: connection, in: context)
            try context.save()
            try context.parent?.performAndWait {
                try context.parent?.save()
                try context.parent?.parent?.save()
            }
//            context.reset()
        }
        
        defer { syncManager.currentQuery = "" }
        
        objectType.additionalActionsAfterExport()
        syncManager.tracker.endRecordSync()
    }
}

private extension Exporter {
    
    func export(_ objects: [any Exportable], with connection: Connection, in context: NSManagedObjectContext) throws {
        for query in objectType.getInsertQueries(for: objects, in: context) {
            try execute(query, with: connection)
        }
        syncManager.tracker.progressUpdate(adding: Double(objects.count))
        objectType.modifyAfterExport(objects)
    }
    
    func execute(_ query: String, with connection: Connection) throws {
        let statement = try connection.prepareStatement(text: query)
        defer {statement.close()}
        
//        print(query)
        syncManager.currentQuery = query
        try statement.execute()
        try connection.commitTransaction()
    }
}
