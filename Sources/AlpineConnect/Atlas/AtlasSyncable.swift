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
    
    static var layerName: String {
        displayName
    }
    
    static var fileExtension: String {
        "fgb"
    }
    
    static var connectionPath: String {
        "Layers/"
    }
    
    static var syncBatchSize: Int {
        5000
    }
}

public extension AtlasSyncable {
    
    static func performAtlasSynchronization(with data: [AtlasFeatureData], deleting: [UUID]) async throws {
        fatalError(#function + " must be implemented in client.")
    }
    
    func getGeometry(in context: NSManagedObjectContext) -> String? {
        context.performAndWait {
            self.value(forKey: "a_geometry") as? String
        }
    }
    
    func selectOnMap() {
        fatalError(#function + " must be implemented in client.")
    }
    
    func deleteOnError() { }
}
