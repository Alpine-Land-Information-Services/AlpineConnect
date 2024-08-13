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
    
    /// Represents the types of synchronization that can be performed.
    public enum SyncType {
        case importOnly, importOnlyNoUI, exportOnly, exportOnlyNoUI
        case importFirst, importFirstNoUI, exportFirst, exportFirstNoUI, none
    }
    
    /// The database associated with the sync manager.
    weak public var database: (any Database)?
    
    /// The tracker responsible for tracking synchronization progress.
    public var tracker: SyncTracker
    
    ///⚠️⁉️
    public var container: ObjectContainer
    
    /// The current query being executed.
    public var currentQuery: String?
    
    /// The Core Data context used for synchronization operations.
    private var context: NSManagedObjectContext
    
    ///⚠️⁉️
    private var isForeground: Bool = true
    
    /// A timer used for managing sync timeouts.
    private var timer: Timer?
    
    /// Indicates whether an Atlas synchronization should be performed.
    private var doAtlasSync: Bool
    
    /// The active connection used for synchronization with PostgresClientKit
    private var activeConnection: Connection?
    
    /// The resolver for handling sync errors.
    private var syncErrorsResolver = SyncErrorsResolver()
    
    /// Indicates whether the synchronization process has been canceled.
    private var isSyncCanceled: Bool {
        tracker.status == .canceled
    }
    
    /// Initializes a new sync manager.
    ///
    /// - Parameters:
    ///   - container: The object container ⚠️⁉️
    ///   - database: The database used for synchronization.
    ///   - doAtlasSync: A boolean indicating whether to perform Atlas synchronization.
    ///   - context: The Core Data context used for synchronization.
    public init(for container: ObjectContainer, database: any Database, doAtlasSync: Bool = true, context: NSManagedObjectContext) {
        self.container = container
        tracker = SyncTracker()
        self.context = context
        context.mergePolicy = SelectiveMergePolicy()
        self.doAtlasSync = doAtlasSync
        tracker.setSyncManager(self)
        self.database = database
        //        DispatchQueue.global(qos: .background).async {
        //            database.getNotExported()
        //        }
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    }
    
    /// Performs a synchronization process.
    ///
    /// - Parameters:
    ///   - type: The type of synchronization to perform.
    ///   - isBackground: A boolean indicating whether the sync is running in the background.
    ///   - doBefore: A closure to execute before starting the sync.
    ///   - doInBetween: A closure to execute between import and export phases.
    ///   - doAfter: A closure to execute after completing the sync.
    public func sync(type: SyncType, isBackground: Bool = false, doBefore: (() -> ())?, doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), doAfter: (() -> ())?) async {
        guard tracker.internalStatus == .none else {
            Core.makeSimpleAlert(title: "Already Syncing", message: "Please wait for the current sync to complete.")
            return
        }
        
        Core.makeEvent("initializing sync", type: .sync)
        
        DispatchQueue.main.async { [weak self] in
            self?.tracker.isDoingSomeSync = true
        }
        
        let (importable, exportable) = sortTypes(container.objects)
        isForeground = !isBackground
        
        tracker.updateType(type)
        tracker.currentSyncStartTime = Date()
        tracker.totalRecordsToSync = getRecordCount(for: type, importable: importable, exportable: exportable) + container.atlasObjects.count
        
        print(code: .red, "start time: \(tracker.currentSyncStartTime)")
        print(code: .red, "last sync: \(String(describing: Connect.user?.lastSync))")
        
        // scheduleTimer() // Sync timeout functionality
        
        if showUI(for: type) {
            showUI()
        }
        
        defer {
            finalizeSync()
        }
        
        guard await NetworkTracker.shared.canConnectToServer() else {
            handleConnectionTimeout()
            return
        }
        
        doBefore?()
        
        await attemptSyncOnlineLogin()
        
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
        
        DispatchQueue.main.async {
            NotificationCenter.default.post(Notification(name: .AC_SyncComplete, object: nil, userInfo: ["success": true]))
        }
        
        doAfter?()
    }
    
    /// Finalizes the synchronization process, performing cleanup and status updates.
    private func finalizeSync() {
        currentQuery = ""
        timer?.invalidate()
        activeConnection = nil
        
        DispatchQueue.main.async { [weak self] in
            self?.tracker.isDoingSomeSync = false
        }
        
        if tracker.status == .canceled {
            tracker.updateType(.none)
        } else if tracker.status != .error {
            DispatchQueue.main.async {
                Connect.user?.lastSync = self.tracker.currentSyncStartTime
            }
            tracker.updateStatus(.none)
            tracker.updateType(.none)
        }
        
        if !tracker.showingUI {
            tracker.updateStatus(.none)
            tracker.updateType(.none)
            clear()
        }
        
        Core.makeEvent("syncing finished", type: .sync)
    }
    
    /// Handles a connection timeout during synchronization.
    private func handleConnectionTimeout() {
        if isForeground {
            Core.makeSimpleAlert(title: "Connection Timeout", message: "Cannot connect to server in reasonable time, please try again later.")
        }
        tracker.updateStatus(.error)
    }
    
    /// Fired when the timer for synchronization timeout is triggered.
    @objc
    private func timerFired() {
        guard activeConnection != nil else {
            timer?.invalidate()
            return
        }
        promptForCancel()
    }
    
    // Handles the save event of the Core Data context.
    ///
    /// - Parameter notification: The notification containing the context save event information.
    @objc
    private func contextDidSave(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.database?.type.main.mergeChanges(fromContextDidSave: notification)
        }
    }
}

