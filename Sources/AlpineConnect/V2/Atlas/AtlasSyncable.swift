//
//  AtlasSyncable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/25/24.
//

import CoreData
import AlpineCore

public struct AtlasSyncField {
    
    public var layerFieldName: String
    public var objectFieldName: String
    public var fieldType: Any.Type
    
    public init(layerFieldName: String, objectFieldName: String, fieldType: Any.Type) {
        self.layerFieldName = layerFieldName
        self.objectFieldName = objectFieldName
        self.fieldType = fieldType
    }
    
    
    public func convertToLayerType() -> Any.Type {
        switch fieldType {
        case is UUID.Type:
            return String.self
        default:
            return fieldType
        }
    }
//    
//    public func convertToLayerFieldValue(value: Any?) -> Any {
//        switch fieldType {
//        case is UUID.Type:
//            let guid = value as? UUID
//            return guid?.uuidString ?? "_INVALID_FIELD_VALUE_"
//        default:
//            return value ?? "_INVALID_FIELD_VALUE_"
//        }
//    }
}

public protocol AtlasSyncable: AtlasObject, Importable {
    
    static var syncBatchSize: Int { get }
    static var syncPredicate: NSPredicate { get }
    
    static var isEditable: Bool { get }
    
    static func performAtlasSynchronization(with data: [AtlasFeatureData], deleting: [UUID]) async throws
    static func createLayerIfNecessary() async throws
    
    static func clearCache() throws
    static func deleteLayer() throws
    
    func updateWithGeometry(_ geometry: String?)
    
    static var syncFields: [AtlasSyncField] { get }
}

public extension AtlasSyncable {
    
    var geometry: String? {
        get {
            self.managedObjectContext?.performAndWait {
                self.value(forKey: "a_geometry") as? String
            }
        }
        set {
            self.managedObjectContext?.performAndWait {
                self.setValue(newValue, forKey: "a_geometry")
            }
        }
    }
    
    func getGeometry(in context: NSManagedObjectContext) -> String? {
        context.performAndWait {
            self.value(forKey: "a_geometry") as? String
        }
    }
}

public extension AtlasSyncable {
    
    static var syncBatchSize: Int {
        100
    }
    
    static func performAtlasSynchronization(with data: [AtlasFeatureData], deleting: [UUID]) async throws {
        fatalError(#function + " must be implemented in client.")
    }
    
    static var syncPredicate: NSPredicate {
        NSPredicate(format: "a_syncDate > %@", syncManager.tracker.currentSyncStartDate as CVarArg)
    }
}
