//
//  Sync.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import CoreData

public class Sync {
    
    static public func doImport(checks: Bool, in context: NSManagedObjectContext, objects: [Syncable.Type], doBefore: (() -> ())?, doAfter: (() -> ())?) {
        guard checks else { return }
        
        SyncTracker.shared.totalReccordsToSync = objects.filter({$0.needUpdate()}).count
        
        AppControl.showSheet(view: SyncView())
        SyncTracker.updateStatus(.importing)
        
        NetworkManager.shared.pool?.withConnection { con_from_pool in
            defer {
                if let doAfter {
                    doAfter()
                }
                SyncTracker.updateStatus(.none)
            }
            do {
                let connection = try con_from_pool.get()
                defer { connection.close() }
                
                if let doBefore {
                    doBefore()
                }
                
                context.performAndWait {
                    for object in objects {
                        object.sync(with: connection, in: context)
                    }
                }
            }
            catch {
                AppControl.makeError(onAction: "Data Sync", error: error)
            }
        }
    }
}
