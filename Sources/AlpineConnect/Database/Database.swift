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
}
