//
//  Sync.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import CoreData

public class Sync {
    
    static public func sync(checks: Bool,
                            objectsContainer: CDObjectsContainer,
                            in context: NSManagedObjectContext,
                            doBefore: (() -> ())?,
                            doInBetween: (() -> ())?,
                            doAfter: (() -> ())?) async
    {
        guard checks else { return }
        
        let (importable, exportable) = sortTypes(objectsContainer.objects)
        
        SyncTracker.shared.syncStartDate = Date()
        SyncTracker.shared.totalRecordsToSync = SyncTracker.status == .exportReady ? importable.count + exportable.count : importable.count
        await AppControl.showSheet(view: SyncView())
        
        defer {
            if SyncTracker.status != .error {
                CurrentUser.updateSyncDate(Date())
                SyncTracker.updateStatus(.none)
            }
        }
        
        if let doBefore {
            doBefore()
        }
        
        if SyncTracker.status == .exportReady {
            await doExport(in: context, objects: exportable)
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

        await doImport(in: context, objects: importable, importHelperObjects: objectsContainer.importHelperObjects)
        
        if let doAfter {
            doAfter()
        }
    }
    
    static private func doImport(in context: NSManagedObjectContext, objects: [Importable.Type], importHelperObjects: [ExecutionHelper.Type]? = nil) async {
        guard SyncTracker.status == .importReady, objects.count > 0 else { return }
        
        SyncTracker.updateStatus(.importing)
        
        await withCheckedContinuation({ continuation in
            NetworkManager.shared.pool?.withConnection { con_from_pool in
                do {
                    try context.performAndWait {
                        let connection = try con_from_pool.get()
                        defer { connection.close() }
                        
                        if let importHelperObjects {
                            for helper in importHelperObjects {
                                try helper.performWork(in: connection)
                            }
                        }
                        
                        for object in objects {
                            guard object.sync(with: connection, in: context) else {
                                SyncTracker.updateStatus(.error)
                                continuation.resume()
                                return
                            }
                        }                        
                        SyncTracker.updateStatus(.importDone)
                        continuation.resume()

                    }
                }
                catch {
                    SyncTracker.updateStatus(.error)
                    AppControl.makeError(onAction: "Data Import", error: error)
                    continuation.resume()
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
                                context.rollback()
                                continuation.resume()
                                return
                            }
                        }
                        SyncTracker.updateStatus(.exportDone)
                        try context.save()
                        continuation.resume()
                    }
                }
                catch {
                    AppControl.makeError(onAction: "Data Export", error: error)
                    continuation.resume()
                }
            }
        }
    }
    
    static private func sortTypes(_ objects: [CDObject.Type]) -> ([Importable.Type], [any Exportable.Type]) {
        let importable = objects.filter({$0 is Importable.Type})
        let exportable =  objects.filter({$0 is any Exportable.Type})
        
        return (importable as! [Importable.Type], exportable as! [any Exportable.Type])
    }
}
