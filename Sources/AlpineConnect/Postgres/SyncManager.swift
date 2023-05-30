//
//  SyncManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import CoreData
import AlpineCore

public class SyncManager {
    
    public var tracker: SyncTracker
    public var container: ObjectContainer
    
    public var currentQuery: String?
    
    weak public var database: (any Database)!
    
    public init(for container: ObjectContainer, database: any Database) {
        self.container = container
        tracker = SyncTracker()
        tracker.manager = self
        self.database = database
        database.getNotExported()
    }

    public func sync(checks: Bool, in context: NSManagedObjectContext,
                            doBefore: (() -> ())?,
                            doInBetween: (() -> ())?,
                            doAfter: (() -> ())?) async
    {
        guard checks else { return }
        currentQuery = ""
        
        let (importable, exportable) = sortTypes(container.objects)
        
        tracker.currentSyncStartDate = Date()
        tracker.totalRecordsToSync = tracker.status == .exportReady ? importable.count + exportable.count : importable.count
        await AppControl.showSheet(view: SyncView(for: self))
        
        defer {
            currentQuery = ""
            if tracker.status != .error {
                CurrentUser.updateSyncDate(tracker.currentSyncStartDate)
                tracker.updateStatus(.none)
            }
        }
        
        guard await NetworkMonitor.shared.canConnectToServer() else {
            AppControl.makeSimpleAlert(title: "Connection Timeout", message: "Cannot connect to server in reasonable time, please try again later.")
            tracker.updateStatus(.error)
            return
        }
        
        if let doBefore {
            doBefore()
        }
        
        if tracker.status == .exportReady {
            await doExport(in: context, objects: exportable, helpers: container.exportHelperObjects)
        }

        if let doInBetween {
            doInBetween()
        }

        if tracker.status == .exportDone {
            tracker.updateStatus(.importReady)
        }

        guard tracker.status == .importReady else {
            return
        }

        await doImport(in: context, objects: importable, helpers: container.importHelperObjects)
        
        if let doAfter {
            doAfter()
        }
    }
    
    
    public func pictureTestExport(in context: NSManagedObjectContext, objects: [any Exportable.Type], helpers: [ExecutionHelper.Type] = []) {
        NetworkManager.shared.pool?.withConnection { result in
            context.performAndWait {
                do {
                    let connection = try result.get()
                    defer { connection.close() }

                    for helper in helpers {
                        try helper.performWork(with: connection, in: context)
                    }

                    for object in objects {
                        try Exporter(for: object, using: self).export(with: connection, in: context)
                    }

//                    self.tracker.updateStatus(.exportDone)
//                    try context.parent?.performAndWait {
//                        try context.parent?.save()
//                    }
                }
                catch {
                    self.tracker.updateStatus(.error)
                    AppControl.makeError(onAction: "Data Export", error: error, customDescription: self.currentQuery)
                    context.parent?.rollback()
                }
            }
        }
    }
}

private extension SyncManager {
    
    func doImport(in context: NSManagedObjectContext, objects: [Importable.Type], helpers: [ExecutionHelper.Type] = []) async {
        guard tracker.status == .importReady, objects.count > 0 else { return }
        
        tracker.updateStatus(.importing)
        
        await withCheckedContinuation({ continuation in
            NetworkManager.shared.pool?.withConnection { con_from_pool in
                do {
                    try context.performAndWait {
                        let connection = try con_from_pool.get()
                        defer { connection.close() }
                        
                        for helper in helpers {
                            try helper.performWork(with: connection, in: context)
                        }
                        
                        for object in objects {
                            guard object.sync(with: connection, in: context) else {
                                self.tracker.updateStatus(.error)
                                continuation.resume()
                                return
                            }
                        }
                        self.tracker.updateStatus(.importDone)
                        continuation.resume()
                    }
                }
                catch {
                    self.tracker.updateStatus(.error)
                    AppControl.makeError(onAction: "Data Import", error: error, customDescription: self.currentQuery)
                    continuation.resume()
                }
            }
        })
    }
    
    func doExport(in context: NSManagedObjectContext, objects: [any Exportable.Type], helpers: [ExecutionHelper.Type] = []) async {
        guard tracker.status == .exportReady, objects.count > 0 else { return }
        tracker.updateStatus(.exporting)
        await withCheckedContinuation { continuation in
            NetworkManager.shared.pool?.withConnection { result in
                context.performAndWait {
                    do {
                        let connection = try result.get()
                        defer { connection.close() }

                        for helper in helpers {
                            try helper.performWork(with: connection, in: context)
                        }

                        for object in objects {
                            try Exporter(for: object, using: self).export(with: connection, in: context)
                        }

                        self.tracker.updateStatus(.exportDone)
                        try context.parent?.performAndWait {
                            try context.parent?.save()
                        }
                        continuation.resume()
                    }
                    catch {
                        self.tracker.updateStatus(.error)
                        AppControl.makeError(onAction: "Data Export", error: error, customDescription: self.currentQuery)
                        context.parent?.rollback()
                        continuation.resume()
                    }
                }
            }
        }
    }
    
    func sortTypes(_ objects: [CDObject.Type]) -> ([Importable.Type], [any Exportable.Type]) {
        let importable = objects.filter({$0 is Importable.Type})
        let exportable =  objects.filter({$0 is any Exportable.Type})
        
        return (importable as! [Importable.Type], exportable as! [any Exportable.Type])
    }
}

public extension SyncManager {
    
    func clear() {
        tracker = SyncTracker()
        tracker.manager = self
        database.getNotExported()
    }
}

//        await withCheckedContinuation { continuation in
//            NetworkManager.shared.pool?.withConnection { con_from_pool in
//                do {
//                    try context.performAndWait {
//                        let connection = try con_from_pool.get()
//                        defer { connection.close() }
//
//                        for helper in helpers {
//                            try helper.performWork(with: connection, in: context)
//                        }
//
//                        for object in objects {
//                            try Exporter(for: object, using: self).export(with: connection, in: context)
//                        }
//                        self.tracker.updateStatus(.exportDone)
//                        continuation.resume()
//                    }
//                }
//                catch {
//                    self.tracker.updateStatus(.error)
//                    AppControl.makeError(onAction: "Data Export", error: error, customDescription: self.currentQuery)
//
//                    context.rollback()
//                    continuation.resume()
//                }
//            }
//        }
