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

    private var objectType: any Exportable.Type
    private weak var syncManager: SyncManager?

    init(for objectType: any Exportable.Type, using syncManager: SyncManager) {
        self.objectType = objectType
        self.syncManager = syncManager
    }
    
    func export(with connection: Connection, in context: NSManagedObjectContext) throws {
        guard let syncManager = syncManager else { return }
        let context: NSManagedObjectContext = objectType.isSavedIndependently ? (syncManager.database?.type.newBackground ?? context) : context
        
        var totalObjectsCount = 0
        try context.performAndWait {
            try objectType.deleteAllLocal(in: context)
            totalObjectsCount = try objectType.getCount(using: objectType.exportPredicate, in: context)
        }
        syncManager.tracker.makeRecord(name: objectType.displayName, type: .export, recordCount: totalObjectsCount)

        guard totalObjectsCount > 0 else { return }

//        defer { syncManager.currentQuery = "" }

        let batchFetcher = CDBatchFetcher(for: objectType.entityName, using: objectType.exportPredicate, sortDescriptors: nil, with: objectType.exportBatchSize, isModifying: true)
        var objects: [any Exportable]? = []

        repeat {
            try context.performAndWait {
                objects = try batchFetcher.fetchObjectBatch(in: context) as? [any Exportable]
//                objects?.forEach { $0.observeDeallocation() }
                if let objects = objects {
                    try export(objects, with: connection)
                    if objectType.isSavedIndependently  {
                        try context.persistentSave()
                    }
                }
            }
        } while objects != nil

        objectType.additionalActionsAfterExport()
        syncManager.tracker.endRecordSync()
    }
}

private extension Exporter {

    func export(_ objects: [any Exportable], with connection: Connection) throws {
        for query in objectType.getInsertQueries(for: objects) {
            try execute(query, with: connection)
        }
        objectType.modifyAfterExport(objects)
        syncManager?.tracker.progressUpdate(adding: Double(objects.count))
    }

    func execute(_ query: String, with connection: Connection) throws {
        guard !query.isEmpty else { return }
        syncManager?.currentQuery = query
        let statement = try connection.prepareStatement(text: query)
        defer { statement.close() }
        try statement.execute()
        try connection.commitTransaction()
    }
}
