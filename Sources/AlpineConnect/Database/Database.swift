//
//  Database.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 3/30/23.
//

import Foundation
import CoreData

public protocol Database: AnyObject {
    
    associatedtype DB: Database
    static var shared: DB { get set }
    
    var moc: NSManagedObjectContext { get }
    var poc: NSManagedObjectContext { get }
    
    var container: NSPersistentContainer { get }
    
    func getNotExported()
}

public extension Database {

    static var main: NSManagedObjectContext {
        Self.shared.moc
    }
    
    static var background: NSManagedObjectContext {
        Self.shared.poc
    }
    
    static var newBackground: NSManagedObjectContext {
        Self.shared.container.newBackgroundContext()
    }
}
