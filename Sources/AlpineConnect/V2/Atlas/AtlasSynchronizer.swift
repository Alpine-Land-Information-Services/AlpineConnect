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
    
    var syncManager: SyncManager?
    var objectType: AtlasSyncable.Type
    
    public init(for objectType: AtlasSyncable.Type, syncManager: SyncManager?) {
        self.objectType = objectType
        self.syncManager = syncManager
    }
    
    public func synchronize(in context: NSManagedObjectContext) async throws {
        try await objectType.reloadOrCreateLayer()
        
        guard objectType.cleanPredicate != nil else { 
            syncManager?.tracker.makeRecord(name: objectType.displayName, type: .atlasSync, recordCount: 0)
            return 
        }
        
        let pred = NSPredicate(format: "a_deleted = false")
        var totalObjectsCount = 0
        totalObjectsCount = try objectType.getCount(using: pred, in: context, performInContext: true)
        syncManager?.tracker.makeRecord(name: objectType.displayName, type: .atlasSync, recordCount: totalObjectsCount)

        guard totalObjectsCount > 0 else { return }

        let batchFetcher = CDBatchFetcher(for: objectType.entityName, 
                                          using: pred,
                                          sortDescriptors: nil,
                                          with: objectType.syncBatchSize, 
                                          isModifying: false)
        var objects: [AtlasSyncable]? = []
        var featuresData = [AtlasFeatureData]()
        
        repeat {
            try context.performAndWait {
                objects = try batchFetcher.fetchObjectBatch(in: context) as? [AtlasSyncable]
//                objects?.forEach { $0.observeDeallocation() }
                if let objects {
                    featuresData = try createAtlasData(from: objects)
                }
            }
            guard !featuresData.isEmpty else { break }
            try await objectType.performAtlasSynchronization(with: featuresData)
            syncManager?.tracker.progressUpdate(adding: Double(featuresData.count))
            
            featuresData.removeAll()
            
        } while objects != nil

        try objectType.clearCache()
        syncManager?.tracker.endRecordSync()
    }
    
    func createAtlasData(from objects: [AtlasSyncable]) throws -> [AtlasFeatureData] {
        var data = [AtlasFeatureData]()
        for object in objects {
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
        return data
    }
}