private extension SyncManager {
    
    /// Attempts to perform an online login during synchronization.
    func attemptSyncOnlineLogin() async {
        tracker.updateStatus(.loginPreparing)
        tracker.statusMessage("Preparing for Postgres connection...")
        
        if ConnectManager.shared.isSignedIn, !ConnectManager.shared.didSignInOnline {
            do {
                _ = try await ConnectManager.shared.attemptSyncOnlineLogin()
                tracker.statusMessage("Postgres connection successful.")
                tracker.updateStatus(.loginDone)
            } catch {
                tracker.statusMessage("Postgres connection failed.")
                tracker.updateStatus(.error)
                Core.makeError(error: error)
            }
        } else {
            tracker.statusMessage("Already established connection to Postgres.")
        }
    }
}

private extension SyncManager {
    
    /// Merges background changes to the main context.
    func mergeBackgroundChangesToMainContext() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let changes = context.insertedObjects.union(context.updatedObjects).union(context.deletedObjects)
            for obj in changes {
                if let mainContextObject = database?.container.viewContext.object(with: obj.objectID) {
                    database?.container.viewContext.refresh(mainContextObject, mergeChanges: true)
                }
            }
        }
    }
    
    /// Gets the total record count for synchronization based on the sync type.
    ///
    /// - Parameters:
    ///   - type: The type of synchronization.
    ///   - importable: The importable objects.
    ///   - exportable: The exportable objects.
    /// - Returns: The total record count for synchronization.
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
    
    /// Sorts the objects into importable and exportable types.
    ///
    /// - Parameter objects: The objects to be sorted.
    /// - Returns: A tuple containing arrays of importable and exportable types.
    func sortTypes(_ objects: [CDObject.Type]) -> ([Importable.Type], [any Exportable.Type]) {
        let importable = objects.compactMap { $0 as? Importable.Type }
        let exportable = objects.compactMap { $0 as? any Exportable.Type }
        return (importable, exportable)
    }
}

private extension SyncManager {
    
    /// Performs in-between actions during synchronization.
    ///
    /// - Parameter function: The closure to execute.
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
    
    /// Determines whether the sync UI should be shown based on the sync type.
    ///
    /// - Parameter type: The type of synchronization.
    /// - Returns: A boolean indicating whether to show the UI.
    func showUI(for type: SyncType) -> Bool {
        switch type {
        case .importOnlyNoUI, .exportOnlyNoUI, .importFirstNoUI, .exportFirstNoUI :
            return false
        default:
            return true
        }
    }
    
    /// Checks if synchronization is allowed to proceed.
    ///
    /// - Returns: A boolean indicating whether synchronization is allowed.
    func allowSync() -> Bool {
        guard !tracker.isDoingSomeSync else {
            Core.makeSimpleAlert(title: "Syncing", message: "Please wait for the sync process to complete before proceeding.")
            return false
        }
        return true
    }
}

public extension SyncManager {
    
    /// Shows the synchronization UI.
    func showUI() {
        Core.presentSheet {
            SyncView(for: self)
        }
    }
    
    /// Clears the sync tracker and reinitializes it.
    func clear() {
        tracker = SyncTracker()
        tracker.manager = self
    }
    
    /// Performs a non-sync action if synchronization is allowed.
    ///
    /// - Parameter action: The closure to execute.
    func nonSyncAction(_ action: () -> Void) {
        guard allowSync() else { return }
        action()
    }
    
    /// Performs an asynchronous non-sync action if synchronization is allowed.
    ///
    /// - Parameter action: The closure to execute.
    func nonSyncAction(_ action: () async -> Void) async {
        guard allowSync() else { return }
        await action()
    }
}

