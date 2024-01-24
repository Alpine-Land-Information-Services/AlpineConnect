//
//  AtlasSynchronizer.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/24/24.
//

import Foundation
import CoreData

import AlpineCore

public class AtlasSynchronizer {
    
    public struct FeatureSyncData {
        public var layerName: String
        public var guid: UUID
        public var wkt: String
    }

    var syncManager: SyncManager
    var objectType: Importable.Type
    
    init(for objectType: Importable.Type, syncManager: SyncManager) {
        self.objectType = objectType
        self.syncManager = syncManager
    }
    
    func synchronize(in context: NSManagedObjectContext) async throws {
        var totalObjectsCount = 0
        try context.performAndWait {
            totalObjectsCount = try objectType.getCount(using: objectType.atlasSyncPredicate, in: context)
        }
        syncManager.tracker.makeRecord(name: objectType.displayName, type: .atlasSync, recordCount: totalObjectsCount)

        guard totalObjectsCount > 0 else {
            return
        }

        let batchFetcher = CDBatchFetcher(for: objectType.entityName, using: objectType.atlasSyncPredicate, sortDescriptors: nil, with: objectType.atlasSyncBatchSize, isModifying: false)
        
        var objects: [Importable]? = []
        var featureData = [FeatureSyncData]()
        
        repeat {
            try context.performAndWait {
                objects = try batchFetcher.fetchObjectBatch(in: context) as? [Importable]
                objects?.forEach { $0.observeDeallocation() }
                if let objects = objects {
                    featureData = try createAtlasData(from: objects)
                }
            }
            
            try await objectType.performAtlasSynchronization(with: featureData)
            syncManager.tracker.progressUpdate(adding: Double(featureData.count))
            
        } while objects != nil

        syncManager.tracker.endRecordSync()
    }
    
    func createAtlasData(from objects: [Importable]) throws -> [FeatureSyncData] {
        var data = [FeatureSyncData]()
        for object in objects {
            guard let geometry = object.value(forKey: "a_geometry") as? String else {
                continue
            }
            data.append(FeatureSyncData(layerName: object.displayName, guid: object.guid, wkt: geometry))
        }
        
        return data
    }
}
