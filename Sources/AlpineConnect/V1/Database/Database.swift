//
//  Database.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 3/30/23.
//

import Foundation
import CoreData
import AlpineCore

public protocol Database: AnyObject {
    
    associatedtype DB: Database
    static var shared: DB { get set }
    
    associatedtype Stack: CDStack
    var stack: Stack { get }
    
    var moc: NSManagedObjectContext { get }
    var poc: NSManagedObjectContext { get }
    
    var container: NSPersistentContainer { get }
    
    func getNotExported()
}

public extension Database {
    
    var type: Self.Type {
        return Self.self
    }
    
    static var main: NSManagedObjectContext {
        Self.shared.moc
    }
    
    static var background: NSManagedObjectContext {
        Self.shared.poc
    }
    
    static var newBackground: NSManagedObjectContext {
        let context = Self.shared.container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    static var syncBackground: NSManagedObjectContext {
        let context = Self.shared.container.newBackgroundContext()
        context.mergePolicy = SelectiveMergePolicy()
        return context
    }
}

class SelectiveMergePolicy: NSMergePolicy {
    
    init() {
        super.init(merge: .mergeByPropertyObjectTrumpMergePolicyType)
    }
    
    override func resolve(constraintConflicts list: [NSConstraintConflict]) throws {
        guard list.allSatisfy({ $0.databaseObject != nil }) else {
            print("CustomSelectiveMergePolicy is only intended to work with database-level conflicts.")
            return try super.resolve(constraintConflicts: list)
        }
       
        for conflict in list {
            guard let databaseObject = conflict.databaseObject else { continue }
            for conflictingObject in conflict.conflictingObjects {
                for key in conflictingObject.entity.attributesByName.keys {
                    let incomingValue = conflictingObject.value(forKey: key)
                    
                    // If the incoming value is nil or NSNull, use the existing value in the database
                    if incomingValue == nil || incomingValue is NSNull {
                        let databaseValue = databaseObject.value(forKey: key)
                        conflictingObject.setValue(databaseValue, forKey: key)
                        continue
                    }

                    // Otherwise, the incoming value will trump (and it's automatically set as the `mergeByPropertyObjectTrumpMergePolicyType` behavior)
                }
            }
        }

        try super.resolve(constraintConflicts: list)
    }
}
