//
//  Modifiable.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 3/22/23.
//

import CoreData

public protocol Modifiable: CDObject {
    
    var wasDeleted: Bool { get }
    
    func update(missingRequirements: Bool, isChanged: Bool, in context: NSManagedObjectContext)
    func deleteObject(in context: NSManagedObjectContext?)
}

public extension Modifiable {
    
    var wasDeleted: Bool {
        value(forKey: "delete_") as? Bool ?? true
    }
    
    func deleteObject(in context: NSManagedObjectContext? = nil) {
        guard let context  = context ?? self.managedObjectContext else {
            return
        }
        
        if let object = self as? Syncable {
            setValue(true, forKey: "delete_")
            update(missingRequirements: false, isChanged: true, in: context)
            if object.isLocal {
                delete(in: context, doSave: true)
            }
        }
        else {
            update(missingRequirements: false, isChanged: true, in: context)
            delete(in: context, doSave: true)
        }
     }
}