private extension SyncManager { //MARK: Cancel
    
    /// Cancels the current synchronization process.
    func cancelSync() {
        guard let activeConnection else {
            return
        }
        
        timer?.invalidate()
        tracker.updateStatus(.canceled)
        activeConnection.closeAbruptly()
        self.activeConnection = nil
    }
    
    /// Performs a non-cancel action if synchronization is not canceled.
    ///
    /// - Parameter action: The closure to execute.
    func nonCancelAction(_ action: @escaping () -> Void) {
        if tracker.status != .canceled {
            action()
        }
    }
    
    /// Prompts the user with an alert to cancel the current synchronization.
    func userSyncCancelAlert() {
        guard activeConnection != nil else {
            Core.makeSimpleAlert(title: "Not Syncing", message: "Cannot cancel as there is no sync in progress.")
            return
        }
        
        let alert = CoreAlert(title: "Cancel Sync?",
                              message: "Current sync process will be canceled.",
                              buttons: [AlertButton.no, AlertButton(title: "Proceed", style: .destructive, action: { self.cancelSync() })])
        Core.makeAlert(alert)
    }
    
    /// Prompts the user to cancel the sync process if it takes too long.
    func promptForCancel() {
        let alert = CoreAlert(title: "Sync Timeout",
                              message: "Current sync process is taking longer than the timeout threshold. \n\n Would you like to cancel or continue the process?",
                              buttons: [AlertButton(title: "Continue", style: .cancel, action: {}),
                                        AlertButton(title: "Cancel It", style: .destructive, action: { self.cancelSync() })])
        Core.makeAlert(alert)
    }
}

private extension SyncManager { //MARK: Import
    
