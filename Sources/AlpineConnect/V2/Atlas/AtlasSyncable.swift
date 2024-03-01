//
//  AtlasSyncable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/25/24.
//

import CoreData
import AlpineCore

public protocol AtlasSyncable: AtlasObject, Importable {
    
    static var syncBatchSize: Int { get }
    static var syncPredicate: NSPredicate { get }
    
    static var syncFields: [AtlasSyncField] { get }
    
    static func performAtlasSynchronization(with data: [AtlasFeatureData], deleting: [UUID]) async throws
    static func createLayerIfNecessary() async throws
    
    static func clearCache() throws
    static func deleteLayer() throws
    
    func selectOnMap()
    
    func deleteOnError()
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
    
    func deleteOnError() {
        
    }
}

public extension AtlasSyncable {
    
    static var layerName: String {
        displayName
    }
    
    static var fileExtension: String {
        "fgb"
    }
    
    static var connectionPath: String {
        "Layers/"
    }
}

public extension AtlasSyncable {
    
    static var syncBatchSize: Int {
        100
    }
    
    static var syncPredicate: NSPredicate {
        NSPredicate(format: "a_syncDate > %@", syncManager.tracker.currentSyncStartTime as CVarArg)
    }
    
    static func performAtlasSynchronization(with data: [AtlasFeatureData], deleting: [UUID]) async throws {
        fatalError(#function + " must be implemented in client.")
    }
    
    func selectOnMap() {
        fatalError(#function + " must be implemented in client.")
    }
}

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
}
