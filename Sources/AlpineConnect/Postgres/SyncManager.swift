//
//  SyncManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import CoreData
import AlpineCore

public class SyncManager {
    
    public enum SyncType {
        case importOnly
        case importOnlyNoUI
        
        case exportOnly
        case exportOnlyNoUI
        
        case importFirst
        case importFirstNoUI
        
        case exportFirst
        case exportFirstNoUI
    }
    
    public var tracker: SyncTracker
    public var container: ObjectContainer
    private var context: NSManagedObjectContext

    public var currentQuery: String?
    
    weak public var database: (any Database)!
    
    
    public init(for container: ObjectContainer, database: any Database, context: NSManagedObjectContext) {
        self.container = container
        tracker = SyncTracker()
        self.context = context
        context.mergePolicy = SelectiveMergePolicy()
        tracker.manager = self
        self.database = database
        database.getNotExported()
    }
    
    public func sync(type: SyncType, doBefore: (() -> ())?, doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), doAfter: (() -> ())?) async {
        currentQuery = ""
        let (importable, exportable) = sortTypes(container.objects)
        
        tracker.currentSyncStartDate = Date()
        tracker.totalRecordsToSync = getRecordCount(for: type, importable: importable, exportable: exportable)
        
        if showUI(for: type) {
            await AppControl.showSheet(view: SyncView(for: self))
        }
        
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
        
        switch type {
        case .exportFirst, .exportFirstNoUI:
            await exportFirst(doInBetween: doInBetween, importable: importable, exportable: exportable)
        case .importFirst, .importFirstNoUI:
            await importFirst(doInBetween: doInBetween, importable: importable, exportable: exportable)
        case .importOnly, .importOnlyNoUI:
            await importOnly(doInBetween: doInBetween, importable: importable)
        case .exportOnly, .exportOnlyNoUI:
            await exportOnly(doInBetween: doInBetween, exportable: exportable)
        }
        
        guard tracker.status != .error else {
            return
        }
        
        if let doAfter {
            doAfter()
        }
    }
}

private extension SyncManager {
    
    func getRecordCount(for type: SyncType, importable: [Importable.Type], exportable: [Exportable.Type]) -> Int {
        switch type {
        case .exportFirst, .importFirst, .exportFirstNoUI, .importFirstNoUI:
            return exportable.count + importable.count
        case .exportOnly, .exportOnlyNoUI:
            return exportable.count
        case .importOnly, .importOnlyNoUI:
            return importable.count
        }
    }
    
    func exportOnly(doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), exportable: [Exportable.Type]) async {
        tracker.updateStatus(.exportReady)
        await executeExport(exportable: exportable)
    }
    
    func importOnly(doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), importable: [Importable.Type]) async {
        tracker.updateStatus(.importReady)
        await exectuteImport(importable: importable)
    }
    
    func exportFirst(doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), importable: [Importable.Type], exportable: [Exportable.Type]) async {
        tracker.updateStatus(.exportReady)
        await executeExport(exportable: exportable)
        
        guard tracker.status == .exportDone else {
            return
        }
        
        inBetweenActions(for: doInBetween)
        
        tracker.updateStatus(.importReady)
        await exectuteImport(importable: importable)
    }
    
    func importFirst(doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), importable: [Importable.Type], exportable: [Exportable.Type]) async {
        tracker.updateStatus(.importReady)
        await exectuteImport(importable: importable)

        guard tracker.status == .importDone else {
            return
        }
        
        inBetweenActions(for: doInBetween)
        
        tracker.updateStatus(.exportReady)
        await executeExport(exportable: exportable)
    }
}

private extension SyncManager {
    
    func inBetweenActions(for function: ((_ context: NSManagedObjectContext) throws -> ())) {
        do {
            try context.performAndWait {
                try function(context)
                try context.persistentSave()
            }
        }
        catch {
            AppControl.makeError(onAction: "Sync Actions Save", error: error)
        }
    }
    
    func executeExport(exportable: [Exportable.Type]) async {
        guard exportable.count > 0 else {
            tracker.updateStatus(.exportDone)
            return
        }

        await doExport(in: context, objects: exportable, helpers: container.exportHelperObjects)

        guard tracker.status == .exportDone else {
            return
        }
                
        do {
            tracker.statusMessage("Saving Export Data")
            try context.performAndWait {
                try context.persistentSave()
                context.refreshAllObjects()
            }
        }
        catch {
            self.tracker.updateStatus(.error)
            AppControl.makeError(onAction: "Saving Export Data", error: error)
        }
        
        try? await Task.sleep(nanoseconds: UInt64(3 * 1_000_000_000))

    }
    
    func exectuteImport(importable: [Importable.Type]) async {
        guard importable.count > 0 else {
            tracker.updateStatus(.importDone)
            return
        }
        
        await doImport(in: context, objects: importable, helpers: container.importHelperObjects)
        
        guard tracker.status == .importDone else {
            return
        }
                
        do {
            tracker.statusMessage("Saving Import Data")
            try context.performAndWait {
                try context.persistentSave()
                context.refreshAllObjects()
            }
        }
        catch {
            self.tracker.updateStatus(.error)
            AppControl.makeError(onAction: "Saving Import Data", error: error)
        }
        
        try? await Task.sleep(nanoseconds: UInt64(3 * 1_000_000_000))
    }
}

private extension SyncManager {
    
    func doImport(in context: NSManagedObjectContext, objects: [Importable.Type], helpers: [ExecutionHelper.Type] = []) async {
        tracker.statusMessage("Importing")
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
        tracker.updateStatus(.exporting)
        tracker.statusMessage("Exporting")
        
        await withCheckedContinuation { continuation in
            NetworkManager.shared.pool?.withConnection { result in
                do {
                    let connection = try result.get()
                    defer { connection.close() }
                    
                    try context.performAndWait {
                        for helper in helpers {
                            try helper.performWork(with: connection, in: context)
                        }
                    }
                    
                    for object in objects {
                        try Exporter(for: object, using: self).export(with: connection, in: context)
                    }
                    
                    self.tracker.updateStatus(.exportDone)
                    continuation.resume()
                }
                catch {
                    self.tracker.updateStatus(.error)
                    AppControl.makeError(onAction: "Data Export", error: error, customDescription: self.currentQuery)
                    context.performAndWait {
                        context.rollback()
                    }
                    continuation.resume()
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

private extension SyncManager {
    
    func showUI(for type: SyncType) -> Bool {
        switch type {
        case .importOnlyNoUI, .exportOnlyNoUI, .importFirstNoUI, .exportFirstNoUI:
            return false
        default:
            return true
        }
    }
}

public extension SyncManager {
    
    func clear() {
        tracker = SyncTracker()
        tracker.manager = self
        database.getNotExported()
    }
}

