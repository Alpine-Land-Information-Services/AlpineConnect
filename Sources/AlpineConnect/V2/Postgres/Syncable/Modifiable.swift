//
//  Modifiable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 3/22/23.
//

import CoreData
import AlpineCore

public protocol Modifiable: CDObject {
    
    var wasDeleted: Bool { get }
    
    func update(missingRequirements: Bool, isChanged: Bool, in context: NSManagedObjectContext)
    func deleteObject(in context: NSManagedObjectContext?)
    func getAllDependentElements() -> [Any]
    
    func modifyRelation(with geometry: String?)
}

public extension Modifiable {
    
    func trash(_ value: Bool) {
        guard let context = managedObjectContext else {
            return
        }
        context.performAndWait {
            setValue(value, forKey: "a_deleted")
            update(missingRequirements: false, isChanged: true, in: context)
        }
    }
    
    var wasDeleted: Bool {
        value(forKey: "a_deleted") as? Bool ?? true
    }
    
    func deleteObject(in context: NSManagedObjectContext? = nil) {
        guard let context = context ?? self.managedObjectContext
        else { return }
        
        if let object = self as? Syncable {
            setValue(true, forKey: "a_deleted")
            update(missingRequirements: false, isChanged: true, in: context)
            if object.isLocal {
                delete(in: context, doSave: false)
            }
        }
        else {
            update(missingRequirements: false, isChanged: true, in: context)
            delete(in: context, doSave: false)
        }
     }
    
    func modifyRelation(with geometry: String?) {
        
    }
}
