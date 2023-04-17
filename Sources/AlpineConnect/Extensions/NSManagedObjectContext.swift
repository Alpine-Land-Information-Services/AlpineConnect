//
//  NSManagedObjectContext.swift
//  
//
//  Created by  on 4/12/23.
//

import CoreData

public extension NSManagedObjectContext {
    
    func easySave() {
        do {
            if self.hasChanges {
                try self.save()
            }
        } catch {
            assertionFailure("Failure to save context: \(error)")
            AppControl.makeError(onAction: "Context Save", error: error)
        }
    }
    
    func forceSave() throws {
        try self.performAndWait {
            try self.save()
            if let main = self.parent {
                try main.performAndWait {
                    try main.save()
                }
            }
        }
    }
}
