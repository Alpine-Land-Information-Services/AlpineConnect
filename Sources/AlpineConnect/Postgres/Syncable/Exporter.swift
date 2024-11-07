//
//  Exporter.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 5/26/23.
//

import CoreData
import AlpineCore
import PostgresNIO

class Exporter {

    private var objectType: any Exportable.Type
    private weak var syncManager: SyncManager?

    init(for objectType: any Exportable.Type, using syncManager: SyncManager) {
        self.objectType = objectType
        self.syncManager = syncManager
    }
    
    func export(using postgresManager: PostgresManager, in context: NSManagedObjectContext) async throws {
        guard let syncManager = syncManager else { return }
        
        let exportContext: NSManagedObjectContext = objectType.isSavedIndependently ? (syncManager.database?.type.newBackground ?? context) : context
        
        var totalObjectsCount = 0
        try exportContext.performAndWait {
            try objectType.deleteAllLocal(in: exportContext)
            totalObjectsCount = try objectType.getCount(using: objectType.exportPredicate, in: exportContext)
        }
        
        syncManager.tracker.makeRecord(name: objectType.displayName, type: .export, recordCount: totalObjectsCount)
        guard totalObjectsCount > 0 else { return }

        let batchFetcher = CDBatchFetcher(for: objectType.entityName, using: objectType.exportPredicate, sortDescriptors: nil, with: objectType.exportBatchSize, isModifying: true)
        
        var objects: [any Exportable]? = []

        repeat {
            // Получаем объекты синхронно
            try exportContext.performAndWait {
                objects = try batchFetcher.fetchObjectBatch(in: exportContext) as? [any Exportable]
            }
            
            // Обрабатываем объекты асинхронно
            if let objects = objects {
                try await export(objects, using: postgresManager)
                if objectType.isSavedIndependently {
                    try exportContext.performAndWait {
                        try exportContext.persistentSave()
                    }
                }
            }
        } while objects != nil

        objectType.additionalActionsAfterExport()
        syncManager.tracker.endRecordSync()
    }
}

private extension Exporter {

    func export(_ objects: [any Exportable], using postgresManager: PostgresManager) async throws {
        let queries = objectType.getInsertQueries(for: objects)
        for query in queries {
            try await execute(query, using: postgresManager)
        }
        objectType.modifyAfterExport(objects)
        syncManager?.tracker.progressUpdate(adding: Double(objects.count))
    }

    func execute(_ query: String, using postgresManager: PostgresManager) async throws {
        guard !query.isEmpty else { return }
        syncManager?.currentQuery = query
        try await postgresManager.queryRows(query)
    }
}
