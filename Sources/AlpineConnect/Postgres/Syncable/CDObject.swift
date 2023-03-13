
//  CDObject.swift
//
//  Created by mkv on 2/21/23.
//

import CoreData

public protocol CDObject where Self: NSManagedObject {
    
    var guid: UUID { get }
    func update(missingRequirements: Bool, isChanged: Bool, in context: NSManagedObjectContext)
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
}
