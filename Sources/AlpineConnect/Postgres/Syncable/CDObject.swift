
//  CDObject.swift
//
//  Created by mkv on 2/21/23.
//

import CoreData

public protocol CDObject where Self: NSManagedObject {
    
    var guid: UUID { get }
    
    func update(missingRequirements: Bool, isChanged: Bool, in context: NSManagedObjectContext)
    func deleteObject(in context: NSManagedObjectContext?)
}

public extension CDObject {
    
    var guid: UUID {
        if let guid = (self.managedObjectContext?.performAndWait {
                            value(forKey: "guid") as? UUID
                        })
        {
            return guid
        }
        assertionFailure("CDObject HAS NO GUID")
        return UUID()
    }
    
    static func clear(in context: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let deleteResult = try context.execute(request) as? NSBatchDeleteResult
         
        if let objectIDs = deleteResult?.result as? [NSManagedObjectID] {
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs], into: [context])
        }
    }
    
    static var type: CDObject.Type {
        self as CDObject.Type
    }
    
    func update(missingRequirements: Bool, isChanged: Bool, in context: NSManagedObjectContext) {
        
    }
    
   func deleteObject(in context: NSManagedObjectContext? = nil) {
       guard let context  = context ?? self.managedObjectContext else {
           return
       }
       
       if let object = self as? Syncable {
           if object.isLocal {
               self.setValue(true, forKey: "delete_")
               self.delete(in: context, doSave: true)
           }
           else {
               self.setValue(true, forKey: "delete_")
               self.update(missingRequirements: false, isChanged: true, in: context)
           }
       }
       else {
           self.update(missingRequirements: false, isChanged: true, in: context)
           self.delete(in: context, doSave: true)
       }
    }
    
    func deleteWithAlert(in context: NSManagedObjectContext? = nil, doAfter: (() -> ())? = nil) {
        let alert = AppAlert(title: "Delete \(Self.entityDisplayName)?", message: "This action cannot be undone", dismiss: AlertAction(text: "Cancel"), actions: [AlertAction(text: "Delete", role: .destructive, action: {
            self.deleteObject(in: context)
            if let doAfter {
                doAfter()
            }
        })])
        
        AppControl.makeAlert(alert: alert)
    }
}
