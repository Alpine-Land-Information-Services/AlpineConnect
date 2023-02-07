//
//  NSManagedObject.swift
//  AlpineConnect
//
//  Created by mkv on 5/9/22.
//

import CoreData


public func ContextSaver(for context: NSManagedObjectContext?) {
    do {
        if context?.hasChanges ?? false {
            try context?.save()
        }
    } catch {
        print(error)
    }
}


public extension NSManagedObject {
    
    func save(context: NSManagedObjectContext? = nil) {
        guard let ctx = context ?? self.managedObjectContext else {
            assertionFailure()
            return
        }
        do {
            if ctx.hasChanges {
                try ctx.save()
            }
        } catch {
            print("Failure to save context: \(error)")
        }
    }
    
    static func MainAsyncSave(_ context: NSManagedObjectContext) {
        DispatchQueue.main.async {
            do {
                try context.save()
            }
            catch {
                print("Could not save changed value:", error)
            }
        }
    }
    
    func delete(context: NSManagedObjectContext? = nil) {
        guard let ctx = context ?? self.managedObjectContext else {
            assertionFailure()
            return
        }
        do {
            ctx.delete(self)
            try ctx.save()
        } catch {
            print("Failure to delete object: \(error)")
        }
    }
    
    static var entityName: String {
        String(describing: Self.self)
    }
    
    static func all(in context: NSManagedObjectContext) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
        request.returnsObjectsAsFaults = false
        var result: [NSManagedObject] = []
        context.performAndWait {
            do {
                result = try context.fetch(request)
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func findByGUID(entityName: String? = nil, _ guid: String?, in context: NSManagedObjectContext) -> Self? {
        guard guid != nil else { return nil }
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName ?? Self.entityName)
        request.predicate = NSPredicate(format: "guid = %@", UUID(uuidString: guid!)! as CVarArg)
        request.returnsObjectsAsFaults = false
        var result: Self?
        context.performAndWait {
            do {
                result = try context.fetch(request).first as? Self
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func findPredicate(with predicate: NSPredicate, fetchLimit: Int, in context: NSManagedObjectContext) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        request.fetchLimit = fetchLimit
        var result: [NSManagedObject] = []
        context.performAndWait {
            do {
                result = try context.fetch(request)
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func clearData(entityName: String? = nil, in context: NSManagedObjectContext) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName ?? Self.entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        context.performAndWait {
            do {
                try context.execute(request)
            } catch {
                print(error)
            }
        }
    }
    
    static func count(entityName: String? = nil, in context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName ?? Self.entityName)
        var result = 0
        context.performAndWait {
            do {
                result = try context.fetch(request).count
            } catch {
                print(error)
            }
        }
        return result
    }
    
    static func hasAnyEntities(entityName: String? = nil, in context: NSManagedObjectContext) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName ?? Self.entityName)
        var result = false
        request.fetchLimit = 1
        request.returnsObjectsAsFaults = true
        context.performAndWait {
            do {
                result = try context.fetch(request).count > 0
            } catch {
                print(error)
            }
        }
        return result
    }
}