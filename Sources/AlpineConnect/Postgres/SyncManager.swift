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
        
        case none
    }
    
    public var tracker: SyncTracker
    public var container: ObjectContainer
    private var context: NSManagedObjectContext

    public var currentQuery: String?
    
    weak public var database: (any Database)!
    var isForeground = true
    
    public init(for container: ObjectContainer, database: any Database, context: NSManagedObjectContext) {
        self.container = container
        tracker = SyncTracker()
        self.context = context
        context.mergePolicy = SelectiveMergePolicy()
        tracker.manager = self
        self.database = database
        database.getNotExported()
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
    @objc
    func contextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.database.type.main.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    public func sync(type: SyncType, isBackground: Bool = false, doBefore: (() -> ())?, doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), doAfter: (() -> ())?) async {
        guard tracker.internalStatus == .none else {
            AppControl.makeSimpleAlert(title: "Already Syncing", message: "Please wait for the current sync to complete.")
            return
        }
        
        tracker.isDoingSomeSync = true
        isForeground = !isBackground
        tracker.updateType(type)
        currentQuery = ""
        let (importable, exportable) = sortTypes(container.objects)
        
        tracker.currentSyncStartDate = Date()
        tracker.totalRecordsToSync = getRecordCount(for: type, importable: importable, exportable: exportable)
        
        if showUI(for: type) {
            showUI()
        }
        
        defer {
            currentQuery = ""
            DispatchQueue.main.async {
                self.tracker.isDoingSomeSync = false
            }
            if tracker.status != .error {
                CurrentUser.updateSyncDate(tracker.currentSyncStartDate)
                self.tracker.updateStatus(.none)
                self.tracker.updateType(.none)
            }
            if !tracker.showingUI {
                self.tracker.updateStatus(.none)
                self.tracker.updateType(.none)
                self.clear()
            }
        }
        
        guard await NetworkMonitor.shared.canConnectToServer() else {
            if isForeground {
                AppControl.makeSimpleAlert(title: "Connection Timeout", message: "Cannot connect to server in reasonable time, please try again later.")
            }
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
        case .none:
            AppControl.makeSimpleAlert(title: "Invalid Status", message: "Sync status cannot be 'none'.")
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
    
    func mergeBackgroundChangesToMainContext() {
        DispatchQueue.main.async { [self] in
            let changes = context.insertedObjects.union(context.updatedObjects).union(context.deletedObjects)
            
            for obj in changes {
                let mainContextObject = database.container.viewContext.object(with: obj.objectID)
                database.container.viewContext.refresh(mainContextObject, mergeChanges: true)
            }
        }
    }
    
    func getRecordCount(for type: SyncType, importable: [Importable.Type], exportable: [Exportable.Type]) -> Int {
        switch type {
        case .exportFirst, .importFirst, .exportFirstNoUI, .importFirstNoUI:
            return exportable.count + importable.count
        case .exportOnly, .exportOnlyNoUI:
            return exportable.count
        case .importOnly, .importOnlyNoUI:
            return importable.count
        case .none:
            return 0
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
        
        if tracker.status == .importDone {
            CurrentUser.requiresSync = false
        }
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
        
        if tracker.status == .exportDone {
            DispatchQueue.main.async {
                CurrentUser.requiresSync = false
            }
        }
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
            AppControl.makeError(onAction: "Sync Actions Save", error: error, showToUser: isForeground)
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
            AppControl.makeError(onAction: "Saving Export Data", error: error, showToUser: isForeground)
        }
        
        try? await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))

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
            AppControl.makeError(onAction: "Saving Import Data", error: error, showToUser: isForeground)
        }
        
        try? await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
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
                    AppControl.makeError(onAction: "Data Import", error: error, customDescription: self.currentQuery, showToUser: self.isForeground)
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
                    AppControl.makeError(onAction: "Data Export", error: error, customDescription: self.currentQuery, showToUser: self.isForeground)
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
    
    func allowSync() -> Bool {
        guard !tracker.isDoingSomeSync else {
            AppControl.makeSimpleAlert(title: "Syncing", message: "Please wait for the sync process to complete before proceeding.")
            return false
        }
        return true
    }
}

public extension SyncManager {
    
    func showUI() {
        AppControl.showSheet(view: SyncView(for: self))
    }
    
    func clear() {
        tracker = SyncTracker()
        tracker.manager = self
        database.getNotExported()
    }
    
    func nonSyncAction(_ action: () -> Void) {
        guard allowSync() else {
            return
        }
        action()
    }
    
    func nonSyncAction(_ action: () async -> Void) async {
        guard allowSync() else {
            return
        }
        await action()
    }
}

