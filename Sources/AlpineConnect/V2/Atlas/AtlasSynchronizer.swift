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
    
    var syncManager: SyncManager
    var objectType: AtlasSyncable.Type
    
    init(for objectType: AtlasSyncable.Type, syncManager: SyncManager) {
        self.objectType = objectType
        self.syncManager = syncManager
    }
    
    func synchronize(in context: NSManagedObjectContext) async throws {
        try await objectType.createLayerIfNecessary()
        
        var totalObjectsCount = 0
        try context.performAndWait {
            totalObjectsCount = try objectType.getCount(using: objectType.syncPredicate, in: context)
        }
        syncManager.tracker.makeRecord(name: objectType.displayName, type: .atlasSync, recordCount: totalObjectsCount)

        guard totalObjectsCount > 0 else {
            return
        }

        let batchFetcher = CDBatchFetcher(for: objectType.entityName, 
                                          using: objectType.syncPredicate,
                                          sortDescriptors: nil,
                                          with: objectType.syncBatchSize, 
                                          isModifying: false)
        
        var objects: [AtlasSyncable]? = []
        var featuresData = [AtlasFeatureData]()
        var deleteFeatures = [UUID]()
        
        repeat {
            try context.performAndWait {
                objects = try batchFetcher.fetchObjectBatch(in: context) as? [AtlasSyncable]
//                objects?.forEach { $0.observeDeallocation() }
                if let objects {
                    (featuresData, deleteFeatures) = try createAtlasData(from: objects)
                }
            }
            guard !featuresData.isEmpty || !deleteFeatures.isEmpty else { break } 
            try await objectType.performAtlasSynchronization(with: featuresData, deleting: deleteFeatures)
            syncManager.tracker.progressUpdate(adding: Double(featuresData.count + deleteFeatures.count))
            
            featuresData.removeAll()
            deleteFeatures.removeAll()
            
        } while objects != nil

        try objectType.clearCache()
        syncManager.tracker.endRecordSync()
    }
    
    func createAtlasData(from objects: [AtlasSyncable]) throws -> ([AtlasFeatureData], [UUID]) {
        var data = [AtlasFeatureData]()
        var delete = [UUID]()
        for object in objects {
            if object.deleted_no_context {
                delete.append(object.guid)
                continue
            }
            guard let geometry = object.geometry else {
                continue
            }
            
            var fields = [AtlasFieldData(name: "UNIQ_ID", value: object.guid.uuidString),
                          AtlasFieldData(name: "OBJECT_TYPE", value: objectType.entityName)]
            
            for field in type(of: object).syncFields {
                fields.append(AtlasFieldData(name: field.layerFieldName, value: object.value(forKey: field.objectFieldName) ?? "")) //"_INVALID_FIELD_NAME_"
            }
            
            let featureData = AtlasFeatureData(wkt: geometry, fields: fields)
            data.append(featureData)
        }
        
        return (data, delete)
    }
}
