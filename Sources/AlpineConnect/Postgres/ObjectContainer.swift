//
//  ObjectContainer.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/24/23.
//

import CoreData
import AlpineCore


public class ObjectContainer {
    
    public var objects: [CDObject.Type]
    public var nonClearableObjects: [CDObject.Type]
    public var importHelperObjects: [ExecutionHelper.Type]
    public var exportHelperObjects: [ExecutionHelper.Type]
    public var atlasObjects: [AtlasObject.Type]
    public var atlasSyncableObjects: [AtlasSyncable.Type] {
        objects.filter({ $0 is AtlasSyncable.Type}) as! [AtlasSyncable.Type]
    }
    
    public init(objects: [CDObject.Type], nonClearables: [CDObject.Type] = [], importHelpers: [ExecutionHelper.Type] = [], exportHelpers: [ExecutionHelper.Type] = [], atlasObjects: [AtlasSyncable.Type] = []) {
        self.objects = objects
        self.nonClearableObjects = nonClearables
        self.importHelperObjects = importHelpers
        self.exportHelperObjects = exportHelpers
        self.atlasObjects = atlasObjects
    }
}
