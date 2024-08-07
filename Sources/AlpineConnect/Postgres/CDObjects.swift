//
//  File.swift
//  
//
//  Created by Vladislav on 7/17/24.
//

import CoreData
import AlpineCore

public class CDObjects {
    
    static public func clearAll(_ objectsContainer: ObjectContainer, in context: NSManagedObjectContext, doAfter: (() -> ())? = nil) async -> Result<Void, Error> {
        await context.perform {
            do {
                for object in objectsContainer.objects {
                    if objectsContainer.nonClearableObjects.contains(where: { $0 == object }) { continue }
                    try object.clear(in: context)
                }
                
                try context.persistentSave()
            }
            catch {
                return .failure(error)
            }
            
            if let doAfter {
                doAfter()
            }
            return .success(())
        }
    }
    
    static public func fetchObject(as layer: String, with guid: UUID, in context: NSManagedObjectContext) -> CDObject? {
        context.performAndWait {
            let request = NSFetchRequest<NSManagedObject>(entityName: layer)
            request.predicate = NSPredicate(format: "a_guid = %@", guid as CVarArg)
            request.fetchLimit = 1
            request.returnsObjectsAsFaults = false
            
            var result: CDObject?
            
            do {
                result = try context.fetch(request).first as? CDObject
            }
            catch {
                Core.makeError(error: error, additionalInfo: "Could not find selected feature.")
            }
            return result
        }
    }
}
