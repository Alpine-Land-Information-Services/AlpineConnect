//
//  CDObjects.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/24/23.
//

import CoreData

public class CDObjects {
    
    static public func clearAll(_ objects: [CDObject.Type], in context: NSManagedObjectContext, doAfter: (() -> ())? = nil) async -> Result<Void, Error> {
        await context.perform {
            do {
                for object in objects {
                    try object.clear(in: context)
                }
                
                try context.save()
                context.reset()
            }
            catch {
                return .failure(error)
            }
            
            if let doAfter {
                doAfter()
            }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name("Connect-Refresh"), object: nil)
            }
            return .success(())
        }
    }
}
