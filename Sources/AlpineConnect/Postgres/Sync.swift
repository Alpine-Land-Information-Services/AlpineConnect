//
//  Sync.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import CoreData

public class Sync {
    
    static public func sync(checks: Bool, exportObjects: [any Exportable.Type], importObjects: [Importable.Type], in context: NSManagedObjectContext, doBefore: (() -> ())?, doInBetween: (() -> ())?, doAfter: (() -> ())?) async {
        guard checks else { return }
        
        SyncTracker.shared.totalReccordsToSync = SyncTracker.status == .exportReady ? exportObjects.count + importObjects.count : importObjects.count
        await AppControl.showSheet(view: SyncView())
//        SyncTracker.toggleSyncWindow(to: true)
        
        defer {
            if SyncTracker.status != .error {
                CurrentUser.updateSyncDate(Date())
            }
            SyncTracker.updateStatus(.none)
//            SyncTracker.toggleSyncWindow(to: false)
        }
        
        if let doBefore {
            doBefore()
        }
        
        if SyncTracker.status == .exportReady {
            await doExport(in: context, objects: exportObjects)
        }
        
        if let doInBetween {
            doInBetween()
        }
        
        if SyncTracker.status == .exportDone {
            SyncTracker.updateStatus(.importReady)
        }
        
        guard SyncTracker.status == .importReady else {
            return
        }
        
        await doImport(in: context, objects: importObjects)
        
        if let doAfter {
            doAfter()
        }
    }
    
    static private func doImport(in context: NSManagedObjectContext, objects: [Importable.Type]) async {
        guard SyncTracker.status == .importReady, objects.count > 0 else { return }
        
        SyncTracker.updateStatus(.importing)
        
        await withCheckedContinuation({ continuation in
            NetworkManager.shared.pool?.withConnection { con_from_pool in
                do {
                    try context.performAndWait {
                        let connection = try con_from_pool.get()
                        defer { connection.close() }
                        for object in objects {
                            guard object.sync(with: connection, in: context) else {
                                SyncTracker.updateStatus(.error)
                                return
                            }
                        }
                        
                        SyncTracker.updateStatus(.importDone)
                        continuation.resume()
                    }
                }
                catch {
                    AppControl.makeError(onAction: "Data Import", error: error)
                }
            }
        })
    }
    
    static private func doExport(in context: NSManagedObjectContext, objects: [any Exportable.Type]) async {
        guard SyncTracker.status == .exportReady, objects.count > 0 else { return }
        
        SyncTracker.updateStatus(.exporting)
        await withCheckedContinuation { continuation in
            NetworkManager.shared.pool?.withConnection { con_from_pool in
                do {
                    try context.performAndWait {
                        let connection = try con_from_pool.get()
                        defer { connection.close() }
                        for object in objects {
                            guard object.export(with: connection, in: context) else {
                                SyncTracker.updateStatus(.error)
                                return
                            }
                        }
                        SyncTracker.updateStatus(.exportDone)
                        continuation.resume()
                    }
                }
                catch {
                    AppControl.makeError(onAction: "Data Export", error: error)
                }
            }
        }
    }
}
