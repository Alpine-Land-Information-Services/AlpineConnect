//
//  NSManagedObject.swift
//  AlpineConnect
//
//  Created by mkv on 5/9/22.
//

import CoreData


public protocol Nameable {
    static var entityName: String { get }
    static var entityDisplayName: String { get }
}

public extension Nameable {
    
    static var entityName: String {
        String(describing: Self.self)
    }
    
    static var entityDisplayName: String {
        var res = entityName
        if res.hasSuffix("_V1") {
            res = res.replacingOccurrences(of: "_V1", with: "")
        }
        return res
    }
}


//MARK: -
public func ContextSaver(for context: NSManagedObjectContext?) {
    do {
        if context?.hasChanges ?? false {
            try context?.save()
        }
    } catch {
        print(error)
    }
}

//MARK: -
extension NSManagedObject: Nameable {
}

public extension NSManagedObject {
    
//    static var entityName: String {
//        String(describing: Self.self)
//    }
//
//    static var entityDisplayName: String {
//        var res = entityName
//        if res.hasSuffix("_V1") {
//            res = res.replacingOccurrences(of: "_V1", with: "")
//        }
//        return res
//    }
    
    func save(in context: NSManagedObjectContext? = nil) {
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
    
    func inContext(_ context: NSManagedObjectContext) -> Self? {
        return try? context.existingObject(with: self.objectID) as? Self
    }
    
    static func mainAsyncSave(in context: NSManagedObjectContext) {
        DispatchQueue.main.async {
            do {
                try context.save()
            }
            catch {
                print("Could not save changed value:", error)
            }
        }
    }
    
    func delete(in context: NSManagedObjectContext? = nil, doSave: Bool = true) {
        guard let ctx = context ?? self.managedObjectContext else {
            assertionFailure()
            return
        }
        do {
            ctx.delete(self)
            if doSave {
                try ctx.save()
            }
        } catch {
            print("Failure to delete object: \(error)")
        }
    }
    
    static func all(entityName: String? = nil, in context: NSManagedObjectContext) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName ?? Self.entityName)
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
    
    static func disableAll(entityName: String? = nil, in context: NSManagedObjectContext) {
        do {
            for item in all(entityName: entityName, in: context) {
                item.setValue(false, forKey: "enabled_")
            }
            try context.save()
        } catch {
            print(error)
        }
    }
    
    static func findByGUID(entityName: String? = nil, _ guid: String?, in context: NSManagedObjectContext) -> Self? {
        guard guid != nil else { return nil }
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName ?? Self.entityName)
        request.predicate = NSPredicate(format: "guid = %@", UUID(uuidString: guid!)! as CVarArg)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
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
    
    static func findByName(entityName: String? = nil,_ name: String, in context: NSManagedObjectContext) -> Self? {
        guard !name.isEmpty else { return nil }
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName ?? Self.entityName)
        request.predicate = NSPredicate(format: "name = %@", name)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
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
    
    static func clearData(entityName: String? = nil, predicate: NSPredicate? = nil, in context: NSManagedObjectContext) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName ?? Self.entityName)
        fetch.predicate = predicate
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        context.performAndWait {
            do {
                try context.execute(request)
            } catch {
                print(error)
            }
        }
    }
    
    static func count(entityName: String? = nil, predicate: NSPredicate? = nil, in context: NSManagedObjectContext) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName ?? Self.entityName)
        request.predicate = predicate
        var result = 0
        request.returnsObjectsAsFaults = true
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
    
    static func findObjects(by predicate: NSPredicate, in context: NSManagedObjectContext) -> [NSManagedObject] {
        let request = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
        request.predicate = predicate
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
    
    static func findObject(by predicate: NSPredicate, in context: NSManagedObjectContext) -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: Self.entityName)
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        var result: NSManagedObject?
        context.performAndWait {
            do {
                result = try context.fetch(request).first
            } catch {
                print(error)
            }
        }
        return result
    }
    
    func saveMergeInTo(context: NSManagedObjectContext) {
        guard let selfContext = self.managedObjectContext else {
            assertionFailure()
            return
        }
        do {
            try selfContext.performAndWait {
                try selfContext.save()
                try context.performAndWait {
                    try context.save()
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
}