    /// Performs the import-only synchronization.
    ///
    /// - Parameters:
    ///   - doInBetween: The closure to execute between import and export phases.
    ///   - importable: The importable objects.
    func importOnly(doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), importable: [Importable.Type]) async {
        tracker.updateStatus(.importReady)
        await executeImport(importable: importable)
    }
    
    /// Performs the import-first synchronization.
    ///
    /// - Parameters:
    ///   - doInBetween: The closure to execute between import and export phases.
    ///   - importable: The importable objects.
    ///   - exportable: The exportable objects.
    func importFirst(doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), importable: [Importable.Type], exportable: [Exportable.Type]) async {
        tracker.updateStatus(.importReady)
        await executeImport(importable: importable)
        
        guard tracker.status == .importDone else {
            return
        }
        
        inBetweenActions(for: doInBetween)
        guard !isSyncCanceled else { return }
        
        tracker.updateStatus(.exportReady)
        await executeExport(exportable: exportable)
        
        if tracker.status == .exportDone {
            DispatchQueue.main.async {
                Connect.user?.requiresSync = false
            }
        }
    }
    
    /// Executes the import process for the specified objects.
    ///
    /// - Parameter importable: The importable objects.
    func executeImport(importable: [Importable.Type]) async {
        guard importable.count > 0 else {
            tracker.updateStatus(.importDone)
            return
        }
        
        syncErrorsResolver = SyncErrorsResolver()
        let syncRecordBackups = tracker.syncRecords
        
        repeat {
            await doImport(in: context, objects: importable, helpers: container.importHelperObjects)
        } while tracker.status == .error && syncErrorsResolver.shouldRepeat(onRepeat: {
            DispatchQueue.main.async { [weak self] in
                self?.tracker.syncRecords = syncRecordBackups
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
        if doAtlasSync {
            await atlasSync(for: container.atlasObjects)
        }
        
        try? await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
    }
    
    /// Performs the import process for the specified objects.
    ///
    /// - Parameters:
    ///   - context: The Core Data context.
    ///   - objects: The objects to import.
    ///   - helpers: The helper objects for execution.
    func doImport(in context: NSManagedObjectContext, objects: [Importable.Type], helpers: [ExecutionHelper.Type] = []) async {
        tracker.updateStatus(.importing, message: "Importing")
        
        await withCheckedContinuation({ continuation in
            guard ConnectManager.shared.postgres?.pool != nil else {
                Core.makeEvent("postgres.pool == nil", type: .sync)
                self.tracker.updateStatus(.error)
                continuation.resume()
                return
            }
            ConnectManager.shared.postgres?.pool?.withConnection { [weak self] response in
                guard let self else { return }
                switch response {
                case .failure(let error):
                    Core.makeEvent("pool.withConnection: .failure", type: .sync)
                    syncErrorsResolver.setError(error)
                    self.tracker.updateStatus(.error)
                    Core.makeError(error: error,
                                   additionalInfo: currentQuery,
                                   showToUser: syncErrorsResolver.shouldShowToUser(isForeground))
                    continuation.resume()
                    return
                case .success(let connection):
                    do {
                        //                        throw AlpineError("_test_connectionClosed_", file: "", function: "", line: 0)
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
                        self.syncErrorsResolver.setError(error)
                        self.nonCancelAction {
                            self.tracker.updateStatus(.error)
                            Core.makeError(error: error,
                                           additionalInfo: self.currentQuery,
                                           showToUser: self.syncErrorsResolver.shouldShowToUser(self.isForeground))
                        }
                        continuation.resume()
                    }
                }
            }
        })
    }
    
    /// Cleans obsolete data after the import process.
    ///
    /// - Parameters:
    ///   - context: The Core Data context.
    ///   - objects: The importable objects.
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
    
    /// Cleans obsolete data after the import process.
    ///
    /// - Parameters:
    ///   - context: The Core Data context.
    ///   - objects: The importable objects.
    func exportOnly(doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), exportable: [Exportable.Type]) async {
        tracker.updateStatus(.exportReady)
        await executeExport(exportable: exportable)
    }
    
    
    /// Performs the export-first synchronization.
    ///
    /// - Parameters:
    ///   - doInBetween: The closure to execute between import and export phases.
    ///   - importable: The importable objects.
    ///   - exportable: The exportable objects.
    func exportFirst(doInBetween: ((_ context: NSManagedObjectContext) throws -> ()), importable: [Importable.Type], exportable: [Exportable.Type]) async {
        tracker.updateStatus(.exportReady)
        await executeExport(exportable: exportable)
        
        guard tracker.status == .exportDone else {
            return
        }
        
        inBetweenActions(for: doInBetween)
        guard !isSyncCanceled else { return }
        
        tracker.updateStatus(.importReady)
        await executeImport(importable: importable)
        
        if tracker.status == .importDone {
            Connect.user?.requiresSync = false
        }
    }
    
    /// Executes the export process for the specified objects.
    ///
    /// - Parameter exportable: The exportable objects.
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
            DispatchQueue.main.async { [weak self] in
                self?.tracker.syncRecords = syncRecordBackups
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
    
    
    /// Performs the export process for the specified objects.
    ///
    /// - Parameters:
    ///   - context: The Core Data context.
    ///   - objects: The objects to export.
    ///   - helpers: The helper objects for execution.
    func doExport(in context: NSManagedObjectContext, objects: [any Exportable.Type], helpers: [ExecutionHelper.Type] = []) async {
        tracker.updateStatus(.exporting, message: "Exporting")
        
        await withCheckedContinuation { continuation in
            guard ConnectManager.shared.postgres?.pool != nil else {
                Core.makeEvent("postgres.pool == nil", type: .sync)
                self.tracker.updateStatus(.error)
                continuation.resume()
                return
            }
            ConnectManager.shared.postgres?.pool?.withConnection { [weak self] response in
                guard let self else { return }
                switch response {
                case .failure(let error):
                    Core.makeEvent("pool.withConnection: .failure", type: .sync)
                    syncErrorsResolver.setError(error)
                    self.tracker.updateStatus(.error)
                    Core.makeError(error: error,
                                   additionalInfo: currentQuery,
                                   showToUser: syncErrorsResolver.shouldShowToUser(isForeground))
                    continuation.resume()
                    return
                case .success(let connection):
                    do {
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
                        self.syncErrorsResolver.setError(error)
                        self.nonCancelAction {
                            self.tracker.updateStatus(.error)
                            Core.makeError(error: error,
                                           additionalInfo: self.currentQuery,
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
}

extension SyncManager {
    
    /// Performs Atlas synchronization for the specified objects.
    ///
    /// - Parameter objects: The Atlas objects to synchronize.
    func atlasSync(for objects: [AtlasObject.Type]) async {
        self.tracker.updateStatus(.atlasSync, message: "Performing Atlas Synchronization")
        for object in objects {
            if let object = object as? AtlasSyncable.Type {
                do {
                    try await AtlasSynchronizer(for: object, syncManager: self).synchronize(in: context)
                }
                catch {
                    Core.makeError(error: error)
                }
            }
        }
    }
    
    /// Clears Atlas data for the specified syncable objects. ( deleting only *.fgb* files from project folder)
    ///
    /// - Parameter atlasSyncable: The Atlas syncable objects.
    public func atlasClear(for atlasSyncable: [AtlasSyncable.Type]) throws {
        for syncable in atlasSyncable {
            try syncable.deleteLayer()
        }
    }
}
