//
//  SyncManager.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import CoreData
import AlpineCore
import PostgresClientKit
import PopupKit

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
    
    var activeConnection: Connection?

    public var currentQuery: String?
    
    weak public var database: (any Database)!
    var isForeground = true
    
    var timer: Timer?
    
    var syncErrorsResolver = SyncErrorsResolver()
    
    public init(for container: ObjectContainer, database: any Database, context: NSManagedObjectContext) {
        self.container = container
        tracker = SyncTracker()
        self.context = context
        context.mergePolicy = SelectiveMergePolicy()
        tracker.manager = self
        self.database = database
//        DispatchQueue.global(qos: .background).async {
//            database.getNotExported()
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
    @objc
    func contextDidSave(notification: Notification) {
        DispatchQueue.main.async {
            self.database.type.main.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    public func sync(type: SyncType, isBackground: Bool = false,
                     doBefore: (() -> ())?,
                     doInBetween: ((_ context: NSManagedObjectContext) throws -> ()),
                     doAfter: (() -> ())?) async
    {
        guard tracker.internalStatus == .none else {
            Core.makeSimpleAlert(title: "Already Syncing", message: "Please wait for the current sync to complete.")
            return
        }
        Core.makeEvent("syncing started", type: .sync)
        DispatchQueue.main.async {
            self.tracker.isDoingSomeSync = true
        }
        isForeground = !isBackground
        tracker.updateType(type)
        let (importable, exportable) = sortTypes(container.objects)
        
        tracker.currentSyncStartTime = Date()
        print(code: .red, "start time: \(tracker.currentSyncStartTime)")
        print(code: .red, "last  sync: \(String(describing: Connect.user.lastSync))")
        tracker.totalRecordsToSync = getRecordCount(for: type, importable: importable, exportable: exportable) + container.atlasObjects.count

//        scheduleTimer() // Sync timeout functionality
        if showUI(for: type) {
            showUI()
        }
        
        defer {
            currentQuery = ""
            timer?.invalidate()
            activeConnection = nil
            DispatchQueue.main.async {
                self.tracker.isDoingSomeSync = false
            }
            if tracker.status == .canceled {
                self.tracker.updateType(.none)
            }
            else if tracker.status != .error {
                Connect.user.lastSync = tracker.currentSyncStartTime
                self.tracker.updateStatus(.none)
                self.tracker.updateType(.none)
            }
            if !tracker.showingUI {
                self.tracker.updateStatus(.none)
                self.tracker.updateType(.none)
                self.clear()
            }
            Core.makeEvent("syncing finished", type: .sync)
        }
        
        guard await NetworkTracker.shared.canConnectToServer() else {
            if isForeground {
                Core.makeSimpleAlert(title: "Connection Timeout", message: "Cannot connect to server in reasonable time, please try again later.")
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
            Core.makeSimpleAlert(title: "Invalid Status", message: "Sync type cannot be 'none'.")
        }
        
        guard tracker.status != .error && !isSyncCanceled else {
            return
        }
        
        if let doAfter {
            doAfter()
        }
    }
    
    @objc
    func timerFired() {
        guard activeConnection != nil else {
            timer?.invalidate()
            return
        }
        promptForCancel()
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
    
    func sortTypes(_ objects: [CDObject.Type]) -> ([Importable.Type], [any Exportable.Type]) {
        let importable = objects.filter({$0 is Importable.Type})
        let exportable = objects.filter({$0 is any Exportable.Type})
        
        return (importable as! [Importable.Type], exportable as! [any Exportable.Type])
    }
}

private extension SyncManager {
    
    func inBetweenActions(for function: ((_ context: NSManagedObjectContext) throws -> ())) {
        do {
            guard !isSyncCanceled else { return }
            try context.performAndWait {
                try function(context)
                try context.persistentSave()
            }
        }
        catch {
            Core.makeError(error: error, additionalInfo: "Sync Actions Save", showToUser: isForeground)
        }
    }
    
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
            Core.makeSimpleAlert(title: "Syncing", message: "Please wait for the sync process to complete before proceeding.")
            return false
        }
        return true
    }
}

public extension SyncManager {
    
    func showUI() {
        Core.presentSheet {
            SyncView(for: self)
        }
    }
    
    func clear() {
        tracker = SyncTracker()
        tracker.manager = self
//        database.getNotExported()
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

extension SyncManager { //MARK: Cancel
    
    var isSyncCanceled: Bool {
        tracker.status == .canceled
    }
    
    func scheduleTimer() {
        if CurrentDBUser.syncTimeout != 0 {
            DispatchQueue.main.async { [self] in
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(Connect.user.syncTimeout), target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
            }
        }
    }
    
    func cancelSync() {
        guard let activeConnection else {
            return
        }
        
        timer?.invalidate()
        tracker.updateStatus(.canceled)
        activeConnection.closeAbruptly()
        self.activeConnection = nil
    }
    
    func nonCancelAction(_ action: @escaping () -> Void) {
        if tracker.status != .canceled {
            action()
        }
    }
    
    func userSyncCancelAlert() {
        guard activeConnection != nil else {
            Core.makeSimpleAlert(title: "Not Syncing", message: "Cannot cancel as there is no sync in progress.")
            return
        }
        
        let alert = CoreAlert(title: "Cancel Sync?",
                              message: "Current sync process will be canceled.",
                              buttons: [AlertButton.no,
                                        AlertButton(title: "Proceed", style: .destructive, action: {
            self.cancelSync()
        })])
        
        Core.makeAlert(alert)
    }
    
    func promptForCancel() {
        let alert = CoreAlert(title: "Sync Timeout",
                              message: "Current sync process is taking longer than the timeout threshold. \n\n Would you like to cancel or continue the process?",
                              buttons: [AlertButton(title: "Continue", style: .cancel, action: {}),
                                        AlertButton(title: "Cancel It", style: .destructive, action: {
            self.cancelSync()
        })])
        Core.makeAlert(alert)
    }
}

private extension SyncManager { //MARK: Import
    
    func importOnly(doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), importable: [Importable.Type]) async {
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
        guard !isSyncCanceled else { return }

        tracker.updateStatus(.exportReady)
        await executeExport(exportable: exportable)
        
        if tracker.status == .exportDone {
            DispatchQueue.main.async {
                Connect.user.requiresSync = false
            }
        }
    }
    
    func exectuteImport(importable: [Importable.Type]) async {
        guard importable.count > 0 else {
            tracker.updateStatus(.importDone)
            return
        }
        
        syncErrorsResolver = SyncErrorsResolver()
        let syncRecordBackups = tracker.syncRecords

        repeat {
            await doImport(in: context, objects: importable, helpers: container.importHelperObjects)
        } while tracker.status == .error && syncErrorsResolver.shouldRepeat(onRepeat: {
            DispatchQueue.main.async {
                self.tracker.syncRecords = syncRecordBackups
            }
        })
        
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
            Core.makeError(error: error, additionalInfo: "Saving Import Data", showToUser: isForeground)
        }
        
        await doClean(in: context, objects: importable)
        await atlasSync(for: container.atlasObjects)

        try? await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
    }
    
    func doImport(in context: NSManagedObjectContext, objects: [Importable.Type], helpers: [ExecutionHelper.Type] = []) async {
        tracker.updateStatus(.importing, message: "Importing")
        
        await withCheckedContinuation({ continuation in
            guard ConnectManager.shared.postgres?.pool != nil else {
                continuation.resume()
                return
            }
            ConnectManager.shared.postgres?.pool?.withConnection { connnection_from_pool in
                do {
//                    throw AlpineError("_test_connectionClosed_", file: "", function: "", line: 0)
                    try context.performAndWait {
                        let connection = try connnection_from_pool.get()
                        self.activeConnection = connection
                        defer { connection.close() }
                        
                        for helper in helpers {
                            guard !self.isSyncCanceled else {
                                continuation.resume()
                                return
                            }
                            try helper.performWork(with: connection, in: context)
                        }
                        
                        for object in objects {
                            guard !self.isSyncCanceled else {
                                continuation.resume()
                                return
                            }
// MARK: main func is HERE:
                            try object.sync(with: connection, in: context)
                        }
                        
                        self.tracker.updateStatus(.importDone)
                        continuation.resume()
                    }
                }
                catch {
                    self.syncErrorsResolver.error = error 
                    self.nonCancelAction {
                        self.tracker.updateStatus(.error)
                        Core.makeError(error: error, additionalInfo: self.currentQuery,
                                       showToUser: self.syncErrorsResolver.shouldShowToUser(self.isForeground))
                    }
                    continuation.resume()
                }
            }
        })
    }
    
    func doClean(in context: NSManagedObjectContext, objects: [Importable.Type]) async {
        var needSave = false
        context.performAndWait {
            for object in objects {
                needSave = object.cleanObsoleteData(in: context) || needSave
            }
            if needSave {
                try? context.persistentSave()
            }
        }
    }
}

private extension SyncManager { //MARK: Export
    
    func exportOnly(doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), exportable: [Exportable.Type]) async {
        tracker.updateStatus(.exportReady)
        await executeExport(exportable: exportable)
    }
    
    func exportFirst(doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), importable: [Importable.Type], exportable: [Exportable.Type]) async {
        tracker.updateStatus(.exportReady)
        await executeExport(exportable: exportable)
        
        guard tracker.status == .exportDone else {
            return
        }
        
        inBetweenActions(for: doInBetween)
        guard !isSyncCanceled else { return }

        tracker.updateStatus(.importReady)
        await exectuteImport(importable: importable)
        
        if tracker.status == .importDone {
            Connect.user.requiresSync = false
        }
    }
    
    func executeExport(exportable: [Exportable.Type]) async {
        guard exportable.count > 0 else {
            tracker.updateStatus(.exportDone)
            return
        }
        
        let syncRecordBackups = tracker.syncRecords
        syncErrorsResolver = SyncErrorsResolver()
        
        repeat {
            await doExport(in: context, objects: exportable, helpers: container.exportHelperObjects)
        } while tracker.status == .error && syncErrorsResolver.shouldRepeat(onRepeat: {
            DispatchQueue.main.async {
                self.tracker.syncRecords = syncRecordBackups
            }
        })
        
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
            nonCancelAction {
                self.tracker.updateStatus(.error)
                Core.makeError(error: error, additionalInfo: "Saving Export Data", showToUser: self.isForeground)
            }
        }
        
        try? await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
    }
    
    func doExport(in context: NSManagedObjectContext, objects: [any Exportable.Type], helpers: [ExecutionHelper.Type] = []) async {
        tracker.updateStatus(.exporting, message: "Exporting")
        
        await withCheckedContinuation { continuation in
            guard ConnectManager.shared.postgres?.pool != nil else {
                continuation.resume()
                return
            }
            ConnectManager.shared.postgres?.pool?.withConnection { connnection_from_pool in
                do {
//                    if self.syncErrorsResolver.repeatAttempts == 2 {
//                        throw AlpineError("_test_connectionClosed_", file: "", function: "", line: 0)
//                    }
                    let connection = try connnection_from_pool.get()
                    self.activeConnection = connection
                    defer { connection.close() }
                    
                    try context.performAndWait {
                        for helper in helpers {
                            guard !self.isSyncCanceled else {
                                continuation.resume()
                                return
                            }
                            try helper.performWork(with: connection, in: context)
                        }
                    }
                    
                    for object in objects {
                        guard !self.isSyncCanceled else {
                            continuation.resume()
                            return
                        }
// MARK: main func is HERE:
                        try Exporter(for: object, using: self).export(with: connection, in: context)
                    }
                    
                    self.tracker.updateStatus(.exportDone)
                    continuation.resume()
                } catch {
                    self.syncErrorsResolver.error = error 
                    self.nonCancelAction {
                        self.tracker.updateStatus(.error)
                        Core.makeError(error: error, additionalInfo: self.currentQuery, 
                                       showToUser: self.syncErrorsResolver.shouldShowToUser(self.isForeground))
                    }
                    context.performAndWait {
                        context.rollback()
                    }
                    continuation.resume()
                }
            }
        }
    }
}

extension SyncManager {
    
    func atlasSync(for objects: [AtlasObject.Type]) async {
        self.tracker.updateStatus(.atlasSync, message: "Performing Atlas Synchronization")
        for object in objects {
            if let object = object as? AtlasSyncable.Type {
                do {
                    try await AtlasSynchronizer(for: object, syncManager: self).synchronize(in: context)
                }
                catch {
                    Core.shared.makeError(error: error)
                }
            }
        }
    }
    
    // deleting only *.fgb files from project folder
    public func atlasClear(for atlasSyncable: [AtlasSyncable.Type]) throws {
        for syncable in atlasSyncable {
            try syncable.deleteLayer()
        }
    }
}
