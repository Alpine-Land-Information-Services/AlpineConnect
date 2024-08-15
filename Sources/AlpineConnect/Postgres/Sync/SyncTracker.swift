//
//  SyncTracker.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import SwiftUI
import CoreData
import AlpineCore

/// A tracker class for managing and observing the synchronization process.
///
/// `SyncTracker` is responsible for tracking the synchronization status,
/// managing sync records, and updating the user interface based on the sync
/// progress and status changes.
public class SyncTracker: ObservableObject {
    
    /// Represents the various statuses of the synchronization process.
    public enum SyncStatus {
        case exportReady
        case exportPreparing
        case exporting
        case exportDone
        case importReady
        case importPreparing
        case importing
        case importDone
        case atlasSync
        case actions
        case saving
        case error
        case canceled
        case none
        case loginPreparing
        case loginDone
    }
    
    /// Represents a record that can be synchronized.
    struct SyncableRecord: Identifiable {
        
        /// The type of the record being synchronized.
        enum RecordType: String {
            case `import`
            case export
            case atlasSync = "Atlas Sync"
        }
        
        /// A unique identifier for the syncable record.
        var id = UUID()
        /// The name of the record.
        var name: String
        /// The type of the record.
        var type: RecordType
        /// The count of the records to be synchronized.
        var recordsCount: Double
    }
    
    /// A message describing the current sync status.
    @Published public var statusMessage: String = ""
    
    /// Indicates whether any synchronization process is ongoing.
    @Published public var isDoingSomeSync: Bool = false
    
    /// Indicates whether the sync UI should be displayed.
    @Published public var showSync: Bool = false
    
    /// A list of UUIDs that were not exported.
    @Published public var notExported = [UUID]()
    
    /// The type of the current synchronization process.
    @Published public var syncType = SyncManager.SyncType.none {
        didSet {
            withAnimation {
                isSyncing = checkIfSyncing(type: syncType)
            }
        }
    }
    
    /// Indicates whether synchronization is currently ongoing.
    @Published public var isSyncing: Bool = false {
        didSet {
            NotificationCenter.default.post(Notification(name: Notification.Name("AC_SyncChange"), object: isSyncing))
        }
    }
    
    /// The current slow status of the synchronization process.
    @Published public var slowStatus: SyncStatus = .none {
        didSet {
            if internalStatus == .error || internalStatus == .canceled {
                NotificationCenter.default.post(Notification(name: Notification.Name("AC_SyncChange"), object: false))
            }
        }
    }
    /// The progress of the current record synchronization.
    @Published var currentRecordProgress = 0.0
    
    /// Indicates whether the synchronization UI is being shown.
    @Published var showingUI = false
    
    /// A list of records that can be synchronized.
    @Published var syncRecords = [SyncableRecord]()
    
    /// The current record being synchronized.
    @Published var currentRecord: SyncableRecord?
    
    /// The manager responsible for synchronization.
    var manager: SyncManager?
    
    /// The internal status of the synchronization process.
    var internalStatus = SyncStatus.none
    
    /// The total number of records to synchronize.
    var totalRecordsToSync: Int = 0
    
    /// The current count of synchronized records.
    var count: Int = 0
    
    /// The start time of the current synchronization.
    public var currentSyncStartTime: Date = Date()
    
    /// Indicates whether this is the initial sync.
    public var isInitial: Bool {
        Connect.user?.lastSync == nil
    }
    
    /// The current synchronization status.
    public var status: SyncStatus {
        internalStatus
    }
    
    internal init() {}
}

extension SyncTracker { //MARK: Setting parameters
    
    func setSyncManager(_ manager: SyncManager){
        self.manager = manager
    }
}

extension SyncTracker {
    
    /// Updates the progress of the current sync record.
    ///
    /// - Parameter adding: The amount to add to the current progress.
    func progressUpdate(adding number: Double = 1) {
        DispatchQueue.main.async { [weak self] in
            self?.currentRecordProgress += number
        }
    }
    
    /// Creates a new syncable record.
    ///
    /// - Parameters:
    ///   - name: The name of the record.
    ///   - type: The type of the record.
    ///   - recordCount: The number of records to sync.
    func makeRecord(name: String, type: SyncTracker.SyncableRecord.RecordType, recordCount: Int) {
        Core.logAtlasConnectEvent(.syncRecordInfo, type: .sync, parameters: ["type":"\(type)", "recordCount":"\(recordCount)", "name":"\(name)"])
        print(code: type == .import ? .yellow : type == .export ? .orange : .blue, "\(type)\t\(recordCount)\t\(name)")
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            currentRecordProgress = 0
            currentRecord = SyncableRecord(name: name, type: type, recordsCount: Double(recordCount))
            if recordCount == 0 {
                endRecordSync()
            }
        }
    }
    
    /// Ends the synchronization of the current record.
    func endRecordSync() {
        if let currentRecord {
            DispatchQueue.main.async { [weak self] in
                self?.syncRecords.insert(currentRecord, at: 0)
            }
        }
    }
}

extension SyncTracker {
    
    /// Checks if the synchronization is ongoing based on the sync type.
    ///
    /// - Parameter type: The type of synchronization.
    /// - Returns: A Boolean indicating if syncing is ongoing.
    private func checkIfSyncing(type: SyncManager.SyncType) -> Bool {
        switch type {
        case .exportFirst, .importFirst, .exportFirstNoUI, .importFirstNoUI:
            return true
        default:
            return false
        }
    }
    
    /// Toggles the visibility of the sync window.
    ///
    /// - Parameter value: A Boolean indicating whether to show the sync window.
    func toggleSyncWindow(to value: Bool) {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.showSync = value
            }
        }
    }
}

public extension SyncTracker {
    
    /// Updates the synchronization status and optional message.
    ///
    /// - Parameters:
    ///   - status: The new synchronization status.
    ///   - message: An optional status message.
    func updateStatus(_ status: SyncStatus, message: String? = nil) {
        internalStatus = status
        Core.logAtlasConnectEvent(.syncStatus, type: .sync, parameters: ["status":"\(status)"])
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.slowStatus = status
            }
            if let message {
                self?.statusMessage = message
            }
        }
    }
    
    /// Updates the synchronization type.
    ///
    /// - Parameter type: The new synchronization type.
    func updateType(_ type: SyncManager.SyncType) {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                print("updated type to \(type)")
                self?.syncType = type
            }
        }
    }
    
    /// Updates the status message.
    ///
    /// - Parameter message: The new status message.
    func statusMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusMessage = message
        }
    }
}

public extension SyncTracker {
    
    /// Adds a UUID to the list of not exported items.
    ///
    /// - Parameter guid: The UUID to add.
    func addToNotExported(_ guid: UUID) {
        DispatchQueue.main.async { [weak self] in
            self?.notExported.appendIfNotExists(guid)
        }
    }
    
    /// Removes a UUID from the list of not exported items.
    ///
    /// - Parameter guid: The UUID to remove.
    func removeFromNotExported(_ guid: UUID) {
        DispatchQueue.main.async { [weak self] in
            self?.notExported.removeIfExists(guid)
        }
    }
}
