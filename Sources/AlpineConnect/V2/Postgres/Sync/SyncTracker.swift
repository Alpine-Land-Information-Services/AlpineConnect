//
//  SyncTracker.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 2/15/23.
//

import SwiftUI
import CoreData
import AlpineCore

public class SyncTracker: ObservableObject {
    
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
    }
    
    struct SyncableRecord: Identifiable {
        
        enum RecordType: String {
            case `import`
            case export
            case atlasSync = "Atlas Sync"
        }
        
        var id = UUID()
        var name: String
        var type: RecordType
        var recordsCount: Double
    }
    
    public var currentSyncStartTime = Date()
    
    @Published public var showSync = false
    @Published public var syncType = SyncManager.SyncType.none {
        didSet {
            withAnimation {
                isSyncing = checkIfSyncing(type: syncType)
            }
        }
    }
    
    @Published public var isDoingSomeSync = false
    @Published var showingUI = false
    
    @Published public var isSyncing = false {
        didSet {
            NotificationCenter.default.post(Notification(name: Notification.Name("AC_SyncChange"), object: isSyncing))
        }
    }
        
    @Published public var slowStatus = SyncStatus.none {
        didSet {
            if internalStatus == .error || internalStatus == .canceled {
                NotificationCenter.default.post(Notification(name: Notification.Name("AC_SyncChange"), object: false))
            }
        }
    }
    var internalStatus = SyncStatus.none
    
    @Published public var statusMessage = ""
    
    @Published var currentRecord: SyncableRecord?
    @Published var currentRecordProgress = 0.0
    
    @Published var syncRecords = [SyncableRecord]()
    var totalRecordsToSync = 0
    
    @Published public var notExported = [UUID]()
    
    weak var manager: SyncManager!
    var count = 0
    
    internal init() {}
}

extension SyncTracker {
    
    func progressUpdate(adding number: Double = 1) {
        DispatchQueue.main.async { [weak self] in
            self?.currentRecordProgress += number
        }
    }
    
    func makeRecord(name: String, type: SyncTracker.SyncableRecord.RecordType, recordCount: Int) {
        Core.makeEvent("\(type): \(recordCount) \(name)", type: .sync)
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
    
    func endRecordSync() {
        if let currentRecord {
            DispatchQueue.main.async { [weak self] in
                self?.syncRecords.insert(currentRecord, at: 0)
            }
        }
    }
}

extension SyncTracker {
    
    func checkIfSyncing(type: SyncManager.SyncType) -> Bool {
        switch type {
        case .exportFirst, .importFirst, .exportFirstNoUI, .importFirstNoUI:
            return true
        default:
            return false
        }
    }
    
    func toggleSyncWindow(to value: Bool) {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.showSync = value
            }
        }
    }
}

public extension SyncTracker {
    
    var isInitial: Bool {
        Connect.user?.lastSync == nil
    }
    
    var status: SyncStatus {
        internalStatus
    }
    
    func updateStatus(_ status: SyncStatus, message: String? = nil) {
        internalStatus = status
        Core.makeEvent("sync status: \(status)", type: .sync)
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                self?.slowStatus = status
            }
            if let message {
                self?.statusMessage = message
            }
        }
    }
    
    func updateType(_ type: SyncManager.SyncType) {
        DispatchQueue.main.async { [weak self] in
            withAnimation {
                print("updated type to \(type)")
                self?.syncType = type
            }
        }
    }
    
    func statusMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusMessage = message
        }
    }
}

extension SyncTracker {
    
    public func addToNotExported(_ guid: UUID) {
        DispatchQueue.main.async { [weak self] in
            self?.notExported.appendIfNotExists(guid)
        }
    }

    public func removeFromNotExported(_ guid: UUID) {
        DispatchQueue.main.async { [weak self] in
            self?.notExported.removeIfExists(guid)
        }
    }
    
//    public func fillNotExported(for objects: [CDObject.Type], in context: NSManagedObjectContext) async {
//        do {
//            let notExported = try await getNotExported(for: objects, in: context)
//            DispatchQueue.main.async {
//                self.notExported = notExported
//            }
//        }
//        catch {
//            Core.makeError(error: error, additionalInfo: "Fetching Object Count")
//        }
//    }
//    
//    private func getNotExported(for objects: [CDObject.Type], in context: NSManagedObjectContext) async throws -> [UUID] {
//        var ids = [UUID]()
//        for object in objects {
//            ids.append(contentsOf: try await object.getNotExportedCount(in: context))
//        }
//        
//        return ids
//    }
}
