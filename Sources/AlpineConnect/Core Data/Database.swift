//
//  Database.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 1/19/23.
//

import CoreData

public class ConnectDB {
    
    static public var shared = ConnectDB()
    
    public var mainContext: NSManagedObjectContext
    public var privateContext: NSManagedObjectContext
    
    private init() {
        mainContext = ConnectStack.persitentContainer.viewContext
        privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.parent = mainContext
        privateContext.automaticallyMergesChangesFromParent = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange(notification:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: privateContext)
    }
    
    @objc
    fileprivate func managedObjectContextObjectsDidChange(notification: Notification) {
        guard let notificationContext = notification.object as? NSManagedObjectContext else { return }
        guard notificationContext !== mainContext else { return }
        mainContext.performAndWait {
            do {
                self.mainContext.mergeChanges(fromContextDidSave: notification)
                if mainContext.hasChanges {
                    try self.mainContext.save()
                }
            } catch {
                print(error)
            }
        }
    }
}

extension NSManagedObjectContext {
    
    static public func main() -> NSManagedObjectContext {
        ConnectDB.shared.mainContext
    }
    
    static public func background() -> NSManagedObjectContext {
        ConnectDB.shared.privateContext
    }
    
    static public func newBackground() -> NSManagedObjectContext {
        ConnectStack.persitentContainer.newBackgroundContext()
    }
}
