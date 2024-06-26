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
    static var cleanPredicate: NSPredicate? { get set }
    
    static var syncFields: [AtlasSyncField] { get }
    var relationshipSyncFields: [AtlasFieldData]? { get }
    
    static func performAtlasSynchronization(with data: [AtlasFeatureData]) async throws
    static func reloadOrCreateLayer() async throws
    
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
    
    var relationshipSyncFields: [AtlasFieldData]? {
        nil
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
        5000
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
    
    public var isReference: Bool
        
    public init(layerFieldName: String, objectFieldName: String, fieldType: Any.Type, isReference: Bool = false) {
        self.layerFieldName = layerFieldName
        self.objectFieldName = objectFieldName
        self.fieldType = fieldType
        self.isReference = isReference
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
